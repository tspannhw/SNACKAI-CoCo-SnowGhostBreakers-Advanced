# SnowGhost Breakers - Deployment Guide

## Prerequisites

### Snowflake Requirements
- Snowflake account with **Enterprise Edition** or higher (for Cortex AI)
- Cortex AI enabled in your region
- Snowpark Container Services access (for MCP server)
- Appropriate credits for AI operations

### Local Development Requirements
- Node.js 18+ and npm/pnpm
- Python 3.11+
- Docker (for MCP server development)
- Git

### Required Permissions
Your Snowflake user needs:
```sql
-- Minimum required grants
GRANT CREATE DATABASE ON ACCOUNT TO ROLE your_role;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE your_role;
GRANT CREATE ROLE ON ACCOUNT TO ROLE your_role;
GRANT CREATE COMPUTE POOL ON ACCOUNT TO ROLE your_role;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE your_role;
```

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourorg/snowghostbreakers-advanced.git
cd snowghostbreakers-advanced
```

### 2. Run Setup Scripts in Snowflake

Execute the SQL scripts in order:

```sql
-- Connect to Snowflake (Snowsight, SnowSQL, or Cortex Code)

-- Step 1: Database Setup
!source snowflake/sql/01_setup/01_database_setup.sql

-- Step 2: Create Tables
!source snowflake/sql/02_tables/01_core_tables.sql
!source snowflake/sql/02_tables/02_vocabulary_tables.sql
!source snowflake/sql/02_tables/03_audit_tables.sql

-- Step 3: Load Sample Data
!source snowflake/sql/03_sample_data/01_ghost_data.sql
!source snowflake/sql/03_sample_data/02_sighting_data.sql
!source snowflake/sql/03_sample_data/03_evidence_data.sql
!source snowflake/sql/03_sample_data/04_investigation_data.sql
!source snowflake/sql/03_sample_data/05_vocabulary_data.sql
!source snowflake/sql/03_sample_data/06_taxonomy_data.sql

-- Step 4: Create Semantic Views
!source snowflake/sql/04_semantic_views/01_ghost_analytics_semantic_view.sql
!source snowflake/sql/04_semantic_views/02_sighting_analytics_semantic_view.sql

-- Step 5: Create Cortex Search Services
!source snowflake/sql/05_cortex_search/01_search_service.sql

-- Step 6: Create Cortex Agent
!source snowflake/sql/06_cortex_agent/01_agent_definition.sql
!source snowflake/sql/06_cortex_agent/02_agent_tools.sql

-- Step 7: Create Stored Procedures
!source snowflake/sql/07_stored_procedures/01_core_procedures.sql

-- Step 8: Create Scheduled Tasks
!source snowflake/sql/08_tasks/01_scheduled_tasks.sql
```

### 3. Verify Installation

```sql
USE DATABASE GHOST_DETECTION;

-- Check tables
SHOW TABLES IN SCHEMA APP;

-- Check views
SHOW VIEWS IN SCHEMA ANALYTICS;

-- Check procedures
SHOW PROCEDURES IN SCHEMA APP;

-- Check tasks
SHOW TASKS IN SCHEMA APP;

-- Test a query
SELECT * FROM APP.GHOSTS LIMIT 5;

-- Test AI function
SELECT SNOWFLAKE.CORTEX.SENTIMENT('I saw a terrifying ghost!');
```

## Detailed Deployment Steps

### Phase 1: Snowflake Infrastructure

#### 1.1 Create Database and Schemas

```sql
-- Create main database
CREATE DATABASE IF NOT EXISTS GHOST_DETECTION
    COMMENT = 'SnowGhost Breakers paranormal investigation database';

-- Create schemas
CREATE SCHEMA IF NOT EXISTS GHOST_DETECTION.APP
    COMMENT = 'Core application tables and procedures';
    
CREATE SCHEMA IF NOT EXISTS GHOST_DETECTION.ANALYTICS
    COMMENT = 'Analytics views and semantic models';
    
CREATE SCHEMA IF NOT EXISTS GHOST_DETECTION.AI
    COMMENT = 'AI services, search, and agent configurations';
    
CREATE SCHEMA IF NOT EXISTS GHOST_DETECTION.MCP
    COMMENT = 'MCP server resources and configurations';
```

#### 1.2 Create Warehouse

```sql
CREATE WAREHOUSE IF NOT EXISTS GHOST_DETECTION_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for ghost detection workloads';
```

#### 1.3 Create Roles

```sql
-- Admin role
CREATE ROLE IF NOT EXISTS GHOST_ADMIN;
GRANT ALL ON DATABASE GHOST_DETECTION TO ROLE GHOST_ADMIN;

