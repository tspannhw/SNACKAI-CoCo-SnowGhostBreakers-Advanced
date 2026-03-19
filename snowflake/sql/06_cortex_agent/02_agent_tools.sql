-- ============================================================================
-- SnowGhostBreakers - Agent Tool Functions
-- ============================================================================
-- Purpose: SQL functions that can be used by the Cortex Agent or called directly
-- Author: SnowGhostBreakers Team
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Prerequisites
-- ----------------------------------------------------------------------------

USE ROLE SYSADMIN;
USE WAREHOUSE GHOST_DETECTION_WH;
USE DATABASE GHOST_DETECTION;
USE SCHEMA AI;

-- ----------------------------------------------------------------------------
-- GENERATE_THREAT_ASSESSMENT
-- Generates an AI-powered threat assessment for a specific ghost entity
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION GHOST_DETECTION.AI.GENERATE_THREAT_ASSESSMENT(
  P_GHOST_ID VARCHAR
)
RETURNS TABLE (
  ghost_id VARCHAR,
  ghost_name VARCHAR,
  threat_level INT,
  assessment_summary VARCHAR,
  risk_factors ARRAY,
  recommended_actions ARRAY,
  containment_protocol VARCHAR,
  team_size_recommendation INT,
  equipment_recommendations ARRAY,
  assessment_timestamp TIMESTAMP_NTZ
)
LANGUAGE SQL
COMMENT = 'Generates a comprehensive threat assessment for a ghost entity based on historical data'
AS
$$
  WITH ghost_data AS (
    SELECT 
      g.ghost_id,
      g.ghost_name,
      g.ghost_type,
      g.threat_level,
      g.status,
      g.description,
      g.abilities,
      g.weaknesses,
      COUNT(DISTINCT s.sighting_id) AS total_sightings,
      COUNT(DISTINCT CASE WHEN s.sighting_timestamp >= DATEADD(day, -30, CURRENT_TIMESTAMP()) 
                         THEN s.sighting_id END) AS recent_sightings,
      MAX(s.sighting_timestamp) AS last_seen,
      AVG(s.witness_credibility_score) AS avg_credibility,
      COUNT(DISTINCT e.evidence_id) AS evidence_count
    FROM GHOST_DETECTION.APP.GHOSTS g
    LEFT JOIN GHOST_DETECTION.APP.GHOST_SIGHTINGS s ON g.ghost_id = s.ghost_id
    LEFT JOIN GHOST_DETECTION.APP.EVIDENCE e ON s.sighting_id = e.sighting_id
    WHERE g.ghost_id = P_GHOST_ID
    GROUP BY g.ghost_id, g.ghost_name, g.ghost_type, g.threat_level, 
             g.status, g.description, g.abilities, g.weaknesses
  ),
  assessment AS (
    SELECT
      ghost_id,
      ghost_name,
      threat_level,
      -- Generate assessment summary
      CASE 
        WHEN threat_level >= 5 THEN 
          'CRITICAL THREAT - ' || ghost_name || ' is classified as extremely dangerous. ' ||
          'Immediate action required with full team deployment.'
        WHEN threat_level >= 4 THEN 
          'HIGH THREAT - ' || ghost_name || ' poses significant danger. ' ||
          'Team engagement required with specialized equipment.'
        WHEN threat_level >= 3 THEN 
          'MODERATE THREAT - ' || ghost_name || ' requires caution. ' ||
          'Standard investigation protocols apply.'
        WHEN threat_level >= 2 THEN 
          'LOW THREAT - ' || ghost_name || ' is generally non-aggressive. ' ||
          'Standard observation protocols recommended.'
        ELSE 
          'MINIMAL THREAT - ' || ghost_name || ' poses little danger. ' ||
          'Basic monitoring sufficient.'
      END AS assessment_summary,
      -- Risk factors based on data
      ARRAY_CONSTRUCT_COMPACT(
        CASE WHEN threat_level >= 4 THEN 'High base threat level' END,
        CASE WHEN recent_sightings > 5 THEN 'Increased recent activity (' || recent_sightings || ' sightings in 30 days)' END,
        CASE WHEN ghost_type IN ('poltergeist', 'demon', 'wraith') THEN 'Aggressive entity type: ' || ghost_type END,
        CASE WHEN status = 'ACTIVE' THEN 'Currently active status' END,
        CASE WHEN avg_credibility > 0.8 THEN 'High-confidence sighting reports' END
      ) AS risk_factors,
      -- Recommended actions
      ARRAY_CONSTRUCT_COMPACT(
        CASE WHEN threat_level >= 4 THEN 'Assemble full investigation team before engagement' END,
        CASE WHEN threat_level >= 3 THEN 'Review all historical sighting data' END,
        CASE WHEN recent_sightings > 3 THEN 'Establish surveillance at recent sighting locations' END,
        CASE WHEN evidence_count < 3 THEN 'Prioritize evidence collection' END,
        'Document all interactions thoroughly',
        'Maintain communication with base at all times'
      ) AS recommended_actions,
      -- Containment protocol
      CASE 
        WHEN threat_level >= 5 THEN 'PROTOCOL OMEGA - Maximum containment required'
        WHEN threat_level >= 4 THEN 'PROTOCOL ALPHA - Full team containment'
        WHEN threat_level >= 3 THEN 'PROTOCOL BETA - Standard containment'
        WHEN threat_level >= 2 THEN 'PROTOCOL GAMMA - Light containment'
        ELSE 'PROTOCOL DELTA - Observation only'
      END AS containment_protocol,
      -- Team size recommendation
      CASE 
        WHEN threat_level >= 5 THEN 6
        WHEN threat_level >= 4 THEN 4
        WHEN threat_level >= 3 THEN 3
        WHEN threat_level >= 2 THEN 2
        ELSE 1
      END AS team_size_recommendation,
      -- Equipment recommendations
      ARRAY_CONSTRUCT_COMPACT(
        'EMF detector',
        'Thermal camera',
        CASE WHEN threat_level >= 3 THEN 'Spirit containment device' END,
        CASE WHEN threat_level >= 4 THEN 'Protective barrier equipment' END,
        CASE WHEN threat_level >= 5 THEN 'Emergency evacuation gear' END,
        CASE WHEN ghost_type = 'poltergeist' THEN 'Object tracking sensors' END,
        CASE WHEN ghost_type IN ('specter', 'apparition') THEN 'Full spectrum camera' END
      ) AS equipment_recommendations,
      CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS assessment_timestamp
    FROM ghost_data
  )
  SELECT * FROM assessment
