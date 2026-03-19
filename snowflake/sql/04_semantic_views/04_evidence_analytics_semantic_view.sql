/*=============================================================================
  SNOWGHOSTBREAKERS - Evidence Analytics Semantic View
  Multimedia evidence analysis for ghost documentation
  
  This semantic view enables Cortex Analyst to answer questions about:
  - Evidence collection and cataloging
  - Authenticity and credibility scoring
  - Evidence types and media analysis
  - Evidence quality metrics
=============================================================================*/

USE DATABASE GHOST_DETECTION;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.EVIDENCE_ANALYTICS_SV
TABLES (
    -- Primary evidence table
    evidence AS GHOST_DETECTION.APP.GHOST_EVIDENCE
        PRIMARY KEY (evidence_id)
        WITH SYNONYMS = ('evidence', 'proof', 'documentation', 'artifact', 'recording', 'media', 'file')
        COMMENT = 'Collected evidence items documenting paranormal activity',
    
    -- Ghost reference for context
    ghosts AS GHOST_DETECTION.APP.GHOSTS
        PRIMARY KEY (ghost_id)
        WITH SYNONYMS = ('ghost', 'entity', 'spirit', 'subject')
        COMMENT = 'Ghost registry for evidence subject context',
    
    -- Sightings for event context
    sightings AS GHOST_DETECTION.APP.GHOST_SIGHTINGS
        PRIMARY KEY (sighting_id)
        WITH SYNONYMS = ('sighting', 'encounter', 'event')
        COMMENT = 'Sighting events linked to evidence'
)

RELATIONSHIPS (
    evidence (ghost_id) REFERENCES ghosts,
    sightings (ghost_id) REFERENCES ghosts
)

FACTS (
    -- Evidence facts
    evidence.evidence_record AS evidence_id
        WITH SYNONYMS = ('evidence identifier', 'proof id', 'evidence number', 'file id')
        COMMENT = 'Unique identifier for the evidence item',
    
    evidence.credibility AS authenticity_score
        WITH SYNONYMS = ('authenticity', 'credibility score', 'validity score', 'trust score', 'quality score', 'reliability')
        COMMENT = 'AI-assessed authenticity score from 0.0 to 1.0',
    
    evidence.size AS file_size_bytes
        WITH SYNONYMS = ('file size', 'size', 'bytes')
        COMMENT = 'Size of the evidence file in bytes',
    
    -- Ghost facts
    ghosts.ghost_record AS ghost_id
        WITH SYNONYMS = ('ghost identifier', 'subject id', 'entity id')
        COMMENT = 'Reference to the ghost this evidence documents',
    
    -- Sighting facts
    sightings.sighting_record AS sighting_id
        WITH SYNONYMS = ('sighting id', 'event id')
        COMMENT = 'Related sighting event identifier'
)

