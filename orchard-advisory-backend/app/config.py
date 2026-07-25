from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parent.parent
KNOWLEDGE_BASE_PATH = BASE_DIR / "data" / "orchard_issues.json"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(BASE_DIR / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    openai_api_key: str = ""
    database_url: str = "sqlite:///./orchard.db"
    allowed_origins: str = "*"
    openai_model: str = "gpt-4o"
    max_image_bytes: int = 8 * 1024 * 1024  # 8 MB


@lru_cache
def get_settings() -> Settings:
    return Settings()
