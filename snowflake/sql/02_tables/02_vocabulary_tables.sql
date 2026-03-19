/*
================================================================================
SnowGhostBreakers - Vocabulary and Ontology Tables Script
================================================================================
Description: Creates business vocabulary and taxonomy tables for standardized
             terminology and ghost classification ontology.
Author: SnowGhostBreakers Team
Created: 2024
Prerequisites: Run 01_setup/01_database_setup.sql first
================================================================================
*/

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;
USE WAREHOUSE GHOST_DETECTION_WH;

-- ============================================================================
-- TABLE 1: BUSINESS_VOCABULARY
-- Description: Centralized business terminology for consistent communication
--              and AI/semantic model alignment
-- ============================================================================

CREATE OR REPLACE TABLE BUSINESS_VOCABULARY (
    -- Primary Key
    TERM_ID             NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each vocabulary term',
    
    -- Term Information
    TERM                VARCHAR(200) NOT NULL UNIQUE
                        COMMENT 'The canonical term or phrase (e.g., "Threat Level", "EMF Reading")',
    CATEGORY            VARCHAR(100) NOT NULL
                        COMMENT 'Category grouping: ENTITY, MEASUREMENT, STATUS, LOCATION, ACTION, EQUIPMENT, ROLE'
                        CHECK (CATEGORY IN ('ENTITY', 'MEASUREMENT', 'STATUS', 'LOCATION', 'ACTION', 'EQUIPMENT', 'ROLE', 'CLASSIFICATION', 'OTHER')),
    
    -- Definition and Context
    DEFINITION          VARCHAR(2000) NOT NULL
                        COMMENT 'Clear definition of the term in the ghost detection context',
    
    -- Related Terms (for semantic search and AI understanding)
    SYNONYMS            ARRAY
                        COMMENT 'Array of synonyms and alternate names (e.g., ["specter", "spirit", "phantom"])',
    RELATED_TERMS       ARRAY
                        COMMENT 'Array of related terms for semantic linking (e.g., ["haunting", "manifestation"])',
    
    -- Domain Classification
    DOMAIN              VARCHAR(100) NOT NULL DEFAULT 'GENERAL'
                        COMMENT 'Business domain: GENERAL, INVESTIGATION, ANALYSIS, EQUIPMENT, SAFETY, LEGAL'
                        CHECK (DOMAIN IN ('GENERAL', 'INVESTIGATION', 'ANALYSIS', 'EQUIPMENT', 'SAFETY', 'LEGAL', 'REPORTING')),
    
    -- Audit Fields
    CREATED_AT          TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
                        COMMENT 'Record creation timestamp'
)
COMMENT = 'Business vocabulary definitions for consistent terminology across the ghost detection application and AI models'
CLUSTER BY (CATEGORY, DOMAIN);

-- ============================================================================
-- TABLE 2: GHOST_TAXONOMY
-- Description: Classification hierarchy and characteristics for ghost types
-- ============================================================================

