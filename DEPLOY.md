# Deploy guide — Render + GitHub Pages

Do this **in order**: backend first (you need its URL for the Flutter build).

---

## Part 1 — Backend on Render

1. Open [https://dashboard.render.com](https://dashboard.render.com) and sign in with GitHub.
2. **New → Blueprint** (or **Web Service**).
3. Connect repo: `alibarkat726/Farm_Ai`.
4. If using Blueprint, Render reads root `render.yaml` (`rootDir: orchard-advisory-backend`).
5. If creating a Web Service manually:
   - **Root Directory:** `orchard-advisory-backend`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
6. Add environment variables:

| Key | Value |
|-----|--------|
| `OPENAI_API_KEY` | your OpenAI key |
| `OPENAI_MODEL` | `gpt-4o` (optional) |
| `DATABASE_URL` | `sqlite:///./orchard.db` |
| `ALLOWED_ORIGINS` | `*` (or later `https://alibarkat726.github.io`) |

7. Deploy. Copy the service URL, e.g.  
   `https://orchard-advisory-backend-xxxx.onrender.com`  
   (no trailing slash).
8. Smoke-test: open `https://YOUR-SERVICE.onrender.com/health` → `{"status":"ok"}`.

**Note:** Free Render services spin down after idle; the first request can take ~30–60s. SQLite data may reset on redeploy — fine for a demo.

---

## Part 2 — Flutter web on GitHub Pages

### A. Enable Pages

1. Repo → **Settings → Pages**
2. **Source:** GitHub Actions

### B. Set the backend URL for the build

1. Repo → **Settings → Secrets and variables → Actions → Variables**
2. **New repository variable**
   - Name: `API_BASE_URL`
   - Value: `https://YOUR-SERVICE.onrender.com` (from Part 1)

### C. Trigger the deploy

- Push to `master`, **or**
- **Actions → Deploy Flutter Web to GitHub Pages → Run workflow**

App URL:

```text
https://alibarkat726.github.io/Farm_Ai/
```

(`--base-href /Farm_Ai/` matches this repo name.)

---

## Updating later

| Change | What to do |
|--------|------------|
| Backend code | Push to GitHub → Render auto-deploys |
| Flutter UI | Push app changes → Pages workflow runs |
| New Render URL | Update GitHub variable `API_BASE_URL`, re-run Pages workflow |
| CORS tighten | Set `ALLOWED_ORIGINS=https://alibarkat726.github.io` on Render |

---

## Checklist

- [ ] Render backend `/health` returns OK
- [ ] `OPENAI_API_KEY` set on Render (not in git)
- [ ] GitHub Pages source = Actions
- [ ] Repo variable `API_BASE_URL` set
- [ ] Workflow succeeded
- [ ] Open `https://alibarkat726.github.io/Farm_Ai/` and run a text diagnosis
