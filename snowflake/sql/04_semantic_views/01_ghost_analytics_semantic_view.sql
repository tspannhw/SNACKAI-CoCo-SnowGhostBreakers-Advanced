/*=============================================================================
  SNOWGHOSTBREAKERS - Ghost Analytics Semantic View
  Comprehensive ghost detection analytics for natural language queries
  
  This semantic view enables Cortex Analyst to answer questions about:
  - Ghost registry and classifications
  - Sighting patterns and locations
  - Evidence collection metrics
  - Investigation case management
=============================================================================*/

USE DATABASE GHOST_DETECTION;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.GHOST_ANALYTICS_SV
TABLES (
    -- GHOSTS fact table - Master registry of detected paranormal entities
    ghosts AS GHOST_DETECTION.APP.GHOSTS
        PRIMARY KEY (ghost_id)
        WITH SYNONYMS = ('ghost', 'entity', 'spirit', 'paranormal entity', 'specter', 'phantom', 'apparition record')
        COMMENT = 'Master registry of detected ghosts and paranormal entities',
    
    -- GHOST_SIGHTINGS fact table - Individual encounter events
    sightings AS GHOST_DETECTION.APP.GHOST_SIGHTINGS
        PRIMARY KEY (sighting_id)
        WITH SYNONYMS = ('sighting', 'encounter', 'observation', 'appearance', 'manifestation', 'spotting')
        COMMENT = 'Individual ghost sighting events with environmental readings',
    
    -- GHOST_EVIDENCE fact table - Collected proof items
    evidence AS GHOST_DETECTION.APP.GHOST_EVIDENCE
        PRIMARY KEY (evidence_id)
        WITH SYNONYMS = ('evidence', 'proof', 'documentation', 'artifact', 'recording')
        COMMENT = 'Collected evidence items documenting paranormal activity',
    
    -- INVESTIGATIONS fact table - Case records
    investigations AS GHOST_DETECTION.APP.INVESTIGATIONS
        PRIMARY KEY (investigation_id)
        WITH SYNONYMS = ('investigation', 'case', 'inquiry', 'assignment', 'mission', 'operation')
        COMMENT = 'Investigation case records and outcomes'
)

RELATIONSHIPS (
    sightings (ghost_id) REFERENCES ghosts,
    evidence (ghost_id) REFERENCES ghosts
)

FACTS (
    -- Ghost facts
    ghosts.ghost_record AS ghost_id
        WITH SYNONYMS = ('ghost identifier', 'entity id')
        COMMENT = 'Unique ghost identifier',
    
    -- Sighting facts  
    sightings.sighting_record AS sighting_id
        WITH SYNONYMS = ('sighting identifier', 'encounter id')
        COMMENT = 'Unique sighting identifier',
    
    sightings.activity_reading AS paranormal_activity_level
        WITH SYNONYMS = ('activity level', 'paranormal reading', 'activity')
        COMMENT = 'Paranormal activity level reading (1-10)',
    
    sightings.emf_measurement AS emf_reading
        WITH SYNONYMS = ('EMF', 'electromagnetic field', 'electromagnetic reading')
        COMMENT = 'EMF reading in milligauss',
    
    sightings.temp_reading AS temperature_celsius
        WITH SYNONYMS = ('temperature', 'temp', 'celsius')
        COMMENT = 'Temperature reading in Celsius',
    
    sightings.observers AS witness_count
        WITH SYNONYMS = ('witnesses', 'observers', 'people present')
        COMMENT = 'Number of witnesses present',
    
    -- Evidence facts
    evidence.evidence_record AS evidence_id
        WITH SYNONYMS = ('evidence identifier', 'proof id')
        COMMENT = 'Unique evidence identifier',
    
    evidence.credibility AS authenticity_score
        WITH SYNONYMS = ('authenticity', 'credibility score', 'validity')
        COMMENT = 'AI-assessed authenticity score (0.0 to 1.0)',
    
    -- Investigation facts
    investigations.case_record AS investigation_id
        WITH SYNONYMS = ('case id', 'investigation number')
        COMMENT = 'Unique investigation identifier'
)

