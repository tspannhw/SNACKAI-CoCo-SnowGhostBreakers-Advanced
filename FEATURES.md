# SnowGhostBreakers Advanced - Feature Inventory

## Project Overview

SnowGhostBreakers is a full-stack paranormal investigation platform built on Snowflake.
It combines real-time data ingestion, AI-powered analysis, multimedia evidence processing,
and automated reporting into a unified ghost detection and investigation system.

**Stack:** Next.js 14 (App Router) + React 18 (Vite) + Snowflake + Cortex AI + Tailwind CSS

---

## Snowflake Database Objects

### Database: `GHOST_DETECTION` | Schema: `APP`

### Tables (50 total)

| Table | Rows | Purpose |
|-------|------|---------|
| GHOSTS | 10,074 | Master ghost registry with name, type, threat level, status |
| GHOST_SIGHTINGS | 30,047 | Sighting reports with location, description, paranormal activity level |
| GHOST_EVIDENCE | 305 | Evidence files (photos, audio, video) with metadata and processing status |
| SPIRIT_BOX_RECORDINGS | 0 | Audio recordings with AI transcription, speaker diarization, sentiment |
| INVESTIGATORS | 7 | Investigation team members |
| OSINT_THREAT_FEED | 50 | Open-source intelligence threat data |
| SENSOR_FUSION_DATA | 100 | Multi-sensor readings (EMF, temperature, audio) |
| MISSION_CONTROL_LOG | 60 | Mission activity log |
| GHOST_CONTAINMENT_PROTOCOLS | 40 | Containment procedures per ghost type |
| GHOST_MEDIA_ANALYSIS | 0 | AI-processed media results |
| REPORT_HISTORY | 2 | Email report delivery log with markdown/HTML content |
| + 39 additional tables | | Supporting data, embeddings, analysis results |

### Stages (8)

| Stage | Purpose |
|-------|---------|
| GHOST_AUDIO_STAGE | Audio file storage for Spirit Box recordings |
| GHOST_IMAGES_STAGE | Photo/image evidence storage |
| GHOST_DATA_STAGE | General data file staging |
| GHOST_APP_STAGE | Application deployment artifacts |
| GHOST_SEMANTIC_STAGE | Semantic model files |
| SEMANTIC_MODEL_STAGE | Cortex Analyst semantic models |
| STREAMLIT_STAGE | Streamlit app deployment |
| EVAL_CONFIG_STAGE | Evaluation configuration files |

### Cortex Search Services (3)

| Service | Status | Source | Embedding Model |
|---------|--------|--------|-----------------|
| GHOST_EVIDENCE_SEARCH | SUSPENDED | GHOST_EVIDENCE (305 rows) | snowflake-arctic-embed-m-v1.5 |
| GHOST_SIGHTINGS_SEARCH | SUSPENDED | GHOST_SIGHTINGS (123 rows indexed) | snowflake-arctic-embed-m-v1.5 |
| SPIRIT_BOX_SEARCH | ACTIVE (0 rows, DOWNSTREAM lag) | SPIRIT_BOX_RECORDINGS | snowflake-arctic-embed-m-v1.5 |

### Stored Procedures (30)

#### AI & Analysis
| Procedure | Signature | Description |
|-----------|-----------|-------------|
| AI_SITUATION_BRIEFING | () | Generates AI-powered situation overview using Cortex |
| AI_EVIDENCE_PROCESSOR | (P_EVIDENCE_ID) | Processes individual evidence with AI analysis |
| AI_THREAT_ASSESSMENT | (P_GHOST_ID) | Assesses threat level for a specific ghost |
| ANALYZE_SIGHTING_WITH_AI | (SIGHTING_ID_PARAM) | AI analysis of a sighting report |
| CLASSIFY_GHOST_TYPE | (DESCRIPTION_TEXT) | AI ghost classification from text description |
| ASK_GHOST_DATABASE | (QUESTION) | Natural language Q&A over the ghost database |
| CORRELATE_OSINT_ANOMALIES | () | Cross-reference OSINT with sighting data |
| UPDATE_GHOST_THREAT_LEVEL | (GHOST_ID_PARAM) | Recalculate and update ghost threat scores |

