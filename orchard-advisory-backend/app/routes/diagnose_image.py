from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.ai_client import get_diagnosis
from app.config import get_settings
from app.database import get_db
from app.schemas import DiagnosisResponse

router = APIRouter(tags=["diagnose"])


@router.post(
    "/diagnose-image",
    response_model=DiagnosisResponse,
    summary="Image-based orchard diagnosis (optional text context)",
)
async def diagnose_image(
    image: UploadFile = File(..., description="JPEG or PNG image of affected leaf/fruit/branch"),
    cropType: str | None = Form(default=None),
    symptomDescription: str | None = Form(default=None),
    month: str | None = Form(default=None),
    location: str | None = Form(default=None),
    db: Session = Depends(get_db),
) -> DiagnosisResponse:
    settings = get_settings()
    allowed_image_types = {"image/jpeg", "image/png"}

    content_type = (image.content_type or "").lower().strip()
    if content_type not in allowed_image_types:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid image type '{content_type or 'unknown'}'. Only JPEG and PNG are allowed.",
        )

    image_bytes = await image.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Uploaded image file is empty.")

    if len(image_bytes) > settings.max_image_bytes:
        raise HTTPException(
            status_code=400,
            detail=f"Image exceeds the maximum allowed size of {settings.max_image_bytes // (1024 * 1024)} MB.",
        )

    # Magic-byte check as a second line of defense beyond Content-Type
    is_jpeg = image_bytes[:3] == b"\xff\xd8\xff"
    is_png = image_bytes[:8] == b"\x89PNG\r\n\x1a\n"
    if not (is_jpeg or is_png):
        raise HTTPException(
            status_code=400,
            detail="File content is not a valid JPEG or PNG image.",
        )

    return get_diagnosis(
        crop_type=cropType.strip() if cropType else None,
        symptom_description=symptomDescription.strip() if symptomDescription else None,
        month=month.strip() if month else None,
        location=location.strip() if location else None,
        image_bytes=image_bytes,
        db=db,
    )