-- Investigator role
CREATE ROLE IF NOT EXISTS GHOSTBUSTER;
GRANT USAGE ON DATABASE GHOST_DETECTION TO ROLE GHOSTBUSTER;
GRANT USAGE ON ALL SCHEMAS IN DATABASE GHOST_DETECTION TO ROLE GHOSTBUSTER;
GRANT SELECT ON ALL TABLES IN DATABASE GHOST_DETECTION TO ROLE GHOSTBUSTER;

-- Analyst role  
CREATE ROLE IF NOT EXISTS GHOST_ANALYST;
GRANT USAGE ON DATABASE GHOST_DETECTION TO ROLE GHOST_ANALYST;
GRANT USAGE ON SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ANALYST;
GRANT SELECT ON ALL VIEWS IN SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ANALYST;
```

### Phase 2: Deploy MCP Server to SPCS

#### 2.1 Build Docker Image

```bash
cd snowflake/mcp_server

# Build the image
docker build -t ghost-mcp-server:latest .

# Tag for Snowflake registry
docker tag ghost-mcp-server:latest \
    <account>.registry.snowflakecomputing.com/ghost_detection/app/images/ghost_mcp_server:latest
```

#### 2.2 Push to Snowflake Registry

```bash
# Login to Snowflake registry
docker login <account>.registry.snowflakecomputing.com

# Push the image
docker push <account>.registry.snowflakecomputing.com/ghost_detection/app/images/ghost_mcp_server:latest
```

#### 2.3 Create SPCS Resources

```sql
-- Create image repository
CREATE IMAGE REPOSITORY IF NOT EXISTS GHOST_DETECTION.APP.IMAGES;

-- Create compute pool
CREATE COMPUTE POOL IF NOT EXISTS GHOST_MCP_POOL
    MIN_NODES = 1
    MAX_NODES = 2
    INSTANCE_FAMILY = CPU_X64_XS;

-- Wait for pool to be ready
DESCRIBE COMPUTE POOL GHOST_MCP_POOL;

-- Create the service
CREATE SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE
    IN COMPUTE POOL GHOST_MCP_POOL
    FROM SPECIFICATION $$
    spec:
      container:
        - name: ghost-mcp-server
          image: /ghost_detection/app/images/ghost_mcp_server:latest
          env:
            SNOWFLAKE_DATABASE: GHOST_DETECTION
            SNOWFLAKE_SCHEMA: APP
          readinessProbe:
            port: 8000
            path: /health
          resources:
            requests:
              memory: 1Gi
              cpu: 0.5
            limits:
              memory: 2Gi
              cpu: 1
      endpoint:
        - name: mcp-endpoint
          port: 8000
          public: true
    $$;

-- Get the service URL
SHOW ENDPOINTS IN SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE;
```

### Phase 3: Deploy React Application

#### 3.1 Install Dependencies

```bash
cd react-app
npm install
```

#### 3.2 Configure Environment

```bash
# Copy example env file
cp .env.example .env.local

# Edit with your values
cat > .env.local << EOF
VITE_SNOWFLAKE_ACCOUNT=your_account
VITE_SNOWFLAKE_WAREHOUSE=GHOST_DETECTION_WH
VITE_API_BASE_URL=https://your-spcs-service-url.snowflakecomputing.app
EOF
```

#### 3.3 Development Mode

```bash
npm run dev
# App available at http://localhost:5173
```

#### 3.4 Production Build

```bash
npm run build
# Output in dist/ directory
```

#### 3.5 Deploy to Hosting

**Option A: Vercel**
```bash
npx vercel
```

**Option B: Streamlit in Snowflake (SiS)**
```sql
-- Create stage for React build
CREATE STAGE IF NOT EXISTS GHOST_DETECTION.APP.REACT_STAGE;

-- Upload built files (via SnowSQL or UI)
PUT file://dist/* @GHOST_DETECTION.APP.REACT_STAGE AUTO_COMPRESS=FALSE;
```

### Phase 4: Enable Scheduled Tasks

```sql
-- Resume all tasks
ALTER TASK GHOST_DETECTION.APP.DAILY_ACTIVITY_SUMMARY_TASK RESUME;
ALTER TASK GHOST_DETECTION.APP.DAILY_THREAT_ASSESSMENT_TASK RESUME;
ALTER TASK GHOST_DETECTION.APP.PROCESS_UNVERIFIED_SIGHTINGS_TASK RESUME;
ALTER TASK GHOST_DETECTION.APP.WEEKLY_HOTSPOT_ANALYSIS_TASK RESUME;
ALTER TASK GHOST_DETECTION.APP.MONTHLY_ANALYTICS_TASK RESUME;
ALTER TASK GHOST_DETECTION.APP.GENERATE_SIGHTING_EMBEDDINGS_TASK RESUME;