#### Agent Pipeline
| Procedure | Description |
|-----------|-------------|
| RUN_ALL_AGENTS | () | Orchestrates all agent procedures |
| AGENT_ANALYZE_NEW_SIGHTINGS | () | Processes unanalyzed sighting reports |
| AGENT_ASSIGN_INVESTIGATORS | () | Auto-assigns investigators to cases |
| AGENT_DAILY_SUMMARY | () | Generates daily activity summary |
| AGENT_GENERATE_PREDICTIONS | () | Predictive analytics for sighting hotspots |
| AGENT_MONITOR_THREATS | () | Continuous threat monitoring |

#### Reports & Email
| Procedure | Signature | Description |
|-----------|-----------|-------------|
| SEND_MARKDOWN_REPORT | (P_RECIPIENTS, P_REPORT_TYPE, P_INTEGRATION, P_SAVE_REPORT) | Generates Markdown report via Cortex AI, converts to styled HTML, sends via email, saves to REPORT_HISTORY |
| SEND_GHOST_REPORT | (P_REPORT_TYPE) | Convenience wrapper for SEND_MARKDOWN_REPORT using default recipient and integration |
| GENERATE_WEEKLY_REPORT | () | Scheduled weekly report generation |
| GENERATE_GHOST_REPORT | (GHOST_ID_PARAM) | Detailed report for a specific ghost |
| GENERATE_INVESTIGATION_SUMMARY | (INVESTIGATION_ID_PARAM) | Summary of an investigation case |

#### Evidence & Embeddings
| Procedure | Description |
|-----------|-------------|
| PROCESS_GHOST_EVIDENCE | (EVIDENCE_ID_PARAM) | Full evidence processing pipeline |
| BATCH_PROCESS_EVIDENCE | () | Bulk evidence processing |
| BATCH_GENERATE_EMBEDDINGS | (BATCH_SIZE) | Generate vector embeddings in batches |
| GENERATE_IMAGE_EMBEDDING | (EVIDENCE_ID, IMAGE_DESCRIPTION) | Single image embedding generation |
| FIND_SIMILAR_SIGHTINGS | (DESCRIPTION_TEXT, LIMIT_COUNT) | Vector similarity search on sightings |
| FIND_SIMILAR_IMAGES | (QUERY_TEXT, TOP_K) | Vector similarity search on images |
| FIND_SIMILAR_TO_IMAGE | (SOURCE_EMBEDDING_ID, TOP_K) | Image-to-image similarity |
| GET_IMAGE_CLUSTERS2 | (SIMILARITY_THRESHOLD) | Cluster images by visual similarity |
| SP_GET_IMAGE_CLUSTERS | (SIMILARITY_THRESHOLD) | Alternative image clustering |

#### Validation
| Procedure | Description |
|-----------|-------------|
| VALIDATE_SNOWGHOSTBREAKERS2 | () | 9-check health validation across all core tables |

### Notification Integrations (5)

| Integration | Type | Scope |
|-------------|------|-------|
| MY_EMAIL_INT | Email | tim.spann@snowflake.com only |
| EMAIL_INTEGRATION | Email | Unrestricted |
| FINOPS_EMAIL_INTEGRATION | Email | FinOps notifications |
| EMAIL_VALIDATOR_INT | Email | Validation emails |
| GHOST_SLACK_ALERTS | Webhook | Slack channel notifications |

---

## Next.js Backend (App Router API Routes)

### API Routes (10 endpoints)