CREATE OR REPLACE TABLE GHOST_TAXONOMY (
    -- Primary Key
    TAXONOMY_ID         NUMBER(38,0) AUTOINCREMENT PRIMARY KEY
                        COMMENT 'Unique identifier for each taxonomy entry',
    
    -- Classification
    GHOST_TYPE          VARCHAR(100) NOT NULL UNIQUE
                        COMMENT 'Primary ghost type classification (e.g., Poltergeist, Apparition)',
    CLASSIFICATION      VARCHAR(100) NOT NULL
                        COMMENT 'Higher-level classification: CLASS_I, CLASS_II, CLASS_III, CLASS_IV, CLASS_V, CLASS_VI, CLASS_VII'
                        CHECK (CLASSIFICATION IN ('CLASS_I', 'CLASS_II', 'CLASS_III', 'CLASS_IV', 'CLASS_V', 'CLASS_VI', 'CLASS_VII')),
    
    -- Characteristics
    CHARACTERISTICS     ARRAY NOT NULL
                        COMMENT 'Array of defining characteristics (e.g., ["corporeal", "malevolent", "telekinetic"])',
    
    -- Threat Assessment
    TYPICAL_THREAT_LEVEL VARCHAR(20) NOT NULL DEFAULT 'MEDIUM'
                        COMMENT 'Typical threat level for this ghost type: BENIGN, LOW, MEDIUM, HIGH, CRITICAL'
                        CHECK (TYPICAL_THREAT_LEVEL IN ('BENIGN', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    
    -- Detection and Response
    DETECTION_METHODS   ARRAY
                        COMMENT 'Array of effective detection methods (e.g., ["EMF", "Thermal", "EVP", "PKE Meter"])',
    NEUTRALIZATION_METHODS ARRAY
                        COMMENT 'Array of neutralization/containment methods (e.g., ["Proton Pack", "Trap", "Ritual"])'
)
COMMENT = 'Ghost type taxonomy with classification levels, characteristics, and recommended detection/neutralization methods'
CLUSTER BY (CLASSIFICATION, TYPICAL_THREAT_LEVEL);

-- ============================================================================
-- POPULATE BUSINESS VOCABULARY WITH INITIAL TERMS
-- ============================================================================

INSERT INTO BUSINESS_VOCABULARY (TERM, CATEGORY, DEFINITION, SYNONYMS, RELATED_TERMS, DOMAIN)
VALUES
    -- Entity Terms
    ('Ghost', 'ENTITY', 'A paranormal entity or spirit that manifests in the physical world, typically associated with deceased persons or supernatural forces.',
     ARRAY_CONSTRUCT('spirit', 'specter', 'phantom', 'apparition', 'spook'),
     ARRAY_CONSTRUCT('haunting', 'manifestation', 'paranormal activity'),
     'GENERAL'),
    
    ('Poltergeist', 'ENTITY', 'A type of ghost characterized by physical interactions with the environment, such as moving objects, making noises, or physical attacks.',
     ARRAY_CONSTRUCT('noisy ghost', 'kinetic spirit'),
     ARRAY_CONSTRUCT('telekinesis', 'haunting', 'physical manifestation'),
     'INVESTIGATION'),
    
    ('Apparition', 'ENTITY', 'A visual manifestation of a ghost, typically appearing as a translucent or solid figure resembling a human form.',
     ARRAY_CONSTRUCT('specter', 'phantom', 'shade', 'wraith'),
     ARRAY_CONSTRUCT('full-body apparition', 'partial manifestation'),
     'INVESTIGATION'),
    
    ('Demon', 'ENTITY', 'A malevolent supernatural entity of non-human origin, typically associated with extreme danger and negative energy.',
     ARRAY_CONSTRUCT('evil spirit', 'dark entity', 'infernal being'),
     ARRAY_CONSTRUCT('possession', 'exorcism', 'demonic activity'),
     'SAFETY'),
    
    -- Measurement Terms
    ('EMF Reading', 'MEASUREMENT', 'Electromagnetic field measurement in milligauss (mG), used to detect paranormal activity as ghosts often cause EMF fluctuations.',
     ARRAY_CONSTRUCT('electromagnetic reading', 'EMF level', 'milligauss'),
     ARRAY_CONSTRUCT('paranormal detection', 'ghost hunting equipment'),
     'EQUIPMENT'),
    
    ('PKE Valence', 'MEASUREMENT', 'Psychokinetic Energy valence measurement indicating the type and intensity of paranormal energy present.',
     ARRAY_CONSTRUCT('psychokinetic reading', 'PKE level'),
     ARRAY_CONSTRUCT('PKE Meter', 'ghost detection'),
     'EQUIPMENT'),
    
    ('Threat Level', 'MEASUREMENT', 'Assessment scale for ghost danger: BENIGN (harmless), LOW (minor risk), MEDIUM (moderate danger), HIGH (significant threat), CRITICAL (extreme danger).',
     ARRAY_CONSTRUCT('danger level', 'risk assessment', 'hazard rating'),
     ARRAY_CONSTRUCT('safety protocol', 'containment priority'),
     'SAFETY'),
    
    ('Confidence Score', 'MEASUREMENT', 'AI-generated probability score (0-100%) indicating certainty of ghost identification or classification.',
     ARRAY_CONSTRUCT('certainty score', 'probability', 'accuracy rating'),
     ARRAY_CONSTRUCT('AI analysis', 'classification'),
     'ANALYSIS'),
    
    -- Status Terms
    ('Active', 'STATUS', 'Ghost status indicating current manifestation activity and ongoing paranormal presence at a location.',
     ARRAY_CONSTRUCT('present', 'manifesting', 'currently active'),
     ARRAY_CONSTRUCT('sighting', 'investigation'),
     'GENERAL'),
    
    ('Contained', 'STATUS', 'Ghost status indicating successful capture and storage in a containment unit or trap.',
     ARRAY_CONSTRUCT('captured', 'trapped', 'secured'),
     ARRAY_CONSTRUCT('ghost trap', 'containment unit'),
     'GENERAL'),
    
    ('Neutralized', 'STATUS', 'Ghost status indicating permanent elimination or banishment from the physical plane.',
     ARRAY_CONSTRUCT('eliminated', 'banished', 'destroyed'),
     ARRAY_CONSTRUCT('exorcism', 'dispersal'),
     'GENERAL'),
    
    -- Equipment Terms
    ('Proton Pack', 'EQUIPMENT', 'Primary ghost capture device that generates a proton stream to wrangle and contain paranormal entities.',
     ARRAY_CONSTRUCT('unlicensed nuclear accelerator', 'proton wand'),
     ARRAY_CONSTRUCT('ghost trap', 'containment'),
     'EQUIPMENT'),
    
    ('Ghost Trap', 'EQUIPMENT', 'Portable containment device used to capture and temporarily hold ghosts for transport to the containment unit.',
     ARRAY_CONSTRUCT('trap', 'capture device', 'portable containment'),
     ARRAY_CONSTRUCT('proton pack', 'containment unit'),
     'EQUIPMENT'),
    
    ('PKE Meter', 'EQUIPMENT', 'Handheld device for detecting and measuring psychokinetic energy, used to locate ghost presence and activity.',
     ARRAY_CONSTRUCT('ghost detector', 'PKE scanner'),
     ARRAY_CONSTRUCT('EMF detector', 'ghost hunting'),
     'EQUIPMENT'),
    
    -- Action Terms
    ('Sighting', 'ACTION', 'A reported observation of paranormal activity or ghost manifestation by a witness.',
     ARRAY_CONSTRUCT('encounter', 'observation', 'witness report'),
     ARRAY_CONSTRUCT('investigation', 'evidence'),
     'INVESTIGATION'),
    
    ('Investigation', 'ACTION', 'Formal inquiry into paranormal activity including evidence collection, witness interviews, and ghost identification.',
     ARRAY_CONSTRUCT('case', 'inquiry', 'hunt'),
     ARRAY_CONSTRUCT('sighting', 'evidence', 'team'),
     'INVESTIGATION'),
    
    ('Containment', 'ACTION', 'The process of capturing and securing a ghost using specialized equipment.',
     ARRAY_CONSTRUCT('capture', 'trapping', 'securing'),
     ARRAY_CONSTRUCT('proton pack', 'ghost trap'),
     'INVESTIGATION');

-- ============================================================================
-- POPULATE GHOST TAXONOMY WITH CLASSIFICATION DATA
-- ============================================================================

INSERT INTO GHOST_TAXONOMY (GHOST_TYPE, CLASSIFICATION, CHARACTERISTICS, TYPICAL_THREAT_LEVEL, DETECTION_METHODS, NEUTRALIZATION_METHODS)
VALUES
    -- Class I: Undeveloped forms, insubstantial
    ('Mist', 'CLASS_I', 
     ARRAY_CONSTRUCT('insubstantial', 'formless', 'non-interactive'),
     'BENIGN',
     ARRAY_CONSTRUCT('Visual', 'Thermal Camera', 'EMF'),
     ARRAY_CONSTRUCT('Dispersal', 'Ventilation')),
    
    ('Orb', 'CLASS_I',
     ARRAY_CONSTRUCT('spherical', 'luminous', 'fast-moving'),
     'BENIGN',
     ARRAY_CONSTRUCT('Photography', 'Night Vision', 'EMF'),
     ARRAY_CONSTRUCT('Light Exposure', 'Dispersal')),
    
    -- Class II: Mobile, can interact with environment
    ('Shade', 'CLASS_II',
     ARRAY_CONSTRUCT('shadow-like', 'mobile', 'minor interaction'),
     'LOW',
     ARRAY_CONSTRUCT('EMF', 'Motion Sensors', 'Thermal'),
     ARRAY_CONSTRUCT('Light Saturation', 'Proton Stream')),
    
    ('Wisp', 'CLASS_II',
     ARRAY_CONSTRUCT('floating', 'luminescent', 'environmental influence'),
     'LOW',
     ARRAY_CONSTRUCT('Visual', 'PKE Meter', 'EMF'),
     ARRAY_CONSTRUCT('Containment Trap', 'Energy Dispersal')),
    
    -- Class III: Defined form, limited ability to interact
    ('Apparition', 'CLASS_III',
     ARRAY_CONSTRUCT('humanoid form', 'translucent', 'limited interaction'),
     'MEDIUM',
     ARRAY_CONSTRUCT('PKE Meter', 'EMF', 'EVP', 'Thermal'),
     ARRAY_CONSTRUCT('Proton Pack', 'Ghost Trap', 'Ritual Banishment')),
    
    ('Specter', 'CLASS_III',
     ARRAY_CONSTRUCT('partial form', 'visible', 'sound production'),
     'MEDIUM',
     ARRAY_CONSTRUCT('EMF', 'Audio Recording', 'PKE Meter'),
     ARRAY_CONSTRUCT('Proton Pack', 'Ghost Trap')),
    
    -- Class IV: Distinct human form, can manipulate environment
    ('Full-Body Apparition', 'CLASS_IV',
     ARRAY_CONSTRUCT('complete humanoid', 'solid appearance', 'environmental manipulation'),
     'MEDIUM',
     ARRAY_CONSTRUCT('PKE Meter', 'EMF', 'Visual', 'Thermal'),
     ARRAY_CONSTRUCT('Proton Pack', 'Ghost Trap', 'Exorcism')),
    
    ('Phantom', 'CLASS_IV',
     ARRAY_CONSTRUCT('corporeal', 'intelligent', 'physical interaction'),
     'HIGH',
     ARRAY_CONSTRUCT('PKE Meter', 'EMF', 'Motion', 'Audio'),
     ARRAY_CONSTRUCT('Proton Pack', 'Ghost Trap', 'Ritual')),
    
    -- Class V: Powerful entities with significant abilities
    ('Poltergeist', 'CLASS_V',
     ARRAY_CONSTRUCT('telekinetic', 'aggressive', 'high energy', 'physical attacks'),
     'HIGH',
     ARRAY_CONSTRUCT('PKE Meter', 'EMF', 'Motion Sensors', 'Audio'),
     ARRAY_CONSTRUCT('Proton Pack', 'Multi-Trap Array', 'Binding Ritual')),
    
    ('Wraith', 'CLASS_V',
     ARRAY_CONSTRUCT('corporeal', 'malevolent', 'energy drain', 'fast'),
     'HIGH',
     ARRAY_CONSTRUCT('PKE Meter', 'Thermal', 'EMF'),
     ARRAY_CONSTRUCT('Proton Pack', 'Specialized Trap', 'Holy Water')),
    
    -- Class VI: Ghosts created from powerful entities
    ('Demonic Entity', 'CLASS_VI',
     ARRAY_CONSTRUCT('non-human origin', 'extremely powerful', 'malevolent', 'possession capable'),
     'CRITICAL',
     ARRAY_CONSTRUCT('PKE Meter', 'Religious Artifacts', 'Thermal Anomaly'),
     ARRAY_CONSTRUCT('Exorcism', 'Specialized Containment', 'Ritual Banishment')),
    
    ('Elder Spirit', 'CLASS_VI',
     ARRAY_CONSTRUCT('ancient', 'immense power', 'reality warping'),
     'CRITICAL',
     ARRAY_CONSTRUCT('PKE Meter', 'Ley Line Mapping', 'Ritual Detection'),
     ARRAY_CONSTRUCT('Ancient Ritual', 'Dimensional Sealing')),
    
    -- Class VII: Metaspectral entities (gods, demons, etc.)
    ('God-Class Entity', 'CLASS_VII',
     ARRAY_CONSTRUCT('deity-level power', 'dimensional', 'reality manipulation', 'worshipped'),
     'CRITICAL',
     ARRAY_CONSTRUCT('Massive PKE Surge', 'Ley Line Convergence', 'Prophecy'),
     ARRAY_CONSTRUCT('Cross-dimensional Sealing', 'Sacrifice', 'Divine Intervention')),
    
    ('Destructor Form', 'CLASS_VII',
     ARRAY_CONSTRUCT('massive scale', 'physical manifestation', 'city-threatening', 'summoned'),
     'CRITICAL',
     ARRAY_CONSTRUCT('Visual', 'Seismic', 'City-wide PKE Surge'),
     ARRAY_CONSTRUCT('Total Protonic Reversal', 'Cross the Streams', 'Divine Intervention'));

-- ============================================================================
-- CREATE VIEWS FOR VOCABULARY ACCESS
-- ============================================================================

-- View for easy vocabulary lookup by category
CREATE OR REPLACE VIEW V_VOCABULARY_BY_CATEGORY AS
SELECT 
    CATEGORY,
    TERM,
    DEFINITION,
    SYNONYMS,
    DOMAIN
FROM BUSINESS_VOCABULARY
ORDER BY CATEGORY, TERM;

-- View for ghost type reference
CREATE OR REPLACE VIEW V_GHOST_TYPE_REFERENCE AS
SELECT 
    t.GHOST_TYPE,
    t.CLASSIFICATION,
    t.TYPICAL_THREAT_LEVEL,
    t.CHARACTERISTICS,
    t.DETECTION_METHODS,
    t.NEUTRALIZATION_METHODS
FROM GHOST_TAXONOMY t
ORDER BY 
    CASE t.CLASSIFICATION 
        WHEN 'CLASS_I' THEN 1
        WHEN 'CLASS_II' THEN 2
        WHEN 'CLASS_III' THEN 3
        WHEN 'CLASS_IV' THEN 4
        WHEN 'CLASS_V' THEN 5
        WHEN 'CLASS_VI' THEN 6
        WHEN 'CLASS_VII' THEN 7
    END,
    t.GHOST_TYPE;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify tables created
SHOW TABLES LIKE '%VOCABULARY%' IN SCHEMA GHOST_DETECTION.APP;
SHOW TABLES LIKE '%TAXONOMY%' IN SCHEMA GHOST_DETECTION.APP;

-- Verify data loaded
SELECT COUNT(*) AS vocabulary_count FROM BUSINESS_VOCABULARY;
SELECT COUNT(*) AS taxonomy_count FROM GHOST_TAXONOMY;

-- Sample vocabulary query
SELECT TERM, CATEGORY, DEFINITION FROM BUSINESS_VOCABULARY WHERE CATEGORY = 'ENTITY';

-- Sample taxonomy query
SELECT GHOST_TYPE, CLASSIFICATION, TYPICAL_THREAT_LEVEL FROM GHOST_TAXONOMY ORDER BY CLASSIFICATION;

/*
================================================================================
VOCABULARY AND TAXONOMY TABLES CREATED
================================================================================
Tables Created:
1. BUSINESS_VOCABULARY - Centralized business terminology
2. GHOST_TAXONOMY - Ghost classification hierarchy

Views Created:
1. V_VOCABULARY_BY_CATEGORY - Vocabulary organized by category
2. V_GHOST_TYPE_REFERENCE - Ghost type quick reference

Initial Data Loaded:
- 17 vocabulary terms across categories
- 14 ghost types across 7 classification levels

Next Steps:
1. Run 03_audit_tables.sql to create audit logging tables
================================================================================
*/
