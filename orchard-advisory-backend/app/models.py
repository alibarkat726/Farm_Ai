from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


class DiagnosisLog(Base):
    __tablename__ = "diagnosis_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    crop_type: Mapped[str | None] = mapped_column(String(64), nullable=True)
    month: Mapped[str | None] = mapped_column(String(32), nullable=True)
    location: Mapped[str | None] = mapped_column(String(128), nullable=True)
    symptom_summary: Mapped[str | None] = mapped_column(Text, nullable=True)
    likely_cause_summary: Mapped[str | None] = mapped_column(String(512), nullable=True)
    urgency: Mapped[str | None] = mapped_column(String(32), nullable=True)
    has_image: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=_utc_now,
        nullable=False,
    )
