# Runbook: Backend Mode Switching & Testing

## Prerequisites

1. Copy `.env.example` to `.env` and fill in your Supabase and FastAPI credentials.
2. Run `flutter pub get`.

---

## Switching Backend Modes

Edit the `BACKEND_MODE` value in `.env`:

### Mode: `supabase_only` (Default — safe rollback)
```
BACKEND_MODE=supabase_only
```
- All data comes from Supabase.
- FastAPI client is initialized but never called.
- Zero risk. Identical to pre-migration behavior.

### Mode: `fastapi_preferred` (Recommended for rollout)
```
BACKEND_MODE=fastapi_preferred
```
- Tries FastAPI first for every call.
- On failure (network, 401, 404, 5xx, parse error) → falls back to Supabase.
- Fallback events are logged with warnings for monitoring.

### Mode: `fastapi_only` (Full migration)
```
BACKEND_MODE=fastapi_only
```
- All calls go to FastAPI. No fallback.
- Errors propagate to the UI.
- Use only when backend is stable and fully tested.

---

## Per-Feature Toggles

Each module can be independently toggled in `.env`:

```
FF_COURSE_FINDER_FASTAPI=true    # Course list/search/detail
FF_JOB_FINDER_FASTAPI=true      # Job list/search/saved/applied
FF_SEARCH_FASTAPI=true           # Unified search
FF_AI_COPILOT=false              # AI recommendations/events
FF_WEBSOCKET=false               # WebSocket connections
```

Setting any flag to `false` forces that module to `supabase_only` regardless of `BACKEND_MODE`.

---

## Testing Each Mode

### 1. Test `supabase_only`
```bash
# Set in .env:
# BACKEND_MODE=supabase_only

flutter run
# Verify: courses load, jobs load, search works
# Verify: no network calls to localhost:8000 (check logs)
```

### 2. Test `fastapi_preferred` (backend running)
```bash
# Start backend:
cd your-backend && uvicorn main:app --reload

# Set in .env:
# BACKEND_MODE=fastapi_preferred
# FF_COURSE_FINDER_FASTAPI=true
# FF_JOB_FINDER_FASTAPI=true

flutter run
# Verify: data loads from FastAPI (check debug logs: → GET /api/v1/courses/)
# Verify: response data appears correctly in UI
```

### 3. Test `fastapi_preferred` (backend DOWN)
```bash
# Stop backend (kill uvicorn)

# Keep BACKEND_MODE=fastapi_preferred in .env

flutter run
# Verify: warning logs appear (FastAPI failed, falling back)
# Verify: data still loads via Supabase
# Verify: no crashes, no empty screens
```

### 4. Test `fastapi_only`
```bash
# Start backend
# Set BACKEND_MODE=fastapi_only

flutter run
# Verify: data loads from FastAPI
# Stop backend → verify: errors shown in UI (no silent fallback)
```

### 5. Test per-feature flag isolation
```bash
# Set in .env:
# BACKEND_MODE=fastapi_preferred
# FF_COURSE_FINDER_FASTAPI=true
# FF_JOB_FINDER_FASTAPI=false

flutter run
# Verify: courses come from FastAPI (check logs)
# Verify: jobs come from Supabase (no FastAPI job calls in logs)
```

---

## Running Unit Tests

```bash
flutter test
```

Tests cover:
- `supabaseOnly` skips FastAPI entirely
- `fastapiPreferred` uses FastAPI on success
- `fastapiPreferred` falls back on NetworkException, 401, 404, 500, ParseException
- `fastapiOnly` propagates errors (no fallback)
- Model JSON parsing with standard and alternate field names
- Null/missing field graceful handling

---

## Instant Rollback

If anything goes wrong in production:

1. Set `BACKEND_MODE=supabase_only` in `.env`
2. Hot restart the app
3. All traffic goes to Supabase — zero FastAPI dependency

Or rollback a single module:
```
FF_COURSE_FINDER_FASTAPI=false   # Just courses back to Supabase
```

---

## Monitoring Fallback Events

In `fastapiPreferred` mode, every fallback emits a warning log:

```
⚠️ [CourseRepo.getCourses] FastAPI failed (timeout), falling back to Supabase
```

Monitor these logs to:
- Track backend reliability
- Identify endpoints that consistently fail
- Decide when to promote to `fastapi_only`

---

## Architecture Overview

```
UI Widgets / Screens
        │
        ▼
  Riverpod Providers (providers.dart)
        │
        ▼
  Compat Repositories (CourseRepositoryCompat, JobRepositoryCompat, ...)
        │                        │
        ▼                        ▼
  FastAPI Repository       Supabase Repository
  (Dio + interceptors)     (supabase_flutter)
        │
        ▼
  FastApiClient (auth, retry, logging, request-id)
```
