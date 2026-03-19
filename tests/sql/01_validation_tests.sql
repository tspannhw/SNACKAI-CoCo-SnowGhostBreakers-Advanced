-- ============================================
-- SnowGhost Breakers - SQL Validation Tests
-- Run these to validate schema and data integrity
-- ============================================

USE DATABASE GHOST_DETECTION;
USE WAREHOUSE GHOST_DETECTION_WH;

-- ============================================
-- TEST 1: Schema Validation
-- ============================================

-- Test 1.1: Verify all required tables exist
CREATE OR REPLACE PROCEDURE TEST_SCHEMA_EXISTS()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_results ARRAY DEFAULT ARRAY_CONSTRUCT();
    v_missing_tables ARRAY DEFAULT ARRAY_CONSTRUCT();
    v_required_tables ARRAY DEFAULT ARRAY_CONSTRUCT(
        'APP.GHOSTS',
        'APP.GHOST_SIGHTINGS', 
        'APP.GHOST_EVIDENCE',
        'APP.INVESTIGATIONS',
        'APP.SENSOR_READINGS',
        'APP.AI_ANALYSIS_RESULTS',
        'APP.BUSINESS_VOCABULARY',
        'APP.GHOST_TAXONOMY',
        'APP.AUDIT_LOG',
        'APP.API_USAGE_LOG'
    );
BEGIN
    FOR i IN 0 TO ARRAY_SIZE(:v_required_tables) - 1 DO
        LET table_name VARCHAR := :v_required_tables[i]::VARCHAR;
        
        LET exists_check INT := (
            SELECT COUNT(*) 
            FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_CATALOG = 'GHOST_DETECTION'
            AND CONCAT(TABLE_SCHEMA, '.', TABLE_NAME) = :table_name
        );
        
        IF (:exists_check = 0) THEN
            v_missing_tables := ARRAY_APPEND(:v_missing_tables, :table_name);
        END IF;
    END FOR;
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'SCHEMA_EXISTS',
        'passed', ARRAY_SIZE(:v_missing_tables) = 0,
        'missing_tables', :v_missing_tables,
        'total_expected', ARRAY_SIZE(:v_required_tables),
        'total_found', ARRAY_SIZE(:v_required_tables) - ARRAY_SIZE(:v_missing_tables)
    );
END;

-- Test 1.2: Verify column data types
CREATE OR REPLACE PROCEDURE TEST_COLUMN_TYPES()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_errors ARRAY DEFAULT ARRAY_CONSTRUCT();
BEGIN
    -- Check GHOSTS table columns
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 'APP' AND TABLE_NAME = 'GHOSTS' 
        AND COLUMN_NAME = 'GHOST_ID' AND DATA_TYPE = 'TEXT'
    ) THEN
        v_errors := ARRAY_APPEND(:v_errors, 'GHOSTS.GHOST_ID should be TEXT');
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 'APP' AND TABLE_NAME = 'GHOSTS' 
        AND COLUMN_NAME = 'CONFIDENCE_SCORE' AND DATA_TYPE LIKE '%FLOAT%'
    ) THEN
        v_errors := ARRAY_APPEND(:v_errors, 'GHOSTS.CONFIDENCE_SCORE should be FLOAT');
    END IF;
    
    -- Check GHOST_SIGHTINGS table columns
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 'APP' AND TABLE_NAME = 'GHOST_SIGHTINGS' 
        AND COLUMN_NAME = 'LATITUDE' AND DATA_TYPE LIKE '%FLOAT%'
    ) THEN
        v_errors := ARRAY_APPEND(:v_errors, 'GHOST_SIGHTINGS.LATITUDE should be FLOAT');
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 'APP' AND TABLE_NAME = 'GHOST_SIGHTINGS' 
        AND COLUMN_NAME = 'VERIFIED' AND DATA_TYPE = 'BOOLEAN'
    ) THEN
        v_errors := ARRAY_APPEND(:v_errors, 'GHOST_SIGHTINGS.VERIFIED should be BOOLEAN');
    END IF;
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'COLUMN_TYPES',
        'passed', ARRAY_SIZE(:v_errors) = 0,
        'errors', :v_errors
    );
END;

-- ============================================
-- TEST 2: Data Integrity Tests
-- ============================================

-- Test 2.1: Check foreign key relationships
CREATE OR REPLACE PROCEDURE TEST_FOREIGN_KEYS()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_orphan_sightings INT;
    v_orphan_evidence INT;
    v_results VARIANT;