$$;

-- Grant execute permission
GRANT USAGE ON FUNCTION GHOST_DETECTION.AI.GENERATE_THREAT_ASSESSMENT(VARCHAR) 
  TO ROLE GHOST_INVESTIGATOR;

-- ----------------------------------------------------------------------------
-- GENERATE_INVESTIGATION_REPORT
-- Generates a comprehensive investigation report
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION GHOST_DETECTION.AI.GENERATE_INVESTIGATION_REPORT(
  P_INVESTIGATION_ID VARCHAR
)
RETURNS TABLE (
  investigation_id VARCHAR,
  report_title VARCHAR,
  executive_summary VARCHAR,
  investigation_details OBJECT,
  sighting_summary OBJECT,
  evidence_summary OBJECT,
  ghost_profiles ARRAY,
  timeline ARRAY,
  conclusions VARCHAR,
  recommendations VARCHAR,
  report_generated_at TIMESTAMP_NTZ
)
LANGUAGE SQL
COMMENT = 'Generates a full investigation report with all related data'
AS
$$
  WITH investigation_base AS (
    SELECT 
      i.*,
      DATEDIFF(day, i.start_date, COALESCE(i.end_date, CURRENT_DATE())) AS duration_days
    FROM GHOST_DETECTION.APP.INVESTIGATIONS i
    WHERE i.investigation_id = P_INVESTIGATION_ID
  ),
  related_sightings AS (
    SELECT 
      investigation_id,
      COUNT(*) AS sighting_count,
      COUNT(DISTINCT ghost_id) AS unique_ghosts,
      MIN(sighting_timestamp) AS first_sighting,
      MAX(sighting_timestamp) AS last_sighting,
      AVG(witness_credibility_score) AS avg_credibility
    FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS
    WHERE investigation_id = P_INVESTIGATION_ID
    GROUP BY investigation_id
  ),
  related_evidence AS (
    SELECT 
      investigation_id,
      COUNT(*) AS evidence_count,
      COUNT(DISTINCT evidence_type) AS evidence_types,
      AVG(authenticity_score) AS avg_authenticity,
      ARRAY_AGG(DISTINCT evidence_type) AS evidence_type_list
    FROM GHOST_DETECTION.APP.EVIDENCE
    WHERE investigation_id = P_INVESTIGATION_ID
    GROUP BY investigation_id
  ),
  involved_ghosts AS (
    SELECT 
      s.investigation_id,
      ARRAY_AGG(DISTINCT OBJECT_CONSTRUCT(
        'ghost_id', g.ghost_id,
        'ghost_name', g.ghost_name,
        'ghost_type', g.ghost_type,
        'threat_level', g.threat_level
      )) AS ghost_list
    FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
    JOIN GHOST_DETECTION.APP.GHOSTS g ON s.ghost_id = g.ghost_id
    WHERE s.investigation_id = P_INVESTIGATION_ID
    GROUP BY s.investigation_id
  ),
  event_timeline AS (
    SELECT 
      investigation_id,
      ARRAY_AGG(OBJECT_CONSTRUCT(
        'timestamp', event_timestamp,
        'event_type', event_type,
        'description', event_description
      )) WITHIN GROUP (ORDER BY event_timestamp) AS timeline
    FROM (
      SELECT 
        investigation_id,
        sighting_timestamp AS event_timestamp,
        'SIGHTING' AS event_type,
        CONCAT('Sighting reported at ', location_name) AS event_description
      FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS
      WHERE investigation_id = P_INVESTIGATION_ID
      UNION ALL
      SELECT 
        investigation_id,
        collection_timestamp AS event_timestamp,
        'EVIDENCE' AS event_type,
        CONCAT(evidence_type, ' evidence collected') AS event_description
      FROM GHOST_DETECTION.APP.EVIDENCE
      WHERE investigation_id = P_INVESTIGATION_ID
    ) events
    GROUP BY investigation_id
  )
  SELECT
    i.investigation_id,
    CONCAT('Investigation Report: ', i.case_name) AS report_title,
    CONCAT(
      'Investigation "', i.case_name, '" conducted at ', i.location_name,
      ' over ', i.duration_days, ' days. ',
      'Status: ', i.investigation_status, '. ',
      COALESCE(i.summary, 'Summary pending.')
    ) AS executive_summary,
    OBJECT_CONSTRUCT(
      'case_name', i.case_name,
      'status', i.investigation_status,
      'lead_investigator', i.lead_investigator,
      'team_members', i.team_members,
      'location', i.location_name,
      'start_date', i.start_date,
      'end_date', i.end_date,
      'duration_days', i.duration_days
    ) AS investigation_details,
    OBJECT_CONSTRUCT(
      'total_sightings', COALESCE(rs.sighting_count, 0),
      'unique_ghosts', COALESCE(rs.unique_ghosts, 0),
      'first_sighting', rs.first_sighting,
      'last_sighting', rs.last_sighting,
      'average_credibility', ROUND(rs.avg_credibility, 2)
    ) AS sighting_summary,
    OBJECT_CONSTRUCT(
      'total_evidence', COALESCE(re.evidence_count, 0),
      'evidence_types', COALESCE(re.evidence_types, 0),
      'type_list', re.evidence_type_list,
      'average_authenticity', ROUND(re.avg_authenticity, 2)
    ) AS evidence_summary,
    ig.ghost_list AS ghost_profiles,
    et.timeline,
    i.findings AS conclusions,
    i.recommendations,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS report_generated_at
  FROM investigation_base i
  LEFT JOIN related_sightings rs ON i.investigation_id = rs.investigation_id
  LEFT JOIN related_evidence re ON i.investigation_id = re.investigation_id
  LEFT JOIN involved_ghosts ig ON i.investigation_id = ig.investigation_id
  LEFT JOIN event_timeline et ON i.investigation_id = et.investigation_id
