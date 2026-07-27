# Deploy guide — Backend (Vercel) + Flutter (GitHub Pages)

Do this **in order**: backend first (you need its URL for the Flutter build).

---

## Part 1 — Backend on Vercel (recommended for this setup)

### Limits to know

| Topic | Reality on Vercel |
|--------|-------------------|
| Runtime | FastAPI runs as a **serverless** function |
| Timeouts | Hobby ≈ **10s**; Pro up to **60s**. Image diagnoses can be slow — Pro is safer |
| SQLite | Uses `/tmp` — **history may reset** between cold starts (demo OK) |
| Cold start | First request after idle can be slower |

If you need always-on + persistent DB, use **Render** instead (see below).

### Steps

1. Install CLI (optional): `npm i -g vercel`
2. Open [vercel.com](https://vercel.com) → **Add New Project** → import `alibarkat726/Farm_Ai`
3. Configure:
   - **Root Directory:** `orchard-advisory-backend`
   - Framework preset: Other
4. **Environment Variables** (Production + Preview):

| Key | Value |
|-----|--------|
| `OPENAI_API_KEY` | your OpenAI key |
| `OPENAI_MODEL` | `gpt-4o` (optional) |
| `ALLOWED_ORIGINS` | `*` or `https://alibarkat726.github.io` |

5. Deploy. Copy the URL, e.g. `https://farm-ai-xxxx.vercel.app` (no trailing slash).
6. Smoke-test: `https://YOUR-APP.vercel.app/health` → `{"status":"ok"}`  
   Also try `/issues`.

### CLI alternative

```bash
cd orchard-advisory-backend
vercel          # link + preview
vercel --prod   # production
# set secrets in dashboard, or:
vercel env add OPENAI_API_KEY
```

Files used: `vercel.json`, `api/index.py`, `requirements.txt`.

---

## Part 1b — Backend on Render (alternative)

1. [dashboard.render.com](https://dashboard.render.com) → **New → Blueprint**
2. Connect `alibarkat726/Farm_Ai` (root `render.yaml`)
3. Set `OPENAI_API_KEY`, deploy
4. URL like `https://orchard-advisory-backend-xxxx.onrender.com`

Better for longer AI timeouts on free tier; still ephemeral SQLite without a disk.

---

## Part 2 — Flutter web on GitHub Pages

### A. Enable Pages

1. Repo → **Settings → Pages**
2. **Source:** GitHub Actions

### B. Point the app at your backend

1. Repo → **Settings → Secrets and variables → Actions → Variables**
2. **New repository variable**
   - Name: `API_BASE_URL`
   - Value: your **Vercel** (or Render) URL — no trailing slash  
     Example: `https://farm-ai-xxxx.vercel.app`

### C. Trigger the deploy

- Push to `master`, **or**
- **Actions → Deploy Flutter Web to GitHub Pages → Run workflow**

App URL:

```text
https://alibarkat726.github.io/Farm_Ai/
```

---

## Updating later

| Change | What to do |
|--------|------------|
| Backend code | Push → Vercel auto-deploys (if Git connected) |
| Flutter UI | Push → Pages workflow runs |
| New backend URL | Update GitHub variable `API_BASE_URL`, re-run Pages workflow |
| CORS | Set `ALLOWED_ORIGINS=https://alibarkat726.github.io` on Vercel |

---

## Checklist

- [ ] Vercel `/health` returns OK
- [ ] `OPENAI_API_KEY` set on Vercel (not in git)
- [ ] GitHub Pages source = Actions
- [ ] Repo variable `API_BASE_URL` = Vercel URL
- [ ] Pages workflow succeeded
- [ ] Open `https://alibarkat726.github.io/Farm_Ai/` and run a text diagnosis
