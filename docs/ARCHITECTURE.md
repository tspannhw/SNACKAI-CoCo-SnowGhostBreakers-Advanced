# SnowGhost Breakers - Advanced Architecture

## System Overview

SnowGhost Breakers Advanced is a comprehensive paranormal investigation platform built on Snowflake, featuring a modern React frontend, Snowflake-managed MCP server, native Semantic Views, and full Cortex AI integration.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   React SPA     │    │   Streamlit     │    │  External AI    │         │
│  │  (TypeScript)   │    │   (Optional)    │    │    Agents       │         │
│  └────────┬────────┘    └────────┬────────┘    └────────┬────────┘         │
│           │                      │                      │                   │
└───────────┼──────────────────────┼──────────────────────┼───────────────────┘
            │                      │                      │
            ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              API LAYER                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐        │
│  │                    MCP Server (SPCS)                             │        │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │        │
│  │  │   Tools      │  │  Resources   │  │   Prompts    │           │        │
│  │  └──────────────┘  └──────────────┘  └──────────────┘           │        │
│  └─────────────────────────────────────────────────────────────────┘        │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────┐        │
│  │                    Cortex Agent                                  │        │
│  │  - Natural Language Interface                                    │        │
│  │  - Tool Orchestration                                            │        │
│  │  - Semantic Model Integration                                    │        │
│  └─────────────────────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SNOWFLAKE LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────┐    ┌─────────────────────────┐                 │
│  │    Cortex AI Services   │    │    Cortex Search        │                 │
│  │  ┌─────────────────┐    │    │  ┌─────────────────┐    │                 │
│  │  │ Complete (LLM)  │    │    │  │ Ghost Search    │    │                 │
│  │  │ Sentiment       │    │    │  │ Sighting Search │    │                 │
│  │  │ Summarize       │    │    │  └─────────────────┘    │                 │
│  │  │ Embed           │    │    └─────────────────────────┘                 │
│  │  │ Extract         │    │                                                │
│  │  │ Classify        │    │    ┌─────────────────────────┐                 │
│  │  └─────────────────┘    │    │    Semantic Views       │                 │
│  └─────────────────────────┘    │  ┌─────────────────┐    │                 │
│                                  │  │ Ghost Analytics │    │                 │
│  ┌─────────────────────────┐    │  │ Sighting Stats  │    │                 │
│  │    Stored Procedures    │    │  │ Investigation   │    │                 │
│  │  ┌─────────────────┐    │    │  └─────────────────┘    │                 │
│  │  │ Register Ghost  │    │    └─────────────────────────┘                 │
│  │  │ Record Sighting │    │                                                │
│  │  │ Generate Report │    │    ┌─────────────────────────┐                 │
│  │  │ Analyze Threat  │    │    │    Scheduled Tasks      │                 │
│  │  └─────────────────┘    │    │  - Daily Summaries      │                 │
│  └─────────────────────────┘    │  - Threat Analysis      │                 │
│                                  │  - Embedding Generation │                 │
│                                  └─────────────────────────┘                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DATA LAYER                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │
│  │   APP Schema     │  │ ANALYTICS Schema │  │    AI Schema     │           │
│  │  ┌────────────┐  │  │  ┌────────────┐  │  │  ┌────────────┐  │           │
│  │  │  GHOSTS    │  │  │  │ VW_GHOST_  │  │  │  │AI_ANALYSIS │  │           │
│  │  │  SIGHTINGS │  │  │  │ ACTIVITY   │  │  │  │_RESULTS    │  │           │
│  │  │  EVIDENCE  │  │  │  │ VW_HOTSPOTS│  │  │  │SEARCH_SVC  │  │           │
│  │  │  INVEST.   │  │  │  │ VW_TIMELINE│  │  │  │EMBEDDINGS  │  │           │
│  │  │  VOCAB.    │  │  │  └────────────┘  │  │  └────────────┘  │           │
│  │  └────────────┘  │  └──────────────────┘  └──────────────────┘           │
│  └──────────────────┘                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. React Frontend

**Technology Stack:**
- React 18 with TypeScript
- Vite for build tooling
- TanStack Query for data fetching
- Zustand for state management
- Tailwind CSS + shadcn/ui for styling
- Recharts for visualizations
- Leaflet for maps

**Key Features:**
- Real-time dashboard with live metrics
- Interactive ghost registry with filtering/sorting
- Sighting map with clustering
- AI-powered chat interface
- Evidence gallery with similarity search
- Investigation case management

### 2. Snowflake MCP Server (SPCS)

**Deployment:**
- Containerized FastAPI application
- Deployed to Snowpark Container Services
- Auto-scaling compute pool (1-2 nodes)
- HTTP endpoint for MCP protocol

**MCP Tools:**
| Tool | Description |
|------|-------------|
| `query_ghosts` | Query ghost registry with filters |
| `analyze_sighting` | AI analysis of a sighting |
| `generate_report` | Generate comprehensive ghost report |
| `classify_ghost` | Classify ghost type from description |
| `search_vocabulary` | Search business vocabulary |
| `find_similar` | Find similar entities/sightings |
| `ask_database` | Natural language database queries |
| `run_agent` | Execute AI agent actions |