| Route | Method | File | Description |
|-------|--------|------|-------------|
| /api/spirit-box | POST | `src/app/api/spirit-box/route.ts` | Upload audio, stage to Snowflake, transcribe with AI_TRANSCRIBE (speaker diarization), analyze with Cortex AI, extract entities, classify, detect anomalies |
| /api/spirit-box/[id] | GET | `src/app/api/spirit-box/[id]/route.ts` | Get recording detail with transcript, speaker segments, duration |
| /api/media | GET | `src/app/api/media/route.ts` | Unified media listing from SPIRIT_BOX_RECORDINGS + GHOST_EVIDENCE with aggregate stats |
| /api/media/upload | POST | `src/app/api/media/upload/route.ts` | Upload any media type (audio/photo/video) with AI_TRANSCRIBE for audio files |
| /api/search | POST | `src/app/api/search/route.ts` | Cortex Search with LIKE fallback when service is suspended |
| /api/chat | POST | `src/app/api/chat/route.ts` | RAG endpoint: Cortex Search retrieval + CORTEX.COMPLETE generation |
| /api/sightings | GET | `src/app/api/sightings/route.ts` | List ghost sightings with pagination |
| /api/sightings/[id] | GET | `src/app/api/sightings/[id]/route.ts` | Individual sighting detail |
| /api/stats | GET | `src/app/api/stats/route.ts` | Dashboard statistics |
| /api/upload | POST | `src/app/api/upload/route.ts` | General file upload endpoint |

### Key AI Feature: Spirit Box Pipeline

```
Audio File Upload
  --> PUT to @GHOST_AUDIO_STAGE
  --> AI_TRANSCRIBE (speaker diarization, timestamps)
  --> CORTEX.COMPLETE (analysis, classification)
  --> CORTEX.SENTIMENT (emotional analysis)
  --> CORTEX.SUMMARIZE (executive summary)
  --> CORTEX.EXTRACT_ANSWER (entity extraction)
  --> INSERT into SPIRIT_BOX_RECORDINGS
  --> Response with full analysis + speaker segments
```

---

## React Frontend (Vite)

### Tech Stack
- React 18 + TypeScript
- Vite 5 build tool
- react-router-dom 6 (client-side routing)
- TanStack Query 5 (data fetching/caching)
- Zustand 4.5 (state management)
- Tailwind CSS + shadcn-style CSS variables
- Radix UI (accessible primitives)
- Recharts (data visualization)
- Leaflet (map views)

### Pages (8)

| Page | File | Description |
|------|------|-------------|
| Dashboard | `pages/Dashboard.tsx` | Live stats from useMedia() hook, ghost/sighting/evidence counts |
| Capture | `pages/Capture.tsx` | Tabbed media capture (audio/photo/video) + upload form |
| Media Dashboard | `pages/MediaDashboard.tsx` | Grid view of all media with type filtering and live stats |
| Media Detail | `pages/MediaDetail.tsx` | Recording detail with speaker-segmented transcript display |
| Search | `pages/Search.tsx` | Search + Cortex Chat side-by-side layout |
| Sightings | `pages/Sightings.tsx` | Ghost sighting list with sorting/filtering |
| Map | `pages/Map.tsx` | Geographic sighting visualization with Leaflet |
| Analytics | `pages/Analytics.tsx` | Charts and trend analysis with Recharts |
| Settings | `pages/Settings.tsx` | Application configuration |

### Components (6)

| Component | File | Description |
|-----------|------|-------------|
| AudioRecorder | `components/media/AudioRecorder.tsx` | Browser mic recording with pause/resume via MediaRecorder API |
| PhotoCapture | `components/media/PhotoCapture.tsx` | Camera photo capture with retake |
| VideoRecorder | `components/media/VideoRecorder.tsx` | Video recording with live preview |
| MediaUploadForm | `components/media/MediaUploadForm.tsx` | Upload form with metadata (location, lat/lng, sighting ID, ghost ID, frequency, sweep rate) |
| CortexChat | `components/CortexChat.tsx` | Chat interface using RAG endpoint |

### State Management (Zustand Stores)

| Store | File | State |
|-------|------|-------|
| mediaStore | `stores/mediaStore.ts` | Audio/video recording state, photo capture |
| searchStore | `stores/searchStore.ts` | Search query, chat history |

### API Client (TanStack Query)

