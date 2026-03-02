# Full Development Report — Agentic Frontend (v2)

> **Purpose**: Hand-off document for backend developers. Describes every API contract the Flutter app expects, exact request/response shapes, authentication flow, error handling, navigation structure, state management, and integration requirements.
>
> **Architecture**: BLoC + GetIt + GoRouter (migrated from Riverpod)

---

## 1. Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                          Flutter App                                 │
│                                                                      │
│  ┌──────────┐   ┌────────────┐   ┌──────────────────────────┐       │
│  │  GoRouter │──▶│    BLoC    │──▶│   Compat Repository      │       │
│  │  (pages)  │   │  (state)   │   │  (routing + fallback)    │       │
│  └──────────┘   └────────────┘   └────────┬─────────┬───────┘       │
│                                           │         │                │
│                   ┌───────────────────────┘         │                │
│                   ▼                                 ▼                │
│         ┌─────────────────┐              ┌──────────────────┐       │
│         │  FastAPI Repo   │              │  Supabase Repo   │       │
│         │  (Dio client)   │              │  (Supabase SDK)  │       │
│         └────────┬────────┘              └────────┬─────────┘       │
└──────────────────┼────────────────────────────────┼──────────────────┘
                   │                                │
                   ▼                                ▼
          ┌────────────────┐              ┌──────────────────┐
          │  FastAPI Server │              │   Supabase DB    │
          │  (your backend) │              │   (PostgreSQL)   │
          └────────────────┘              └──────────────────┘
```

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | flutter_bloc | Predictable, testable, event-driven |
| Dependency Injection | GetIt (`sl` global) | Simple service locator, lazy singletons |
| Navigation | GoRouter + StatefulShellRoute | Declarative, deep-link ready, 5-tab shell |
| HTTP Client | Dio (4-interceptor chain) | Auth, correlation IDs, logging, retry |
| Backend Strategy | Compat adapter (FastAPI → Supabase fallback) | Zero-downtime migration |
| Feature Flags | Per-module `.env` toggles | Gradual rollout per module |

---

## 2. Environment Configuration

### `.env` Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `SUPABASE_URL` | String | (required) | Supabase project URL |
| `SUPABASE_ANON_KEY` | String | (required) | Supabase anonymous key |
| `FASTAPI_BASE_URL` | String | `http://localhost:8000` | FastAPI server base URL |
| `FASTAPI_API_PREFIX` | String | `/api/v1` | API path prefix |
| `BACKEND_MODE` | Enum | `supabase_only` | `supabase_only` / `fastapi_preferred` / `fastapi_only` |
| `REQUEST_TIMEOUT_MS` | int | `15000` | HTTP receive timeout (ms) |
| `CONNECT_TIMEOUT_MS` | int | `10000` | HTTP connect timeout (ms) |
| `MAX_RETRIES` | int | `2` | Retry count for transient failures |
| `FF_COURSE_FINDER_FASTAPI` | bool | `false` | Route Course module to FastAPI |
| `FF_JOB_FINDER_FASTAPI` | bool | `false` | Route Job module to FastAPI |
| `FF_SEARCH_FASTAPI` | bool | `false` | Route Search module to FastAPI |
| `FF_AI_COPILOT` | bool | `false` | Enable AI Copilot features |

### Backend Modes

| Mode | Behavior |
|------|----------|
| `supabase_only` | All data from Supabase. FastAPI never called. |
| `fastapi_preferred` | Try FastAPI first. On failure → fallback to Supabase. |
| `fastapi_only` | FastAPI only. Errors propagate to UI. No fallback. |

**Feature flag override**: When `FF_<MODULE>_FASTAPI=false`, that module always uses Supabase regardless of `BACKEND_MODE`.

---

## 3. FastAPI Endpoint Contracts

### 3.1 Course Endpoints

#### `GET /api/v1/courses/`

List courses with optional filters and pagination.

**Query Parameters:**

| Parameter | Type | Required | Example |
|-----------|------|----------|---------|
| `page` | int | Yes | `1` |
| `page_size` | int | Yes | `20` |
| `q` | string | No | `"flutter"` |
| `category` | string | No | `"Technology"` |
| `level` | string | No | `"beginner"` |
| `is_free` | bool | No | `true` |
| `provider` | string | No | `"Coursera"` |

