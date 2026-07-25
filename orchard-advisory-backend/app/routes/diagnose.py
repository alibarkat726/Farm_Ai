from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.ai_client import get_diagnosis
from app.database import get_db
from app.schemas import DiagnoseRequest, DiagnosisResponse

router = APIRouter(tags=["diagnose"])


@router.post(
    "/diagnose",
    response_model=DiagnosisResponse,
    summary="Text-only orchard symptom diagnosis",
)
def diagnose_text(payload: DiagnoseRequest, db: Session = Depends(get_db)) -> DiagnosisResponse:
    return get_diagnosis(
        crop_type=payload.cropType.strip(),
        symptom_description=payload.symptomDescription.strip(),
        month=payload.month.strip() if payload.month else None,
        location=payload.location.strip() if payload.location else None,
        image_bytes=None,
        db=db,
    )