File: `lib/api.ts` - Hooks: `useMedia`, `useRecordings`, `useRecordingDetail`, `useSearch`, `useChat`, `useUploadMedia`

---

## Operations (manage.sh)

280-line Bash script with the following commands:

| Command | Description |
|---------|-------------|
| `manage.sh setup` | Full environment setup (dependencies, env vars, DB objects) |
| `manage.sh dev` | Start Next.js dev server |
| `manage.sh build` | Production build |
| `manage.sh validate` | Check 7 environment variables |
| `manage.sh db-init` | Initialize Snowflake tables, stages, services |
| `manage.sh snowflake-stop` | Suspend all warehouses, Cortex Search services, and tasks |
| `manage.sh help` | Show usage |

### `snowflake-stop` Command Detail

Generates and executes SQL to:
1. `ALTER WAREHOUSE IF EXISTS ... SUSPEND` for all warehouses
2. `ALTER CORTEX SEARCH SERVICE ... SET TARGET_LAG = 'DOWNSTREAM'` for all search services
3. `ALTER TASK IF EXISTS ... SUSPEND` for all scheduled tasks
4. Falls back to printing SQL if SnowSQL/Snowflake CLI unavailable

---

## Email Reporting System

### SEND_MARKDOWN_REPORT Stored Procedure

**Parameters:**
- `P_RECIPIENTS` (VARCHAR) - Email address(es)
- `P_REPORT_TYPE` (VARCHAR) - 'daily', 'weekly', or 'monthly'
- `P_INTEGRATION` (VARCHAR) - Notification integration name
- `P_SAVE_REPORT` (BOOLEAN) - Whether to persist to REPORT_HISTORY

**Pipeline:**
1. Query aggregate stats from GHOSTS, GHOST_SIGHTINGS, GHOST_EVIDENCE, SPIRIT_BOX_RECORDINGS, GHOST_MEDIA_ANALYSIS
2. Generate Markdown report via `CORTEX.COMPLETE('llama3.1-8b', prompt)` with stats context
3. Convert Markdown to styled HTML:
   - Headers via REGEXP_REPLACE (`#` -> `<h1>`, `##` -> `<h2>`, `###` -> `<h3>`)
   - Bold via iterative POSITION/SUBSTR loop (`**text**` -> `<b>text</b>`)
   - Bullets via REPLACE (`\n- ` -> `<li>`)
   - Paragraphs via REPLACE (`\n\n` -> `</p><p>`)
   - Wrapped in styled HTML template (dark theme, Snowflake blue accents)
4. Send via `SYSTEM$SEND_EMAIL(integration, recipients, subject, html, 'text/html')`
   - Nested BEGIN/EXCEPTION/END for error resilience
5. Save to REPORT_HISTORY with stats JSON (when P_SAVE_REPORT = TRUE)

### REPORT_HISTORY Schema

```
REPORT_ID VARCHAR (UUID)
REPORT_TYPE VARCHAR
RECIPIENTS VARCHAR
SUBJECT VARCHAR
MARKDOWN_CONTENT VARCHAR
HTML_CONTENT VARCHAR
INTEGRATION_USED VARCHAR
SENT_AT TIMESTAMP
GENERATED_BY VARCHAR (default: 'SEND_MARKDOWN_REPORT')
STATUS VARCHAR ('Sent' or 'Report Generated (Email Failed)')
ERROR_MESSAGE VARCHAR
REPORT_STATS VARIANT (JSON with ghost_count, sighting_count, etc.)
```

---

## AI Components

### Cortex AI Functions Used

#### 1. AI_TRANSCRIBE (Snowflake AI Audio)
- **Where:** `src/app/api/spirit-box/route.ts`, `src/app/api/media/upload/route.ts`
- **Usage:** `AI_TRANSCRIBE(TO_FILE('@GHOST_AUDIO_STAGE', filename), {'timestamp_granularity': 'speaker'})`
- **Purpose:** Transcribes uploaded audio with speaker diarization, timestamps, and audio duration
- **Output:** JSON with `text`, `audio_duration`, `segments[]` (each segment has speaker ID, start/end timestamps, and text)