**Expected Response** (any of these envelope shapes):

```json
{
  "items": [
    {
      "id": 1,
      "title": "Flutter Basics",
      "description": "Learn Flutter from scratch",
      "provider": "Coursera",
      "image_url": "https://...",
      "category": "Technology",
      "duration": "8 weeks",
      "level": "beginner",
      "rating": 4.5,
      "review_count": 128,
      "price": 0.0,
      "currency": "USD",
      "is_free": true,
      "is_eligible": true,
      "tags": ["flutter", "dart", "mobile"],
      "url": "https://...",
      "created_at": "2025-01-15T10:00:00Z"
    }
  ],
  "total": 150,
  "page": 1,
  "page_size": 20
}
```

**Accepted alternate field names** (parser handles both):

| Primary | Alternate |
|---------|-----------|
| `id` | `course_id` |
| `title` | `name` |
| `provider` | `institution` |
| `image_url` | `thumbnail` |
| `level` | `difficulty` |
| `review_count` | `reviews` |
| `url` | `link` |

**Accepted envelope keys**: `items`, `results`, or `data`
**Accepted total keys**: `total` or `count`

---

#### `GET /api/v1/courses/{id}`

Get a single course by ID.

**Response**: Single course object (same fields as above, unwrapped).

**Error**: Return HTTP 404 with `{ "detail": "Course not found" }` if missing.

---

#### `GET /api/v1/courses/categories`

List distinct course categories.

**Expected Response:**

```json
{
  "categories": ["Technology", "Business", "Design", "Science"]
}
```

**Note**: If this endpoint is not implemented yet, return 404. The frontend catches 404 and raises `NotImplementedException`, which triggers Supabase fallback in `fastapiPreferred` mode.

---

### 3.2 Job Endpoints

#### `GET /api/v1/jobs/`

List jobs with optional filters and pagination.

**Query Parameters:**

| Parameter | Type | Required | Example |
|-----------|------|----------|---------|
| `page` | int | Yes | `1` |
| `page_size` | int | Yes | `20` |
| `q` | string | No | `"developer"` |
| `category` | string | No | `"Engineering"` |
| `type` | string | No | `"full-time"` |
| `location` | string | No | `"Remote"` |
| `is_remote` | bool | No | `true` |
| `experience_level` | string | No | `"senior"` |

**Expected Response:**

```json
{
  "items": [
    {
      "id": 1,
      "title": "Senior Flutter Developer",
      "company": "TechCorp",
      "company_logo": "https://...",
      "location": "San Francisco, CA",
      "is_remote": true,
      "type": "full-time",
      "salary": "$120k - $180k",
      "salary_min": 120000.0,
      "salary_max": 180000.0,
      "currency": "USD",
      "description": "We are looking for...",
      "requirements": ["3+ years Flutter", "State management experience"],
      "skills": ["flutter", "dart", "bloc"],
      "category": "Engineering",
      "experience_level": "senior",
      "posted_at": "2025-02-01T00:00:00Z",
      "url": "https://apply.techcorp.com/123",
      "is_saved": false,
      "is_applied": false,
      "application_status": null
    }
  ],
  "total": 85,
  "page": 1,
  "page_size": 20
}
```

**Accepted alternate field names:**

| Primary | Alternate |
|---------|-----------|
| `id` | `job_id` |
| `title` | `job_title` |
| `company` | `company_name` |
| `company_logo` | `logo_url` |
| `type` | `job_type` |
| `experience_level` | `level` |
| `posted_at` | `created_at` |
| `url` | `apply_url` |

---

#### `GET /api/v1/jobs/{id}`

Get a single job by ID.

**Response**: Single job object (same fields as above, unwrapped).

**Error**: Return HTTP 404 with `{ "detail": "Job not found" }`.

---

#### `GET /api/v1/saved-items/jobs`

Get the authenticated user's saved/bookmarked jobs.

**Response** (accepts both formats):

```json
[
  { "id": 1, "title": "Flutter Dev", "company": "Acme", ... }
]
```

or:

