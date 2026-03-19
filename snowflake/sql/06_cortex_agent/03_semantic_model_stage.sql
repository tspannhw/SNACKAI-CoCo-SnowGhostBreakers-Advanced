-- ============================================================================
-- SnowGhostBreakers - Semantic Model Stage Setup
-- ============================================================================
-- Purpose: Create stage and deploy semantic model YAML for Cortex Agent
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
-- Create Stage for Semantic Models
-- ----------------------------------------------------------------------------

CREATE STAGE IF NOT EXISTS GHOST_DETECTION.AI.SEMANTIC_MODELS
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Stage for storing semantic model YAML files for Cortex Agent and Analyst';

-- Grant access to the stage
GRANT READ ON STAGE GHOST_DETECTION.AI.SEMANTIC_MODELS TO ROLE GHOST_ANALYST;
GRANT READ ON STAGE GHOST_DETECTION.AI.SEMANTIC_MODELS TO ROLE GHOST_INVESTIGATOR;

-- ----------------------------------------------------------------------------
-- Upload Semantic Model YAML
-- Note: This creates the YAML content and provides instructions for upload
-- ----------------------------------------------------------------------------

-- The semantic model YAML file should be uploaded using:
-- PUT file://path/to/ghost_semantic_model.yaml @GHOST_DETECTION.AI.SEMANTIC_MODELS AUTO_COMPRESS=FALSE;

-- For development, you can create the file content directly:
-- snowsql -q "PUT file://ghost_semantic_model.yaml @GHOST_DETECTION.AI.SEMANTIC_MODELS AUTO_COMPRESS=FALSE OVERWRITE=TRUE"