#### 2. CORTEX.COMPLETE (LLM Generation)
- **Where:** Spirit Box route, chat route, SEND_MARKDOWN_REPORT SP, all 5 agent SPs, and 5+ analysis SPs
- **Models used:** `llama3.1-8b` (reports), `mistral-large2` (agents, threat assessment)
- **Purposes:** Audio analysis, RAG answer generation, report generation, threat assessments, situation briefings, ghost classification, natural language Q&A, investigator assignment, predictive analytics

#### 3. CORTEX.SENTIMENT
- **Where:** `src/app/api/spirit-box/route.ts`
- **Purpose:** Emotional/sentiment scoring of audio transcripts (-1.0 to +1.0 scale)

#### 4. CORTEX.SUMMARIZE
- **Where:** `src/app/api/spirit-box/route.ts`
- **Purpose:** Executive summary generation from transcripts and AI analysis

#### 5. CORTEX.EXTRACT_ANSWER
- **Where:** `src/app/api/spirit-box/route.ts`
- **Purpose:** Entity extraction from transcripts (ghost names, locations, phenomena, timestamps)

#### 6. Cortex Search (Vector/Semantic Search)
- **3 services** using `snowflake-arctic-embed-m-v1.5` embedding model
- Used for RAG retrieval in `/api/search` and `/api/chat` endpoints
- Fallback to SQL `LIKE` when services are suspended

### AI-Powered API Routes

| Route | AI Pipeline |
|-------|-------------|
| `POST /api/spirit-box` | AI_TRANSCRIBE -> CORTEX.COMPLETE -> CORTEX.SENTIMENT -> CORTEX.SUMMARIZE -> CORTEX.EXTRACT_ANSWER |
| `POST /api/media/upload` | AI_TRANSCRIBE (audio files only) |
| `POST /api/search` | Cortex Search Service (with LIKE fallback) |
| `POST /api/chat` | Cortex Search (retrieval) + CORTEX.COMPLETE (generation) = RAG |

---

## Autonomous Agent System

Five AI agents operate as stored procedures, each with a dedicated agent ID, writing to shared
`AGENT_ACTIONS` and `AGENT_COMMUNICATIONS` tables. All five are orchestrated sequentially
by `RUN_ALL_AGENTS()`.

### Agent Infrastructure Tables

| Table | Rows | Purpose |
|-------|------|---------|
| AGENT_ACTIONS | 1 | Action audit log: every agent decision is recorded with type, reasoning, risk level, confidence score, approval status |
| AGENT_COMMUNICATIONS | 1 | Inter-agent and agent-to-human message queue with priority and response tracking |
| INVESTIGATIONS | 15 | Investigation cases with status, priority, lead investigator assignment |
| GHOST_AI_ANALYSIS | 3 | Per-sighting AI analysis results (entities, sentiment, anomalies, recommendations) |
| INVESTIGATORS | 7 | Available investigators with specialization and active status |

### AGENT_ACTIONS Schema

```
ACTION_ID         VARCHAR(50)  PK  -- UUID prefixed with ACT_
AGENT_ID          VARCHAR(50)      -- Which agent (AGENT_001 through AGENT_005)
ACTION_TYPE       VARCHAR(100)     -- Alert, Analyze, Recommend, Communicate, Forecast
ACTION_DESCRIPTION VARCHAR        -- AI-generated content or action summary
TRIGGER_EVENT     VARCHAR(200)     -- What triggered the action
DECISION_REASONING VARCHAR        -- Why the agent took this action
ACTION_PARAMETERS VARIANT          -- Optional structured parameters
RISK_LEVEL        VARCHAR(50)      -- Critical, Medium, Low
REQUIRES_APPROVAL BOOLEAN          -- Whether human approval needed (default FALSE)
APPROVAL_STATUS   VARCHAR(50)      -- Auto-Approved, Pending
EXECUTED_DATE     TIMESTAMP_NTZ    -- When the action was taken
EXECUTION_RESULT  VARIANT          -- Optional structured result
CONFIDENCE_SCORE  FLOAT            -- Agent confidence (0.0 to 1.0)
CREATED_DATE      TIMESTAMP_NTZ    -- Row creation time
```