```json
{
  "items": [
    { "id": 1, "title": "Flutter Dev", "company": "Acme", ... }
  ]
}
```

Frontend automatically sets `isSaved: true` on all returned jobs.

---

#### `POST /api/v1/saved-items/jobs`

Save/bookmark a job.

**Request Body:**

```json
{
  "job_id": "123"
}
```

**Response**: Any 2xx (body ignored).

---

#### `DELETE /api/v1/saved-items/jobs/{jobId}`

Remove a saved job.

**Response**: Any 2xx (body ignored).

---

#### `GET /api/v1/jobs/applied`

Get the authenticated user's applied jobs.

**Response** (accepts both formats):

```json
[
  { "id": 1, "title": "Flutter Dev", "company": "Acme", "application_status": "pending", ... }
]
```

or:

```json
{
  "items": [...]
}
```

Frontend automatically sets `isApplied: true` on all returned jobs.

---

### 3.3 Search Endpoint (Planned — behind `FF_SEARCH_FASTAPI`)

#### `GET /api/v1/search/`

Unified cross-module search.

**Query Parameters:**

| Parameter | Type | Required | Example |
|-----------|------|----------|---------|
| `q` | string | Yes | `"flutter"` |
| `types` | string | No | `"course,job"` (comma-separated) |
| `page` | int | Yes | `1` |
| `page_size` | int | Yes | `20` |

**Expected Response:**

```json
{
  "items": [
    {
      "id": "123",
      "type": "course",
      "title": "Flutter Basics",
      "subtitle": "Learn Flutter from scratch",
      "image_url": "https://...",
      "score": 0.95,
      "metadata": { "provider": "Coursera", "rating": 4.5 }
    }
  ],
  "total": 42,
  "page": 1,
  "page_size": 20
}
```

---

### 3.4 AI Copilot Endpoints (Planned — behind `FF_AI_COPILOT`)

#### `POST /api/v1/ai-copilot/events`

Publish a single user behavior event.

**Request Body:**

```json
{
  "event_type": "page_view",
  "payload": { "page": "/courses", "duration_ms": 5000 },
  "timestamp": "2025-03-01T12:00:00Z"
}
```

**Event types**: `page_view`, `course_click`, `job_apply`, `search`, `bookmark`, etc.

---

#### `POST /api/v1/ai-copilot/events/batch`

Publish multiple events at once.

**Request Body:**

```json
{
  "events": [
    { "event_type": "page_view", "payload": {...}, "timestamp": "..." },
    { "event_type": "course_click", "payload": {...}, "timestamp": "..." }
  ]
}
```

---

#### `GET /api/v1/ai-copilot/recommendations`

Get personalized recommendations.

**Query Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `type` | string | No (filter by "course", "job", "action") |

**Expected Response:**

```json
[
  {
    "id": "rec-001",
    "type": "course",
    "title": "Advanced Flutter",
    "description": "Based on your recent activity...",
    "score": 0.92,
    "reason": "You viewed 3 Flutter courses this week",
    "action_url": "/courses/detail/42",
    "metadata": {}
  }
]
```

---

#### `GET /api/v1/ai-copilot/context`

Get the user's AI context (lead score, next action, summary).

**Expected Response:**

```json
{
  "user_id": "abc-123",
  "lead_score": 0.85,
  "next_action": "Complete your profile to unlock recommendations",
  "summary": "Active learner focused on mobile development"
}
```

---

## 4. Pagination Contract

All paginated endpoints must follow this contract:

```json
{
  "<array_key>": [ ... ],
  "total": 150,
  "page": 1,
  "page_size": 20
}
```

**Rules:**
- Pages are **1-based** (first page = `page=1`)
- `total` is the **total count across all pages**, not just the current page
- `<array_key>` can be `items`, `results`, or `data`
- `total` can alternatively be `count`
- Frontend computes `hasMore = (page * page_size) < total`

---

## 5. Authentication Strategy

### Token Flow

```
┌──────────┐    POST /auth/login     ┌──────────────┐
│  Flutter  │ ──────────────────────▶ │   FastAPI     │
│   App     │ ◀────────────────────── │   Server      │
│           │   { access_token,       │               │
│           │     refresh_token }     │               │
└──────────┘                         └──────────────┘
     │
     │ Stored in FlutterSecureStorage
     │ Key: fastapi_access_token
     │ Key: fastapi_refresh_token
     │
     ▼
  Every subsequent request:
  Authorization: Bearer <access_token>
```