-- Verify task status
SELECT name, state, schedule, next_scheduled_time
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE DATABASE_NAME = 'GHOST_DETECTION';
```

## Configuration Options

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SNOWFLAKE_ACCOUNT` | Snowflake account identifier | Required |
| `SNOWFLAKE_USER` | Snowflake username | Required |
| `SNOWFLAKE_PASSWORD` | Snowflake password | Required |
| `SNOWFLAKE_ROLE` | Default role | `GHOSTBUSTER` |
| `SNOWFLAKE_WAREHOUSE` | Default warehouse | `GHOST_DETECTION_WH` |
| `SNOWFLAKE_DATABASE` | Default database | `GHOST_DETECTION` |

### Cortex AI Configuration

```sql
-- Configure default LLM model
ALTER SESSION SET CORTEX_DEFAULT_MODEL = 'mistral-large2';

-- Configure embedding model
-- Options: voyage-multilingual-2, snowflake-arctic-embed-l-v2.0-8k
```

### Search Service Tuning

```sql
-- Adjust target lag for faster updates
ALTER CORTEX SEARCH SERVICE GHOST_DETECTION.AI.GHOST_SEARCH_SERVICE
    SET TARGET_LAG = '30 minutes';
```

## Troubleshooting

### Common Issues

#### 1. Cortex AI Not Available
```
Error: Function SNOWFLAKE.CORTEX.COMPLETE does not exist
```
**Solution**: Ensure Cortex AI is enabled in your region. Check with:
```sql
SELECT SYSTEM$BEHAVIOR_CHANGE_BUNDLE_STATUS('2024_02');
```

#### 2. SPCS Service Not Starting
```sql
-- Check service status
DESCRIBE SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE;

-- Check logs
SELECT * FROM TABLE(
    GHOST_DETECTION.INFORMATION_SCHEMA.SERVICE_LOGS(
        'GHOST_DETECTION.APP.GHOST_MCP_SERVICE'
    )
);
```

#### 3. Tasks Not Running
```sql
-- Check task ownership and grants
SHOW GRANTS ON TASK GHOST_DETECTION.APP.DAILY_ACTIVITY_SUMMARY_TASK;

-- Check warehouse is available
SELECT * FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY());
```

#### 4. Semantic View Errors
```sql
-- Validate semantic view
DESCRIBE SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.GHOST_ANALYTICS_SV;

-- Check for syntax errors
SELECT GET_DDL('SEMANTIC_VIEW', 'GHOST_DETECTION.ANALYTICS.GHOST_ANALYTICS_SV');
```

## Upgrading

### Version Migration
```sql
-- Before upgrade: backup critical data
CREATE TABLE GHOST_DETECTION.APP.GHOSTS_BACKUP CLONE GHOST_DETECTION.APP.GHOSTS;

-- Run migration scripts
!source migrations/v2_to_v3.sql

-- Verify data integrity
SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOSTS;
```

## Cleanup

### Remove All Resources
```sql
-- WARNING: This deletes everything!

-- Suspend and drop tasks
ALTER TASK GHOST_DETECTION.APP.DAILY_ACTIVITY_SUMMARY_TASK SUSPEND;
DROP TASK IF EXISTS GHOST_DETECTION.APP.DAILY_ACTIVITY_SUMMARY_TASK;
-- ... repeat for all tasks

-- Drop services
DROP SERVICE IF EXISTS GHOST_DETECTION.APP.GHOST_MCP_SERVICE;
DROP COMPUTE POOL IF EXISTS GHOST_MCP_POOL;

-- Drop database (cascades to all objects)
DROP DATABASE IF EXISTS GHOST_DETECTION;

-- Drop warehouse
DROP WAREHOUSE IF EXISTS GHOST_DETECTION_WH;

-- Drop roles
DROP ROLE IF EXISTS GHOSTBUSTER;
DROP ROLE IF EXISTS GHOST_ADMIN;
DROP ROLE IF EXISTS GHOST_ANALYST;
```

## Support

For issues and questions:
- GitHub Issues: [Repository Issues Page]
- Documentation: [Full Documentation]
- Snowflake Community: [Snowflake Forums]
