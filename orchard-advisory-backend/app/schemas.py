from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


ConfidenceLevel = Literal["high", "moderate", "low"]
UrgencyLevel = Literal["low", "moderate", "high", "critical"]


class DiagnoseRequest(BaseModel):
    cropType: str = Field(..., min_length=1, description="Crop type, e.g. apricot, apple, cherry")
    symptomDescription: str = Field(..., min_length=1, description="Plain-language symptom description")
    location: str | None = Field(default=None, description="Optional location, e.g. Skardu")
    month: str | None = Field(default=None, description="Current month, e.g. April")


class LikelyCause(BaseModel):
    issueId: str
    commonName: str
    confidence: ConfidenceLevel
    reasoning: str


class DiagnosisResponse(BaseModel):
    likelyCauses: list[LikelyCause]
    recommendedAction: str
    treatmentSteps: list[str]
    urgency: UrgencyLevel
    consultExtensionOffice: bool
    disclaimer: str


class IssueSummary(BaseModel):
    id: str
    commonName: str
    affectedCrops: list[str]
    category: str


class OrchardIssue(BaseModel):
    id: str
    commonName: str
    affectedCrops: list[str]
    category: str
    symptoms: list[str]
    typicalSeason: list[str]
    conditionsThatFavorIt: str
    treatment: list[str]
    prevention: list[str]
    urgency: UrgencyLevel
    notes: str


class HistoryItem(BaseModel):
    id: int
    cropType: str | None
    month: str | None
    location: str | None
    likelyCauseSummary: str | None
    urgency: str | None
    hasImage: bool
    createdAt: datetime


class ErrorResponse(BaseModel):
    detail: str