### Required Headers

| Header | Value | Description |
|--------|-------|-------------|
| `Authorization` | `Bearer <token>` | JWT access token (auto-injected by AuthInterceptor) |
| `X-Request-Id` | UUID v4 | Correlation ID (auto-injected by RequestIdInterceptor) |
| `Content-Type` | `application/json` | All requests |
| `Accept` | `application/json` | All requests |

### Token Storage Keys

| Key | Description |
|-----|-------------|
| `fastapi_access_token` | Bearer token for API calls |
| `fastapi_refresh_token` | Refresh token (stored but not yet used for auto-refresh) |

**Note**: Auth endpoints (`/auth/login`, `/auth/register`, `/auth/refresh`) are **not yet implemented** in the frontend. The token storage and auth interceptor infrastructure is ready. Backend should provide JWT tokens compatible with this flow.

---

## 6. HTTP Client Configuration

### Interceptor Chain (executed in order)

| # | Interceptor | Purpose |
|---|-------------|---------|
| 1 | `AuthInterceptor` | Injects `Authorization: Bearer <token>` from secure storage |
| 2 | `RequestIdInterceptor` | Injects `X-Request-Id: <UUID v4>` for correlation |
| 3 | `LoggingInterceptor` | Logs `→ GET /api/v1/courses/` and `← 200 /api/v1/courses/` |
| 4 | `RetryInterceptor` | Retries transient failures with linear backoff |

### Retry Policy

| Condition | Retried? |
|-----------|----------|
| Connection timeout | Yes |
| Receive timeout | Yes |
| Connection error (DNS, offline) | Yes |
| HTTP 5xx | Yes |
| HTTP 4xx | No |
| Request cancelled | No |

**Max retries**: 2 (configurable via `MAX_RETRIES`)
**Backoff**: Linear — 1s for attempt 1, 2s for attempt 2

### Error Mapping (DioException → AppException)

| Dio Error Type | Mapped To |
|----------------|-----------|
| `connectionTimeout` | `NetworkException` |
| `sendTimeout` | `NetworkException` |
| `receiveTimeout` | `NetworkException` |
| `connectionError` | `NetworkException` |
| `badResponse` | `ApiException(statusCode, detail)` |
| `cancel` | `NetworkException("Request cancelled")` |
| `badCertificate` | `NetworkException("Bad certificate")` |
| `unknown` | `NetworkException` |

Error body parsing: expects `{ "detail": "..." }` or `{ "message": "..." }`.

---

## 7. Error Hierarchy & Fallback Conditions

### Exception Types

```dart
sealed class AppException implements Exception
├── ApiException          // HTTP errors (status + detail)
│   ├── isUnauthorized   // statusCode == 401
│   ├── isNotFound       // statusCode == 404
│   └── isServerError    // statusCode >= 500
├── NetworkException      // Connectivity / timeout
├── SupabaseException     // Supabase SDK errors
├── ParseException        // JSON parsing failures
└── NotImplementedException // Feature not available
```

### Fallback Decision Matrix (fastapiPreferred mode only)

| Exception | Fallback to Supabase? |
|-----------|----------------------|
| `NetworkException` | **Yes** |
| `ApiException` 401 | **Yes** |
| `ApiException` 404 | **Yes** |
| `ApiException` 5xx | **Yes** |
| `NotImplementedException` | **Yes** |
| `ParseException` | **Yes** |
| `ApiException` 400 | **No** — propagated to UI |
| `ApiException` 403 | **No** — propagated to UI |
| Any other 4xx | **No** — propagated to UI |

**In `fastapiOnly` mode**: No fallback — all errors propagate to UI.
**In `supabaseOnly` mode**: FastAPI is never called.

---

## 8. Supabase Table Schema (current Supabase fallback)

### `courses` Table

