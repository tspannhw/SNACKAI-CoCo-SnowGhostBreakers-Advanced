/*
================================================================================
SnowGhostBreakers - Core Tables Script
================================================================================
Description: Creates core application tables for ghost detection, sightings,
             evidence, investigations, sensor readings, and AI analysis.
Author: SnowGhostBreakers Team
Created: 2024
Prerequisites: Run 01_setup/01_database_setup.sql first
================================================================================
*/

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;
USE WAREHOUSE GHOST_DETECTION_WH;

-- ============================================================================
-- TABLE 1: GHOSTS
-- Description: Master table for tracked ghosts and paranormal entities
-- ============================================================================

CREATE OR REPLACE TABLE GHOSTS (
    -- Primary Key
    GHOST_ID            NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each ghost entity',
    
    -- Core Identification
    GHOST_NAME          VARCHAR(200) NOT NULL
                        COMMENT 'Name or designation of the ghost (e.g., "The Gray Lady", "Slimer")',
    GHOST_TYPE          VARCHAR(100) NOT NULL
                        COMMENT 'Classification type (e.g., Poltergeist, Apparition, Specter, Demon)',
    
    -- Threat Assessment
    THREAT_LEVEL        VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN'
                        COMMENT 'Threat classification: BENIGN, LOW, MEDIUM, HIGH, CRITICAL, UNKNOWN'
                        CHECK (THREAT_LEVEL IN ('BENIGN', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL', 'UNKNOWN')),
    STATUS              VARCHAR(50) NOT NULL DEFAULT 'ACTIVE'
                        COMMENT 'Current status: ACTIVE, CONTAINED, NEUTRALIZED, DORMANT, UNKNOWN'
                        CHECK (STATUS IN ('ACTIVE', 'CONTAINED', 'NEUTRALIZED', 'DORMANT', 'UNKNOWN')),
    
    -- Detailed Information
    DESCRIPTION         VARCHAR(4000)
                        COMMENT 'Detailed description of the ghost, behavior, and characteristics',
    FIRST_SIGHTING      TIMESTAMP_NTZ
                        COMMENT 'Date and time of first documented sighting',
    LAST_SIGHTING       TIMESTAMP_NTZ
                        COMMENT 'Date and time of most recent sighting',
    MANIFESTATION_PATTERN VARCHAR(500)
                        COMMENT 'Known patterns of appearance (e.g., "Full moons", "Midnight", "Anniversaries")',
    
    -- Confidence Metrics
    CONFIDENCE_SCORE    NUMBER(5,2) DEFAULT 0.00
                        COMMENT 'AI confidence score for entity classification (0.00 - 100.00)'
                        CHECK (CONFIDENCE_SCORE >= 0 AND CONFIDENCE_SCORE <= 100),
    
    -- Audit Fields
    CREATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record creation timestamp',
    UPDATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record last update timestamp'
)
COMMENT = 'Master table containing all documented ghost entities and paranormal beings tracked by SnowGhostBreakers'
CLUSTER BY (GHOST_TYPE, THREAT_LEVEL);

-- Create index-like clustering for common queries
ALTER TABLE GHOSTS CLUSTER BY (STATUS, THREAT_LEVEL);

-- ============================================================================
-- TABLE 2: GHOST_SIGHTINGS
-- Description: Individual sighting reports with location and environmental data
-- ============================================================================

CREATE OR REPLACE TABLE GHOST_SIGHTINGS (
    -- Primary Key
    SIGHTING_ID         NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each sighting report',
    
    -- Foreign Key to Ghost
    GHOST_ID            NUMBER(38,0)
                        COMMENT 'Reference to the identified ghost (NULL if unidentified)'
                        REFERENCES GHOSTS(GHOST_ID),
    
    -- Location Information
    LOCATION_NAME       VARCHAR(300) NOT NULL
                        COMMENT 'Name of the sighting location (e.g., "Sedgwick Hotel", "Central Park")',
    LOCATION_ADDRESS    VARCHAR(500)
                        COMMENT 'Full address of the sighting location',
    LATITUDE            NUMBER(10,7)
                        COMMENT 'GPS latitude coordinate of sighting location',
    LONGITUDE           NUMBER(10,7)
                        COMMENT 'GPS longitude coordinate of sighting location',
    
    -- Sighting Details
    SIGHTING_DATETIME   TIMESTAMP_NTZ NOT NULL
                        COMMENT 'Date and time when the sighting occurred',
    DESCRIPTION         VARCHAR(4000) NOT NULL
                        COMMENT 'Detailed description of what was witnessed',
    
    -- Witness Information
    WITNESS_NAME        VARCHAR(200)
                        COMMENT 'Name of the primary witness',
    WITNESS_CONTACT     VARCHAR(300)
                        COMMENT 'Contact information for the witness (email/phone)',
    
    -- Environmental Conditions
    ENVIRONMENTAL_CONDITIONS VARCHAR(500)
                        COMMENT 'Weather and environmental conditions during sighting',
    TEMPERATURE_CELSIUS NUMBER(5,2)
                        COMMENT 'Ambient temperature at time of sighting in Celsius',
    EMF_READING         NUMBER(10,4)
                        COMMENT 'Electromagnetic field reading in milligauss',
    PARANORMAL_ACTIVITY_LEVEL VARCHAR(20) DEFAULT 'LOW'
                        COMMENT 'Assessed paranormal activity level: NONE, LOW, MODERATE, HIGH, EXTREME'
                        CHECK (PARANORMAL_ACTIVITY_LEVEL IN ('NONE', 'LOW', 'MODERATE', 'HIGH', 'EXTREME')),
    
    -- Verification
    VERIFIED            BOOLEAN DEFAULT FALSE
                        COMMENT 'Whether the sighting has been verified by investigators',
    
    -- Audit Fields
    CREATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record creation timestamp'
)
COMMENT = 'Individual ghost sighting reports with location, witness, and environmental data'
CLUSTER BY (SIGHTING_DATETIME, GHOST_ID);

-- ============================================================================
-- TABLE 3: GHOST_EVIDENCE
-- Description: Evidence files and media captured during sightings
-- ============================================================================

CREATE OR REPLACE TABLE GHOST_EVIDENCE (
    -- Primary Key
    EVIDENCE_ID         NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each piece of evidence',
    
    -- Foreign Keys
    GHOST_ID            NUMBER(38,0)
                        COMMENT 'Reference to the associated ghost (if identified)'
                        REFERENCES GHOSTS(GHOST_ID),
    SIGHTING_ID         NUMBER(38,0)
                        COMMENT 'Reference to the associated sighting report'
                        REFERENCES GHOST_SIGHTINGS(SIGHTING_ID),
    
    -- Evidence Classification
    EVIDENCE_TYPE       VARCHAR(50) NOT NULL
                        COMMENT 'Type of evidence: PHOTO, VIDEO, AUDIO, EMF_LOG, THERMAL, DOCUMENT, OTHER'
                        CHECK (EVIDENCE_TYPE IN ('PHOTO', 'VIDEO', 'AUDIO', 'EMF_LOG', 'THERMAL', 'DOCUMENT', 'OTHER')),
    
    -- File Information
    FILE_PATH           VARCHAR(1000)
                        COMMENT 'Internal file path or stage location',
    FILE_URL            VARCHAR(2000)
                        COMMENT 'Public or signed URL for accessing the evidence file',
    DESCRIPTION         VARCHAR(2000)
                        COMMENT 'Description of what the evidence shows or contains',
    CAPTURED_DATETIME   TIMESTAMP_NTZ
                        COMMENT 'When the evidence was captured',
    FILE_SIZE_BYTES     NUMBER(38,0)
                        COMMENT 'Size of the evidence file in bytes',
    
    -- Structured Metadata
    METADATA            VARIANT
                        COMMENT 'JSON metadata: camera settings, device info, EXIF data, etc.',
    
    -- AI Analysis Results
    AI_ANALYSIS         VARIANT
                        COMMENT 'JSON results from AI analysis: detected entities, classifications, confidence scores',
    
    -- Audit Fields
    CREATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record creation timestamp'
)
COMMENT = 'Evidence files and media associated with ghost sightings including AI analysis results'
CLUSTER BY (EVIDENCE_TYPE, CAPTURED_DATETIME);

-- ============================================================================
-- TABLE 4: INVESTIGATIONS
-- Description: Investigation cases tracking multiple ghosts and team assignments
-- ============================================================================

CREATE OR REPLACE TABLE INVESTIGATIONS (
    -- Primary Key
    INVESTIGATION_ID    NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each investigation case',
    
    -- Case Information
    CASE_NAME           VARCHAR(300) NOT NULL
                        COMMENT 'Name or title of the investigation case',
    DESCRIPTION         VARCHAR(4000)
                        COMMENT 'Detailed description of the investigation scope and objectives',
    
    -- Associated Ghosts (Array for multiple ghosts per investigation)
    GHOST_IDS           ARRAY
                        COMMENT 'Array of GHOST_IDs being investigated in this case',
    
    -- Timeline
    START_DATE          DATE NOT NULL
                        COMMENT 'Investigation start date',
    END_DATE            DATE
                        COMMENT 'Investigation end date (NULL if ongoing)',
    
    -- Status and Priority
    STATUS              VARCHAR(50) NOT NULL DEFAULT 'PENDING'
                        COMMENT 'Investigation status: PENDING, IN_PROGRESS, ON_HOLD, COMPLETED, CANCELLED'
                        CHECK (STATUS IN ('PENDING', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'CANCELLED')),
    PRIORITY            VARCHAR(20) NOT NULL DEFAULT 'MEDIUM'
                        COMMENT 'Investigation priority: LOW, MEDIUM, HIGH, CRITICAL'
                        CHECK (PRIORITY IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    
    -- Team Assignment
    LEAD_INVESTIGATOR   VARCHAR(200) NOT NULL
                        COMMENT 'Name of the lead investigator responsible for the case',
    TEAM_MEMBERS        ARRAY
                        COMMENT 'Array of team member names assigned to the investigation',
    
    -- Results
    OUTCOME             VARCHAR(4000)
                        COMMENT 'Summary of investigation outcome and findings',
    
    -- Audit Fields
    CREATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record creation timestamp',
    UPDATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record last update timestamp'
)
COMMENT = 'Investigation cases tracking ghost hunting operations, team assignments, and outcomes'
CLUSTER BY (STATUS, PRIORITY);

-- ============================================================================
-- TABLE 5: SENSOR_READINGS
-- Description: Sensor data from paranormal detection equipment
-- ============================================================================

CREATE OR REPLACE TABLE SENSOR_READINGS (
    -- Primary Key
    READING_ID          NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each sensor reading',
    
    -- Foreign Key to Evidence
    EVIDENCE_ID         NUMBER(38,0)
                        COMMENT 'Reference to associated evidence record'
                        REFERENCES GHOST_EVIDENCE(EVIDENCE_ID),
    
    -- Reading Information
    READING_DATETIME    TIMESTAMP_NTZ NOT NULL
                        COMMENT 'Timestamp when the reading was captured',
    SENSOR_TYPE         VARCHAR(100) NOT NULL
                        COMMENT 'Type of sensor: EMF, THERMAL, MOTION, AUDIO_SPECTRUM, RADIATION, PRESSURE, HUMIDITY'
                        CHECK (SENSOR_TYPE IN ('EMF', 'THERMAL', 'MOTION', 'AUDIO_SPECTRUM', 'RADIATION', 'PRESSURE', 'HUMIDITY', 'OTHER')),
    
    -- Reading Value
    VALUE               NUMBER(20,6) NOT NULL
                        COMMENT 'Numeric value of the sensor reading',
    UNIT                VARCHAR(50) NOT NULL
                        COMMENT 'Unit of measurement (e.g., mG, Celsius, dB, Hz)',
    
    -- Anomaly Detection
    ANOMALY_DETECTED    BOOLEAN DEFAULT FALSE
                        COMMENT 'Whether the reading indicates anomalous/paranormal activity',
    
    -- Audit Fields
    CREATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record creation timestamp'
)
COMMENT = 'Time-series sensor readings from paranormal detection equipment with anomaly flags'
CLUSTER BY (READING_DATETIME, SENSOR_TYPE);

-- ============================================================================
-- TABLE 6: AI_ANALYSIS_RESULTS
-- Description: Results from Cortex AI/ML analysis operations
-- ============================================================================

CREATE OR REPLACE TABLE AI_ANALYSIS_RESULTS (
    -- Primary Key
    ANALYSIS_ID         NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each AI analysis result',
    
    -- Source Reference
    SOURCE_TYPE         VARCHAR(50) NOT NULL
                        COMMENT 'Type of source analyzed: GHOST, SIGHTING, EVIDENCE, SENSOR_READING, TEXT'
                        CHECK (SOURCE_TYPE IN ('GHOST', 'SIGHTING', 'EVIDENCE', 'SENSOR_READING', 'TEXT')),
    SOURCE_ID           NUMBER(38,0)
                        COMMENT 'ID of the source record in its respective table',
    
    -- Model Information
    MODEL_NAME          VARCHAR(100) NOT NULL
                        COMMENT 'Name of the AI model used (e.g., claude-3.5-sonnet, llama3.2-70b)',
    ANALYSIS_TYPE       VARCHAR(100) NOT NULL
                        COMMENT 'Type of analysis: CLASSIFICATION, ENTITY_EXTRACTION, SUMMARIZATION, SENTIMENT, IMAGE_ANALYSIS, ANOMALY_DETECTION'
                        CHECK (ANALYSIS_TYPE IN ('CLASSIFICATION', 'ENTITY_EXTRACTION', 'SUMMARIZATION', 'SENTIMENT', 'IMAGE_ANALYSIS', 'ANOMALY_DETECTION', 'EMBEDDING', 'TRANSLATION', 'OTHER')),
    
    -- Results
    RESULT              VARIANT NOT NULL
                        COMMENT 'JSON result containing analysis output, predictions, and extracted data',
    CONFIDENCE_SCORE    NUMBER(5,4)
                        COMMENT 'Overall confidence score of the analysis (0.0000 - 1.0000)',
    
    -- Performance Metrics
    TOKENS_USED         NUMBER(38,0)
                        COMMENT 'Number of tokens consumed by the AI model',
    LATENCY_MS          NUMBER(38,0)
                        COMMENT 'Processing latency in milliseconds',
    
    -- Audit Fields
    CREATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record creation timestamp'
)
COMMENT = 'Results from Snowflake Cortex AI/ML analysis including classification, entity extraction, and image analysis'
CLUSTER BY (ANALYSIS_TYPE, CREATED_AT);

-- ============================================================================
-- ADDITIONAL INDEXES AND CLUSTERING
-- ============================================================================

-- Optimize GHOST_SIGHTINGS for date-based queries
ALTER TABLE GHOST_SIGHTINGS CLUSTER BY (TO_DATE(SIGHTING_DATETIME), VERIFIED);

-- Optimize INVESTIGATIONS for status lookups
ALTER TABLE INVESTIGATIONS CLUSTER BY (STATUS, START_DATE);

-- ============================================================================
-- CREATE SEQUENCES (if needed for external ID generation)
-- ============================================================================

CREATE OR REPLACE SEQUENCE GHOST_SEQ START = 1000 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE SIGHTING_SEQ START = 1000 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE EVIDENCE_SEQ START = 1000 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE INVESTIGATION_SEQ START = 1000 INCREMENT = 1;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify all tables created
SHOW TABLES IN SCHEMA GHOST_DETECTION.APP;

-- Describe each table structure
DESCRIBE TABLE GHOSTS;
DESCRIBE TABLE GHOST_SIGHTINGS;
DESCRIBE TABLE GHOST_EVIDENCE;
DESCRIBE TABLE INVESTIGATIONS;
DESCRIBE TABLE SENSOR_READINGS;
DESCRIBE TABLE AI_ANALYSIS_RESULTS;

/*
================================================================================
CORE TABLES CREATED
================================================================================
Tables Created:
1. GHOSTS - Master ghost entity registry
2. GHOST_SIGHTINGS - Individual sighting reports
3. GHOST_EVIDENCE - Evidence files and AI analysis
4. INVESTIGATIONS - Investigation case management
5. SENSOR_READINGS - Paranormal sensor data
6. AI_ANALYSIS_RESULTS - Cortex AI analysis results

Next Steps:
1. Run 02_vocabulary_tables.sql to create vocabulary/ontology tables
2. Run 03_audit_tables.sql to create audit logging tables
================================================================================
*/
