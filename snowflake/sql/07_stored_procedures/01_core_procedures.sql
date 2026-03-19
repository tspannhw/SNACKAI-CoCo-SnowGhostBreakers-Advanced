-- ============================================
-- SnowGhost Breakers - Core Stored Procedures
-- Business logic and AI-powered operations
-- ============================================

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;

-- ============================================
-- GHOST MANAGEMENT PROCEDURES
-- ============================================

-- Register a new ghost entity
CREATE OR REPLACE PROCEDURE REGISTER_GHOST(
    P_GHOST_NAME VARCHAR,
    P_GHOST_TYPE VARCHAR,
    P_THREAT_LEVEL VARCHAR,
    P_DESCRIPTION VARCHAR,
    P_MANIFESTATION_PATTERN VARCHAR DEFAULT 'Random'
)
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_ghost_id VARCHAR;
    v_confidence FLOAT;
    v_ai_classification VARCHAR;
BEGIN
    -- Generate unique ID
    v_ghost_id := 'GH' || TO_VARCHAR(UNIFORM(100000, 999999, RANDOM()));
    
    -- Get AI classification confidence
    v_ai_classification := SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'Classify this ghost description into one of these types: Apparition, Poltergeist, Shadow_Figure, Orb, Residual_Haunt, Intelligent_Haunt, Demonic, Elemental. Description: ' || :P_DESCRIPTION || '. Return only the type name.'
    );
    
    -- Calculate initial confidence based on description quality
    v_confidence := LEAST(0.95, 0.5 + (LENGTH(:P_DESCRIPTION) / 500.0));
    
    -- Insert the ghost record
    INSERT INTO GHOSTS (
        ghost_id, ghost_name, ghost_type, threat_level, status, 
        description, manifestation_pattern, confidence_score,
        first_sighting, last_sighting, created_at, updated_at
    ) VALUES (
        :v_ghost_id, :P_GHOST_NAME, :P_GHOST_TYPE, :P_THREAT_LEVEL, 'Active',
        :P_DESCRIPTION, :P_MANIFESTATION_PATTERN, :v_confidence,
        CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
    );
    
    -- Log the registration
    INSERT INTO AUDIT_LOG (log_id, action, table_name, record_id, new_value, user_name, timestamp)
    VALUES (
        UUID_STRING(),
        'INSERT',
        'GHOSTS',
        :v_ghost_id,
        OBJECT_CONSTRUCT('ghost_name', :P_GHOST_NAME, 'ghost_type', :P_GHOST_TYPE),
        CURRENT_USER(),
        CURRENT_TIMESTAMP()
    );
    
    RETURN OBJECT_CONSTRUCT(
        'success', TRUE,
        'ghost_id', :v_ghost_id,
        'ai_suggested_type', :v_ai_classification,
        'confidence_score', :v_confidence
    );
END;

-- Update ghost status
CREATE OR REPLACE PROCEDURE UPDATE_GHOST_STATUS(
    P_GHOST_ID VARCHAR,
    P_NEW_STATUS VARCHAR,
    P_REASON VARCHAR DEFAULT NULL
)
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_old_status VARCHAR;
BEGIN
    -- Get current status
    SELECT status INTO v_old_status FROM GHOSTS WHERE ghost_id = :P_GHOST_ID;
    
    IF (v_old_status IS NULL) THEN
        RETURN OBJECT_CONSTRUCT('success', FALSE, 'error', 'Ghost not found');
    END IF;
    
    -- Update status
    UPDATE GHOSTS 
    SET status = :P_NEW_STATUS, 
        updated_at = CURRENT_TIMESTAMP()
    WHERE ghost_id = :P_GHOST_ID;
    
    -- Log the change
    INSERT INTO AUDIT_LOG (log_id, action, table_name, record_id, old_value, new_value, user_name, timestamp)
    VALUES (
        UUID_STRING(),
        'UPDATE',
        'GHOSTS',
        :P_GHOST_ID,
        OBJECT_CONSTRUCT('status', :v_old_status),
        OBJECT_CONSTRUCT('status', :P_NEW_STATUS, 'reason', :P_REASON),
        CURRENT_USER(),
        CURRENT_TIMESTAMP()
    );
    
    RETURN OBJECT_CONSTRUCT(
        'success', TRUE,
        'ghost_id', :P_GHOST_ID,
        'old_status', :v_old_status,
        'new_status', :P_NEW_STATUS
    );
END;