$$;

-- Grant execute permission
GRANT USAGE ON FUNCTION GHOST_DETECTION.AI.GENERATE_INVESTIGATION_REPORT(VARCHAR) 
  TO ROLE GHOST_INVESTIGATOR;

-- ----------------------------------------------------------------------------
-- FIND_SIMILAR_ENTITIES
-- Uses text similarity to find ghosts matching a description
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION GHOST_DETECTION.AI.FIND_SIMILAR_ENTITIES(
  P_DESCRIPTION VARCHAR,
  P_LIMIT INT DEFAULT 5
)
RETURNS TABLE (
  ghost_id VARCHAR,
  ghost_name VARCHAR,
  ghost_type VARCHAR,
  threat_level INT,
  description VARCHAR,
  similarity_score FLOAT,
  match_reasoning VARCHAR
)
LANGUAGE SQL
COMMENT = 'Finds ghost entities similar to the provided description using text analysis'
AS
$$
  WITH description_tokens AS (
    SELECT 
      LOWER(P_DESCRIPTION) AS search_desc,
      SPLIT(LOWER(P_DESCRIPTION), ' ') AS tokens
  ),
  ghost_scores AS (
    SELECT 
      g.ghost_id,
      g.ghost_name,
      g.ghost_type,
      g.threat_level,
      g.description,
      -- Calculate similarity based on keyword matching
      (
        CASE WHEN LOWER(g.ghost_name) LIKE '%' || LOWER(P_DESCRIPTION) || '%' THEN 0.3 ELSE 0 END +
        CASE WHEN LOWER(g.ghost_type) LIKE '%' || LOWER(P_DESCRIPTION) || '%' THEN 0.2 ELSE 0 END +
        CASE WHEN LOWER(g.description) LIKE '%' || LOWER(P_DESCRIPTION) || '%' THEN 0.3 ELSE 0 END +
        -- Add points for each matching word
        (SELECT COUNT(*) FROM description_tokens dt, LATERAL FLATTEN(dt.tokens) t 
         WHERE LOWER(g.description) LIKE '%' || t.value || '%'
           AND LENGTH(t.value) > 2) * 0.05
      ) AS base_score
    FROM GHOST_DETECTION.APP.GHOSTS g
    WHERE g.status != 'DELETED'
  )
  SELECT 
    ghost_id,
    ghost_name,
    ghost_type,
    threat_level,
    description,
    ROUND(LEAST(base_score, 1.0), 3) AS similarity_score,
    CASE 
      WHEN base_score >= 0.5 THEN 'Strong match based on description and type'
      WHEN base_score >= 0.3 THEN 'Moderate match with some keyword overlap'
      WHEN base_score >= 0.1 THEN 'Weak match - partial keyword alignment'
      ELSE 'Minimal similarity detected'
    END AS match_reasoning
  FROM ghost_scores
  WHERE base_score > 0
  ORDER BY base_score DESC
  LIMIT P_LIMIT
