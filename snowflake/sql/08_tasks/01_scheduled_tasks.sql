-- ============================================
-- SnowGhost Breakers - Scheduled Tasks
-- Automated processing and maintenance
-- ============================================

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;

-- ============================================
-- DAILY TASKS
-- ============================================

-- Daily activity summary generation
CREATE OR REPLACE TASK DAILY_ACTIVITY_SUMMARY_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 8 * * * America/New_York'
    COMMENT = 'Generate daily paranormal activity summary report'
AS
    CALL GENERATE_DAILY_ACTIVITY_SUMMARY();

-- Daily threat assessment update
CREATE OR REPLACE TASK DAILY_THREAT_ASSESSMENT_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 6 * * * America/New_York'
    COMMENT = 'Re-analyze threat levels for active ghosts'
AS
    BEGIN
        -- Update threat analysis for all active ghosts
        FOR ghost_record IN (SELECT ghost_id FROM GHOSTS WHERE status = 'Active')
        DO
            CALL ANALYZE_THREAT_LEVEL(ghost_record.ghost_id);
        END FOR;
    END;

-- ============================================
-- HOURLY TASKS
-- ============================================

-- Process unverified sightings
CREATE OR REPLACE TASK PROCESS_UNVERIFIED_SIGHTINGS_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 * * * * America/New_York'
    COMMENT = 'Auto-analyze unverified sightings for patterns'
AS
    BEGIN
        -- Analyze sentiment and flag high-concern sightings
        INSERT INTO AI_ANALYSIS_RESULTS (
            analysis_id, source_type, source_id, model_name, analysis_type,
            result, confidence_score, created_at
        )
        SELECT 
            UUID_STRING(),
            'SIGHTING',
            sighting_id,
            'cortex-sentiment',
            'SENTIMENT_ANALYSIS',
            OBJECT_CONSTRUCT(
                'sentiment_score', SNOWFLAKE.CORTEX.SENTIMENT(description),
                'urgency', CASE 
                    WHEN SNOWFLAKE.CORTEX.SENTIMENT(description) < -0.5 THEN 'HIGH'
                    WHEN SNOWFLAKE.CORTEX.SENTIMENT(description) < 0 THEN 'MEDIUM'
                    ELSE 'LOW'
                END
            ),
            0.9,
            CURRENT_TIMESTAMP()
        FROM GHOST_SIGHTINGS
        WHERE verified = FALSE
          AND created_at >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
          AND sighting_id NOT IN (
              SELECT source_id FROM AI_ANALYSIS_RESULTS 
              WHERE source_type = 'SIGHTING' AND analysis_type = 'SENTIMENT_ANALYSIS'
          );
    END;

-- Refresh Cortex Search index (via dynamic table refresh)
CREATE OR REPLACE TASK REFRESH_SEARCH_INDEX_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 30 * * * * America/New_York'
    COMMENT = 'Ensure search indexes are up to date'
AS
    SELECT 1; -- Placeholder - Cortex Search auto-refreshes based on TARGET_LAG

-- ============================================
-- WEEKLY TASKS
-- ============================================

-- Weekly hotspot analysis
CREATE OR REPLACE TASK WEEKLY_HOTSPOT_ANALYSIS_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 9 * * 1 America/New_York'
    COMMENT = 'Generate weekly paranormal hotspot report'