DIMENSIONS (
    -- Evidence identification
    evidence.evidence_name AS evidence_name
        WITH SYNONYMS = ('evidence title', 'file name', 'item name', 'name')
        COMMENT = 'Descriptive name of the evidence item',
    
    -- Evidence type and classification
    evidence.evidence_type AS evidence_type
        WITH SYNONYMS = ('proof type', 'evidence category', 'type of evidence', 'media type', 'format')
        COMMENT = 'Type: Photograph, Audio, Video, EMF_Recording, Thermal_Image, Physical',
    
    -- Ghost reference
    evidence.ghost_id AS ghost_reference
        WITH SYNONYMS = ('ghost identifier', 'subject id', 'entity id')
        COMMENT = 'Reference to the ghost this evidence documents',
    
    ghosts.ghost_name AS ghost_name
        WITH SYNONYMS = ('ghost name', 'subject name', 'entity name', 'who')
        COMMENT = 'Name of the ghost documented in the evidence',
    
    ghosts.ghost_type AS ghost_type
        WITH SYNONYMS = ('ghost type', 'entity type', 'subject classification')
        COMMENT = 'Type of ghost documented',
    
    ghosts.threat_level AS threat_level
        WITH SYNONYMS = ('threat', 'danger level', 'risk')
        COMMENT = 'Threat level of the documented ghost',
    
    -- Temporal dimensions
    evidence.collection_date AS collection_date
        WITH SYNONYMS = ('collected date', 'evidence date', 'when collected', 'capture date', 'recorded date')
        COMMENT = 'Date the evidence was collected',
    
    DATE_TRUNC('MONTH', evidence.collection_date) AS collection_month
        WITH SYNONYMS = ('month collected', 'collection month')
        COMMENT = 'Month the evidence was collected',
    
    YEAR(evidence.collection_date) AS collection_year
        WITH SYNONYMS = ('year collected', 'collection year')
        COMMENT = 'Year the evidence was collected',
    
    -- Location
    evidence.collection_location AS collection_location
        WITH SYNONYMS = ('collection site', 'where collected', 'evidence location', 'capture location')
        COMMENT = 'Location where the evidence was collected',
    
    -- Quality grading
    CASE 
        WHEN evidence.authenticity_score >= 0.9 THEN 'Excellent'
        WHEN evidence.authenticity_score >= 0.7 THEN 'Good'
        WHEN evidence.authenticity_score >= 0.5 THEN 'Moderate'
        WHEN evidence.authenticity_score >= 0.3 THEN 'Low'
        ELSE 'Very Low'
    END AS authenticity_grade
        WITH SYNONYMS = ('quality grade', 'authenticity level', 'credibility grade')
        COMMENT = 'Letter grade for authenticity: Excellent, Good, Moderate, Low, Very Low',
    
    -- Storage and access
    evidence.file_url AS file_url
        WITH SYNONYMS = ('file location', 'evidence url', 'media url', 'download link', 'file path')
        COMMENT = 'URL to the evidence file in storage',
    
    -- Personnel
    evidence.collected_by AS collected_by
        WITH SYNONYMS = ('collector', 'who collected', 'investigator', 'captured by')
        COMMENT = 'Person who collected the evidence',
    
    evidence.verified_by AS verified_by
        WITH SYNONYMS = ('verifier', 'who verified', 'authenticated by')
        COMMENT = 'Person who verified the evidence authenticity',
    
    -- Description and notes
    evidence.description AS description
        WITH SYNONYMS = ('evidence description', 'details', 'notes', 'summary')
        COMMENT = 'Detailed description of the evidence',
    
    evidence.analysis_notes AS analysis_notes
        WITH SYNONYMS = ('analysis', 'findings', 'technical notes')
        COMMENT = 'Technical analysis notes on the evidence'
)

