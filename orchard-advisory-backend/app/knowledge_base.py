import json
from functools import lru_cache
from pathlib import Path

from fastapi import HTTPException

from app.config import KNOWLEDGE_BASE_PATH
from app.schemas import OrchardIssue, IssueSummary


@lru_cache
def _load_raw_issues() -> list[dict]:
    path: Path = KNOWLEDGE_BASE_PATH
    if not path.exists():
        raise FileNotFoundError(f"Knowledge base not found at {path}")
    with path.open(encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, list):
        raise ValueError("Knowledge base must be a JSON array")
    return data


def get_all_issues() -> list[OrchardIssue]:
    return [OrchardIssue.model_validate(item) for item in _load_raw_issues()]


def get_issue_summaries() -> list[IssueSummary]:
    return [
        IssueSummary(
            id=issue.id,
            commonName=issue.commonName,
            affectedCrops=issue.affectedCrops,
            category=issue.category,
        )
        for issue in get_all_issues()
    ]


def get_issue_by_id(issue_id: str) -> OrchardIssue:
    for issue in get_all_issues():
        if issue.id == issue_id:
            return issue
    raise HTTPException(status_code=404, detail=f"Issue '{issue_id}' not found")


def get_knowledge_base_json() -> str:
    """Return the raw knowledge base as a compact JSON string for the AI prompt."""
    return json.dumps(_load_raw_issues(), ensure_ascii=False)
