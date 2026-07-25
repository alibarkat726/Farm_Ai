import base64
import json
import logging
import re
from typing import Any

from fastapi import HTTPException
from openai import APIError, OpenAI
from sqlalchemy.orm import Session

from app.config import get_settings
from app.knowledge_base import get_knowledge_base_json
from app.models import DiagnosisLog
from app.schemas import DiagnosisResponse

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are an orchard diagnostic assistant for fruit growers in Gilgit-Baltistan, Pakistan, specializing in apricot, apple, and cherry trees.

You will be given: the crop type, a symptom description and/or an uploaded photo, the current month, and a JSON knowledge base of known orchard issues (each with symptoms, typical season, treatment, and prevention).

Rules:
1. Ground every diagnosis in the provided knowledge base. Do not invent diseases, pests, or treatments not present in the knowledge base unless the symptoms clearly don't match anything provided — in that case, say so honestly rather than forcing a match.
2. Weigh the current month against each candidate issue's typicalSeason — flag if a symptom is unusual for the current season.
3. If an image is provided, describe what you visually observe before matching it to knowledge base entries.
4. Rank likely causes by confidence (high/moderate/low). Include at least the top 1-3 candidates, not just one, when the picture is ambiguous.
5. Never recommend a treatment not listed in the matched knowledge base entry.
6. If symptoms suggest a severe, fast-spreading, or unclear issue (e.g. possible fire blight, unclear widespread dieback), recommend consulting a local agricultural extension office and set consultExtensionOffice to true.
7. If an image is unclear or does not show a diagnosable plant issue, use low confidence and ask a clarifying question in recommendedAction rather than guessing.
8. Output ONLY valid JSON matching the exact schema below — no markdown, no preamble, no code fences.

Response JSON schema:
{
  "likelyCauses": [
    {
      "issueId": "string matching a knowledge base id, or unknown",
      "commonName": "string",
      "confidence": "high" | "moderate" | "low",
      "reasoning": "string"
    }
  ],
  "recommendedAction": "1-3 sentence plain-language next steps",
  "treatmentSteps": ["..."],
  "urgency": "low" | "moderate" | "high" | "critical",
  "consultExtensionOffice": true | false,
  "disclaimer": "This is guidance only, not a substitute for an in-person agricultural expert for severe or unclear cases."
}
"""


def _strip_json_fences(text: str) -> str:
    cleaned = text.strip()
    fence_match = re.match(r"^```(?:json)?\s*([\s\S]*?)\s*```$", cleaned, re.IGNORECASE)
    if fence_match:
        return fence_match.group(1).strip()
    return cleaned


def _parse_diagnosis_json(raw_text: str) -> DiagnosisResponse:
    cleaned = _strip_json_fences(raw_text)
    try:
        data = json.loads(cleaned)
    except json.JSONDecodeError as exc:
        logger.error("Failed to parse model JSON: %s | raw=%s", exc, raw_text[:500])
        raise HTTPException(
            status_code=502,
            detail="The AI model returned an invalid response. Please try again.",
        ) from exc

    try:
        return DiagnosisResponse.model_validate(data)
    except Exception as exc:
        logger.error("Diagnosis response failed validation: %s | data=%s", exc, data)
        raise HTTPException(
            status_code=502,
            detail="The AI model returned a response that did not match the expected schema.",
        ) from exc


def _build_user_text(
    crop_type: str | None,
    symptom_description: str | None,
    month: str | None,
    location: str | None,
    has_image: bool,
) -> str:
    knowledge_base = get_knowledge_base_json()
    parts = [
        f"Crop type: {crop_type or 'not specified'}",
        f"Month: {month or 'not specified'}",
        f"Location: {location or 'not specified'}",
        f"Symptom description: {symptom_description or ('(see uploaded image)' if has_image else 'not provided')}",
        f"Image provided: {'yes' if has_image else 'no'}",
        "",
        "Knowledge base (JSON):",
        knowledge_base,
        "",
        "Diagnose the likely orchard issue(s) and respond with ONLY the required JSON object.",
    ]
    return "\n".join(parts)


def _media_type_for_bytes(image_bytes: bytes) -> str:
    if image_bytes[:3] == b"\xff\xd8\xff":
        return "image/jpeg"
    if image_bytes[:8] == b"\x89PNG\r\n\x1a\n":
        return "image/png"
    return "image/jpeg"


def get_diagnosis(
    *,
    crop_type: str | None,
    symptom_description: str | None,
    month: str | None = None,
    location: str | None = None,
    image_bytes: bytes | None = None,
    db: Session | None = None,
) -> DiagnosisResponse:
    settings = get_settings()
    api_key = (settings.openai_api_key or "").strip()
    if not api_key or api_key.startswith("your_openai_api_key"):
        raise HTTPException(
            status_code=500,
            detail="OPENAI_API_KEY is not configured on the server.",
        )

    has_image = image_bytes is not None and len(image_bytes) > 0
    user_text = _build_user_text(
        crop_type=crop_type,
        symptom_description=symptom_description,
        month=month,
        location=location,
        has_image=has_image,
    )

    content: list[dict[str, Any]] = [{"type": "text", "text": user_text}]
    if has_image and image_bytes is not None:
        media_type = _media_type_for_bytes(image_bytes)
        b64 = base64.standard_b64encode(image_bytes).decode("ascii")
        content.append(
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:{media_type};base64,{b64}",
                },
            }
        )

    client = OpenAI(api_key=api_key)

    try:
        completion = client.chat.completions.create(
            model=settings.openai_model,
            max_tokens=2048,
            temperature=0.2,
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": content},
            ],
        )
    except APIError as exc:
        logger.exception("OpenAI API error: %s", exc)
        raise HTTPException(
            status_code=500,
            detail="Failed to get a diagnosis from the AI service. Please try again later.",
        ) from exc
    except Exception as exc:
        logger.exception("Unexpected error calling OpenAI API: %s", exc)
        raise HTTPException(
            status_code=500,
            detail="An unexpected error occurred while contacting the AI service.",
        ) from exc

    raw_text = (completion.choices[0].message.content or "").strip()
    if not raw_text:
        raise HTTPException(
            status_code=502,
            detail="The AI model returned an empty response.",
        )

    diagnosis = _parse_diagnosis_json(raw_text)

    if db is not None:
        top_cause = diagnosis.likelyCauses[0].commonName if diagnosis.likelyCauses else None
        log = DiagnosisLog(
            crop_type=crop_type,
            month=month,
            location=location,
            symptom_summary=(symptom_description or "")[:1000] or None,
            likely_cause_summary=top_cause,
            urgency=diagnosis.urgency,
            has_image=has_image,
        )
        db.add(log)
        db.commit()

    return diagnosis