$$;

-- Grant execute permission
GRANT USAGE ON FUNCTION GHOST_DETECTION.AI.FIND_SIMILAR_ENTITIES(VARCHAR, INT) 
  TO ROLE GHOST_INVESTIGATOR;
GRANT USAGE ON FUNCTION GHOST_DETECTION.AI.FIND_SIMILAR_ENTITIES(VARCHAR, INT) 
  TO ROLE GHOST_ANALYST;

-- ----------------------------------------------------------------------------
-- CLASSIFY_SIGHTING
-- Classifies a sighting report and suggests ghost type and threat level
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION GHOST_DETECTION.AI.CLASSIFY_SIGHTING(
  P_DESCRIPTION VARCHAR,
  P_ENVIRONMENTAL_CONDITIONS VARCHAR DEFAULT NULL,
  P_WITNESS_COUNT INT DEFAULT 1
)
RETURNS TABLE (
  suggested_ghost_type VARCHAR,
  suggested_threat_level INT,
  confidence_score FLOAT,
  classification_reasoning VARCHAR,
  similar_past_sightings INT,
  recommended_follow_up ARRAY
)
LANGUAGE SQL
COMMENT = 'Classifies a sighting description and suggests entity type and threat level'
AS
$$
  WITH classification AS (
    SELECT
      -- Determine ghost type from keywords
      CASE 
        WHEN LOWER(P_DESCRIPTION) LIKE '%object%moving%' OR LOWER(P_DESCRIPTION) LIKE '%throwing%' 
          OR LOWER(P_DESCRIPTION) LIKE '%furniture%' THEN 'poltergeist'
        WHEN LOWER(P_DESCRIPTION) LIKE '%transparent%' OR LOWER(P_DESCRIPTION) LIKE '%see through%'
          OR LOWER(P_DESCRIPTION) LIKE '%fading%' THEN 'apparition'
        WHEN LOWER(P_DESCRIPTION) LIKE '%shadow%' OR LOWER(P_DESCRIPTION) LIKE '%dark figure%'
          OR LOWER(P_DESCRIPTION) LIKE '%silhouette%' THEN 'shadow_entity'
        WHEN LOWER(P_DESCRIPTION) LIKE '%mist%' OR LOWER(P_DESCRIPTION) LIKE '%fog%'
          OR LOWER(P_DESCRIPTION) LIKE '%vapor%' THEN 'specter'
        WHEN LOWER(P_DESCRIPTION) LIKE '%voice%' OR LOWER(P_DESCRIPTION) LIKE '%whisper%'
          OR LOWER(P_DESCRIPTION) LIKE '%sound%' THEN 'residual_haunting'
        WHEN LOWER(P_DESCRIPTION) LIKE '%attack%' OR LOWER(P_DESCRIPTION) LIKE '%scratch%'
          OR LOWER(P_DESCRIPTION) LIKE '%hostile%' THEN 'malevolent_spirit'
        WHEN LOWER(P_DESCRIPTION) LIKE '%child%' OR LOWER(P_DESCRIPTION) LIKE '%crying%' THEN 'child_spirit'
        WHEN LOWER(P_DESCRIPTION) LIKE '%orb%' OR LOWER(P_DESCRIPTION) LIKE '%light%ball%' THEN 'orb_entity'
        ELSE 'unknown_entity'
      END AS ghost_type,
      -- Determine threat level
      CASE 
        WHEN LOWER(P_DESCRIPTION) LIKE '%attack%' OR LOWER(P_DESCRIPTION) LIKE '%violent%'
          OR LOWER(P_DESCRIPTION) LIKE '%dangerous%' THEN 4
        WHEN LOWER(P_DESCRIPTION) LIKE '%aggressive%' OR LOWER(P_DESCRIPTION) LIKE '%hostile%'
          OR LOWER(P_DESCRIPTION) LIKE '%threatening%' THEN 3
        WHEN LOWER(P_DESCRIPTION) LIKE '%scary%' OR LOWER(P_DESCRIPTION) LIKE '%frightening%' THEN 2
        WHEN LOWER(P_DESCRIPTION) LIKE '%friendly%' OR LOWER(P_DESCRIPTION) LIKE '%peaceful%' THEN 1
        ELSE 2
      END AS threat_level,
      -- Calculate confidence
      CASE 
        WHEN P_WITNESS_COUNT >= 3 THEN 0.9
        WHEN P_WITNESS_COUNT = 2 THEN 0.7
        ELSE 0.5
      END AS base_confidence
  ),
  similar_sightings AS (
    SELECT COUNT(*) AS similar_count
    FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
    JOIN GHOST_DETECTION.APP.GHOSTS g ON s.ghost_id = g.ghost_id
    WHERE g.ghost_type = (SELECT ghost_type FROM classification)
  )
  SELECT 
    c.ghost_type AS suggested_ghost_type,
    c.threat_level AS suggested_threat_level,
    ROUND(c.base_confidence + 
      CASE WHEN ss.similar_count > 10 THEN 0.1 ELSE 0 END, 2) AS confidence_score,
    CONCAT(
      'Based on description keywords, this appears to be a ', c.ghost_type, 
      ' with estimated threat level ', c.threat_level, '/5. ',
      CASE 
        WHEN c.threat_level >= 4 THEN 'CAUTION: High threat indicators detected.'
        WHEN c.threat_level >= 3 THEN 'Moderate threat - proceed with care.'
        ELSE 'Low threat - standard protocols apply.'
      END
    ) AS classification_reasoning,
    ss.similar_count AS similar_past_sightings,
    ARRAY_CONSTRUCT(
      'Document with photos/video if possible',
      'Interview all witnesses separately',
      CASE WHEN c.threat_level >= 3 THEN 'Deploy EMF and thermal equipment' END,
      CASE WHEN c.ghost_type = 'poltergeist' THEN 'Secure loose objects in area' END,
      'Cross-reference with local historical records'
    ) AS recommended_follow_up
  FROM classification c
  CROSS JOIN similar_sightings ss