AS
    BEGIN
        DECLARE
            v_hotspots VARIANT;
            v_report VARCHAR;
        BEGIN
            -- Get hotspot data
            SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
                'location', location_name,
                'sightings', total_sightings,
                'classification', hotspot_classification
            )) INTO v_hotspots
            FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
            FROM TABLE(GET_PARANORMAL_HOTSPOTS(3));
            
            -- Generate AI summary
            v_report := SNOWFLAKE.CORTEX.COMPLETE(
                'mistral-large2',
                'Analyze these paranormal hotspots and provide strategic recommendations: ' || TO_VARCHAR(:v_hotspots)
            );
            
            -- Store the report
            INSERT INTO AI_ANALYSIS_RESULTS (
                analysis_id, source_type, source_id, model_name, analysis_type,
                result, confidence_score, created_at
            ) VALUES (
                UUID_STRING(),
                'SYSTEM',
                'WEEKLY_HOTSPOT_REPORT',
                'mistral-large2',
                'HOTSPOT_ANALYSIS',
                OBJECT_CONSTRUCT('report', :v_report, 'hotspots', :v_hotspots),
                0.85,
                CURRENT_TIMESTAMP()
            );
        END;
    END;

-- Weekly investigation progress review
CREATE OR REPLACE TASK WEEKLY_INVESTIGATION_REVIEW_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 10 * * 1 America/New_York'
    COMMENT = 'Review open investigations and generate status updates'
AS
    BEGIN
        FOR inv_record IN (
            SELECT investigation_id, case_name 
            FROM INVESTIGATIONS 
            WHERE status IN ('Open', 'In_Progress')
        )
        DO
            -- Generate summary for each open investigation
            INSERT INTO AI_ANALYSIS_RESULTS (
                analysis_id, source_type, source_id, model_name, analysis_type,
                result, confidence_score, created_at
            )
            SELECT 
                UUID_STRING(),
                'INVESTIGATION',
                inv_record.investigation_id,
                'mistral-large2',
                'WEEKLY_PROGRESS',
                OBJECT_CONSTRUCT('summary', SUMMARIZE_INVESTIGATION(inv_record.investigation_id)),
                0.8,
                CURRENT_TIMESTAMP();
        END FOR;
    END;

-- ============================================
-- MONTHLY TASKS
-- ============================================

-- Monthly comprehensive analytics
CREATE OR REPLACE TASK MONTHLY_ANALYTICS_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 0 1 * * America/New_York'
    COMMENT = 'Generate monthly comprehensive analytics report'
AS
    BEGIN
        DECLARE
            v_metrics VARIANT;
            v_report VARCHAR;
        BEGIN
            -- Calculate monthly metrics
            SELECT OBJECT_CONSTRUCT(
                'month', DATE_TRUNC('month', CURRENT_DATE()),
                'total_ghosts', (SELECT COUNT(*) FROM GHOSTS),
                'new_ghosts', (SELECT COUNT(*) FROM GHOSTS WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE())),
                'total_sightings', (SELECT COUNT(*) FROM GHOST_SIGHTINGS WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE())),
                'investigations_opened', (SELECT COUNT(*) FROM INVESTIGATIONS WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE())),
                'investigations_closed', (SELECT COUNT(*) FROM INVESTIGATIONS WHERE DATE_TRUNC('month', end_date) = DATE_TRUNC('month', CURRENT_DATE())),
                'evidence_collected', (SELECT COUNT(*) FROM GHOST_EVIDENCE WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE())),
                'threat_distribution', (SELECT OBJECT_AGG(threat_level, cnt) FROM (SELECT threat_level, COUNT(*) cnt FROM GHOSTS GROUP BY threat_level))
            ) INTO v_metrics;
            
            -- Generate comprehensive report
            v_report := SNOWFLAKE.CORTEX.COMPLETE(
                'mistral-large2',
                'Generate a comprehensive monthly analytics report for a paranormal investigation organization. Include trends, recommendations, and strategic insights. Metrics: ' || TO_VARCHAR(:v_metrics)
            );
            
            -- Store the report
            INSERT INTO AI_ANALYSIS_RESULTS (
                analysis_id, source_type, source_id, model_name, analysis_type,
                result, confidence_score, created_at
            ) VALUES (
                UUID_STRING(),
                'SYSTEM',
                'MONTHLY_ANALYTICS_' || TO_VARCHAR(DATE_TRUNC('month', CURRENT_DATE())),
                'mistral-large2',
                'MONTHLY_REPORT',
                OBJECT_CONSTRUCT('report', :v_report, 'metrics', :v_metrics),
                0.9,
                CURRENT_TIMESTAMP()
            );
        END;
    END;