### AGENT_COMMUNICATIONS Schema

```
COMMUNICATION_ID  VARCHAR(50)  PK  -- UUID prefixed with COMM_
FROM_AGENT_ID     VARCHAR(50)      -- Sending agent
TO_AGENT_ID       VARCHAR(50)      -- Receiving agent (nullable)
TO_HUMAN_USER     VARCHAR(200)     -- Human recipient (nullable)
MESSAGE_TYPE      VARCHAR(100)     -- Alert, Update, Recommendation
MESSAGE_CONTENT   VARCHAR          -- AI-generated message body
PRIORITY          VARCHAR(50)      -- Urgent, Medium, Low
REQUIRES_RESPONSE BOOLEAN          -- Whether reply expected (default FALSE)
RESPONSE_CONTENT  VARCHAR          -- Reply content (nullable)
RESPONSE_DATE     TIMESTAMP_NTZ    -- When reply was received
CREATED_DATE      TIMESTAMP_NTZ    -- Row creation time
```

### Agent 1: AGENT_MONITOR_THREATS (AGENT_001)

**Purpose:** Autonomous threat detection. Scans for extreme-threat ghosts with sightings
in the last 24 hours. When found, generates AI-powered investigator alerts.

**Execution Flow:**
```
1. Generate unique ACTION_ID (ACT_ + UUID)
2. COUNT extreme-threat ghosts with sightings in last 24h
   (GHOSTS.threat_level='Extreme' AND status='Active'
    AND GHOST_SIGHTINGS.sighting_datetime >= NOW - 24h)
3. If count > 0:
   a. LISTAGG ghost names + sighting counts
      -> "Banshee (4 sightings); Poltergeist (2 sightings)"
   b. CORTEX.COMPLETE('mistral-large2', alert_prompt)
      -> AI-generated alert with recommended actions
   c. INSERT into AGENT_ACTIONS
      (type=Alert, risk=Critical, auto-approved, confidence=0.95)
   d. INSERT into AGENT_COMMUNICATIONS
      (type=Alert, priority=Urgent, requires_response=FALSE)
   e. RETURN "ALERT: N extreme threats detected. Alert sent."
4. If count = 0:
   RETURN "No immediate threats detected."
```

**Tables Read:** GHOSTS (ghost_id, ghost_name, threat_level, status), GHOST_SIGHTINGS (ghost_id, sighting_id, sighting_datetime)
**Tables Written:** AGENT_ACTIONS, AGENT_COMMUNICATIONS
**AI Model:** mistral-large2
**Risk Level:** Critical | **Confidence:** 0.95 | **Approval:** Auto-Approved

**Detection Criteria:**
- Ghost `THREAT_LEVEL = 'Extreme'`
- Ghost `STATUS = 'Active'`
- At least one sighting within last 24 hours

**Current State:** 2,546 total extreme ghosts, 1,290 active, 0 with sightings in last 24h (most recent: 2026-03-31, 15 days ago). Returns "No immediate threats detected."

### Agent 2: AGENT_ANALYZE_NEW_SIGHTINGS (AGENT_002)

**Purpose:** Batch-processes unanalyzed sighting reports from the last 7 days by calling
`ANALYZE_SIGHTING_WITH_AI()` for each one.

**Execution Flow:**
```
1. COUNT DISTINCT unanalyzed sightings from last 7 days
   (LEFT JOIN GHOST_AI_ANALYSIS where analysis_id IS NULL)
2. If count > 0:
   a. FOR each sighting (LIMIT 10):
      CALL ANALYZE_SIGHTING_WITH_AI(sighting_id)
   b. INSERT into AGENT_ACTIONS
      (type=Analyze, risk=Low, auto-approved, confidence=0.88)
   c. RETURN "Analyzed N sightings."
3. If count = 0:
   RETURN "No new sightings to analyze."
```