$$;

-- Grant execute permission
GRANT USAGE ON FUNCTION GHOST_DETECTION.AI.CLASSIFY_SIGHTING(VARCHAR, VARCHAR, INT) 
  TO ROLE GHOST_INVESTIGATOR;
GRANT USAGE ON FUNCTION GHOST_DETECTION.AI.CLASSIFY_SIGHTING(VARCHAR, VARCHAR, INT) 
  TO ROLE GHOST_ANALYST;

-- ----------------------------------------------------------------------------
-- GET_ACTIVITY_HOTSPOTS
-- Identifies locations with highest paranormal activity
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION GHOST_DETECTION.AI.GET_ACTIVITY_HOTSPOTS(
  P_DAYS_BACK INT DEFAULT 30,
  P_MIN_SIGHTINGS INT DEFAULT 3,
  P_LIMIT INT DEFAULT 10
)
RETURNS TABLE (
  location_name VARCHAR,
  sighting_count INT,
  unique_ghosts INT,
  avg_threat_level FLOAT,
  max_threat_level INT,
  most_recent_sighting TIMESTAMP_NTZ,
  primary_ghost_type VARCHAR,
  risk_assessment VARCHAR
)
LANGUAGE SQL
COMMENT = 'Identifies paranormal activity hotspots based on recent sighting density'
AS
$$
  WITH location_activity AS (
    SELECT 
      s.location_name,
      COUNT(DISTINCT s.sighting_id) AS sighting_count,
      COUNT(DISTINCT s.ghost_id) AS unique_ghosts,
      AVG(g.threat_level) AS avg_threat,
      MAX(g.threat_level) AS max_threat,
      MAX(s.sighting_timestamp) AS last_sighting,
      MODE(g.ghost_type) AS common_ghost_type
    FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
    JOIN GHOST_DETECTION.APP.GHOSTS g ON s.ghost_id = g.ghost_id
    WHERE s.sighting_timestamp >= DATEADD(day, -P_DAYS_BACK, CURRENT_TIMESTAMP())
      AND s.location_name IS NOT NULL
    GROUP BY s.location_name
    HAVING COUNT(DISTINCT s.sighting_id) >= P_MIN_SIGHTINGS
  )
  SELECT 
    location_name,
    sighting_count,
    unique_ghosts,
    ROUND(avg_threat, 2) AS avg_threat_level,
    max_threat AS max_threat_level,
    last_sighting::TIMESTAMP_NTZ AS most_recent_sighting,
    common_ghost_type AS primary_ghost_type,
    CASE 
      WHEN max_threat >= 4 OR avg_threat >= 3 THEN 
        'HIGH RISK - Dangerous activity detected. Full team required.'
      WHEN max_threat >= 3 OR avg_threat >= 2 THEN 
        'MODERATE RISK - Increased activity. Exercise caution.'
      ELSE 
        'LOW RISK - Normal activity levels. Standard monitoring.'
    END AS risk_assessment
  FROM location_activity
  ORDER BY sighting_count DESC, avg_threat DESC
  LIMIT P_LIMIT
$$;

-- Grant execute permission
GRANT USAGE ON FUNCTION GHOST_DETECTION.AI.GET_ACTIVITY_HOTSPOTS(INT, INT, INT) 
  TO ROLE GHOST_INVESTIGATOR;
GRANT USAGE ON FUNCTION GHOST_DETECTION.AI.GET_ACTIVITY_HOTSPOTS(INT, INT, INT) 
  TO ROLE GHOST_ANALYST;

-- ----------------------------------------------------------------------------
-- Verification
-- ----------------------------------------------------------------------------

-- Show all created functions
SHOW USER FUNCTIONS IN SCHEMA GHOST_DETECTION.AI;

-- ============================================================================
-- End of Agent Tool Functions
-- ============================================================================