-- ============================================
-- SIGHTING MANAGEMENT PROCEDURES
-- ============================================

-- Record a new sighting
CREATE OR REPLACE PROCEDURE RECORD_SIGHTING(
    P_GHOST_ID VARCHAR,
    P_LOCATION_NAME VARCHAR,
    P_LOCATION_ADDRESS VARCHAR,
    P_LATITUDE FLOAT,
    P_LONGITUDE FLOAT,
    P_DESCRIPTION VARCHAR,
    P_WITNESS_NAME VARCHAR,
    P_WITNESS_CONTACT VARCHAR DEFAULT NULL,
    P_TEMPERATURE_CELSIUS FLOAT DEFAULT NULL,
    P_EMF_READING FLOAT DEFAULT NULL,
    P_ACTIVITY_LEVEL INT DEFAULT 5
)
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_sighting_id VARCHAR;
    v_sentiment FLOAT;
    v_env_conditions VARCHAR;
BEGIN
    -- Generate unique ID
    v_sighting_id := 'SIGHT' || TO_VARCHAR(UNIFORM(100000, 999999, RANDOM()));
    
    -- Analyze sentiment of the description (fear level)
    v_sentiment := SNOWFLAKE.CORTEX.SENTIMENT(:P_DESCRIPTION);
    
    -- Generate environmental conditions description
    v_env_conditions := CASE 
        WHEN :P_TEMPERATURE_CELSIUS < 5 THEN 'Cold spot detected'
        WHEN :P_EMF_READING > 5 THEN 'High EMF anomaly'
        ELSE 'Normal conditions'
    END;
    
    -- Insert the sighting
    INSERT INTO GHOST_SIGHTINGS (
        sighting_id, ghost_id, location_name, location_address,
        latitude, longitude, sighting_datetime, description,
        witness_name, witness_contact, environmental_conditions,
        temperature_celsius, emf_reading, paranormal_activity_level,
        verified, created_at
    ) VALUES (
        :v_sighting_id, :P_GHOST_ID, :P_LOCATION_NAME, :P_LOCATION_ADDRESS,
        :P_LATITUDE, :P_LONGITUDE, CURRENT_TIMESTAMP(), :P_DESCRIPTION,
        :P_WITNESS_NAME, :P_WITNESS_CONTACT, :v_env_conditions,
        :P_TEMPERATURE_CELSIUS, :P_EMF_READING, :P_ACTIVITY_LEVEL,
        FALSE, CURRENT_TIMESTAMP()
    );
    
    -- Update ghost's last_sighting
    UPDATE GHOSTS 
    SET last_sighting = CURRENT_TIMESTAMP(),
        updated_at = CURRENT_TIMESTAMP()
    WHERE ghost_id = :P_GHOST_ID;
    
    RETURN OBJECT_CONSTRUCT(
        'success', TRUE,
        'sighting_id', :v_sighting_id,
        'fear_level', :v_sentiment,
        'environmental_conditions', :v_env_conditions
    );
END;

-- Verify a sighting
CREATE OR REPLACE PROCEDURE VERIFY_SIGHTING(
    P_SIGHTING_ID VARCHAR,
    P_VERIFIED_BY VARCHAR,
    P_VERIFICATION_NOTES VARCHAR DEFAULT NULL
)
RETURNS VARIANT
LANGUAGE SQL
AS
BEGIN
    UPDATE GHOST_SIGHTINGS
    SET verified = TRUE
    WHERE sighting_id = :P_SIGHTING_ID;
    
    INSERT INTO AUDIT_LOG (log_id, action, table_name, record_id, new_value, user_name, timestamp)
    VALUES (
        UUID_STRING(),
        'VERIFY',
        'GHOST_SIGHTINGS',
        :P_SIGHTING_ID,
        OBJECT_CONSTRUCT('verified_by', :P_VERIFIED_BY, 'notes', :P_VERIFICATION_NOTES),
        CURRENT_USER(),
        CURRENT_TIMESTAMP()
    );
    
    RETURN OBJECT_CONSTRUCT('success', TRUE, 'sighting_id', :P_SIGHTING_ID, 'verified', TRUE);
END;

-- ============================================
-- INVESTIGATION MANAGEMENT PROCEDURES
-- ============================================