**Tables Read:** GHOST_SIGHTINGS, GHOST_AI_ANALYSIS (LEFT JOIN to find unprocessed)
**Tables Written:** AGENT_ACTIONS (+ GHOST_AI_ANALYSIS via ANALYZE_SIGHTING_WITH_AI)
**AI Model:** mistral-large2 (via sub-procedure)
**Risk Level:** Low | **Confidence:** 0.88 | **Approval:** Auto-Approved
**Batch Size:** 10 sightings per execution

### Agent 3: AGENT_ASSIGN_INVESTIGATORS (AGENT_003)

**Purpose:** Finds open investigation cases without an assigned lead investigator and uses
AI to recommend optimal investigator-case matchings based on skills and workload.

**Execution Flow:**
```
1. COUNT open cases with no lead_investigator_id
2. If count > 0:
   a. LISTAGG unassigned cases with priority
      -> "Haunted Manor (High); Cemetery Case (Medium)"
   b. LISTAGG available investigators with specialization
      -> "Dr. Smith (EVP Analysis); Jane Doe (Visual Evidence)"
   c. CORTEX.COMPLETE('mistral-large2', assignment_prompt)
      -> AI-recommended investigator assignments
   d. INSERT into AGENT_ACTIONS
      (type=Recommend, risk=Low, requires_approval=TRUE,
       approval_status=Pending, confidence=0.82)
   e. RETURN "Generated assignment recommendations for N cases."
3. If count = 0:
   RETURN "All cases have assigned investigators."
```

**Tables Read:** INVESTIGATIONS (case_name, priority, lead_investigator_id, status), INVESTIGATORS (investigator_name, specialization, active_status)
**Tables Written:** AGENT_ACTIONS
**AI Model:** mistral-large2
**Risk Level:** Low | **Confidence:** 0.82 | **Approval:** Pending (requires human approval)

**Note:** This is the only agent that sets `requires_approval = TRUE` and `approval_status = 'Pending'`,
meaning its recommendations need human review before being acted upon.

### Agent 4: AGENT_DAILY_SUMMARY (AGENT_004)

**Purpose:** Generates a comprehensive daily operations summary by collecting metrics across
all tables and using AI to produce a structured report.

**Execution Flow:**
```
1. Collect daily metrics:
   - COUNT sightings today (GHOST_SIGHTINGS where date = today)
   - COUNT new ghosts today (GHOSTS where first_detected_date = today)
   - COUNT active investigations (INVESTIGATIONS where status IN ('Open','In_Progress'))
   - COUNT extreme threats (GHOSTS where threat_level='Extreme' AND status='Active')
   - COUNT cases closed today (INVESTIGATIONS where end_date = today)
   - TOP location today (GHOST_SIGHTINGS GROUP BY location_name, top 1)
2. CORTEX.COMPLETE('mistral-large2', summary_prompt)
   -> Structured report: Executive Summary, Key Metrics,
      Notable Incidents, Threat Assessment, Recommendations
3. INSERT into AGENT_COMMUNICATIONS
   (type=Update, priority=Medium, from AGENT_004)
4. INSERT into AGENT_ACTIONS
   (type=Communicate, risk=Low, auto-approved, confidence=0.92)
5. RETURN "Daily summary report generated and sent."
```

**Tables Read:** GHOST_SIGHTINGS, GHOSTS, INVESTIGATIONS
**Tables Written:** AGENT_COMMUNICATIONS, AGENT_ACTIONS
**AI Model:** mistral-large2
**Risk Level:** Low | **Confidence:** 0.92 | **Approval:** Auto-Approved
**Always executes** (no conditional skip; always generates a summary even with zero activity)

### Agent 5: AGENT_GENERATE_PREDICTIONS (AGENT_005)

**Purpose:** Predictive analytics engine. Analyzes the last 7 days of sighting patterns to
forecast future activity hotspots, active ghosts, and risk levels.