METRICS (
    -- Evidence counts
    evidence.total_evidence AS COUNT(*)
        WITH SYNONYMS = ('evidence count', 'proof items', 'how many evidence', 'total items')
        COMMENT = 'Total number of evidence items',
    
    evidence.unique_evidence AS COUNT(DISTINCT evidence_id)
        WITH SYNONYMS = ('distinct evidence', 'unique items')
        COMMENT = 'Count of unique evidence items',
    
    evidence.ghosts_with_evidence AS COUNT(DISTINCT ghost_id)
        WITH SYNONYMS = ('documented ghosts', 'ghosts with proof', 'entities with evidence')
        COMMENT = 'Number of unique ghosts with documented evidence',
    
    -- Evidence type counts
    evidence.photograph_count AS COUNT(CASE WHEN evidence_type = 'Photograph' THEN 1 END)
        WITH SYNONYMS = ('photos', 'photographs', 'images', 'pictures')
        COMMENT = 'Number of photographic evidence items',
    
    evidence.video_count AS COUNT(CASE WHEN evidence_type = 'Video' THEN 1 END)
        WITH SYNONYMS = ('videos', 'video recordings', 'footage')
        COMMENT = 'Number of video evidence items',
    
    evidence.audio_count AS COUNT(CASE WHEN evidence_type = 'Audio' THEN 1 END)
        WITH SYNONYMS = ('audio recordings', 'sound files', 'EVPs')
        COMMENT = 'Number of audio evidence items',
    
    evidence.emf_count AS COUNT(CASE WHEN evidence_type = 'EMF_Recording' THEN 1 END)
        WITH SYNONYMS = ('EMF recordings', 'electromagnetic readings', 'EMF data')
        COMMENT = 'Number of EMF recording evidence items',
    
    evidence.thermal_count AS COUNT(CASE WHEN evidence_type = 'Thermal_Image' THEN 1 END)
        WITH SYNONYMS = ('thermal images', 'heat signatures', 'infrared images')
        COMMENT = 'Number of thermal image evidence items',
    
    evidence.physical_count AS COUNT(CASE WHEN evidence_type = 'Physical' THEN 1 END)
        WITH SYNONYMS = ('physical evidence', 'artifacts', 'tangible proof')
        COMMENT = 'Number of physical evidence items',
    
    -- Authenticity metrics
    evidence.avg_authenticity AS AVG(authenticity_score)
        WITH SYNONYMS = ('average authenticity', 'mean credibility', 'typical authenticity score')
        COMMENT = 'Average authenticity score of evidence',
    
    evidence.max_authenticity AS MAX(authenticity_score)
        WITH SYNONYMS = ('highest authenticity', 'best credibility', 'most reliable')
        COMMENT = 'Maximum authenticity score',
    
    evidence.min_authenticity AS MIN(authenticity_score)
        WITH SYNONYMS = ('lowest authenticity', 'worst credibility', 'least reliable')
        COMMENT = 'Minimum authenticity score',
    
    evidence.high_quality_evidence AS COUNT(CASE WHEN authenticity_score >= 0.8 THEN 1 END)
        WITH SYNONYMS = ('credible evidence', 'high authenticity count', 'verified evidence', 'good evidence')
        COMMENT = 'Evidence items with authenticity score >= 0.8',
    
    evidence.moderate_quality_evidence AS COUNT(CASE WHEN authenticity_score >= 0.5 THEN 1 END)
        WITH SYNONYMS = ('acceptable evidence', 'moderate authenticity count')
        COMMENT = 'Evidence items with authenticity score >= 0.5',
    
    evidence.low_quality_evidence AS COUNT(CASE WHEN authenticity_score < 0.5 THEN 1 END)
        WITH SYNONYMS = ('questionable evidence', 'low authenticity count', 'unreliable evidence')
        COMMENT = 'Evidence items with authenticity score < 0.5',
    
    evidence.high_quality_percentage AS ROUND(COUNT(CASE WHEN authenticity_score >= 0.8 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2)
        WITH SYNONYMS = ('quality rate', 'high authenticity percentage', 'credibility rate')
        COMMENT = 'Percentage of evidence with high authenticity',
    
    -- Storage metrics
    evidence.total_storage_bytes AS SUM(file_size_bytes)
        WITH SYNONYMS = ('total size', 'storage used', 'all file sizes')
        COMMENT = 'Total storage used by evidence files in bytes',
    
    evidence.avg_file_size AS AVG(file_size_bytes)
        WITH SYNONYMS = ('average size', 'mean file size', 'typical file size')
        COMMENT = 'Average file size of evidence items',
    
    evidence.largest_file AS MAX(file_size_bytes)
        WITH SYNONYMS = ('biggest file', 'maximum file size')
        COMMENT = 'Size of the largest evidence file',
    
    -- Collector metrics
    evidence.unique_collectors AS COUNT(DISTINCT collected_by)
        WITH SYNONYMS = ('collector count', 'investigators who collected')
        COMMENT = 'Number of unique evidence collectors',
    
    -- Location metrics
    evidence.unique_collection_locations AS COUNT(DISTINCT collection_location)
        WITH SYNONYMS = ('evidence locations', 'collection sites')
        COMMENT = 'Number of unique evidence collection locations',
    
    -- Date range
    evidence.earliest_evidence AS MIN(collection_date)
        WITH SYNONYMS = ('oldest evidence', 'first collected')
        COMMENT = 'Date of earliest collected evidence',
    
    evidence.latest_evidence AS MAX(collection_date)
        WITH SYNONYMS = ('newest evidence', 'most recently collected')
        COMMENT = 'Date of most recently collected evidence'
)
COMMENT = 'Multimedia evidence analysis for ghost documentation and natural language queries'
AI_SQL_GENERATION 'When asked about evidence, proof, or documentation use this view. Evidence types are: Photograph, Audio, Video, EMF_Recording, Thermal_Image, Physical. Authenticity scores range from 0.0 to 1.0 where higher is better. Use authenticity_score >= 0.8 for high quality evidence. Use collected_by for questions about who collected evidence. Use collection_date for temporal analysis.';

-- Grant access to analytics role
GRANT SELECT ON SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.EVIDENCE_ANALYTICS_SV 
    TO ROLE GHOST_DETECTION_ANALYST;
