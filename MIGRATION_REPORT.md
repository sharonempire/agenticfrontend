# Migration Report: FastAPI Backend Integration

## Mapped Endpoints (FastAPI → App Model)

| Backend Route | HTTP | Repository Method | App Model |
|---|---|---|---|
| `/api/v1/courses/` | GET | `CourseRepository.getCourses()` | `PaginatedResponse<Course>` |
| `/api/v1/courses/{id}` | GET | `CourseRepository.getCourseById()` | `Course` |
| `/api/v1/courses/search` | GET | `CourseRepository.searchCourses()` | `PaginatedResponse<Course>` |
| `/api/v1/courses/eligible` | GET | `CourseRepository.getEligibleCourses()` | `PaginatedResponse<Course>` |
| `/api/v1/jobs/` | GET | `JobRepository.getJobs()` | `PaginatedResponse<Job>` |
| `/api/v1/jobs/{id}` | GET | `JobRepository.getJobById()` | `Job` |
| `/api/v1/jobs/applied` | GET | `JobRepository.getAppliedJobs()` | `List<Job>` |
| `/api/v1/saved-items/jobs` | GET | `JobRepository.getSavedJobs()` | `List<Job>` |
| `/api/v1/saved-items/jobs` | POST | `JobRepository.saveJob()` | `void` |
| `/api/v1/saved-items/jobs/{id}` | DELETE | `JobRepository.unsaveJob()` | `void` |
| `/api/v1/search/` | GET | `SearchRepository.search()` | `PaginatedResponse<SearchResult>` |
| `/api/v1/ai-copilot/events` | POST | `AiCopilotRepository.publishEvent()` | `void` |
| `/api/v1/ai-copilot/events/batch` | POST | `AiCopilotRepository.publishEventsBatch()` | `void` |
| `/api/v1/ai-copilot/recommendations` | GET | `AiCopilotRepository.getRecommendations()` | `List<Recommendation>` |
| `/api/v1/ai-copilot/context` | GET | `AiCopilotRepository.getContext()` | `CopilotContext` |
| `/api/v1/ai-copilot/next-action` | GET | `AiCopilotRepository.getNextAction()` | `String?` |
| `/api/v1/ai-copilot/lead-score` | GET | `AiCopilotRepository.getLeadScore()` | `double?` |
| `/api/v1/ai-copilot/email-draft` | POST | `AiCopilotRepository.generateEmailDraft()` | `EmailDraft` |

## Fallback Endpoints (Supabase only — no FastAPI equivalent)

| Feature | Supabase Table/Query | Notes |
|---|---|---|
| Course categories | `SELECT DISTINCT category FROM courses` | Backend may add `/courses/categories` later |
| Course levels | `SELECT DISTINCT level FROM courses` | Backend may add `/courses/levels` later |
| Notifications | Supabase realtime / table | No backend endpoint confirmed |
| Chat/messaging | Supabase realtime | No backend endpoint confirmed |
| Resume/profile storage | Supabase Storage | No backend endpoint confirmed |
| Payments | Supabase + Stripe | No backend endpoint confirmed |
| Guest mode data | Supabase anon queries | No backend endpoint confirmed |
| Onboarding flow | Supabase tables | No backend endpoint confirmed |

## Missing Backend Endpoints (TODO)

| Feature | Expected Route | Status |
|---|---|---|
| Course categories list | `GET /api/v1/courses/categories` | Not confirmed |
| Course levels list | `GET /api/v1/courses/levels` | Not confirmed |
| Course approvals | `GET /api/v1/courses/approvals` | Mentioned but not mapped |
| Leads CRUD | `GET/POST /api/v1/leads/*` | Confirmed but not consumed by app yet |
| Auth login | `POST /api/v1/auth/login` | Confirmed; student auth stays on Supabase |
| Auth refresh | `POST /api/v1/auth/refresh` | Confirmed; not wired (Supabase handles) |
| Auth profile | `GET /api/v1/auth/profile` | Confirmed; model ready, not wired to UI |
| Auth change password | `POST /api/v1/auth/change_password` | Confirmed; not wired |
| Auth OTP | `POST /api/v1/auth/otp` | Confirmed; not wired |
| WebSocket `/ws` | WS upgrade | Phase 6; not implemented yet |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| FastAPI response schema mismatch | Parse failures, empty data | `ParseException` triggers fallback; resilient `fromJson` with null-safe defaults |
| Backend downtime | All FastAPI calls fail | `fastapiPreferred` mode auto-falls back to Supabase |
| Token mismatch (Supabase vs FastAPI JWT) | 401 on FastAPI calls | Separate `TokenStorage`; 401 triggers Supabase fallback |
| Pagination format differences | Wrong page counts | `_parsePaginatedX` methods handle `items`, `results`, and `data` envelope variants |
| Feature flag misconfiguration | Wrong backend used | Flags default to `false` (Supabase); `.env.example` ships safe defaults |
| Offline/connectivity loss | Network exceptions | Retry interceptor (2 retries + backoff); AI events queue locally |
| Secret leakage | Credentials in git | `.env` in `.gitignore`; `.env.example` has placeholders only |
