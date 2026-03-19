/*
================================================================================
SnowGhostBreakers - Audit and Logging Tables Script
================================================================================
Description: Creates audit logging and API usage tracking tables for
             compliance, debugging, and operational monitoring.
Author: SnowGhostBreakers Team
Created: 2024
Prerequisites: Run 01_setup/01_database_setup.sql first
================================================================================
*/

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;
USE WAREHOUSE GHOST_DETECTION_WH;

-- ============================================================================
-- TABLE 1: AUDIT_LOG
-- Description: Tracks all data changes across application tables for
--              compliance and forensic analysis
-- ============================================================================

CREATE OR REPLACE TABLE AUDIT_LOG (
    -- Primary Key
    LOG_ID              NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each audit log entry',
    
    -- Action Information
    ACTION              VARCHAR(50) NOT NULL
                        COMMENT 'Type of action performed: INSERT, UPDATE, DELETE, SELECT, MERGE, TRUNCATE'
                        CHECK (ACTION IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT', 'MERGE', 'TRUNCATE', 'LOGIN', 'LOGOUT', 'EXPORT', 'IMPORT', 'OTHER')),
    
    -- Target Information
    TABLE_NAME          VARCHAR(256) NOT NULL
                        COMMENT 'Fully qualified name of the affected table (e.g., GHOST_DETECTION.APP.GHOSTS)',
    RECORD_ID           VARCHAR(100)
                        COMMENT 'Primary key value of the affected record (as string for flexibility)',
    
    -- Change Data
    OLD_VALUE           VARIANT
                        COMMENT 'JSON representation of the record before the change (NULL for INSERT)',
    NEW_VALUE           VARIANT
                        COMMENT 'JSON representation of the record after the change (NULL for DELETE)',
    
    -- Changed Columns (for UPDATE operations)
    CHANGED_COLUMNS     ARRAY
                        COMMENT 'Array of column names that were modified in this operation',
    
    -- User and Session Information
    USER_NAME           VARCHAR(256) NOT NULL
                        COMMENT 'Snowflake username who performed the action',
    ROLE_NAME           VARCHAR(256)
                        COMMENT 'Snowflake role active when action was performed',
    SESSION_ID          NUMBER(38,0)
                        COMMENT 'Snowflake session ID for the transaction',
    QUERY_ID            VARCHAR(100)
                        COMMENT 'Snowflake query ID that triggered the change',
    
    -- Client Information
    CLIENT_IP           VARCHAR(50)
                        COMMENT 'IP address of the client connection',
    CLIENT_APPLICATION  VARCHAR(256)
                        COMMENT 'Application name that initiated the change',
    
    -- Additional Context
    CONTEXT             VARIANT
                        COMMENT 'Additional context information (investigation ID, batch ID, etc.)',
    
    -- Timestamp
    TIMESTAMP           TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Timestamp when the action was recorded'
)
COMMENT = 'Comprehensive audit log tracking all data modifications for compliance, security, and forensic analysis'
CLUSTER BY (TO_DATE(TIMESTAMP), TABLE_NAME, ACTION);

-- ============================================================================
-- TABLE 2: API_USAGE_LOG
-- Description: Tracks API calls for monitoring, debugging, and rate limiting
-- ============================================================================

CREATE OR REPLACE TABLE API_USAGE_LOG (
    -- Primary Key
    LOG_ID              NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each API log entry',
    
    -- Request Information
    ENDPOINT            VARCHAR(500) NOT NULL
                        COMMENT 'API endpoint path (e.g., /api/v1/ghosts, /api/v1/sightings)',
    METHOD              VARCHAR(10) NOT NULL
                        COMMENT 'HTTP method: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS'
                        CHECK (METHOD IN ('GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS')),
    
    -- Request Details
    REQUEST_PARAMS      VARIANT
                        COMMENT 'JSON object containing query parameters and path variables',
    REQUEST_BODY        VARIANT
                        COMMENT 'JSON representation of the request body (sanitized)',
    REQUEST_HEADERS     VARIANT
                        COMMENT 'Relevant request headers (sanitized, no auth tokens)',
    
    -- Response Information
    RESPONSE_STATUS     NUMBER(3,0) NOT NULL
                        COMMENT 'HTTP response status code (200, 201, 400, 401, 403, 404, 500, etc.)',
    RESPONSE_SIZE_BYTES NUMBER(38,0)
                        COMMENT 'Size of the response body in bytes',
    ERROR_MESSAGE       VARCHAR(2000)
                        COMMENT 'Error message if the request failed',
    ERROR_CODE          VARCHAR(50)
                        COMMENT 'Application-specific error code',
    
    -- Performance Metrics
    LATENCY_MS          NUMBER(38,0) NOT NULL
                        COMMENT 'Total request processing time in milliseconds',
    DB_QUERY_TIME_MS    NUMBER(38,0)
                        COMMENT 'Time spent on database queries in milliseconds',
    AI_PROCESSING_TIME_MS NUMBER(38,0)
                        COMMENT 'Time spent on AI/ML processing in milliseconds',
    
    -- Client Information
    USER_AGENT          VARCHAR(500)
                        COMMENT 'User-Agent header from the request',
    CLIENT_IP           VARCHAR(50)
                        COMMENT 'IP address of the client',
    USER_ID             VARCHAR(100)
                        COMMENT 'Authenticated user ID (if applicable)',
    API_KEY_ID          VARCHAR(100)
                        COMMENT 'API key identifier used for the request',
    
    -- Rate Limiting
    RATE_LIMIT_REMAINING NUMBER(38,0)
                        COMMENT 'Remaining rate limit quota after this request',
    RATE_LIMIT_RESET    TIMESTAMP_NTZ
                        COMMENT 'Timestamp when rate limit resets',
    
    -- Correlation
    REQUEST_ID          VARCHAR(100)
                        COMMENT 'Unique request ID for tracing across systems',
    CORRELATION_ID      VARCHAR(100)
                        COMMENT 'Correlation ID for tracking related requests',
    
    -- Timestamp
    TIMESTAMP           TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Timestamp when the API call was recorded'
)
COMMENT = 'API usage log for monitoring endpoints, performance tracking, debugging, and rate limiting'
CLUSTER BY (TO_DATE(TIMESTAMP), ENDPOINT, RESPONSE_STATUS);

-- ============================================================================
-- TABLE 3: ERROR_LOG (Additional logging table)
-- Description: Centralized error tracking for application-wide error monitoring
-- ============================================================================

CREATE OR REPLACE TABLE ERROR_LOG (
    -- Primary Key
    ERROR_ID            NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each error entry',
    
    -- Error Classification
    ERROR_TYPE          VARCHAR(100) NOT NULL
                        COMMENT 'Type of error: SYSTEM, APPLICATION, DATABASE, AI_SERVICE, NETWORK, VALIDATION, AUTHENTICATION'
                        CHECK (ERROR_TYPE IN ('SYSTEM', 'APPLICATION', 'DATABASE', 'AI_SERVICE', 'NETWORK', 'VALIDATION', 'AUTHENTICATION', 'AUTHORIZATION', 'TIMEOUT', 'OTHER')),
    SEVERITY            VARCHAR(20) NOT NULL DEFAULT 'ERROR'
                        COMMENT 'Severity level: DEBUG, INFO, WARNING, ERROR, CRITICAL'
                        CHECK (SEVERITY IN ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL')),
    
    -- Error Details
    ERROR_CODE          VARCHAR(50)
                        COMMENT 'Application-specific error code',
    ERROR_MESSAGE       VARCHAR(4000) NOT NULL
                        COMMENT 'Human-readable error message',
    STACK_TRACE         VARCHAR(16000)
                        COMMENT 'Full stack trace (for debugging)',
    
    -- Context
    SOURCE_COMPONENT    VARCHAR(200) NOT NULL
                        COMMENT 'Component or module where error originated',
    SOURCE_FUNCTION     VARCHAR(200)
                        COMMENT 'Function or method where error occurred',
    CONTEXT             VARIANT
                        COMMENT 'Additional context: request data, user state, etc.',
    
    -- Related Records
    RELATED_TABLE       VARCHAR(256)
                        COMMENT 'Database table related to the error',
    RELATED_RECORD_ID   VARCHAR(100)
                        COMMENT 'Record ID related to the error',
    REQUEST_ID          VARCHAR(100)
                        COMMENT 'Request ID if error occurred during API call',
    
    -- User Information
    USER_NAME           VARCHAR(256)
                        COMMENT 'User who encountered the error',
    SESSION_ID          VARCHAR(100)
                        COMMENT 'Session ID when error occurred',
    
    -- Resolution
    RESOLVED            BOOLEAN DEFAULT FALSE
                        COMMENT 'Whether the error has been resolved',
    RESOLVED_BY         VARCHAR(256)
                        COMMENT 'User who resolved the error',
    RESOLVED_AT         TIMESTAMP_NTZ
                        COMMENT 'Timestamp when error was resolved',
    RESOLUTION_NOTES    VARCHAR(2000)
                        COMMENT 'Notes about how the error was resolved',
    
    -- Timestamp
    TIMESTAMP           TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Timestamp when the error was logged'
)
COMMENT = 'Centralized error log for tracking application errors, debugging, and incident management'
CLUSTER BY (TO_DATE(TIMESTAMP), ERROR_TYPE, SEVERITY);

-- ============================================================================
-- TABLE 4: SYSTEM_METRICS_LOG
-- Description: System performance and health metrics
-- ============================================================================

CREATE OR REPLACE TABLE SYSTEM_METRICS_LOG (
    -- Primary Key
    METRIC_ID           NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each metric entry',
    
    -- Metric Identification
    METRIC_NAME         VARCHAR(200) NOT NULL
                        COMMENT 'Name of the metric (e.g., active_investigations, daily_sightings, ai_requests)',
    METRIC_CATEGORY     VARCHAR(100) NOT NULL
                        COMMENT 'Category: PERFORMANCE, USAGE, CAPACITY, HEALTH, COST'
                        CHECK (METRIC_CATEGORY IN ('PERFORMANCE', 'USAGE', 'CAPACITY', 'HEALTH', 'COST', 'AI_USAGE', 'OTHER')),
    
    -- Metric Value
    METRIC_VALUE        NUMBER(20,6) NOT NULL
                        COMMENT 'Numeric value of the metric',
    METRIC_UNIT         VARCHAR(50)
                        COMMENT 'Unit of measurement (count, ms, bytes, percent, credits)',
    
    -- Dimensions
    DIMENSIONS          VARIANT
                        COMMENT 'JSON object with dimensional attributes for grouping/filtering',
    
    -- Thresholds
    WARNING_THRESHOLD   NUMBER(20,6)
                        COMMENT 'Value at which warning should be triggered',
    CRITICAL_THRESHOLD  NUMBER(20,6)
                        COMMENT 'Value at which critical alert should be triggered',
    THRESHOLD_EXCEEDED  BOOLEAN DEFAULT FALSE
                        COMMENT 'Whether any threshold was exceeded',
    
    -- Collection Information
    COLLECTION_METHOD   VARCHAR(50) DEFAULT 'SCHEDULED'
                        COMMENT 'How metric was collected: SCHEDULED, ON_DEMAND, EVENT_TRIGGERED',
    
    -- Timestamp
    TIMESTAMP           TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Timestamp when the metric was recorded'
)
COMMENT = 'System performance and health metrics for monitoring and alerting'
CLUSTER BY (TO_DATE(TIMESTAMP), METRIC_CATEGORY, METRIC_NAME);

-- ============================================================================
-- CREATE AUDIT HELPER VIEWS
-- ============================================================================

-- View: Recent audit activity (last 24 hours)
CREATE OR REPLACE VIEW V_RECENT_AUDIT_ACTIVITY AS
SELECT 
    LOG_ID,
    ACTION,
    TABLE_NAME,
    RECORD_ID,
    USER_NAME,
    TIMESTAMP,
    CASE 
        WHEN OLD_VALUE IS NULL THEN 'Created new record'
        WHEN NEW_VALUE IS NULL THEN 'Deleted record'
        ELSE 'Modified ' || ARRAY_SIZE(CHANGED_COLUMNS) || ' columns'
    END AS CHANGE_SUMMARY
FROM AUDIT_LOG
WHERE TIMESTAMP >= DATEADD('hour', -24, CURRENT_TIMESTAMP())
ORDER BY TIMESTAMP DESC;

-- View: API performance summary
CREATE OR REPLACE VIEW V_API_PERFORMANCE_SUMMARY AS
SELECT 
    ENDPOINT,
    METHOD,
    DATE_TRUNC('hour', TIMESTAMP) AS HOUR,
    COUNT(*) AS REQUEST_COUNT,
    ROUND(AVG(LATENCY_MS), 2) AS AVG_LATENCY_MS,
    MAX(LATENCY_MS) AS MAX_LATENCY_MS,
    MIN(LATENCY_MS) AS MIN_LATENCY_MS,
    COUNT(CASE WHEN RESPONSE_STATUS >= 400 THEN 1 END) AS ERROR_COUNT,
    ROUND(COUNT(CASE WHEN RESPONSE_STATUS >= 400 THEN 1 END) * 100.0 / COUNT(*), 2) AS ERROR_RATE_PCT
FROM API_USAGE_LOG
WHERE TIMESTAMP >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY ENDPOINT, METHOD, DATE_TRUNC('hour', TIMESTAMP)
ORDER BY HOUR DESC, REQUEST_COUNT DESC;

-- View: Error summary by type
CREATE OR REPLACE VIEW V_ERROR_SUMMARY AS
SELECT 
    ERROR_TYPE,
    SEVERITY,
    SOURCE_COMPONENT,
    COUNT(*) AS ERROR_COUNT,
    MAX(TIMESTAMP) AS LAST_OCCURRENCE,
    COUNT(CASE WHEN NOT RESOLVED THEN 1 END) AS UNRESOLVED_COUNT
FROM ERROR_LOG
WHERE TIMESTAMP >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY ERROR_TYPE, SEVERITY, SOURCE_COMPONENT
ORDER BY ERROR_COUNT DESC;

-- View: System health dashboard
CREATE OR REPLACE VIEW V_SYSTEM_HEALTH_DASHBOARD AS
SELECT 
    METRIC_NAME,
    METRIC_CATEGORY,
    METRIC_VALUE,
    METRIC_UNIT,
    WARNING_THRESHOLD,
    CRITICAL_THRESHOLD,
    THRESHOLD_EXCEEDED,
    TIMESTAMP,
    CASE 
        WHEN CRITICAL_THRESHOLD IS NOT NULL AND METRIC_VALUE >= CRITICAL_THRESHOLD THEN 'CRITICAL'
        WHEN WARNING_THRESHOLD IS NOT NULL AND METRIC_VALUE >= WARNING_THRESHOLD THEN 'WARNING'
        ELSE 'OK'
    END AS HEALTH_STATUS
FROM SYSTEM_METRICS_LOG
WHERE TIMESTAMP >= DATEADD('hour', -1, CURRENT_TIMESTAMP())
ORDER BY 
    CASE WHEN THRESHOLD_EXCEEDED THEN 0 ELSE 1 END,
    TIMESTAMP DESC;

-- ============================================================================
-- CREATE RETENTION POLICY TASKS (Optional - for automated cleanup)
-- ============================================================================

-- Note: Uncomment and customize the following task for automated data retention
/*
CREATE OR REPLACE TASK AUDIT_LOG_RETENTION_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 2 * * 0 America/New_York'  -- Weekly at 2 AM Sunday
AS
    DELETE FROM AUDIT_LOG 
    WHERE TIMESTAMP < DATEADD('day', -90, CURRENT_TIMESTAMP());  -- Keep 90 days

CREATE OR REPLACE TASK API_USAGE_LOG_RETENTION_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 2 * * 0 America/New_York'
AS
    DELETE FROM API_USAGE_LOG 
    WHERE TIMESTAMP < DATEADD('day', -30, CURRENT_TIMESTAMP());  -- Keep 30 days

CREATE OR REPLACE TASK ERROR_LOG_RETENTION_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 2 * * 0 America/New_York'
AS
    DELETE FROM ERROR_LOG 
    WHERE TIMESTAMP < DATEADD('day', -60, CURRENT_TIMESTAMP()) 
    AND RESOLVED = TRUE;  -- Keep 60 days (resolved only)
*/

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify all audit tables created
SHOW TABLES LIKE '%LOG%' IN SCHEMA GHOST_DETECTION.APP;
SHOW TABLES LIKE '%METRICS%' IN SCHEMA GHOST_DETECTION.APP;

-- Describe table structures
DESCRIBE TABLE AUDIT_LOG;
DESCRIBE TABLE API_USAGE_LOG;
DESCRIBE TABLE ERROR_LOG;
DESCRIBE TABLE SYSTEM_METRICS_LOG;

-- Verify views created
SHOW VIEWS LIKE 'V_%' IN SCHEMA GHOST_DETECTION.APP;

/*
================================================================================
AUDIT AND LOGGING TABLES CREATED
================================================================================
Tables Created:
1. AUDIT_LOG - Data change tracking for compliance
2. API_USAGE_LOG - API endpoint monitoring
3. ERROR_LOG - Centralized error tracking
4. SYSTEM_METRICS_LOG - System health metrics

Views Created:
1. V_RECENT_AUDIT_ACTIVITY - Last 24 hours of changes
2. V_API_PERFORMANCE_SUMMARY - API performance metrics
3. V_ERROR_SUMMARY - Error aggregation by type
4. V_SYSTEM_HEALTH_DASHBOARD - Current system health

Note: 
- Retention policy tasks are provided but commented out
- Uncomment and adjust retention periods as needed
- Consider enabling Time Travel for additional recovery options

Next Steps:
1. Run sample data scripts to populate test data
2. Configure monitoring alerts based on metrics
3. Set up retention policies based on compliance requirements
================================================================================
*/