DIMENSIONS (
    -- Ghost classification dimensions
    ghosts.ghost_name AS ghost_name
        WITH SYNONYMS = ('name', 'entity name', 'ghost title', 'designation')
        COMMENT = 'Name or designation of the ghost',
    
    ghosts.ghost_type AS ghost_type
        WITH SYNONYMS = ('type', 'classification', 'category', 'kind', 'species')
        COMMENT = 'Type of ghost: Apparition, Poltergeist, Shadow_Figure, Residual, Demonic, Elemental',
    
    ghosts.threat_level AS threat_level
        WITH SYNONYMS = ('danger level', 'risk', 'hazard', 'threat', 'danger rating', 'risk level')
        COMMENT = 'Threat assessment: Low, Medium, High, Extreme',
    
    ghosts.status AS ghost_status
        WITH SYNONYMS = ('state', 'activity status', 'current status', 'condition')
        COMMENT = 'Current status: Active, Dormant, Captured, Neutralized, Unknown',
    
    ghosts.origin_story AS origin_story
        WITH SYNONYMS = ('backstory', 'history', 'background', 'origin')
        COMMENT = 'Historical background and origin of the ghost',
    
    ghosts.known_weaknesses AS known_weaknesses
        WITH SYNONYMS = ('weaknesses', 'vulnerabilities', 'weak points')
        COMMENT = 'Known vulnerabilities that can be exploited',
    
    ghosts.containment_protocol AS containment_protocol
        WITH SYNONYMS = ('containment', 'capture method', 'neutralization protocol')
        COMMENT = 'Recommended containment or neutralization procedures',
    
    ghosts.first_sighted_date AS first_sighted_date
        WITH SYNONYMS = ('first seen', 'discovery date', 'initial sighting')
        COMMENT = 'Date when the ghost was first documented',
    
    -- Sighting dimensions
    sightings.location_name AS sighting_location
        WITH SYNONYMS = ('place', 'location', 'site', 'venue', 'address', 'spot', 'where')
        COMMENT = 'Name of the sighting location',
    
    sightings.latitude AS latitude
        WITH SYNONYMS = ('lat', 'latitude coordinate')
        COMMENT = 'Geographic latitude of sighting',
    
    sightings.longitude AS longitude
        WITH SYNONYMS = ('lon', 'long', 'longitude coordinate')
        COMMENT = 'Geographic longitude of sighting',
    
    sightings.sighting_timestamp AS sighting_time
        WITH SYNONYMS = ('sighting time', 'encounter time', 'when seen', 'observation time', 'when')
        COMMENT = 'Date and time of the sighting',
    
    sightings.verified AS is_verified
        WITH SYNONYMS = ('confirmed', 'validated', 'authenticated', 'proven')
        COMMENT = 'Whether the sighting has been verified by investigators',
    
    sightings.weather_conditions AS weather
        WITH SYNONYMS = ('weather', 'conditions', 'atmospheric conditions')
        COMMENT = 'Weather conditions during the sighting',
    
    sightings.moon_phase AS moon_phase
        WITH SYNONYMS = ('lunar phase', 'moon')
        COMMENT = 'Phase of the moon during sighting',
    
    -- Evidence dimensions
    evidence.evidence_type AS evidence_type
        WITH SYNONYMS = ('proof type', 'evidence category', 'type of evidence', 'media type')
        COMMENT = 'Type: Photograph, Audio, Video, EMF_Recording, Thermal_Image, Physical',
    
    evidence.collection_date AS evidence_date
        WITH SYNONYMS = ('collected date', 'evidence date', 'when collected')
        COMMENT = 'Date the evidence was collected',
    
    evidence.file_url AS evidence_url
        WITH SYNONYMS = ('file location', 'evidence url', 'media url')
        COMMENT = 'URL to the evidence file in storage',
    
    -- Investigation dimensions
    investigations.case_name AS case_name
        WITH SYNONYMS = ('case title', 'investigation name', 'operation name')
        COMMENT = 'Name of the investigation case',
    
    investigations.status AS case_status
        WITH SYNONYMS = ('case status', 'investigation state', 'case state')
        COMMENT = 'Investigation status: Open, In_Progress, Closed, Archived',
    
    investigations.priority AS case_priority
        WITH SYNONYMS = ('case priority', 'urgency', 'importance level')
        COMMENT = 'Priority level: Low, Medium, High, Critical',
    
    investigations.lead_investigator AS lead_investigator
        WITH SYNONYMS = ('investigator', 'case lead', 'assigned investigator')
        COMMENT = 'Lead investigator assigned to the case',
    
    investigations.start_date AS case_start_date
        WITH SYNONYMS = ('case start', 'investigation start', 'opened date')
        COMMENT = 'Date the investigation was opened',
    
    investigations.end_date AS case_end_date
        WITH SYNONYMS = ('case end', 'closed date', 'completion date')
        COMMENT = 'Date the investigation was closed',
    
    investigations.outcome AS case_outcome
        WITH SYNONYMS = ('result', 'resolution', 'case outcome', 'finding')
        COMMENT = 'Final outcome: Resolved, Unresolved, Inconclusive, Ongoing'
)