-- ----------------------------------------------------------------------------
-- Create the Semantic Model YAML content as a stored procedure for deployment
-- ----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE GHOST_DETECTION.AI.DEPLOY_SEMANTIC_MODEL()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'deploy_model'
COMMENT = 'Deploys the ghost detection semantic model YAML to the stage'
AS
$$
def deploy_model(session):
    """
    Creates and uploads the semantic model YAML file to the stage.
    """
    
    semantic_model_yaml = '''# ============================================================================
# SnowGhostBreakers Semantic Model
# ============================================================================
# Purpose: Semantic model for Cortex Analyst and Agent natural language queries
# Version: 1.0
# ============================================================================

name: ghost_detection_semantic_model
description: >
  Semantic model for the SnowGhostBreakers paranormal investigation database.
  Enables natural language queries about ghosts, sightings, evidence, and investigations.

# ----------------------------------------------------------------------------
# Database Connection
# ----------------------------------------------------------------------------
database: GHOST_DETECTION
schema: APP

# ----------------------------------------------------------------------------
# Tables
# ----------------------------------------------------------------------------
tables:

  # GHOSTS table - Core entity profiles
  - name: GHOSTS
    description: Registry of known paranormal entities with threat assessments
    base_table: GHOST_DETECTION.APP.GHOSTS
    primary_key: ghost_id
    
    dimensions:
      - name: ghost_id
        description: Unique identifier for the ghost entity
        expr: ghost_id
        data_type: VARCHAR
        
      - name: ghost_name
        description: Name or designation of the ghost
        expr: ghost_name
        data_type: VARCHAR
        synonyms:
          - name
          - entity name
          - spirit name
          
      - name: ghost_type
        description: Classification type of the paranormal entity
        expr: ghost_type
        data_type: VARCHAR
        synonyms:
          - type
          - entity type
          - classification
          - kind
          
      - name: status
        description: Current status of the entity (ACTIVE, CONTAINED, DORMANT, BANISHED)
        expr: status
        data_type: VARCHAR
        synonyms:
          - current status
          - state
          
      - name: description
        description: Detailed description of the ghost's appearance and behavior
        expr: description
        data_type: VARCHAR
        
      - name: first_sighted_date
        description: Date when the entity was first documented
        expr: first_sighted_date
        data_type: DATE
        synonyms:
          - first seen
          - discovery date
          
      - name: last_activity_date
        description: Most recent date of confirmed activity
        expr: last_activity_date
        data_type: DATE
        synonyms:
          - last seen
          - recent activity
          
    measures:
      - name: threat_level
        description: Danger rating from 1 (harmless) to 5 (extremely dangerous)
        expr: threat_level
        data_type: NUMBER
        synonyms:
          - danger level
          - risk level
          - threat rating
          
      - name: ghost_count
        description: Count of ghost entities
        expr: COUNT(DISTINCT ghost_id)
        data_type: NUMBER
        synonyms:
          - number of ghosts
          - entity count
          - how many ghosts

  # GHOST_SIGHTINGS table - Sighting reports
  - name: GHOST_SIGHTINGS
    description: Documented sighting reports from witnesses and investigators
    base_table: GHOST_DETECTION.APP.GHOST_SIGHTINGS
    primary_key: sighting_id
    
    dimensions:
      - name: sighting_id
        description: Unique identifier for the sighting report
        expr: sighting_id
        data_type: VARCHAR
        
      - name: ghost_id
        description: Reference to the ghost entity sighted
        expr: ghost_id
        data_type: VARCHAR
        
      - name: location_name
        description: Name of the location where sighting occurred
        expr: location_name
        data_type: VARCHAR
        synonyms:
          - location
          - place
          - where
          
      - name: sighting_timestamp
        description: Date and time of the sighting
        expr: sighting_timestamp
        data_type: TIMESTAMP_NTZ
        synonyms:
          - when
          - date
          - time
          
      - name: witness_name
        description: Name of the primary witness
        expr: witness_name
        data_type: VARCHAR
        synonyms:
          - witness
          - reported by
          
      - name: description
        description: Detailed description of what was witnessed
        expr: description
        data_type: VARCHAR
        synonyms:
          - report
          - account
          - what happened
          
      - name: environmental_conditions
        description: Weather and environmental conditions during sighting
        expr: environmental_conditions
        data_type: VARCHAR
        synonyms:
          - conditions
          - weather
          - environment
          
      - name: is_verified
        description: Whether the sighting has been verified by investigators
        expr: is_verified
        data_type: BOOLEAN
        synonyms:
          - verified
          - confirmed
          
    measures:
      - name: witness_credibility_score
        description: Credibility rating of the witness (0-1 scale)
        expr: witness_credibility_score
        data_type: FLOAT
        synonyms:
          - credibility
          - reliability
          
      - name: sighting_count
        description: Count of sightings
        expr: COUNT(DISTINCT sighting_id)
        data_type: NUMBER
        synonyms:
          - number of sightings
          - how many sightings
          - sightings count

  # EVIDENCE table - Collected evidence items
  - name: EVIDENCE
    description: Evidence collected during investigations
    base_table: GHOST_DETECTION.APP.EVIDENCE
    primary_key: evidence_id
    
    dimensions:
      - name: evidence_id
        description: Unique identifier for the evidence item
        expr: evidence_id
        data_type: VARCHAR
        
      - name: evidence_type
        description: Type of evidence (photo, video, audio, EMF, physical)
        expr: evidence_type
        data_type: VARCHAR
        synonyms:
          - type
          - kind
          - category
          
      - name: analysis_status
        description: Current analysis status (PENDING, IN_PROGRESS, COMPLETED, INCONCLUSIVE)
        expr: analysis_status
        data_type: VARCHAR
        synonyms:
          - status
          - state
          
      - name: collected_by
        description: Name of the investigator who collected the evidence
        expr: collected_by
        data_type: VARCHAR
        synonyms:
          - collector
          - investigator
          
      - name: collection_timestamp
        description: When the evidence was collected
        expr: collection_timestamp
        data_type: TIMESTAMP_NTZ
        synonyms:
          - collected when
          - date collected
          
    measures:
      - name: authenticity_score
        description: Calculated authenticity score (0-1 scale)
        expr: authenticity_score
        data_type: FLOAT
        synonyms:
          - authenticity
          - validity score
          
      - name: evidence_count
        description: Count of evidence items
        expr: COUNT(DISTINCT evidence_id)
        data_type: NUMBER
        synonyms:
          - number of evidence
          - how much evidence

  # INVESTIGATIONS table - Case files
  - name: INVESTIGATIONS
    description: Investigation case files and their outcomes
    base_table: GHOST_DETECTION.APP.INVESTIGATIONS
    primary_key: investigation_id
    
    dimensions:
      - name: investigation_id
        description: Unique identifier for the investigation
        expr: investigation_id
        data_type: VARCHAR
        
      - name: case_name
        description: Name or title of the investigation case
        expr: case_name
        data_type: VARCHAR
        synonyms:
          - case
          - name
          - title
          
      - name: investigation_status
        description: Current status (PLANNING, ACTIVE, ON_HOLD, COMPLETED, CLOSED)
        expr: investigation_status
        data_type: VARCHAR
        synonyms:
          - status
          - state
          
      - name: lead_investigator
        description: Primary investigator assigned to the case
        expr: lead_investigator
        data_type: VARCHAR
        synonyms:
          - lead
          - investigator
          - assigned to
          
      - name: location_name
        description: Primary location being investigated
        expr: location_name
        data_type: VARCHAR
        synonyms:
          - location
          - place
          - site
          
      - name: start_date
        description: When the investigation began
        expr: start_date
        data_type: DATE
        synonyms:
          - started
          - begin date
          
      - name: end_date
        description: When the investigation concluded
        expr: end_date
        data_type: DATE
        synonyms:
          - ended
          - completion date
          
    measures:
      - name: investigation_count
        description: Count of investigations
        expr: COUNT(DISTINCT investigation_id)
        data_type: NUMBER
        synonyms:
          - number of investigations
          - how many cases
          - case count

# ----------------------------------------------------------------------------
# Relationships
# ----------------------------------------------------------------------------
relationships:
  - name: ghost_to_sightings
    left_table: GHOSTS
    right_table: GHOST_SIGHTINGS
    relationship_type: one_to_many
    join_condition: GHOSTS.ghost_id = GHOST_SIGHTINGS.ghost_id
    
  - name: sighting_to_evidence
    left_table: GHOST_SIGHTINGS
    right_table: EVIDENCE
    relationship_type: one_to_many
    join_condition: GHOST_SIGHTINGS.sighting_id = EVIDENCE.sighting_id
    
  - name: investigation_to_evidence
    left_table: INVESTIGATIONS
    right_table: EVIDENCE
    relationship_type: one_to_many
    join_condition: INVESTIGATIONS.investigation_id = EVIDENCE.investigation_id
    
  - name: investigation_to_sightings
    left_table: INVESTIGATIONS
    right_table: GHOST_SIGHTINGS
    relationship_type: one_to_many
    join_condition: INVESTIGATIONS.investigation_id = GHOST_SIGHTINGS.investigation_id

# ----------------------------------------------------------------------------
# Verified Queries (Sample questions and expected SQL)
# ----------------------------------------------------------------------------
verified_queries:
  - question: "How many ghosts are in the database?"
    sql: "SELECT COUNT(DISTINCT ghost_id) AS ghost_count FROM GHOST_DETECTION.APP.GHOSTS"
    
  - question: "What are the most dangerous ghosts?"
    sql: "SELECT ghost_name, threat_level FROM GHOST_DETECTION.APP.GHOSTS WHERE threat_level >= 4 ORDER BY threat_level DESC"
    
  - question: "How many sightings happened this month?"
    sql: "SELECT COUNT(*) AS sighting_count FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS WHERE sighting_timestamp >= DATE_TRUNC('month', CURRENT_DATE())"
    
  - question: "Which locations have the most activity?"
    sql: "SELECT location_name, COUNT(*) AS sighting_count FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS GROUP BY location_name ORDER BY sighting_count DESC LIMIT 10"
    
  - question: "What investigations are currently active?"
    sql: "SELECT case_name, lead_investigator, location_name FROM GHOST_DETECTION.APP.INVESTIGATIONS WHERE investigation_status = 'ACTIVE'"
    
  - question: "Show me all poltergeist sightings"
    sql: "SELECT s.*, g.ghost_name FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s JOIN GHOST_DETECTION.APP.GHOSTS g ON s.ghost_id = g.ghost_id WHERE g.ghost_type = 'poltergeist'"
'''
    
    # Write to stage using Snowpark
    import io
    
    # Create a temporary file-like object
    yaml_bytes = semantic_model_yaml.encode('utf-8')
    
    # Use session to put the file
    session.file.put_stream(
        io.BytesIO(yaml_bytes),
        '@GHOST_DETECTION.AI.SEMANTIC_MODELS/ghost_semantic_model.yaml',
        auto_compress=False,
        overwrite=True
    )
    
    return "Semantic model deployed successfully to @GHOST_DETECTION.AI.SEMANTIC_MODELS/ghost_semantic_model.yaml"