| Column | Type | Notes |
|--------|------|-------|
| `id` | UUID/int | Primary key |
| `title` | text | Course title |
| `description` | text | Nullable |
| `provider` | text | e.g., "Coursera" |
| `image_url` | text | Nullable |
| `category` | text | e.g., "Technology" |
| `duration` | text | e.g., "8 weeks" |
| `level` | text | e.g., "beginner" |
| `rating` | numeric | Nullable |
| `review_count` | int | Nullable |
| `price` | numeric | 0 = free |
| `is_free` | bool | Nullable |
| `tags` | json/text[] | Array of strings |
| `url` | text | Course URL |
| `created_at` | timestamptz | Auto-set |

**Queries used**: `ilike('title', '%q%')`, `eq('category')`, `eq('level')`, `eq('is_free', true)`, `range(from, to)`

### `jobs` Table

| Column | Type | Notes |
|--------|------|-------|
| `id` | UUID/int | Primary key |
| `title` | text | Job title |
| `company` | text | Company name |
| `company_logo` | text | Logo URL |
| `location` | text | e.g., "San Francisco, CA" |
| `is_remote` | bool | Default false |
| `type` | text | "full-time", "part-time", "contract" |
| `salary` | text | Display string |
| `salary_min` | numeric | Nullable |
| `salary_max` | numeric | Nullable |
| `description` | text | Full description |
| `requirements` | json/text[] | Array of strings |
| `skills` | json/text[] | Array of strings |
| `category` | text | e.g., "Engineering" |
| `experience_level` | text | "junior", "mid", "senior" |
| `posted_at` | timestamptz | When posted |

**Queries used**: `ilike('title', '%q%')`, `eq('category')`, `eq('type')`, `eq('is_remote', true)`, `range(from, to)`

### `saved_jobs` Table (junction)

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | UUID | FK → auth.users |
| `job_id` | UUID/int | FK → jobs.id |

**Queries**: `select('job_id, jobs(*)').eq('user_id', userId)`, `insert(...)`, `delete().eq(...).eq(...)`

### `job_applications` Table

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | UUID | FK → auth.users |
| `job_id` | UUID/int | FK → jobs.id |
| `status` | text | "pending", "accepted", "rejected" |

**Queries**: `select('status, jobs(*)').eq('user_id', userId)`

---

## 9. Navigation & Screen Map

### Route Table

| Route | Screen | Tab | BLoC |
|-------|--------|-----|------|
| `/splash` | SplashPage | — | — |
| `/onboarding` | OnboardingPage | — | — |
| `/login` | LoginPage | — | — |
| `/home` | HomePage | Tab 0 (Home) | — |
| `/courses` | CourseListPage | Tab 1 (Courses) | CourseListBloc |
| `/courses/detail/:courseId` | CourseDetailPage | — (full screen) | CourseDetailBloc |
| `/jobs` | JobListPage | Tab 2 (Jobs) | JobListBloc |
| `/jobs/detail/:jobId` | JobDetailPage | — (full screen) | JobDetailBloc |
| `/jobs/saved` | SavedJobsPage | — | — |
| `/jobs/applied` | AppliedJobsPage | — | — |
| `/ai-copilot` | AiCopilotPage | Tab 3 (AI) | — |
| `/profile` | ProfilePage | Tab 4 (Profile) | — |
| `/profile/settings` | SettingsPage | — | — |
| `/notifications` | NotificationsPage | — (full screen) | — |

### 5-Tab Bottom Navigation

| Index | Label | Icon | Route |
|-------|-------|------|-------|
| 0 | Home | `nav/home.svg` | `/home` |
| 1 | Courses | `nav/courses.svg` | `/courses` |
| 2 | Jobs | `nav/jobs.svg` | `/jobs` |
| 3 | AI | `nav/ai.svg` | `/ai-copilot` |
| 4 | Profile | `nav/profile.svg` | `/profile` |

---

## 10. BLoC → API Call Mapping

### CourseListBloc

| Event | API Call | Parameters |
|-------|----------|------------|
| `CourseListFetched(filter)` | `getCourses(CourseFilter)` | query, category, level, isFree, provider, page, pageSize |
| `CourseListLoadMore` | `getCourses(CourseFilter)` | Same filter, page + 1 |
| `CourseListRefreshed` | `getCourses(CourseFilter)` | Same filter, page = 1 |