BEGIN
    -- Check for orphan sightings (ghost_id not in GHOSTS)
    SELECT COUNT(*) INTO v_orphan_sightings
    FROM APP.GHOST_SIGHTINGS s
    WHERE NOT EXISTS (SELECT 1 FROM APP.GHOSTS g WHERE g.ghost_id = s.ghost_id);
    
    -- Check for orphan evidence
    SELECT COUNT(*) INTO v_orphan_evidence
    FROM APP.GHOST_EVIDENCE e
    WHERE e.ghost_id IS NOT NULL 
    AND NOT EXISTS (SELECT 1 FROM APP.GHOSTS g WHERE g.ghost_id = e.ghost_id);
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'FOREIGN_KEYS',
        'passed', :v_orphan_sightings = 0 AND :v_orphan_evidence = 0,
        'orphan_sightings', :v_orphan_sightings,
        'orphan_evidence', :v_orphan_evidence
    );
END;

-- Test 2.2: Check data constraints
CREATE OR REPLACE PROCEDURE TEST_DATA_CONSTRAINTS()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_invalid_threat_levels INT;
    v_invalid_statuses INT;
    v_invalid_activity_levels INT;
    v_errors ARRAY DEFAULT ARRAY_CONSTRUCT();
BEGIN
    -- Check threat_level values
    SELECT COUNT(*) INTO v_invalid_threat_levels
    FROM APP.GHOSTS
    WHERE threat_level NOT IN ('Low', 'Medium', 'High', 'Extreme');
    
    IF (:v_invalid_threat_levels > 0) THEN
        v_errors := ARRAY_APPEND(:v_errors, 'Found ' || :v_invalid_threat_levels || ' invalid threat_level values');
    END IF;
    
    -- Check status values
    SELECT COUNT(*) INTO v_invalid_statuses
    FROM APP.GHOSTS
    WHERE status NOT IN ('Active', 'Dormant', 'Captured', 'Neutralized');
    
    IF (:v_invalid_statuses > 0) THEN
        v_errors := ARRAY_APPEND(:v_errors, 'Found ' || :v_invalid_statuses || ' invalid status values');
    END IF;
    
    -- Check activity level range (1-10)
    SELECT COUNT(*) INTO v_invalid_activity_levels
    FROM APP.GHOST_SIGHTINGS
    WHERE paranormal_activity_level < 1 OR paranormal_activity_level > 10;
    
    IF (:v_invalid_activity_levels > 0) THEN
        v_errors := ARRAY_APPEND(:v_errors, 'Found ' || :v_invalid_activity_levels || ' activity levels outside 1-10 range');
    END IF;
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'DATA_CONSTRAINTS',
        'passed', ARRAY_SIZE(:v_errors) = 0,
        'errors', :v_errors
    );
END;

-- ============================================
-- TEST 3: Stored Procedure Tests
-- ============================================

-- Test 3.1: Test REGISTER_GHOST procedure
CREATE OR REPLACE PROCEDURE TEST_REGISTER_GHOST()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_result VARIANT;
    v_ghost_id VARCHAR;
    v_cleanup_success BOOLEAN DEFAULT FALSE;
BEGIN
    -- Call the procedure
    CALL REGISTER_GHOST(
        'Test Ghost',
        'Apparition',
        'Low',
        'A test ghost for validation purposes',
        'Random'
    ) INTO v_result;
    
    -- Check result structure
    IF (:v_result:success = TRUE AND :v_result:ghost_id IS NOT NULL) THEN
        v_ghost_id := :v_result:ghost_id::VARCHAR;
        
        -- Verify ghost was created
        IF EXISTS (SELECT 1 FROM APP.GHOSTS WHERE ghost_id = :v_ghost_id) THEN
            -- Cleanup: delete test ghost
            DELETE FROM APP.GHOSTS WHERE ghost_id = :v_ghost_id;
            v_cleanup_success := TRUE;
        END IF;
    END IF;
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'REGISTER_GHOST',
        'passed', :v_result:success = TRUE AND :v_cleanup_success,
        'result', :v_result,
        'cleanup_success', :v_cleanup_success
    );
EXCEPTION
    WHEN OTHER THEN
        RETURN OBJECT_CONSTRUCT(
            'test_name', 'REGISTER_GHOST',
            'passed', FALSE,
            'error', SQLERRM
        );
END;

-- Test 3.2: Test CLASSIFY_GHOST_TYPE procedure
CREATE OR REPLACE PROCEDURE TEST_CLASSIFY_GHOST_TYPE()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_result VARIANT;
BEGIN
    -- Test with a poltergeist description
    CALL CLASSIFY_GHOST_TYPE(
        'Objects flying across the room, loud banging noises, furniture moving on its own'
    ) INTO v_result;
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'CLASSIFY_GHOST_TYPE',
        'passed', :v_result:type IS NOT NULL,
        'classification', :v_result:type,
        'confidence', :v_result:confidence
    );
EXCEPTION
    WHEN OTHER THEN
        RETURN OBJECT_CONSTRUCT(
            'test_name', 'CLASSIFY_GHOST_TYPE',
            'passed', FALSE,
            'error', SQLERRM
        );