$$;

-- Grant execute on the deployment procedure
GRANT USAGE ON PROCEDURE GHOST_DETECTION.AI.DEPLOY_SEMANTIC_MODEL() TO ROLE SYSADMIN;

-- ----------------------------------------------------------------------------
-- Execute the deployment
-- ----------------------------------------------------------------------------

-- Deploy the semantic model
CALL GHOST_DETECTION.AI.DEPLOY_SEMANTIC_MODEL();

-- ----------------------------------------------------------------------------
-- Verify the deployment
-- ----------------------------------------------------------------------------

-- List files in the stage
LIST @GHOST_DETECTION.AI.SEMANTIC_MODELS;

-- Optionally, view the file contents
-- SELECT $1 FROM @GHOST_DETECTION.AI.SEMANTIC_MODELS/ghost_semantic_model.yaml;

-- ----------------------------------------------------------------------------
-- Alternative: Manual YAML Upload Instructions
-- ----------------------------------------------------------------------------
/*
If you prefer to upload the YAML file manually:

1. Save the YAML content (from the Python procedure above) to a local file:
   ghost_semantic_model.yaml

2. Use SnowSQL or Snowflake CLI to upload:
   
   Using SnowSQL:
   PUT file://./ghost_semantic_model.yaml @GHOST_DETECTION.AI.SEMANTIC_MODELS 
       AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
   
   Using Snowflake CLI:
   snow stage copy ./ghost_semantic_model.yaml @GHOST_DETECTION.AI.SEMANTIC_MODELS 
       --overwrite

3. Verify the upload:
   LIST @GHOST_DETECTION.AI.SEMANTIC_MODELS;
*/

-- ----------------------------------------------------------------------------
-- Validate Semantic Model (Optional)
-- ----------------------------------------------------------------------------

-- You can validate the semantic model using Cortex tools:
-- SELECT SNOWFLAKE.CORTEX.VALIDATE_SEMANTIC_MODEL('@GHOST_DETECTION.AI.SEMANTIC_MODELS/ghost_semantic_model.yaml');

-- ============================================================================
-- End of Semantic Model Stage Setup
-- ============================================================================