-- Create a new investigation
CREATE OR REPLACE PROCEDURE CREATE_INVESTIGATION(
    P_CASE_NAME VARCHAR,
    P_DESCRIPTION VARCHAR,
    P_GHOST_IDS ARRAY,
    P_LEAD_INVESTIGATOR VARCHAR,
    P_TEAM_MEMBERS ARRAY,
    P_PRIORITY VARCHAR DEFAULT 'Medium'
)
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_investigation_id VARCHAR;
BEGIN
    v_investigation_id := 'INV' || TO_VARCHAR(UNIFORM(100000, 999999, RANDOM()));
    
    INSERT INTO INVESTIGATIONS (
        investigation_id, case_name, description, ghost_ids,
        start_date, status, lead_investigator, team_members,
        priority, created_at, updated_at
    ) VALUES (
        :v_investigation_id, :P_CASE_NAME, :P_DESCRIPTION, :P_GHOST_IDS,
        CURRENT_DATE(), 'Open', :P_LEAD_INVESTIGATOR, :P_TEAM_MEMBERS,
        :P_PRIORITY, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
    );
    
    RETURN OBJECT_CONSTRUCT(
        'success', TRUE,
        'investigation_id', :v_investigation_id,
        'status', 'Open'
    );
END;

-- Close an investigation
CREATE OR REPLACE PROCEDURE CLOSE_INVESTIGATION(
    P_INVESTIGATION_ID VARCHAR,
    P_OUTCOME VARCHAR,
    P_SUMMARY VARCHAR DEFAULT NULL
)
RETURNS VARIANT
LANGUAGE SQL
AS
BEGIN
    UPDATE INVESTIGATIONS
    SET status = 'Closed',
        outcome = :P_OUTCOME,
        end_date = CURRENT_DATE(),
        updated_at = CURRENT_TIMESTAMP()
    WHERE investigation_id = :P_INVESTIGATION_ID;
    
    RETURN OBJECT_CONSTRUCT(
        'success', TRUE,
        'investigation_id', :P_INVESTIGATION_ID,
        'outcome', :P_OUTCOME
    );
END;

-- ============================================
-- AI-POWERED ANALYSIS PROCEDURES
-- ============================================

