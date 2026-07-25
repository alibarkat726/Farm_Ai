# Orchard Advisory Bot — Backend

REST API for diagnosing common apricot, apple, and cherry orchard problems in Gilgit-Baltistan, Pakistan. Farmers (or a future frontend / WhatsApp webhook) send plain-text symptoms and/or a photo; the service calls OpenAI with a seeded local knowledge base and returns structured, actionable guidance.

**Scope:** backend only — no frontend, auth, or WhatsApp integration.

## Features

- `POST /diagnose` — text-only symptom diagnosis
- `POST /diagnose-image` — JPEG/PNG upload (+ optional text context)
- `GET /issues` / `GET /issues/{id}` — browse the seeded knowledge base
- `GET /history` — recent diagnosis logs (SQLite)
- Grounded AI responses via OpenAI (`gpt-4o`, vision-capable)

## Requirements

- Python 3.11+
- An [OpenAI API key](https://platform.openai.com/api-keys)

## Setup

```bash
cd orchard-advisory-backend
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
```

Edit `.env` and set your key:

```
OPENAI_API_KEY=sk-...
DATABASE_URL=sqlite:///./orchard.db
ALLOWED_ORIGINS=*
# Optional:
# OPENAI_MODEL=gpt-4o
```

Run the API locally:

```bash
uvicorn app.main:app --reload
```

- API: http://127.0.0.1:8000
- Interactive docs: http://127.0.0.1:8000/docs
- Health check: http://127.0.0.1:8000/health

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OPENAI_API_KEY` | Yes | — | OpenAI API key |
| `OPENAI_MODEL` | No | `gpt-4o` | Chat model (must support vision for image diagnoses) |
| `DATABASE_URL` | No | `sqlite:///./orchard.db` | SQLAlchemy database URL |
| `ALLOWED_ORIGINS` | No | `*` | Comma-separated CORS origins, or `*` |

Never commit `.env`. Secrets belong only in environment variables.

## Knowledge Base

Seeded dataset: `data/orchard_issues.json` (20 common issues for high-altitude temperate orchards). The AI is instructed to ground diagnoses in this file and not invent treatments outside matched entries.

## API Reference

### `POST /diagnose`

Text-only diagnosis.

**Request**

```json
{
  "cropType": "apricot",
  "symptomDescription": "Leaves have small brown-purple spots and some are falling off. It's been rainy this week.",
  "location": "Skardu",
  "month": "April"
}
```

**Response**

```json
{
  "likelyCauses": [
    {
      "issueId": "coryneum-blight",
      "commonName": "Shot Hole Disease (Coryneum Blight)",
      "confidence": "high",
      "reasoning": "Matches purple-brown leaf spotting, shot-hole pattern, and recent wet weather in April, a known risk window."
    }
  ],
  "recommendedAction": "Prune for airflow and plan a copper spray at the next appropriate window; monitor for twig lesions.",
  "treatmentSteps": [
    "Prune out and destroy infected twigs during the dormant season",
    "Apply copper-based fungicide spray at bud swell and after petal fall",
    "Improve air circulation through selective pruning"
  ],
  "urgency": "moderate",
  "consultExtensionOffice": false,
  "disclaimer": "This is guidance only, not a substitute for an in-person agricultural expert for severe or unclear cases."
}
```

**Example (curl)**

```bash
curl -X POST http://127.0.0.1:8000/diagnose \
  -H "Content-Type: application/json" \
  -d '{
    "cropType": "apricot",
    "symptomDescription": "Leaves have small brown-purple spots and some are falling off. It has been rainy this week.",
    "location": "Skardu",
    "month": "April"
  }'
```

---

### `POST /diagnose-image`

Multipart upload. Fields:

| Field | Required | Description |
|-------|----------|-------------|
| `image` | Yes | JPEG or PNG, max 8 MB |
| `cropType` | No | e.g. `apricot` |
| `symptomDescription` | No | Extra context |
| `month` | No | e.g. `April` |
| `location` | No | e.g. `Skardu` |

Same response shape as `/diagnose`. Invalid type/size returns `400` with a clear message.

**Example (curl)**

```bash
curl -X POST http://127.0.0.1:8000/diagnose-image \
  -F "image=@/path/to/leaf.jpg" \
  -F "cropType=apricot" \
  -F "symptomDescription=Spots on leaves after rain" \
  -F "month=April" \
  -F "location=Skardu"
```

---

### `GET /issues`

Lightweight list of knowledge-base entries (`id`, `commonName`, `affectedCrops`, `category`).

**Example response**

```json
[
  {
    "id": "coryneum-blight",
    "commonName": "Shot Hole Disease (Coryneum Blight)",
    "affectedCrops": ["apricot", "cherry", "peach"],
    "category": "fungal"
  }
]
```

---

### `GET /issues/{id}`

Full knowledge-base entry for one issue.

```bash
curl http://127.0.0.1:8000/issues/coryneum-blight
```

Returns `404` if the id is unknown.

---

### `GET /history?limit=20`

Most recent diagnosis logs (no auth — single-tenant demo).

**Example response**

```json
[
  {
    "id": 1,
    "cropType": "apricot",
    "month": "April",
    "location": "Skardu",
    "likelyCauseSummary": "Shot Hole Disease (Coryneum Blight)",
    "urgency": "moderate",
    "hasImage": false,
    "createdAt": "2026-04-12T10:15:00+00:00"
  }
]
```

---

### `GET /health`

```json
{ "status": "ok" }
```

## Project Structure

```
orchard-advisory-backend/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── models.py
│   ├── database.py
│   ├── schemas.py
│   ├── knowledge_base.py
│   ├── ai_client.py
│   └── routes/
│       ├── diagnose.py
│       ├── diagnose_image.py
│       ├── issues.py
│       └── history.py
├── data/
│   └── orchard_issues.json
├── requirements.txt
├── .env.example
├── Procfile
├── render.yaml
└── README.md
```

## Deployment

Works on **Railway** or **Render**. Set the same env vars as local (`OPENAI_API_KEY` required; `OPENAI_MODEL`, `DATABASE_URL`, and `ALLOWED_ORIGINS` optional).

### Railway

1. Create a new project from this repo (root = `orchard-advisory-backend` if the repo is a monorepo).
2. Add environment variables in the Railway dashboard.
3. Railway detects the `Procfile`:

```
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

4. Deploy. The SQLite file lives on the instance filesystem (fine for demos; use a volume or external DB for production persistence).

### Render

1. Use `render.yaml` (Blueprint) or create a **Web Service** manually.
2. Build: `pip install -r requirements.txt`
3. Start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. Add `OPENAI_API_KEY` (and optional `OPENAI_MODEL`, `DATABASE_URL`, `ALLOWED_ORIGINS`) in the Render dashboard.

## Error Handling

| Situation | Status | Behavior |
|-----------|--------|----------|
| Missing/invalid request fields | 400 | Clear validation message |
| Bad/oversized image | 400 | JPEG/PNG only, max 8 MB |
| Unknown issue id | 404 | Not found |
| OpenAI / server failure | 500 | Clean message; details logged server-side |
| Model returned non-JSON | 502 | Ask client to retry |

## Disclaimer

Responses are guidance only and are not a substitute for a local agricultural extension officer, especially for severe, fast-spreading, or unclear cases (e.g. suspected fire blight).
