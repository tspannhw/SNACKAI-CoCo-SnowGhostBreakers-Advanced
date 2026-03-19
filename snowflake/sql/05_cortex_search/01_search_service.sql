-- ============================================================================
-- SnowGhostBreakers - Cortex Search Services
-- ============================================================================
-- Purpose: Create Cortex Search services for semantic search across ghost data
-- Author: SnowGhostBreakers Team
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Prerequisites: Ensure the warehouse and schemas exist
-- ----------------------------------------------------------------------------

USE ROLE SYSADMIN;
USE WAREHOUSE GHOST_DETECTION_WH;
USE DATABASE GHOST_DETECTION;
USE SCHEMA AI;

-- ----------------------------------------------------------------------------
-- Ghost Search Service
-- Enables semantic search across ghost profiles including name, type, and
-- descriptions for quick entity discovery
-- ----------------------------------------------------------------------------

CREATE OR REPLACE CORTEX SEARCH SERVICE GHOST_DETECTION.AI.GHOST_SEARCH_SERVICE
  ON ghost_searchable_text
  WAREHOUSE = GHOST_DETECTION_WH
  TARGET_LAG = '1 hour'
AS (
  SELECT 
    ghost_id,
    ghost_name,
    ghost_type,
    threat_level,
    status,
    description,
    first_sighted_date,
    last_activity_date,
    -- Composite searchable text field combining key attributes
    CONCAT(
      COALESCE(ghost_name, ''), ' ',
      COALESCE(ghost_type, ''), ' ',
      'threat level ', COALESCE(CAST(threat_level AS VARCHAR), ''), ' ',
      COALESCE(status, ''), ' ',
      COALESCE(description, '')
    ) AS ghost_searchable_text
  FROM GHOST_DETECTION.APP.GHOSTS
  WHERE status != 'DELETED'  -- Exclude deleted records from search
);

-- Grant search access to appropriate roles
GRANT USAGE ON CORTEX SEARCH SERVICE GHOST_DETECTION.AI.GHOST_SEARCH_SERVICE 
  TO ROLE GHOST_ANALYST;
GRANT USAGE ON CORTEX SEARCH SERVICE GHOST_DETECTION.AI.GHOST_SEARCH_SERVICE 
  TO ROLE GHOST_INVESTIGATOR;

-- ----------------------------------------------------------------------------
-- Sighting Search Service
-- Enables semantic search across sighting reports including location,
-- witness information, and detailed descriptions
-- ----------------------------------------------------------------------------

CREATE OR REPLACE CORTEX SEARCH SERVICE GHOST_DETECTION.AI.SIGHTING_SEARCH_SERVICE
  ON sighting_searchable_text
  WAREHOUSE = GHOST_DETECTION_WH
  TARGET_LAG = '1 hour'
AS (
  SELECT
    s.sighting_id,
    s.ghost_id,
    g.ghost_name,
    g.ghost_type,
    g.threat_level,
    s.location_name,
    s.latitude,
    s.longitude,
    s.sighting_timestamp,
    s.description AS sighting_description,
    s.witness_name,
    s.witness_credibility_score,
    s.environmental_conditions,
    -- Composite searchable text for comprehensive sighting search
    CONCAT(
      COALESCE(g.ghost_name, 'Unknown entity'), ' ',
      COALESCE(g.ghost_type, ''), ' ',
      'sighted at ', COALESCE(s.location_name, 'unknown location'), ' ',
      'by ', COALESCE(s.witness_name, 'anonymous witness'), ' ',
      COALESCE(s.description, ''), ' ',
      COALESCE(s.environmental_conditions, '')
    ) AS sighting_searchable_text
  FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
  LEFT JOIN GHOST_DETECTION.APP.GHOSTS g ON s.ghost_id = g.ghost_id
  WHERE s.is_verified IS DISTINCT FROM FALSE  -- Include verified and unverified
);

-- Grant search access
GRANT USAGE ON CORTEX SEARCH SERVICE GHOST_DETECTION.AI.SIGHTING_SEARCH_SERVICE 
  TO ROLE GHOST_ANALYST;
GRANT USAGE ON CORTEX SEARCH SERVICE GHOST_DETECTION.AI.SIGHTING_SEARCH_SERVICE 
  TO ROLE GHOST_INVESTIGATOR;

-- ----------------------------------------------------------------------------
-- Evidence Search Service
-- Enables semantic search across collected evidence including photos,
-- audio recordings, EMF readings, and physical samples
-- ----------------------------------------------------------------------------