**State**: `CourseListStatus { initial, loading, loaded, loadingMore, error }` + courses list + hasMore + total

### CourseDetailBloc

| Event | API Call | Parameters |
|-------|----------|------------|
| `CourseDetailFetched(courseId)` | `getCourseById(id)` | Course ID |

**State**: `CourseDetailStatus { initial, loading, loaded, error }` + course

### JobListBloc

| Event | API Call | Parameters |
|-------|----------|------------|
| `JobListFetched(filter)` | `getJobs(JobFilter)` | query, category, type, location, isRemote, experienceLevel, page, pageSize |
| `JobListLoadMore` | `getJobs(JobFilter)` | Same filter, page + 1 |

**State**: `JobListStatus { initial, loading, loaded, loadingMore, error }` + jobs list + hasMore + total

### JobDetailBloc

| Event | API Call | Parameters |
|-------|----------|------------|
| `JobDetailFetched(jobId)` | `getJobById(id)` | Job ID |
| `JobSaveToggled(jobId, isSaved)` | `saveJob(id)` or `unsaveJob(id)` | Job ID |

**State**: `JobDetailStatus { initial, loading, loaded, error }` + job

---

## 11. Dependency Injection Graph

```
GetIt (sl)
├── TokenStorage (lazy singleton)
├── FastApiClient (lazy singleton) ← depends on TokenStorage
├── SupabaseCourseRepository (lazy singleton)
├── SupabaseJobRepository (lazy singleton)
├── FastApiCourseRepository (lazy singleton) ← depends on FastApiClient
├── FastApiJobRepository (lazy singleton) ← depends on FastApiClient
├── CourseRepository = CourseRepositoryCompat (lazy singleton)
│   ├── fastApi: FastApiCourseRepository
│   └── supabase: SupabaseCourseRepository
├── JobRepository = JobRepositoryCompat (lazy singleton)
│   ├── fastApi: FastApiJobRepository
│   └── supabase: SupabaseJobRepository
├── CourseListBloc (factory — new per screen)
├── CourseDetailBloc (factory — new per screen)
├── JobListBloc (factory — new per screen)
└── JobDetailBloc (factory — new per screen)
```

---

## 12. Dependencies (pubspec.yaml)

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management |
| `equatable` | ^2.0.7 | Value equality for events/states |
| `go_router` | ^14.2.0 | Declarative navigation |
| `get_it` | ^7.7.0 | Dependency injection |
| `dio` | ^5.7.0 | HTTP client |
| `supabase_flutter` | ^2.8.0 | Supabase SDK |
| `flutter_secure_storage` | ^9.2.3 | Encrypted token storage |
| `flutter_dotenv` | ^5.2.1 | .env loading |
| `cached_network_image` | ^3.4.1 | Image caching |
| `shimmer` | ^3.0.0 | Loading skeletons |
| `flutter_svg` | ^2.0.17 | SVG rendering |
| `lottie` | ^3.3.1 | Lottie animations |
| `logger` | ^2.5.0 | Structured logging |
| `uuid` | ^4.5.1 | Request correlation IDs |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `bloc_test` | ^9.1.7 | BLoC testing |
| `mocktail` | ^1.0.4 | Mocking |

---

## 13. Implementation Checklist for Backend

### Phase 1 — MVP (required for app to function)

- [ ] `GET /api/v1/courses/` — paginated, filterable
- [ ] `GET /api/v1/courses/{id}` — single course
- [ ] `GET /api/v1/jobs/` — paginated, filterable
- [ ] `GET /api/v1/jobs/{id}` — single job
- [ ] `GET /api/v1/saved-items/jobs` — user's saved jobs (auth required)
- [ ] `POST /api/v1/saved-items/jobs` — save a job (body: `{"job_id": "..."}`)
- [ ] `DELETE /api/v1/saved-items/jobs/{jobId}` — unsave a job

### Phase 2 — Enhanced

- [ ] `GET /api/v1/jobs/applied` — user's applied jobs
- [ ] `GET /api/v1/courses/categories` — distinct categories
- [ ] Auth endpoints: `/api/v1/auth/login`, `/api/v1/auth/register`, `/api/v1/auth/refresh`

