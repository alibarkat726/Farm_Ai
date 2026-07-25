from fastapi import APIRouter

from app.knowledge_base import get_issue_by_id, get_issue_summaries
from app.schemas import IssueSummary, OrchardIssue

router = APIRouter(tags=["issues"])


@router.get(
    "/issues",
    response_model=list[IssueSummary],
    summary="List knowledge base issues (summary)",
)
def list_issues() -> list[IssueSummary]:
    return get_issue_summaries()


@router.get(
    "/issues/{issue_id}",
    response_model=OrchardIssue,
    summary="Get one knowledge base issue in full detail",
)
def get_issue(issue_id: str) -> OrchardIssue:
    return get_issue_by_id(issue_id)
