# FarmAi — Orchard Advisory Bot

Diagnostic tool for apricot, apple, and cherry growers in Gilgit-Baltistan.

| Folder | What |
|--------|------|
| `orchard-advisory-backend/` | FastAPI + OpenAI backend |
| `orchard_advisory_app/` | Flutter client (web / mobile) |

## Live deploy targets

- **Backend:** [Render](https://render.com) (see root `render.yaml`)
- **Frontend (web):** [GitHub Pages](https://alibarkat726.github.io/Farm_Ai/) via `.github/workflows/deploy-pages.yml`

Full step-by-step: **[DEPLOY.md](./DEPLOY.md)**

## Local development

### Backend

```bash
cd orchard-advisory-backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # add OPENAI_API_KEY
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Flutter (web)

```bash
cd orchard_advisory_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## License

Private / project use — update as needed.