### Phase 3 — Search (behind `FF_SEARCH_FASTAPI`)

- [ ] `GET /api/v1/search/` — unified cross-module search

### Phase 4 — AI Copilot (behind `FF_AI_COPILOT`)

- [ ] `POST /api/v1/ai-copilot/events` — single event
- [ ] `POST /api/v1/ai-copilot/events/batch` — batch events
- [ ] `GET /api/v1/ai-copilot/recommendations` — personalized recommendations
- [ ] `GET /api/v1/ai-copilot/context` — user context / lead score

---

## 14. Critical Backend Requirements

1. **Return 401 for expired/missing tokens** — NOT 403. Only 401 triggers fallback in `fastapiPreferred` mode.
2. **Use 1-based pagination** — `page=1` is the first page.
3. **Always include `total` count** — the app needs it for "load more" and `hasMore` computation.
4. **Accept query parameters for GET endpoints** — not request bodies.
5. **Return errors in `{ "detail": "..." }` format** — the Dio error mapper extracts `detail` or `message`.
6. **Log `X-Request-Id` header** — UUID v4 sent on every request for tracing.
7. **Support CORS** — the app may hit the API from web builds.
8. **Return `application/json`** — for all responses including errors.
9. **Use snake_case** for all JSON field names — `created_at`, `page_size`, `is_remote`, etc.

---

## 15. Test Coverage

| Suite | Tests | Status |
|-------|-------|--------|
| CourseRepositoryCompat | 3 (routing + model parsing) | Passing |
| JobRepositoryCompat | 3 (routing + model parsing) | Passing |
| Course.fromJson | 3 (standard, alternate, empty) | Passing |
| Job.fromJson | 3 (standard, alternate, copyWith) | Passing |
| Widget test | 1 (app renders) | Passing |
| **Total** | **13** | **All passing** |

`flutter analyze`: **0 issues**

---

## 16. File Structure

```
lib/
├── main.dart                           # App entry point
├── core/
│   ├── config/app_config.dart          # Env vars, feature flags, backend mode
│   ├── constants/                      # AppImages, AppIcons, AppAnimations, AppStrings
│   ├── di/injection.dart               # GetIt registration
│   ├── error/
│   │   ├── app_exception.dart          # Sealed exception hierarchy
│   │   └── fallback_helper.dart        # shouldFallback() logic
│   ├── network/fastapi_client.dart     # Dio + 4 interceptors
│   ├── router/
│   │   ├── route_names.dart            # All route path constants
│   │   └── app_router.dart             # GoRouter config
│   ├── storage/token_storage.dart      # FlutterSecureStorage wrapper
│   └── theme/                          # AppColors, AppTypography, AppSpacing, AppTheme
├── blocs/
│   ├── course/
│   │   ├── course_list_bloc.dart       # List + pagination + filter
│   │   └── course_detail_bloc.dart     # Single course fetch
│   └── job/
│       ├── job_list_bloc.dart          # List + pagination + filter
│       └── job_detail_bloc.dart        # Single job + save toggle
├── models/
│   ├── course/course.dart              # Course + CourseFilter
│   ├── job/job.dart                    # Job + JobFilter + copyWith
│   ├── search/search_result.dart       # SearchResult + SearchQuery
│   ├── ai_copilot/ai_copilot.dart      # CopilotEvent, Recommendation, CopilotContext
│   └── common/paginated_response.dart  # Generic PaginatedResponse<T>
├── repositories/
│   ├── interfaces/                     # Abstract contracts
│   ├── supabase/                       # Supabase implementations
│   ├── fastapi/                        # FastAPI implementations
│   └── compat/                         # Fallback adapters
├── features/                           # Feature-based page organization
│   ├── home/
│   ├── courses/
│   ├── jobs/
│   ├── ai_copilot/
│   ├── profile/
│   ├── auth/
│   ├── splash/
│   ├── onboarding/
│   ├── notifications/
│   ├── settings/
│   └── shell/                          # MainShellPage (bottom nav)
└── shared/widgets/                     # AppCard, AppShimmer, EmptyState, ErrorView
```

---

*Generated: March 2, 2026 — Agentic Frontend v2 (BLoC + GetIt + GoRouter architecture)*