METRICS (
    -- Ghost counts
    ghosts.total_ghosts AS COUNT(DISTINCT ghost_id)
        WITH SYNONYMS = ('ghost count', 'number of ghosts', 'entity count', 'how many ghosts')
        COMMENT = 'Total number of unique ghosts in the registry',
    
    ghosts.active_ghosts AS COUNT(DISTINCT CASE WHEN status = 'Active' THEN ghost_id END)
        WITH SYNONYMS = ('active ghost count', 'active entities', 'currently active')
        COMMENT = 'Number of ghosts with Active status',
    
    ghosts.high_threat_ghosts AS COUNT(DISTINCT CASE WHEN threat_level IN ('High', 'Extreme') THEN ghost_id END)
        WITH SYNONYMS = ('dangerous ghosts', 'high risk ghosts', 'high threat count')
        COMMENT = 'Number of ghosts with High or Extreme threat level',
    
    -- Sighting metrics
    sightings.total_sightings AS COUNT(sighting_id)
        WITH SYNONYMS = ('sighting count', 'encounters', 'observations', 'how many sightings')
        COMMENT = 'Total number of recorded sightings',
    
    sightings.verified_sightings AS COUNT(CASE WHEN verified = TRUE THEN sighting_id END)
        WITH SYNONYMS = ('confirmed sightings', 'validated encounters')
        COMMENT = 'Number of verified sightings',
    
    sightings.total_witnesses AS SUM(witness_count)
        WITH SYNONYMS = ('witness count', 'total observers', 'people who saw')
        COMMENT = 'Total number of witnesses across all sightings',
    
    sightings.avg_activity_level AS AVG(paranormal_activity_level)
        WITH SYNONYMS = ('average activity', 'mean activity level', 'typical activity')
        COMMENT = 'Average paranormal activity level (scale 1-10)',
    
    sightings.avg_emf_reading AS AVG(emf_reading)
        WITH SYNONYMS = ('average EMF', 'mean electromagnetic field', 'typical EMF')
        COMMENT = 'Average EMF reading in milligauss',
    
    sightings.max_emf_reading AS MAX(emf_reading)
        WITH SYNONYMS = ('highest EMF', 'peak EMF', 'maximum electromagnetic')
        COMMENT = 'Maximum recorded EMF reading',
    
    sightings.avg_temperature AS AVG(temperature_celsius)
        WITH SYNONYMS = ('average temp', 'mean temperature', 'typical temperature')
        COMMENT = 'Average temperature in Celsius during sightings',
    
    sightings.min_temperature AS MIN(temperature_celsius)
        WITH SYNONYMS = ('coldest temp', 'minimum temperature', 'lowest temperature', 'cold spot')
        COMMENT = 'Minimum temperature recorded (cold spots)',
    
    -- Evidence metrics
    evidence.total_evidence AS COUNT(evidence_id)
        WITH SYNONYMS = ('evidence count', 'proof items', 'how many evidence')
        COMMENT = 'Total evidence items collected',
    
    evidence.avg_authenticity AS AVG(authenticity_score)
        WITH SYNONYMS = ('average authenticity', 'mean credibility', 'typical authenticity score')
        COMMENT = 'Average authenticity score of evidence',
    
    evidence.high_quality_evidence AS COUNT(CASE WHEN authenticity_score >= 0.8 THEN evidence_id END)
        WITH SYNONYMS = ('credible evidence', 'high authenticity evidence', 'verified evidence')
        COMMENT = 'Evidence items with authenticity score >= 0.8',
    
    -- Investigation metrics
    investigations.total_investigations AS COUNT(DISTINCT investigation_id)
        WITH SYNONYMS = ('case count', 'investigation count', 'how many investigations')
        COMMENT = 'Total number of investigations',
    
    investigations.open_investigations AS COUNT(DISTINCT CASE WHEN status = 'Open' THEN investigation_id END)
        WITH SYNONYMS = ('open cases', 'active investigations', 'current cases')
        COMMENT = 'Number of open investigations',
    
    investigations.resolved_investigations AS COUNT(DISTINCT CASE WHEN outcome = 'Resolved' THEN investigation_id END)
        WITH SYNONYMS = ('resolved cases', 'successful investigations', 'closed successfully')
        COMMENT = 'Number of investigations with Resolved outcome',
    
    -- Derived metrics
    investigations.success_rate AS 
        ROUND(COUNT(DISTINCT CASE WHEN outcome = 'Resolved' THEN investigation_id END) * 100.0 / 
              NULLIF(COUNT(DISTINCT CASE WHEN status = 'Closed' THEN investigation_id END), 0), 2)
        WITH SYNONYMS = ('success rate', 'resolution rate', 'case success percentage')
        COMMENT = 'Percentage of closed investigations that were resolved successfully'
)
COMMENT = 'Comprehensive ghost detection analytics for natural language queries'
AI_SQL_GENERATION 'When asked about ghosts, use the ghosts table. When asked about sightings or encounters, use the sightings table. When asked about evidence or proof, use the evidence table. When asked about cases or investigations, use the investigations table. Threat levels are: Low, Medium, High, Extreme. Ghost statuses are: Active, Dormant, Captured, Neutralized, Unknown.';

-- Grant access to analytics role
GRANT SELECT ON SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.GHOST_ANALYTICS_SV 
    TO ROLE GHOST_DETECTION_ANALYST;