CREATE OR REPLACE CORTEX SEARCH SERVICE GHOST_DETECTION.AI.EVIDENCE_SEARCH_SERVICE
  ON evidence_searchable_text
  WAREHOUSE = GHOST_DETECTION_WH
  TARGET_LAG = '1 hour'
AS (
  SELECT
    e.evidence_id,
    e.sighting_id,
    e.investigation_id,
    e.evidence_type,
    e.description AS evidence_description,
    e.collected_by,
    e.collection_timestamp,
    e.analysis_status,
    e.analysis_notes,
    e.authenticity_score,
    s.location_name,
    g.ghost_name,
    -- Composite searchable text for evidence discovery
    CONCAT(
      COALESCE(e.evidence_type, ''), ' evidence ',
      COALESCE(e.description, ''), ' ',
      'collected by ', COALESCE(e.collected_by, 'unknown'), ' ',
      'at ', COALESCE(s.location_name, 'unknown location'), ' ',
      'related to ', COALESCE(g.ghost_name, 'unknown entity'), ' ',
      COALESCE(e.analysis_notes, '')
    ) AS evidence_searchable_text
  FROM GHOST_DETECTION.APP.EVIDENCE e
  LEFT JOIN GHOST_DETECTION.APP.GHOST_SIGHTINGS s ON e.sighting_id = s.sighting_id
  LEFT JOIN GHOST_DETECTION.APP.GHOSTS g ON s.ghost_id = g.ghost_id
);

-- Grant search access
GRANT USAGE ON CORTEX SEARCH SERVICE GHOST_DETECTION.AI.EVIDENCE_SEARCH_SERVICE 
  TO ROLE GHOST_ANALYST;
GRANT USAGE ON CORTEX SEARCH SERVICE GHOST_DETECTION.AI.EVIDENCE_SEARCH_SERVICE 
  TO ROLE GHOST_INVESTIGATOR;

-- ----------------------------------------------------------------------------
-- Investigation Search Service
-- Enables semantic search across investigation case files
-- ----------------------------------------------------------------------------

CREATE OR REPLACE CORTEX SEARCH SERVICE GHOST_DETECTION.AI.INVESTIGATION_SEARCH_SERVICE
  ON investigation_searchable_text
  WAREHOUSE = GHOST_DETECTION_WH
  TARGET_LAG = '1 hour'
AS (
  SELECT
    i.investigation_id,
    i.case_name,
    i.investigation_status,
    i.lead_investigator,
    i.team_members,
    i.start_date,
    i.end_date,
    i.location_name,
    i.summary,
    i.findings,
    i.recommendations,
    -- Composite searchable text for investigation discovery
    CONCAT(
      'Case: ', COALESCE(i.case_name, ''), ' ',
      'Status: ', COALESCE(i.investigation_status, ''), ' ',
      'Lead: ', COALESCE(i.lead_investigator, ''), ' ',
      'Location: ', COALESCE(i.location_name, ''), ' ',
      COALESCE(i.summary, ''), ' ',
      COALESCE(i.findings, ''), ' ',
      COALESCE(i.recommendations, '')
    ) AS investigation_searchable_text
  FROM GHOST_DETECTION.APP.INVESTIGATIONS i
);

-- Grant search access
GRANT USAGE ON CORTEX SEARCH SERVICE GHOST_DETECTION.AI.INVESTIGATION_SEARCH_SERVICE 
  TO ROLE GHOST_ANALYST;
GRANT USAGE ON CORTEX SEARCH SERVICE GHOST_DETECTION.AI.INVESTIGATION_SEARCH_SERVICE 
  TO ROLE GHOST_INVESTIGATOR;

-- ----------------------------------------------------------------------------
-- Verification Queries
-- ----------------------------------------------------------------------------

-- Verify search services were created
SHOW CORTEX SEARCH SERVICES IN SCHEMA GHOST_DETECTION.AI;

-- Test ghost search (example query)
-- SELECT * FROM TABLE(
--   GHOST_DETECTION.AI.GHOST_SEARCH_SERVICE!SEARCH(
--     query => 'dangerous poltergeist',
--     columns => ['ghost_id', 'ghost_name', 'threat_level', 'description'],
--     limit => 5
--   )
-- );

-- Test sighting search (example query)
-- SELECT * FROM TABLE(
--   GHOST_DETECTION.AI.SIGHTING_SEARCH_SERVICE!SEARCH(
--     query => 'cemetery apparition at night',
--     columns => ['sighting_id', 'ghost_name', 'location_name', 'sighting_description'],
--     limit => 5
--   )
-- );

-- ============================================================================
-- End of Cortex Search Service Definitions
-- ============================================================================