**MCP Resources:**
| Resource | URI |
|----------|-----|
| Ghost Registry | `snowflake://ghost-detection/ghosts` |
| Sightings | `snowflake://ghost-detection/sightings` |
| Evidence | `snowflake://ghost-detection/evidence` |
| Investigations | `snowflake://ghost-detection/investigations` |
| Analytics | `snowflake://ghost-detection/analytics/*` |

### 3. Native Semantic Views

**GHOST_ANALYTICS_SV:**
```
TABLES:
├── ghosts (PK: ghost_id)
├── sightings (PK: sighting_id, FK: ghost_id)
├── evidence (PK: evidence_id, FK: ghost_id)
└── investigations (PK: investigation_id)

DIMENSIONS:
├── ghost_type
├── threat_level
├── status
├── location_name
├── evidence_type
└── investigation_status

MEASURES:
├── total_ghosts
├── total_sightings
├── avg_activity_level
├── avg_emf_reading
└── total_evidence

METRICS:
├── Threat Distribution
├── Active High Threats
└── Investigation Success Rate
```

### 4. Cortex AI Integration

**Functions Used:**
| Function | Purpose |
|----------|---------|
| `CORTEX.COMPLETE` | LLM for reports, analysis, classification |
| `CORTEX.SENTIMENT` | Fear level analysis from descriptions |
| `CORTEX.SUMMARIZE` | Investigation and report summarization |
| `CORTEX.EMBED_TEXT_1024` | Vector embeddings for similarity search |
| `VECTOR_COSINE_SIMILARITY` | Finding similar entities |

**Cortex Search Services:**
- `GHOST_SEARCH_SERVICE`: Full-text search over ghost data
- `SIGHTING_SEARCH_SERVICE`: Search sighting descriptions

**Cortex Agent:**
- Model: claude-3-5-sonnet
- Tools: SQL query, Cortex Search, Cortex Analyst
- Purpose: Natural language investigation assistant

## Data Flow

### Sighting Recording Flow
```
User Input → React App → MCP Server → RECORD_SIGHTING Procedure
                                            │
                                            ├── Insert into GHOST_SIGHTINGS
                                            ├── AI Sentiment Analysis
                                            ├── Update GHOSTS.last_sighting
                                            └── Return sighting_id + analysis
```

### AI Analysis Flow
```
Ghost Report Request → MCP Server → GENERATE_GHOST_REPORT
                                            │
                                            ├── Fetch ghost data
                                            ├── Aggregate sighting count
                                            ├── Aggregate evidence count
                                            ├── CORTEX.COMPLETE (LLM)
                                            ├── Store in AI_ANALYSIS_RESULTS
                                            └── Return formatted report
```

### Similarity Search Flow
```
Description Input → FIND_SIMILAR_SIGHTINGS
                          │
                          ├── CORTEX.EMBED_TEXT_1024 (input)
                          ├── VECTOR_COSINE_SIMILARITY (all sightings)
                          └── Return top N matches with scores
```

## Security Model

### Roles
| Role | Permissions |
|------|-------------|
| `GHOST_ADMIN` | Full access, create investigations, verify sightings |
| `GHOSTBUSTER` | Read all, create ghosts/sightings, run AI analysis |
| `GHOST_ANALYST` | Read all, run analytics queries |

### Data Protection
- Row-level security on sensitive witness information
- Audit logging for all data modifications
- API rate limiting via API_USAGE_LOG

## Scheduled Automation

| Task | Schedule | Purpose |
|------|----------|---------|
| Daily Activity Summary | 8 AM | Generate daily report |
| Threat Assessment | 6 AM | Update threat levels |
| Process Unverified | Hourly | Analyze new sightings |
| Weekly Hotspot Analysis | Monday 9 AM | Geographic trends |
| Monthly Analytics | 1st of month | Comprehensive report |
| Embedding Generation | Every 15 min | Generate vectors for search |

## Performance Considerations

### Warehouse Sizing
- **GHOST_DETECTION_WH (X-SMALL)**: Default for most operations
- Auto-suspend after 60 seconds
- Auto-resume on query

### Optimization Strategies
- Cortex Search services with 1-hour TARGET_LAG
- Batch embedding generation (100 records per run)
- Materialized analytics views where needed
- Connection pooling in MCP server

## Monitoring

### Key Metrics
- Active ghost count
- Daily sighting rate
- AI analysis latency
- MCP server response times
- Task execution success rate

### Observability
```sql
-- Check task history
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME LIKE '%GHOST%'
ORDER BY SCHEDULED_TIME DESC;

-- Monitor AI usage
SELECT analysis_type, COUNT(*), AVG(latency_ms)
FROM AI_ANALYSIS_RESULTS
WHERE created_at >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY analysis_type;
```