END;

-- ============================================
-- TEST 4: Cortex AI Tests
-- ============================================

-- Test 4.1: Test Cortex Sentiment
CREATE OR REPLACE PROCEDURE TEST_CORTEX_SENTIMENT()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_positive_score FLOAT;
    v_negative_score FLOAT;
BEGIN
    -- Test positive sentiment
    SELECT SNOWFLAKE.CORTEX.SENTIMENT('The ghost was friendly and harmless') INTO v_positive_score;
    
    -- Test negative sentiment
    SELECT SNOWFLAKE.CORTEX.SENTIMENT('Terrifying encounter, extremely dangerous entity') INTO v_negative_score;
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'CORTEX_SENTIMENT',
        'passed', :v_positive_score > :v_negative_score,
        'positive_score', :v_positive_score,
        'negative_score', :v_negative_score
    );
EXCEPTION
    WHEN OTHER THEN
        RETURN OBJECT_CONSTRUCT(
            'test_name', 'CORTEX_SENTIMENT',
            'passed', FALSE,
            'error', SQLERRM
        );
END;

-- Test 4.2: Test Cortex Complete
CREATE OR REPLACE PROCEDURE TEST_CORTEX_COMPLETE()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_response VARCHAR;
BEGIN
    SELECT SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'In one word, what type of paranormal entity moves objects? Answer with just the word.'
    ) INTO v_response;
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'CORTEX_COMPLETE',
        'passed', :v_response IS NOT NULL AND LENGTH(:v_response) > 0,
        'response', :v_response
    );
EXCEPTION
    WHEN OTHER THEN
        RETURN OBJECT_CONSTRUCT(
            'test_name', 'CORTEX_COMPLETE',
            'passed', FALSE,
            'error', SQLERRM
        );
END;

-- ============================================
-- TEST 5: Analytics Views Tests
-- ============================================

-- Test 5.1: Test analytics views return data
CREATE OR REPLACE PROCEDURE TEST_ANALYTICS_VIEWS()
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_errors ARRAY DEFAULT ARRAY_CONSTRUCT();
    v_view_count INT;
BEGIN
    -- Test each analytics view
    BEGIN
        SELECT COUNT(*) INTO v_view_count FROM ANALYTICS.VW_GHOST_ACTIVITY_SUMMARY;
    EXCEPTION
        WHEN OTHER THEN
            v_errors := ARRAY_APPEND(:v_errors, 'VW_GHOST_ACTIVITY_SUMMARY: ' || SQLERRM);
    END;
    
    BEGIN
        SELECT COUNT(*) INTO v_view_count FROM ANALYTICS.VW_PARANORMAL_HOTSPOTS;
    EXCEPTION
        WHEN OTHER THEN
            v_errors := ARRAY_APPEND(:v_errors, 'VW_PARANORMAL_HOTSPOTS: ' || SQLERRM);
    END;
    
    RETURN OBJECT_CONSTRUCT(
        'test_name', 'ANALYTICS_VIEWS',
        'passed', ARRAY_SIZE(:v_errors) = 0,
        'errors', :v_errors
    );
END;

-- ============================================
-- MAIN TEST RUNNER
-- ============================================

CREATE OR REPLACE PROCEDURE RUN_ALL_TESTS()
RETURNS TABLE (
    test_name VARCHAR,
    passed BOOLEAN,
    details VARIANT
)
LANGUAGE SQL
AS
DECLARE
    v_results ARRAY DEFAULT ARRAY_CONSTRUCT();
    v_result VARIANT;
BEGIN
    -- Run all tests
    CALL TEST_SCHEMA_EXISTS() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    CALL TEST_COLUMN_TYPES() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    CALL TEST_FOREIGN_KEYS() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    CALL TEST_DATA_CONSTRAINTS() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    CALL TEST_REGISTER_GHOST() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    CALL TEST_CLASSIFY_GHOST_TYPE() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    CALL TEST_CORTEX_SENTIMENT() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    CALL TEST_CORTEX_COMPLETE() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    CALL TEST_ANALYTICS_VIEWS() INTO v_result;
    v_results := ARRAY_APPEND(:v_results, :v_result);
    
    -- Return results as table
    RETURN TABLE(
        SELECT 
            r.value:test_name::VARCHAR AS test_name,
            r.value:passed::BOOLEAN AS passed,
            r.value AS details
        FROM TABLE(FLATTEN(input => :v_results)) r
    );
END;

-- ============================================
-- RUN TESTS
-- ============================================

-- Execute all tests
-- CALL RUN_ALL_TESTS();

-- Or run individual tests
-- CALL TEST_SCHEMA_EXISTS();
-- CALL TEST_FOREIGN_KEYS();
-- CALL TEST_CORTEX_SENTIMENT();