-- ============================================
-- DATA MAINTENANCE TASKS
-- ============================================

-- Archive old audit logs (keep 90 days)
CREATE OR REPLACE TASK ARCHIVE_AUDIT_LOGS_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 2 * * 0 America/New_York'
    COMMENT = 'Archive audit logs older than 90 days'
AS
    BEGIN
        -- Move to archive table (create if not exists)
        CREATE TABLE IF NOT EXISTS AUDIT_LOG_ARCHIVE LIKE AUDIT_LOG;
        
        INSERT INTO AUDIT_LOG_ARCHIVE
        SELECT * FROM AUDIT_LOG 
        WHERE timestamp < DATEADD(day, -90, CURRENT_TIMESTAMP());
        
        DELETE FROM AUDIT_LOG 
        WHERE timestamp < DATEADD(day, -90, CURRENT_TIMESTAMP());
    END;

-- Clean up old API usage logs
CREATE OR REPLACE TASK CLEANUP_API_LOGS_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 0 3 * * 0 America/New_York'
    COMMENT = 'Clean up API usage logs older than 30 days'
AS
    DELETE FROM API_USAGE_LOG 
    WHERE timestamp < DATEADD(day, -30, CURRENT_TIMESTAMP());

-- ============================================
-- EMBEDDING GENERATION TASKS
-- ============================================

-- Generate embeddings for new sightings
CREATE OR REPLACE TASK GENERATE_SIGHTING_EMBEDDINGS_TASK
    WAREHOUSE = GHOST_DETECTION_WH
    SCHEDULE = 'USING CRON 15 * * * * America/New_York'
    COMMENT = 'Generate vector embeddings for new sighting descriptions'
AS
    BEGIN
        -- Create embeddings table if not exists
        CREATE TABLE IF NOT EXISTS SIGHTING_EMBEDDINGS (
            sighting_id VARCHAR PRIMARY KEY,
            embedding VECTOR(FLOAT, 1024),
            created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
        );
        
        -- Generate embeddings for sightings without them
        INSERT INTO SIGHTING_EMBEDDINGS (sighting_id, embedding, created_at)
        SELECT 
            sighting_id,
            SNOWFLAKE.CORTEX.EMBED_TEXT_1024('voyage-multilingual-2', description),
            CURRENT_TIMESTAMP()
        FROM GHOST_SIGHTINGS
        WHERE description IS NOT NULL
          AND sighting_id NOT IN (SELECT sighting_id FROM SIGHTING_EMBEDDINGS)
        LIMIT 100; -- Process in batches
    END;

-- ============================================
-- TASK MANAGEMENT
-- ============================================

-- Enable all tasks
ALTER TASK DAILY_ACTIVITY_SUMMARY_TASK RESUME;
ALTER TASK DAILY_THREAT_ASSESSMENT_TASK RESUME;
ALTER TASK PROCESS_UNVERIFIED_SIGHTINGS_TASK RESUME;
ALTER TASK WEEKLY_HOTSPOT_ANALYSIS_TASK RESUME;
ALTER TASK WEEKLY_INVESTIGATION_REVIEW_TASK RESUME;
ALTER TASK MONTHLY_ANALYTICS_TASK RESUME;
ALTER TASK ARCHIVE_AUDIT_LOGS_TASK RESUME;
ALTER TASK CLEANUP_API_LOGS_TASK RESUME;
ALTER TASK GENERATE_SIGHTING_EMBEDDINGS_TASK RESUME;

-- View task status
-- SHOW TASKS IN SCHEMA APP;

-- Monitor task history
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
-- WHERE NAME LIKE '%GHOST%'
-- ORDER BY SCHEDULED_TIME DESC
-- LIMIT 50;