**Execution Flow:**
```
1. COUNT sightings from last 7 days
2. LISTAGG top 3 most active locations (by sighting count)
3. LISTAGG top 3 most active ghosts (JOIN GHOSTS + GHOST_SIGHTINGS)
4. CORTEX.COMPLETE('mistral-large2', prediction_prompt)
   -> Predictions: Where activity will occur, which ghosts most active,
      7-day risk assessment, recommended monitoring locations
5. INSERT into AGENT_ACTIONS
   (type=Forecast, risk=Low, auto-approved, confidence=0.75)
6. RETURN "Prediction report generated successfully."
```

**Tables Read:** GHOST_SIGHTINGS, GHOSTS
**Tables Written:** AGENT_ACTIONS
**AI Model:** mistral-large2
**Risk Level:** Low | **Confidence:** 0.75 | **Approval:** Auto-Approved

**Note:** Has the lowest confidence score (0.75) of all agents, reflecting the inherent
uncertainty in predictive forecasting.

### RUN_ALL_AGENTS Orchestrator

**Purpose:** Executes all agents sequentially and returns a consolidated JSON result.

**Execution Order:**
```
1. CALL AGENT_MONITOR_THREATS()     -> threat_result
2. CALL AGENT_ANALYZE_NEW_SIGHTINGS() -> sighting_result
3. CALL AGENT_ASSIGN_INVESTIGATORS()  -> assignment_result
4. CALL AGENT_GENERATE_PREDICTIONS()  -> prediction_result
5. RETURN JSON: {
     "threat_monitoring": threat_result,
     "sighting_analysis": sighting_result,
     "investigator_assignment": assignment_result,
     "predictions": prediction_result
   }
```

**Note:** `AGENT_DAILY_SUMMARY` is not called by `RUN_ALL_AGENTS`. It runs independently,
intended for scheduled daily execution.

### Agent Summary Matrix

| Agent | ID | Action Type | Risk | Confidence | Approval | Condition |
|-------|----|-------------|------|------------|----------|-----------|
| MONITOR_THREATS | AGENT_001 | Alert | Critical | 0.95 | Auto | Extreme threats in 24h |
| ANALYZE_SIGHTINGS | AGENT_002 | Analyze | Low | 0.88 | Auto | Unanalyzed sightings exist |
| ASSIGN_INVESTIGATORS | AGENT_003 | Recommend | Low | 0.82 | **Pending** | Unassigned open cases |
| DAILY_SUMMARY | AGENT_004 | Communicate | Low | 0.92 | Auto | Always runs |
| GENERATE_PREDICTIONS | AGENT_005 | Forecast | Low | 0.75 | Auto | Always runs |

---

## Validation Results

### Test Matrix (all passing)

| Test | Status | Details |
|------|--------|---------|
| Next.js TypeScript compilation | PASS | Zero errors |
| React TypeScript compilation | PASS | Zero errors |
| React Vite production build | PASS | 1881 modules, 1.83s |
| Snowflake objects inventory | PASS | 50 tables, 8 stages, 30 SPs, 3 search services |
| VALIDATE_SNOWGHOSTBREAKERS2 | PASS | 9/9 checks pass |
| SEND_MARKDOWN_REPORT execution | PASS | 2 reports in REPORT_HISTORY (1 sent, 1 email-failed but report saved) |
| manage.sh snowflake-stop | PASS | Correct SQL generated |
| manage.sh validate | PASS | 7/7 env vars OK |

### Data Counts Verified

| Object | Count |
|--------|-------|
| GHOSTS | 10,074 |
| GHOST_SIGHTINGS | 30,047 |
| GHOST_EVIDENCE | 305 |
| SPIRIT_BOX_RECORDINGS | 0 (ready for ingestion) |
| REPORT_HISTORY | 2 |
| INVESTIGATORS | 7 |
| OSINT_THREAT_FEED | 50 |
| SENSOR_FUSION_DATA | 100 |
| MISSION_CONTROL_LOG | 60 |
| GHOST_CONTAINMENT_PROTOCOLS | 40 |