-- Generate comprehensive ghost report
CREATE OR REPLACE PROCEDURE GENERATE_GHOST_REPORT(P_GHOST_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
DECLARE
    v_ghost_data VARIANT;
    v_sighting_count INT;
    v_evidence_count INT;
    v_prompt VARCHAR;
    v_report VARCHAR;
BEGIN
    -- Gather ghost data
    SELECT OBJECT_CONSTRUCT(
        'ghost_id', ghost_id,
        'ghost_name', ghost_name,
        'ghost_type', ghost_type,
        'threat_level', threat_level,
        'status', status,
        'description', description,
        'manifestation_pattern', manifestation_pattern,
        'first_sighting', first_sighting,
        'last_sighting', last_sighting
    ) INTO v_ghost_data
    FROM GHOSTS WHERE ghost_id = :P_GHOST_ID;
    
    -- Get counts
    SELECT COUNT(*) INTO v_sighting_count FROM GHOST_SIGHTINGS WHERE ghost_id = :P_GHOST_ID;
    SELECT COUNT(*) INTO v_evidence_count FROM GHOST_EVIDENCE WHERE ghost_id = :P_GHOST_ID;
    
    -- Build prompt
    v_prompt := 'Generate a comprehensive paranormal investigation report for this ghost entity. Include threat assessment, behavioral analysis, and recommended containment strategies.

Ghost Data: ' || TO_VARCHAR(:v_ghost_data) || '
Total Sightings: ' || TO_VARCHAR(:v_sighting_count) || '
Evidence Items: ' || TO_VARCHAR(:v_evidence_count) || '

Format the report professionally with sections for: Overview, Threat Assessment, Behavioral Pattern Analysis, Evidence Summary, and Recommendations.';
    
    -- Generate report using Cortex
    v_report := SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', :v_prompt);
    
    -- Store the analysis
    INSERT INTO AI_ANALYSIS_RESULTS (
        analysis_id, source_type, source_id, model_name, analysis_type, 
        result, confidence_score, created_at
    ) VALUES (
        UUID_STRING(), 'GHOST', :P_GHOST_ID, 'mistral-large2', 'COMPREHENSIVE_REPORT',
        PARSE_JSON(OBJECT_CONSTRUCT('report', :v_report)), 0.85, CURRENT_TIMESTAMP()
    );
    
    RETURN v_report;
END;

-- Analyze threat level using AI
CREATE OR REPLACE PROCEDURE ANALYZE_THREAT_LEVEL(P_GHOST_ID VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_description VARCHAR;
    v_sighting_data ARRAY;
    v_analysis VARCHAR;
    v_threat_score FLOAT;
BEGIN
    -- Get ghost description
    SELECT description INTO v_description FROM GHOSTS WHERE ghost_id = :P_GHOST_ID;
    
    -- Get recent sighting descriptions
    SELECT ARRAY_AGG(description) INTO v_sighting_data
    FROM (
        SELECT description FROM GHOST_SIGHTINGS 
        WHERE ghost_id = :P_GHOST_ID 
        ORDER BY sighting_datetime DESC 
        LIMIT 10
    );
    
    -- AI analysis
    v_analysis := SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'Analyze the threat level of this paranormal entity based on the description and recent sightings. 
        Ghost Description: ' || COALESCE(:v_description, 'Unknown') || '
        Recent Sightings: ' || COALESCE(TO_VARCHAR(:v_sighting_data), 'None') || '
        
        Provide a threat score from 0.0 (harmless) to 1.0 (extremely dangerous), and explain your reasoning.'
    );
    
    -- Extract threat score (simplified - would use EXTRACT in production)
    v_threat_score := CASE 
        WHEN v_analysis ILIKE '%extremely dangerous%' OR v_analysis ILIKE '%1.0%' THEN 0.95
        WHEN v_analysis ILIKE '%very dangerous%' OR v_analysis ILIKE '%0.8%' OR v_analysis ILIKE '%0.9%' THEN 0.85
        WHEN v_analysis ILIKE '%dangerous%' OR v_analysis ILIKE '%0.6%' OR v_analysis ILIKE '%0.7%' THEN 0.65
        WHEN v_analysis ILIKE '%moderate%' OR v_analysis ILIKE '%0.4%' OR v_analysis ILIKE '%0.5%' THEN 0.45
        ELSE 0.25
    END;
    
    RETURN OBJECT_CONSTRUCT(
        'ghost_id', :P_GHOST_ID,
        'threat_score', :v_threat_score,
        'analysis', :v_analysis,
        'recommended_threat_level', CASE 
            WHEN :v_threat_score >= 0.8 THEN 'Extreme'
            WHEN :v_threat_score >= 0.6 THEN 'High'
            WHEN :v_threat_score >= 0.4 THEN 'Medium'
            ELSE 'Low'
        END
    );
END;

-- Classify ghost type from description
CREATE OR REPLACE PROCEDURE CLASSIFY_GHOST_TYPE(P_DESCRIPTION VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS
DECLARE
    v_classification VARCHAR;
BEGIN
    v_classification := SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'Based on this description of a paranormal encounter, classify the entity into exactly one of these types:
        - Apparition: A visible ghostly figure, often of a deceased person
        - Poltergeist: A noisy, mischievous spirit that moves objects
        - Shadow_Figure: A dark, shadowy humanoid form
        - Orb: A spherical ball of light or energy
        - Residual_Haunt: A recording-like replay of past events
        - Intelligent_Haunt: A spirit that interacts and responds to the living
        - Demonic: A malevolent non-human entity
        - Elemental: A spirit connected to nature or elements
        
        Description: ' || :P_DESCRIPTION || '
        
        Return a JSON object with: type, confidence (0-1), and reasoning.'
    );
    
    RETURN PARSE_JSON(:v_classification);
EXCEPTION
    WHEN OTHER THEN
        RETURN OBJECT_CONSTRUCT(
            'type', 'Unknown',
            'confidence', 0.0,
            'reasoning', 'Classification failed: ' || SQLERRM
        );
END;

-- Find similar sightings using embeddings
CREATE OR REPLACE PROCEDURE FIND_SIMILAR_SIGHTINGS(
    P_DESCRIPTION VARCHAR,
    P_LIMIT INT DEFAULT 5
)
RETURNS TABLE (
    sighting_id VARCHAR,
    ghost_name VARCHAR,
    location_name VARCHAR,
    description VARCHAR,
    similarity_score FLOAT
)
LANGUAGE SQL
AS
DECLARE
    v_embedding VECTOR(FLOAT, 1024);
BEGIN
    -- Generate embedding for input description
    v_embedding := SNOWFLAKE.CORTEX.EMBED_TEXT_1024('voyage-multilingual-2', :P_DESCRIPTION);
    
    -- Find similar sightings
    RETURN TABLE(
        SELECT 
            s.sighting_id,
            g.ghost_name,
            s.location_name,
            s.description,
            VECTOR_COSINE_SIMILARITY(:v_embedding, SNOWFLAKE.CORTEX.EMBED_TEXT_1024('voyage-multilingual-2', s.description)) AS similarity_score
        FROM GHOST_SIGHTINGS s
        JOIN GHOSTS g ON s.ghost_id = g.ghost_id
        WHERE s.description IS NOT NULL
        ORDER BY similarity_score DESC
        LIMIT :P_LIMIT
    );
END;

-- Summarize investigation findings
CREATE OR REPLACE PROCEDURE SUMMARIZE_INVESTIGATION(P_INVESTIGATION_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
DECLARE
    v_investigation VARIANT;
    v_ghost_names ARRAY;
    v_sighting_count INT;
    v_summary VARCHAR;
BEGIN
    -- Get investigation details
    SELECT OBJECT_CONSTRUCT(*) INTO v_investigation
    FROM INVESTIGATIONS WHERE investigation_id = :P_INVESTIGATION_ID;
    
    -- Get ghost names
    SELECT ARRAY_AGG(g.ghost_name) INTO v_ghost_names
    FROM GHOSTS g
    WHERE g.ghost_id IN (SELECT VALUE FROM TABLE(FLATTEN(input => :v_investigation:ghost_ids)));
    
    -- Get total sightings during investigation period
    SELECT COUNT(*) INTO v_sighting_count
    FROM GHOST_SIGHTINGS s
    WHERE s.ghost_id IN (SELECT VALUE FROM TABLE(FLATTEN(input => :v_investigation:ghost_ids)))
    AND s.sighting_datetime >= :v_investigation:start_date;
    
    -- Generate summary
    v_summary := SNOWFLAKE.CORTEX.SUMMARIZE(
        'Investigation: ' || :v_investigation:case_name || 
        '. Description: ' || :v_investigation:description ||
        '. Ghosts investigated: ' || ARRAY_TO_STRING(:v_ghost_names, ', ') ||
        '. Total sightings during investigation: ' || TO_VARCHAR(:v_sighting_count) ||
        '. Status: ' || :v_investigation:status ||
        '. Outcome: ' || COALESCE(:v_investigation:outcome, 'Pending')
    );
    
    RETURN v_summary;
END;

-- ============================================
-- UTILITY PROCEDURES
-- ============================================

-- Search business vocabulary
CREATE OR REPLACE PROCEDURE SEARCH_VOCABULARY(P_SEARCH_TERM VARCHAR)
RETURNS TABLE (
    term VARCHAR,
    category VARCHAR,
    definition VARCHAR,
    synonyms ARRAY,
    relevance_score FLOAT
)
LANGUAGE SQL
AS
BEGIN
    RETURN TABLE(
        SELECT 
            term,
            category,
            definition,
            synonyms,
            CASE 
                WHEN LOWER(term) = LOWER(:P_SEARCH_TERM) THEN 1.0
                WHEN LOWER(term) LIKE '%' || LOWER(:P_SEARCH_TERM) || '%' THEN 0.8
                WHEN LOWER(definition) LIKE '%' || LOWER(:P_SEARCH_TERM) || '%' THEN 0.6
                WHEN ARRAY_CONTAINS(:P_SEARCH_TERM::VARIANT, synonyms) THEN 0.7
                ELSE 0.3
            END AS relevance_score
        FROM BUSINESS_VOCABULARY
        WHERE LOWER(term) LIKE '%' || LOWER(:P_SEARCH_TERM) || '%'
           OR LOWER(definition) LIKE '%' || LOWER(:P_SEARCH_TERM) || '%'
           OR ARRAY_CONTAINS(:P_SEARCH_TERM::VARIANT, synonyms)
        ORDER BY relevance_score DESC
        LIMIT 20
    );
END;

-- Get paranormal hotspots
CREATE OR REPLACE PROCEDURE GET_PARANORMAL_HOTSPOTS(P_MIN_SIGHTINGS INT DEFAULT 3)
RETURNS TABLE (
    location_name VARCHAR,
    latitude FLOAT,
    longitude FLOAT,
    total_sightings INT,
    unique_ghosts INT,
    avg_activity_level FLOAT,
    max_threat_level VARCHAR,
    hotspot_classification VARCHAR
)
LANGUAGE SQL
AS
BEGIN
    RETURN TABLE(
        SELECT 
            s.location_name,
            AVG(s.latitude) AS latitude,
            AVG(s.longitude) AS longitude,
            COUNT(*) AS total_sightings,
            COUNT(DISTINCT s.ghost_id) AS unique_ghosts,
            AVG(s.paranormal_activity_level) AS avg_activity_level,
            MAX(g.threat_level) AS max_threat_level,
            CASE 
                WHEN COUNT(*) >= 10 AND AVG(s.paranormal_activity_level) >= 7 THEN 'Critical Hotspot'
                WHEN COUNT(*) >= 5 AND AVG(s.paranormal_activity_level) >= 5 THEN 'Major Hotspot'
                WHEN COUNT(*) >= :P_MIN_SIGHTINGS THEN 'Minor Hotspot'
                ELSE 'Low Activity'
            END AS hotspot_classification
        FROM GHOST_SIGHTINGS s
        JOIN GHOSTS g ON s.ghost_id = g.ghost_id
        GROUP BY s.location_name
        HAVING COUNT(*) >= :P_MIN_SIGHTINGS
        ORDER BY total_sightings DESC
    );
END;

-- Daily activity summary task procedure
CREATE OR REPLACE PROCEDURE GENERATE_DAILY_ACTIVITY_SUMMARY()
RETURNS VARCHAR
LANGUAGE SQL
AS
DECLARE
    v_summary VARIANT;
    v_report VARCHAR;
BEGIN
    -- Calculate daily metrics
    SELECT OBJECT_CONSTRUCT(
        'date', CURRENT_DATE(),
        'new_sightings', (SELECT COUNT(*) FROM GHOST_SIGHTINGS WHERE DATE(created_at) = CURRENT_DATE()),
        'active_ghosts', (SELECT COUNT(*) FROM GHOSTS WHERE status = 'Active'),
        'high_threat_count', (SELECT COUNT(*) FROM GHOSTS WHERE status = 'Active' AND threat_level IN ('High', 'Extreme')),
        'open_investigations', (SELECT COUNT(*) FROM INVESTIGATIONS WHERE status IN ('Open', 'In_Progress')),
        'evidence_collected', (SELECT COUNT(*) FROM GHOST_EVIDENCE WHERE DATE(created_at) = CURRENT_DATE())
    ) INTO v_summary;
    
    -- Generate narrative summary
    v_report := SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'Generate a brief daily activity summary for a paranormal investigation organization based on these metrics: ' || TO_VARCHAR(:v_summary)
    );
    
    RETURN v_report;
END;

-- Grant execute permissions
GRANT USAGE ON PROCEDURE REGISTER_GHOST(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO ROLE GHOSTBUSTER;
GRANT USAGE ON PROCEDURE UPDATE_GHOST_STATUS(VARCHAR, VARCHAR, VARCHAR) TO ROLE GHOSTBUSTER;
GRANT USAGE ON PROCEDURE RECORD_SIGHTING(VARCHAR, VARCHAR, VARCHAR, FLOAT, FLOAT, VARCHAR, VARCHAR, VARCHAR, FLOAT, FLOAT, INT) TO ROLE GHOSTBUSTER;
GRANT USAGE ON PROCEDURE VERIFY_SIGHTING(VARCHAR, VARCHAR, VARCHAR) TO ROLE GHOST_ADMIN;
GRANT USAGE ON PROCEDURE CREATE_INVESTIGATION(VARCHAR, VARCHAR, ARRAY, VARCHAR, ARRAY, VARCHAR) TO ROLE GHOST_ADMIN;
GRANT USAGE ON PROCEDURE CLOSE_INVESTIGATION(VARCHAR, VARCHAR, VARCHAR) TO ROLE GHOST_ADMIN;
GRANT USAGE ON PROCEDURE GENERATE_GHOST_REPORT(VARCHAR) TO ROLE GHOSTBUSTER;
GRANT USAGE ON PROCEDURE ANALYZE_THREAT_LEVEL(VARCHAR) TO ROLE GHOSTBUSTER;
GRANT USAGE ON PROCEDURE CLASSIFY_GHOST_TYPE(VARCHAR) TO ROLE GHOSTBUSTER;
GRANT USAGE ON PROCEDURE SUMMARIZE_INVESTIGATION(VARCHAR) TO ROLE GHOSTBUSTER;
GRANT USAGE ON PROCEDURE SEARCH_VOCABULARY(VARCHAR) TO ROLE GHOSTBUSTER;
GRANT USAGE ON PROCEDURE GET_PARANORMAL_HOTSPOTS(INT) TO ROLE GHOSTBUSTER;
