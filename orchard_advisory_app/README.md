# Orchard Advisory App (Flutter)

Mobile client for **Orchard Advisory Bot**. Fruit growers in Gilgit-Baltistan can describe symptoms and/or upload a photo; the app calls the FastAPI backend and shows a clear diagnosis.

```
FarmAi/
├── orchard-advisory-backend/   # FastAPI API
└── orchard_advisory_app/       # this Flutter app
```

## Prerequisites

- Flutter stable (3.x+)
- Backend running (see `../orchard-advisory-backend/README.md`)
- Android emulator / device, or iOS Simulator / device

## Setup

```bash
cd orchard_advisory_app
flutter pub get
```

## Pointing at the backend

The API base URL comes from `--dart-define=API_BASE_URL` (see `lib/config.dart`).

| Where you run the app | Typical `API_BASE_URL` |
|-----------------------|-------------------------|
| Android emulator | `http://10.0.2.2:8000` (default) |
| iOS Simulator | `http://127.0.0.1:8000` |
| Physical phone (same Wi‑Fi) | `http://YOUR_LAN_IP:8000` |
| Deployed backend | `https://your-deployed-backend-url.com` |

### Web (Chrome)

```bash
# terminal 1 — backend must allow browser CORS (ALLOWED_ORIGINS=* is fine)
cd ../orchard-advisory-backend
source .venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000

# terminal 2 — Flutter web
cd ../orchard_advisory_app
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

On web the default API URL is already `http://127.0.0.1:8000`. Use **Upload Photo** (file picker); camera is not used in the browser UI.

**Production (GitHub Pages):** see repo root [DEPLOY.md](../DEPLOY.md). Build uses:

```bash
flutter build web --release \
  --base-href /Farm_Ai/ \
  --dart-define=API_BASE_URL=https://YOUR-BACKEND.onrender.com
```

Live app (after deploy): https://alibarkat726.github.io/Farm_Ai/

---

### Local backend + Android emulator

```bash
# terminal 1 — backend
cd ../orchard-advisory-backend
source .venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000

# terminal 2 — app
cd ../orchard_advisory_app
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### iOS Simulator

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

**Camera note:** the iOS Simulator has no camera. Use **Gallery** to pick a test image. Camera works on a real iPhone.

### Release / deployed API

```bash
flutter build apk --dart-define=API_BASE_URL=https://your-deployed-backend-url.com
```

## Screens

1. **Diagnose** — crop, month, symptom text, camera/gallery photo → Get Diagnosis  
2. **Result** — urgency, likely causes, recommended action, treatment steps  
3. **History** — recent diagnoses from `GET /history`  
4. **Library** — browse knowledge-base issues from `GET /issues`

## Project layout

```
lib/
├── main.dart
├── config.dart
├── theme.dart
├── models/
├── services/api_service.dart
├── providers/diagnose_provider.dart
├── screens/
└── widgets/
```

## Troubleshooting

- **"Can't reach the orchard advisory server"** — backend not running, wrong `API_BASE_URL`, or phone not on the same network as the host.
- **Cleartext HTTP on Android** — local `http://` is allowed in debug via `usesCleartextTraffic`; production should use HTTPS.
- **Diagnosis timeout** — AI calls can take several seconds; the client waits up to 60s for diagnose endpoints.
