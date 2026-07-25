from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import DiagnosisLog
from app.schemas import HistoryItem

router = APIRouter(tags=["history"])


@router.get(
    "/history",
    response_model=list[HistoryItem],
    summary="List recent diagnosis logs",
)
def get_history(
    limit: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
) -> list[HistoryItem]:
    stmt = (
        select(DiagnosisLog)
        .order_by(DiagnosisLog.created_at.desc())
        .limit(limit)
    )
    rows = db.scalars(stmt).all()
    return [
        HistoryItem(
            id=row.id,
            cropType=row.crop_type,
            month=row.month,
            location=row.location,
            likelyCauseSummary=row.likely_cause_summary,
            urgency=row.urgency,
            hasImage=bool(row.has_image),
            createdAt=row.created_at,
        )
        for row in rows
    ]
