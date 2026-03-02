# Full Development Report — Agentic Frontend

> **Purpose**: Hand-off document for backend developers. Describes every API contract the Flutter app expects, the exact request/response shapes, authentication flow, error handling, and integration requirements.

---

## 1. Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                      Flutter UI                          │
│  (Screens / Widgets / Controllers)                       │
└────────────────────┬─────────────────────────────────────┘
                     │  ref.watch(courseRepositoryProvider)
                     │  ref.watch(jobRepositoryProvider)
                     │  ref.watch(searchRepositoryProvider)
                     │  ref.watch(aiCopilotRepositoryProvider)
                     ▼
┌──────────────────────────────────────────────────────────┐
│            Riverpod Providers (providers.dart)            │
└────────────────────┬─────────────────────────────────────┘
                     ▼
┌──────────────────────────────────────────────────────────┐
│         Compatibility Adapters (compat/*.dart)            │
│   ┌──────────────────────────────────────────────┐       │
│   │  if (mode == supabaseOnly) → Supabase        │       │
│   │  if (mode == fastapiPreferred) →              │       │
│   │      try FastAPI → on failure → Supabase      │       │
│   │  if (mode == fastapiOnly) → FastAPI           │       │
│   └──────────────────────────────────────────────┘       │
└────────┬──────────────────────────┬──────────────────────┘
         ▼                          ▼
┌─────────────────┐      ┌─────────────────────┐
│  FastAPI Repos   │      │  Supabase Repos      │
│  (Dio + Client)  │      │  (supabase_flutter)  │
└────────┬─────────┘      └──────────┬───────────┘
         ▼                           ▼
   FastAPI Backend             Supabase Cloud
   http://localhost:8000       https://xxx.supabase.co
```

**State management**: Riverpod 2.x
**HTTP client**: Dio 5.x
**Auth storage**: flutter_secure_storage
**Environment**: flutter_dotenv (.env file)

---

## 2. Project File Map

```
lib/
├── main.dart                                    # App entry, init Supabase + dotenv
├── config/
│   ├── env_config.dart                          # All .env vars centralized
│   ├── backend_mode.dart                        # BackendMode enum (3 modes)
│   └── feature_flags.dart                       # Per-module on/off toggles
├── core/
│   ├── error/
│   │   ├── app_exception.dart                   # Typed exception hierarchy (sealed)
│   │   └── fallback_helper.dart                 # Decides when to fallback
│   ├── network/
│   │   └── fastapi_client.dart                  # Dio client + interceptor chain
│   └── storage/
│       └── token_storage.dart                   # Secure FastAPI JWT storage
├── models/
│   ├── auth/auth_models.dart                    # BackendTokens, BackendProfile
│   ├── ai_copilot/ai_copilot.dart               # CopilotEvent, Recommendation, etc.
│   ├── common/
│   │   ├── api_result.dart                      # ApiResult<T> sealed type
│   │   └── paginated_response.dart              # PaginatedResponse<T>
│   ├── course/course.dart                       # Course model + CourseFilter
│   ├── job/job.dart                             # Job model + JobFilter
│   └── search/search_result.dart                # SearchResult + SearchQuery
├── providers/
│   └── providers.dart                           # All Riverpod provider wiring
├── repositories/
│   ├── course_repository.dart                   # Abstract interface
│   ├── job_repository.dart                      # Abstract interface
│   ├── search_repository.dart                   # Abstract interface
│   ├── ai_copilot_repository.dart               # Abstract interface
│   ├── supabase/
│   │   ├── supabase_course_repository.dart
│   │   ├── supabase_job_repository.dart
│   │   └── supabase_search_repository.dart
│   ├── fastapi/
│   │   ├── fastapi_course_repository.dart
│   │   ├── fastapi_job_repository.dart
│   │   ├── fastapi_search_repository.dart
│   │   └── fastapi_ai_copilot_repository.dart
│   └── compat/
│       ├── course_repository_compat.dart
│       ├── job_repository_compat.dart
│       ├── search_repository_compat.dart
│       └── ai_copilot_repository_compat.dart
test/
├── widget_test.dart
└── repositories/
    ├── course_repository_compat_test.dart       # 12 tests
    └── job_repository_compat_test.dart          # 11 tests
```

---

## 3. Backend Mode & Feature Flags

### 3.1 Backend Modes

| Mode | Env Value | Behavior |
|---|---|---|
| **Supabase Only** | `BACKEND_MODE=supabase_only` | All data from Supabase. FastAPI never called. |
| **FastAPI Preferred** | `BACKEND_MODE=fastapi_preferred` | Try FastAPI first. On failure → fallback to Supabase. |
| **FastAPI Only** | `BACKEND_MODE=fastapi_only` | FastAPI only. Errors propagate to UI. No fallback. |

### 3.2 Per-Module Feature Flags

| Flag | Controls | Default |
|---|---|---|
| `FF_COURSE_FINDER_FASTAPI` | Course list/search/detail routing | `false` |
| `FF_JOB_FINDER_FASTAPI` | Job list/search/saved/applied routing | `false` |
| `FF_SEARCH_FASTAPI` | Unified search routing | `false` |
| `FF_AI_COPILOT` | AI copilot features (events, recs) | `false` |
| `FF_WEBSOCKET` | WebSocket connections (placeholder) | `false` |

When any flag is `false`, that module always uses Supabase regardless of `BACKEND_MODE`.

---

## 4. HTTP Client Configuration

### 4.1 Base Configuration

```
Base URL:      ${FASTAPI_BASE_URL}${FASTAPI_API_PREFIX}
               Default: http://localhost:8000/api/v1

Content-Type:  application/json
Accept:        application/json

Connect Timeout: 10,000 ms (configurable via CONNECT_TIMEOUT_MS)
Receive Timeout: 15,000 ms (configurable via REQUEST_TIMEOUT_MS)
```

### 4.2 Request Headers (sent on every request)

| Header | Value | Source |
|---|---|---|
| `Content-Type` | `application/json` | Static |
| `Accept` | `application/json` | Static |
| `Authorization` | `Bearer <fastapi_access_token>` | From secure storage (if token exists) |
| `X-Request-Id` | UUID v4 (e.g. `550e8400-e29b-41d4-a716-446655440000`) | Generated per request |

### 4.3 Interceptor Chain (execution order)

```
Request flow:  AuthInterceptor → RequestIdInterceptor → LoggingInterceptor → [network]
Response flow: LoggingInterceptor → [return]
Error flow:    LoggingInterceptor → RetryInterceptor → [error mapping]
```

1. **AuthInterceptor** — reads token from `flutter_secure_storage` key `fastapi_access_token`, injects `Authorization: Bearer <token>` if present
2. **RequestIdInterceptor** — generates UUID v4, adds `X-Request-Id` header
3. **LoggingInterceptor** — logs request/response/error at debug level
4. **RetryInterceptor** — retries on transient failures (see below)

### 4.4 Retry Policy

| Condition | Retries? |
|---|---|
| Connection timeout | Yes |
| Receive timeout | Yes |
| Connection error (DNS, offline) | Yes |
| HTTP 5xx | Yes |
| HTTP 4xx | No |
| Request cancelled | No |

- **Max retries**: 2 (configurable via `MAX_RETRIES`)
- **Backoff**: `RETRY_DELAY_MS * (attempt + 1)` — e.g. 1000ms, 2000ms
- Retry count tracked via `requestOptions.extra['_retryCount']`

---

## 5. API Contracts — What the Frontend Expects

> **CRITICAL FOR BACKEND DEVELOPER**: These are the exact endpoint paths, query parameters, request bodies, and response shapes the Flutter app will call. If your response deviates, the compat layer will attempt to parse alternate shapes, but matching these contracts avoids fallback.

---

### 5.1 Courses API

#### `GET /api/v1/courses/`

List/filter courses with pagination.

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `page` | int | Yes | Page number (1-based) |
| `page_size` | int | Yes | Items per page (default 20) |
| `q` | string | No | Search query (title match) |
| `category` | string | No | Filter by category |
| `level` | string | No | Filter by level (e.g. "beginner") |
| `is_free` | bool | No | Filter free courses only |
| `min_rating` | float | No | Minimum rating filter |
| `provider` | string | No | Filter by provider/institution |
| `tags` | string | No | Comma-separated tag list |

**Expected Response** (preferred shape):

```json
{
  "items": [
    {
      "id": "string | int",
      "title": "string",
      "description": "string | null",
      "provider": "string | null",
      "image_url": "string | null",
      "category": "string | null",
      "duration": "string | null",
      "level": "string | null",
      "rating": "float | null",
      "review_count": "int | null",
      "price": "float | null",
      "currency": "string | null",
      "is_free": "bool",
      "is_eligible": "bool | null",
      "tags": ["string"],
      "url": "string | null",
      "created_at": "ISO8601 | null",
      "updated_at": "ISO8601 | null"
    }
  ],
  "total": 150,
  "page": 1,
  "page_size": 20
}
```

**Alternate field names the parser also accepts:**

| Preferred | Also Accepted |
|---|---|
| `id` | `course_id` |
| `title` | `name` |
| `provider` | `institution` |
| `image_url` | `thumbnail` |
| `level` | `difficulty` |
| `review_count` | `reviews` |
| `url` | `link` |

**Alternate envelope shapes the parser handles:**

```json
{ "results": [...], "total": N, "page": N, "page_size": N }
{ "data": [...], "total": N }
```

---

#### `GET /api/v1/courses/{id}`

Get single course by ID.

**Response**: Single course object (same shape as items above, unwrapped).

---

#### `GET /api/v1/courses/search`

Search courses by text query.

**Query Parameters:**

| Param | Type | Required |
|---|---|---|
| `q` | string | Yes |
| `page` | int | Yes |
| `page_size` | int | Yes |

**Response**: Same paginated envelope as `GET /api/v1/courses/`.

---

#### `GET /api/v1/courses/eligible`

Get courses the current user is eligible for.

**Query Parameters:**

| Param | Type | Required |
|---|---|---|
| `page` | int | Yes |
| `page_size` | int | Yes |

**Response**: Same paginated envelope.

---

#### `GET /api/v1/courses/categories`

List all distinct course categories.

**Response:**

```json
{
  "categories": ["Technology", "Business", "Design"]
}
```

> **NOTE**: If this endpoint doesn't exist (returns 404), the app falls back to Supabase `SELECT DISTINCT category FROM courses`. Consider implementing it.

---

#### `GET /api/v1/courses/levels`

List all distinct course levels.

**Response:**

```json
{
  "levels": ["Beginner", "Intermediate", "Advanced"]
}
```

> **NOTE**: Same 404-fallback behavior as categories.

---

### 5.2 Jobs API

#### `GET /api/v1/jobs/`

List/filter jobs with pagination.

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `page` | int | Yes | Page number (1-based) |
| `page_size` | int | Yes | Items per page |
| `q` | string | No | Search query (also used for job search) |
| `category` | string | No | Job category filter |
| `type` | string | No | "full-time", "part-time", "contract", "internship" |
| `location` | string | No | Location filter |
| `is_remote` | bool | No | Remote only |
| `experience_level` | string | No | e.g. "junior", "senior" |
| `salary_min` | float | No | Minimum salary |
| `skills` | string | No | Comma-separated skills |

**Expected Response:**

```json
{
  "items": [
    {
      "id": "string | int",
      "title": "string",
      "company": "string | null",
      "company_logo": "string | null",
      "location": "string | null",
      "is_remote": false,
      "type": "string | null",
      "salary": "string | null",
      "salary_min": "float | null",
      "salary_max": "float | null",
      "currency": "string | null",
      "description": "string | null",
      "requirements": ["string"],
      "skills": ["string"],
      "category": "string | null",
      "experience_level": "string | null",
      "posted_at": "ISO8601 | null",
      "expires_at": "ISO8601 | null",
      "url": "string | null",
      "is_saved": "bool",
      "is_applied": "bool",
      "application_status": "string | null"
    }
  ],
  "total": 85,
  "page": 1,
  "page_size": 20
}
```

**Alternate field names also accepted:**

| Preferred | Also Accepted |
|---|---|
| `id` | `job_id` |
| `title` | `job_title` |
| `company` | `company_name` |
| `company_logo` | `logo_url` |
| `type` | `job_type` |
| `experience_level` | `level` |
| `url` | `apply_url` |
| `posted_at` | `created_at` |

---

#### `GET /api/v1/jobs/{id}`

Get single job by ID.

**Response**: Single job object (unwrapped).

---

#### `GET /api/v1/jobs/applied`

Get list of jobs the current user has applied to.

**Response** (either shape):

```json
[{ ...job_object, "is_applied": true, "application_status": "pending" }]
```
or
```json
{ "items": [...] }
```

---

#### `GET /api/v1/saved-items/jobs`

Get user's saved/bookmarked jobs.

**Response** (either shape):

```json
[{ ...job_object }]
```
or
```json
{ "items": [...] }
```

App marks all returned jobs with `isSaved: true`.

---

#### `POST /api/v1/saved-items/jobs`

Save/bookmark a job.

**Request Body:**

```json
{
  "job_id": "string"
}
```

**Response**: Any (status 2xx).

---

#### `DELETE /api/v1/saved-items/jobs/{jobId}`

Remove a saved job.

**Response**: Any (status 2xx).

---

### 5.3 Unified Search API

#### `GET /api/v1/search/`

Search across all entity types.

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `q` | string | Yes | Search query |
| `page` | int | Yes | Page number |
| `page_size` | int | Yes | Items per page |
| `types` | string | No | Comma-separated type filter (e.g. "course,job") |

**Expected Response:**

```json
{
  "items": [
    {
      "id": "string",
      "type": "course | job | lead",
      "title": "string",
      "subtitle": "string | null",
      "image_url": "string | null",
      "score": "float | null",
      "metadata": {}
    }
  ],
  "total": 42,
  "page": 1,
  "page_size": 20
}
```

Also accepts `{ "results": [...] }` envelope.

---

### 5.4 AI Copilot API

> All AI endpoints are behind the `FF_AI_COPILOT` feature flag. When disabled, the app never calls these. When enabled, all calls degrade gracefully on failure (no crash).

#### `POST /api/v1/ai-copilot/events`

Publish a single user action event.

**Request Body:**

```json
{
  "event_type": "page_view | course_click | job_apply | search | ...",
  "payload": {
    "arbitrary": "data relevant to the event"
  },
  "timestamp": "2025-01-15T10:30:00Z"
}
```

**Response**: Any (status 2xx).

---

#### `POST /api/v1/ai-copilot/events/batch`

Publish multiple events at once (used for offline queue flush).

**Request Body:**

```json
{
  "events": [
    {
      "event_type": "string",
      "payload": {},
      "timestamp": "ISO8601"
    }
  ]
}
```

**Response**: Any (status 2xx).

---

#### `GET /api/v1/ai-copilot/recommendations`

Get AI-generated recommendations for the current user.

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `type` | string | No | Filter by recommendation type ("course", "job", "action") |

**Expected Response** (any of these):

```json
[
  {
    "id": "string",
    "type": "course | job | action",
    "title": "string",
    "description": "string | null",
    "score": "float | null",
    "reason": "string | null",
    "action_url": "string | null",
    "metadata": {}
  }
]
```
or
```json
{
  "recommendations": [...],
  "items": [...],
  "results": [...]
}
```

---

#### `GET /api/v1/ai-copilot/context`

Get the AI context for the current user/session.

**Response:**

```json
{
  "user_id": "string | null",
  "lead_score": "float | null",
  "next_action": "string | null",
  "summary": "string | null",
  "metadata": {}
}
```

---

#### `GET /api/v1/ai-copilot/next-action`

Get the next recommended action for the user.

**Response:**

```json
{
  "action": "string | null"
}
```

---

#### `GET /api/v1/ai-copilot/lead-score`

Get lead score for a specific lead.

**Query Parameters:**

| Param | Type | Required |
|---|---|---|
| `lead_id` | string | Yes |

**Response:**

```json
{
  "score": 0.85
}
```

---

#### `POST /api/v1/ai-copilot/email-draft`

Generate an AI email draft.

**Request Body:**

```json
{
  "lead_id": "string",
  "context": "string",
  "tone": "formal | casual",
  ...any additional params
}
```

**Response:**

```json
{
  "subject": "string",
  "body": "string",
  "to": "string | null"
}
```

> **NOTE**: This is the only AI endpoint that propagates errors to the UI (no silent fallback).

---

### 5.5 Auth API (Confirmed but NOT yet wired)

These endpoints are confirmed in the backend but the app currently uses Supabase auth for students. Models are ready for future integration.

| Endpoint | Method | Status |
|---|---|---|
| `/api/v1/auth/login` | POST | Model ready (`BackendTokens`), not wired |
| `/api/v1/auth/refresh` | POST | Model ready, not wired |
| `/api/v1/auth/logout` | POST | Not wired |
| `/api/v1/auth/change_password` | POST | Not wired |
| `/api/v1/auth/otp` | POST | Not wired |
| `/api/v1/auth/profile` | GET | Model ready (`BackendProfile`), not wired |

**Expected login response** (for when it's wired):

```json
{
  "access_token": "string",
  "refresh_token": "string | null",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

**Expected profile response:**

```json
{
  "id": "string",
  "email": "string | null",
  "name": "string | null",
  "role": "string | null",
  "metadata": {}
}
```

Also accepts `user_id` for `id` and `full_name` for `name`.

---

### 5.6 Leads API (Confirmed but NOT consumed)

| Endpoint | Method | Status |
|---|---|---|
| `/api/v1/leads/*` | Various | Confirmed, no frontend consumer yet |

---

## 6. Authentication Strategy

### Current State

```
Student login flow:
  User → Supabase Auth (email/password, OAuth, OTP)
       → Supabase session token (managed by supabase_flutter SDK)
       → Used for all Supabase queries

FastAPI token (separate):
  Stored in flutter_secure_storage under keys:
    - 'fastapi_access_token'
    - 'fastapi_refresh_token'
  Injected via Authorization: Bearer header by AuthInterceptor
  If missing → FastAPI calls go without auth → may get 401 → triggers Supabase fallback
```

### Token Flow

```
1. App starts → Supabase session restored automatically
2. If backend auth available → call /api/v1/auth/login → store tokens
3. Every FastAPI request → AuthInterceptor reads token from secure storage
4. If token missing/expired → 401 from backend → compat layer falls back to Supabase
5. Student flows NEVER blocked by backend auth unavailability
```

### What Backend Developer Needs To Know

- The app sends `Authorization: Bearer <token>` on **every** FastAPI request if a token exists
- If the token is invalid/expired, return **401** — the app will fallback gracefully
- The app does NOT currently call `/api/v1/auth/login` — tokens must be provisioned separately or by a future login integration
- **Never** return 403 for missing auth — use 401 (403 does NOT trigger fallback)

---

## 7. Error Handling Contract

### HTTP Status Codes the App Handles

| Status | App Behavior (fastapiPreferred) | App Behavior (fastapiOnly) |
|---|---|---|
| 2xx | Parse response, return data | Same |
| 400 | **Propagate error** (no fallback) | Propagate error |
| 401 | **Fallback to Supabase** | Propagate error |
| 403 | **Propagate error** (no fallback) | Propagate error |
| 404 | **Fallback to Supabase** | Propagate error |
| 5xx | **Fallback to Supabase** (after retries) | Propagate error (after retries) |

### Expected Error Response Shape

```json
{
  "detail": "Human-readable error message",
  "error_code": "OPTIONAL_ERROR_CODE"
}
```

Also accepts `"message"` instead of `"detail"`.

### Timeout & Retry Behavior

```
Request timeout: 15 seconds
Connect timeout: 10 seconds
Retries: 2 attempts on 5xx/timeout
Backoff: 1s, 2s (linear with attempt multiplier)
```

---

## 8. Pagination Contract

### Standard Envelope (preferred)

```json
{
  "items": [...],
  "total": 150,
  "page": 1,
  "page_size": 20
}
```

### Also Accepted

```json
{ "results": [...], "total": N, "page": N, "page_size": N }
{ "results": [...], "count": N }
{ "data": [...], "total": N }
```

### Frontend Pagination Logic

- `page` is 1-based
- `hasMore = (page * pageSize) < total`
- `totalPages = ceil(total / pageSize)`
- The app will request `page=1&page_size=20`, then `page=2&page_size=20`, etc.

---

## 9. Supabase Tables Referenced (for backend developer awareness)

If the backend needs to replicate or replace Supabase behavior, these are the table schemas the app expects:

### `courses`

| Column | Type | Notes |
|---|---|---|
| `id` | uuid/int | Primary key |
| `title` | text | Required |
| `description` | text | Nullable |
| `provider` | text | Nullable |
| `image_url` | text | Nullable |
| `category` | text | Filterable |
| `duration` | text | Nullable |
| `level` | text | Filterable |
| `rating` | float | Nullable |
| `review_count` | int | Nullable |
| `price` | float | Nullable |
| `currency` | text | Nullable |
| `is_free` | bool | Default false |
| `is_eligible` | bool | Nullable |
| `tags` | text[] | Array |
| `url` | text | Nullable |
| `created_at` | timestamptz | Auto |
| `updated_at` | timestamptz | Auto |

### `jobs`

| Column | Type | Notes |
|---|---|---|
| `id` | uuid/int | Primary key |
| `title` | text | Required |
| `company` | text | Nullable |
| `company_logo` | text | URL |
| `location` | text | Filterable (ilike) |
| `is_remote` | bool | Default false |
| `type` | text | "full-time" etc |
| `salary` | text | Display string |
| `salary_min` | float | Nullable |
| `salary_max` | float | Nullable |
| `currency` | text | Nullable |
| `description` | text | Nullable |
| `requirements` | text[] | Array |
| `skills` | text[] | Array |
| `category` | text | Filterable |
| `experience_level` | text | Filterable |
| `posted_at` | timestamptz | Nullable |
| `expires_at` | timestamptz | Nullable |
| `url` | text | Apply URL |

### `saved_jobs`

| Column | Type | Notes |
|---|---|---|
| `user_id` | uuid | FK → auth.users |
| `job_id` | uuid/int | FK → jobs |

### `job_applications`

| Column | Type | Notes |
|---|---|---|
| `user_id` | uuid | FK → auth.users |
| `job_id` | uuid/int | FK → jobs |
| `status` | text | "pending", "accepted", etc. |

---

## 10. Offline / Degraded Mode Behavior

### AI Copilot Offline Queue

When `POST /api/v1/ai-copilot/events` or `events/batch` fails:
1. Events are stored in an in-memory queue (`Queue<CopilotEvent>`)
2. On the next successful event publish, queued events are batch-flushed first
3. If flush fails, events remain in queue for next attempt
4. Queue is lost on app restart (no persistence — acceptable for analytics events)

### Connectivity Loss

| Module | Behavior |
|---|---|
| Courses | Falls back to Supabase (in fastapiPreferred) |
| Jobs | Falls back to Supabase (in fastapiPreferred) |
| Search | Falls back to Supabase (in fastapiPreferred) |
| AI Copilot | Returns empty data, queues events |

---

## 11. Request Correlation

Every request includes `X-Request-Id: <UUID v4>` header. This ID is:
- Logged on the client side
- Available in error responses for debugging
- Included in all `AppException` objects

**Backend recommendation**: Log this header server-side for request tracing across frontend ↔ backend.

---

## 12. What the Backend Must NOT Do

1. **Do NOT return 403 for missing/expired tokens** — return 401 (only 401 triggers fallback)
2. **Do NOT use non-JSON response bodies** — the client expects `application/json` always
3. **Do NOT paginate with 0-based pages** — the app sends `page=1` for the first page
4. **Do NOT omit `total` from paginated responses** — the app needs it for "load more" logic
5. **Do NOT require request body for GET endpoints** — use query parameters
6. **Do NOT block on missing `Authorization` header** for public endpoints — return data for anonymous users (guest mode)

---

## 13. Recommended Backend Implementation Priorities

Based on what the frontend actively consumes:

### P0 — Required for launch

| Endpoint | Reason |
|---|---|
| `GET /api/v1/courses/` | Course finder screen |
| `GET /api/v1/courses/{id}` | Course detail screen |
| `GET /api/v1/jobs/` | Job finder screen |
| `GET /api/v1/jobs/{id}` | Job detail screen |
| `GET /api/v1/saved-items/jobs` | Saved jobs list |
| `POST /api/v1/saved-items/jobs` | Save job action |
| `DELETE /api/v1/saved-items/jobs/{id}` | Unsave job action |

### P1 — Important

| Endpoint | Reason |
|---|---|
| `GET /api/v1/courses/search` | Course search |
| `GET /api/v1/courses/eligible` | Personalized courses |
| `GET /api/v1/jobs/applied` | Application tracking |
| `GET /api/v1/search/` | Unified search |

### P2 — AI Features (behind flag)

| Endpoint | Reason |
|---|---|
| `POST /api/v1/ai-copilot/events` | User analytics |
| `POST /api/v1/ai-copilot/events/batch` | Batch analytics |
| `GET /api/v1/ai-copilot/recommendations` | AI recommendations |
| `GET /api/v1/ai-copilot/context` | User context |
| `GET /api/v1/ai-copilot/next-action` | Next best action |
| `GET /api/v1/ai-copilot/lead-score` | Lead scoring |
| `POST /api/v1/ai-copilot/email-draft` | Email generation |

### P3 — Future

| Endpoint | Reason |
|---|---|
| `GET /api/v1/courses/categories` | Filter dropdown |
| `GET /api/v1/courses/levels` | Filter dropdown |
| Auth endpoints | Replace Supabase auth |
| WebSocket `/ws` | Real-time updates |

---

## 14. Test Coverage Summary

| Test Suite | Tests | Covers |
|---|---|---|
| `course_repository_compat_test.dart` | 12 | All 3 modes, 5 error types, model parsing |
| `job_repository_compat_test.dart` | 11 | All 3 modes, fallback, model parsing, copyWith |
| `widget_test.dart` | 1 | App renders |
| **Total** | **23** | **All pass** |
