/*=============================================================================
  SNOWGHOSTBREAKERS - Sighting Analytics Semantic View
  Geographic and temporal analysis of ghost sightings
  
  This semantic view enables Cortex Analyst to answer questions about:
  - Where sightings occur (geographic analysis)
  - When sightings happen (temporal patterns)
  - Environmental conditions during encounters
  - Sighting verification and credibility
=============================================================================*/

USE DATABASE GHOST_DETECTION;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.SIGHTING_ANALYTICS_SV
TABLES (
    -- Primary sightings table
    sightings AS GHOST_DETECTION.APP.GHOST_SIGHTINGS
        PRIMARY KEY (sighting_id)
        WITH SYNONYMS = ('sighting', 'encounter', 'observation', 'appearance', 'manifestation', 'spotting', 'ghost sighting')
        COMMENT = 'Individual ghost sighting events with location and environmental data',
    
    -- Ghost reference for context
    ghosts AS GHOST_DETECTION.APP.GHOSTS
        PRIMARY KEY (ghost_id)
        WITH SYNONYMS = ('ghost', 'entity', 'spirit', 'paranormal entity')
        COMMENT = 'Ghost registry for sighting context'
)

RELATIONSHIPS (
    sightings (ghost_id) REFERENCES ghosts
)

FACTS (
    -- Sighting facts
    sightings.sighting_record AS sighting_id
        WITH SYNONYMS = ('sighting identifier', 'encounter id', 'sighting number', 'observation id')
        COMMENT = 'Unique identifier for the sighting event',
    
    sightings.activity_reading AS paranormal_activity_level
        WITH SYNONYMS = ('activity level', 'paranormal reading', 'activity', 'paranormal activity')
        COMMENT = 'Paranormal activity level reading (1-10 scale)',
    
    sightings.emf_measurement AS emf_reading
        WITH SYNONYMS = ('EMF', 'electromagnetic field', 'electromagnetic reading', 'milligauss')
        COMMENT = 'EMF reading in milligauss',
    
    sightings.temp_reading AS temperature_celsius
        WITH SYNONYMS = ('temperature', 'temp', 'celsius', 'degrees')
        COMMENT = 'Temperature reading in Celsius',
    
    sightings.observers AS witness_count
        WITH SYNONYMS = ('witnesses', 'observers', 'people present', 'observer count')
        COMMENT = 'Number of witnesses present during the sighting',
    
    -- Ghost facts for context
    ghosts.ghost_record AS ghost_id
        WITH SYNONYMS = ('ghost identifier', 'entity id')
        COMMENT = 'Reference to the ghost that was sighted'
)

DIMENSIONS (
    -- Ghost reference dimensions
    sightings.ghost_id AS ghost_reference
        WITH SYNONYMS = ('ghost identifier', 'entity id', 'which ghost')
        COMMENT = 'Reference to the ghost that was sighted',
    
    ghosts.ghost_name AS ghost_name
        WITH SYNONYMS = ('ghost name', 'entity name', 'who was seen')
        COMMENT = 'Name of the ghost that was sighted',
    
    ghosts.ghost_type AS ghost_type
        WITH SYNONYMS = ('ghost type', 'entity type', 'classification')
        COMMENT = 'Type of ghost that was sighted',
    
    ghosts.threat_level AS threat_level
        WITH SYNONYMS = ('danger level', 'threat', 'risk level')
        COMMENT = 'Threat level of the sighted ghost',
    
    -- Location dimensions
    sightings.location_name AS location_name
        WITH SYNONYMS = ('place', 'location', 'site', 'venue', 'address', 'where', 'spot', 'area')
        COMMENT = 'Name of the sighting location',
    
    sightings.latitude AS latitude
        WITH SYNONYMS = ('lat', 'latitude coordinate', 'north-south position')
        COMMENT = 'Geographic latitude of sighting location',
    
    sightings.longitude AS longitude
        WITH SYNONYMS = ('lon', 'long', 'longitude coordinate', 'east-west position')
        COMMENT = 'Geographic longitude of sighting location',
    
    -- Temporal dimensions
    sightings.sighting_timestamp AS sighting_timestamp
        WITH SYNONYMS = ('sighting time', 'encounter time', 'when', 'date and time', 'observation time', 'timestamp')
        COMMENT = 'Date and time when the sighting occurred',
    
    DATE(sightings.sighting_timestamp) AS sighting_date
        WITH SYNONYMS = ('date', 'sighting date', 'encounter date', 'which day')
        COMMENT = 'Date of the sighting',
    
    TIME(sightings.sighting_timestamp) AS time_of_day
        WITH SYNONYMS = ('time of day', 'hour', 'clock time')
        COMMENT = 'Time of day when sighting occurred',
    
    HOUR(sightings.sighting_timestamp) AS sighting_hour
        WITH SYNONYMS = ('hour of day', 'what hour')
        COMMENT = 'Hour of the day (0-23) when sighting occurred',
    
    DAYOFWEEK(sightings.sighting_timestamp) AS day_of_week
        WITH SYNONYMS = ('weekday', 'which day of week', 'day name')
        COMMENT = 'Day of the week (0=Sunday to 6=Saturday)',
    
    MONTH(sightings.sighting_timestamp) AS sighting_month
        WITH SYNONYMS = ('month', 'which month')
        COMMENT = 'Month number (1-12)',
    
    YEAR(sightings.sighting_timestamp) AS sighting_year
        WITH SYNONYMS = ('year', 'which year')
        COMMENT = 'Year of the sighting',
    
    DATE_TRUNC('MONTH', sightings.sighting_timestamp) AS month_year
        WITH SYNONYMS = ('month year', 'period')
        COMMENT = 'Month and year of sighting for trending',
    
    -- Verification status
    sightings.verified AS is_verified
        WITH SYNONYMS = ('confirmed', 'validated', 'authenticated', 'proven', 'verified status')
        COMMENT = 'Whether the sighting has been verified by investigators',
    
    -- Environmental conditions
    sightings.weather_conditions AS weather_conditions
        WITH SYNONYMS = ('weather', 'conditions', 'atmospheric conditions', 'climate')
        COMMENT = 'Weather conditions during the sighting',
    
    sightings.moon_phase AS moon_phase
        WITH SYNONYMS = ('lunar phase', 'moon', 'moon state', 'lunar cycle')
        COMMENT = 'Phase of the moon during sighting',
    
    -- Descriptions
    sightings.description AS description
        WITH SYNONYMS = ('details', 'sighting details', 'what happened', 'encounter description')
        COMMENT = 'Detailed description of the sighting event'
)

METRICS (
    -- Sighting counts
    sightings.total_sightings AS COUNT(*)
        WITH SYNONYMS = ('sighting count', 'number of sightings', 'encounters', 'how many sightings', 'observation count')
        COMMENT = 'Total number of sightings',
    
    sightings.unique_sightings AS COUNT(DISTINCT sighting_id)
        WITH SYNONYMS = ('distinct sightings', 'unique encounters')
        COMMENT = 'Count of unique sighting events',
    
    sightings.verified_sightings AS COUNT(CASE WHEN verified = TRUE THEN 1 END)
        WITH SYNONYMS = ('confirmed sightings', 'validated encounters', 'proven sightings')
        COMMENT = 'Number of verified sightings',
    
    sightings.unverified_sightings AS COUNT(CASE WHEN verified = FALSE THEN 1 END)
        WITH SYNONYMS = ('unconfirmed sightings', 'pending verification')
        COMMENT = 'Number of unverified sightings',
    
    sightings.verification_rate AS ROUND(COUNT(CASE WHEN verified = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2)
        WITH SYNONYMS = ('verification percentage', 'confirmed rate', 'validation rate')
        COMMENT = 'Percentage of sightings that are verified',
    
    -- Ghost counts in sightings
    sightings.unique_ghosts_sighted AS COUNT(DISTINCT ghost_id)
        WITH SYNONYMS = ('different ghosts', 'unique entities seen', 'distinct ghosts')
        COMMENT = 'Number of unique ghosts involved in sightings',
    
    -- Location counts
    sightings.unique_locations AS COUNT(DISTINCT location_name)
        WITH SYNONYMS = ('different locations', 'unique places', 'distinct sites', 'number of locations')
        COMMENT = 'Number of unique sighting locations',
    
    -- Witness metrics
    sightings.total_witnesses AS SUM(witness_count)
        WITH SYNONYMS = ('all witnesses', 'total observers', 'witness sum')
        COMMENT = 'Total number of witnesses across all sightings',
    
    sightings.avg_witnesses AS AVG(witness_count)
        WITH SYNONYMS = ('average witnesses', 'mean observers', 'typical witness count')
        COMMENT = 'Average number of witnesses per sighting',
    
    sightings.max_witnesses AS MAX(witness_count)
        WITH SYNONYMS = ('most witnesses', 'maximum observers', 'largest crowd')
        COMMENT = 'Maximum witnesses at a single sighting',
    
    -- Environmental readings
    sightings.avg_activity_level AS AVG(paranormal_activity_level)
        WITH SYNONYMS = ('average activity', 'mean paranormal level', 'typical activity')
        COMMENT = 'Average paranormal activity level (1-10 scale)',
    
    sightings.max_activity_level AS MAX(paranormal_activity_level)
        WITH SYNONYMS = ('highest activity', 'peak paranormal level', 'maximum activity')
        COMMENT = 'Maximum paranormal activity level recorded',
    
    sightings.avg_emf AS AVG(emf_reading)
        WITH SYNONYMS = ('average EMF', 'mean electromagnetic', 'typical EMF reading')
        COMMENT = 'Average EMF reading in milligauss',
    
    sightings.max_emf AS MAX(emf_reading)
        WITH SYNONYMS = ('highest EMF', 'peak electromagnetic', 'maximum EMF')
        COMMENT = 'Maximum EMF reading recorded',
    
    sightings.min_emf AS MIN(emf_reading)
        WITH SYNONYMS = ('lowest EMF', 'minimum electromagnetic')
        COMMENT = 'Minimum EMF reading recorded',
    
    sightings.avg_temperature AS AVG(temperature_celsius)
        WITH SYNONYMS = ('average temp', 'mean temperature', 'typical temperature')
        COMMENT = 'Average temperature in Celsius',
    
    sightings.min_temperature AS MIN(temperature_celsius)
        WITH SYNONYMS = ('coldest', 'minimum temp', 'lowest temperature', 'cold spot')
        COMMENT = 'Minimum (coldest) temperature recorded',
    
    sightings.max_temperature AS MAX(temperature_celsius)
        WITH SYNONYMS = ('warmest', 'maximum temp', 'highest temperature')
        COMMENT = 'Maximum temperature recorded',
    
    -- Date range metrics
    sightings.first_sighting AS MIN(sighting_timestamp)
        WITH SYNONYMS = ('earliest sighting', 'first encounter', 'oldest sighting')
        COMMENT = 'Timestamp of the earliest sighting',
    
    sightings.latest_sighting AS MAX(sighting_timestamp)
        WITH SYNONYMS = ('most recent sighting', 'last encounter', 'newest sighting')
        COMMENT = 'Timestamp of the most recent sighting'
)
COMMENT = 'Geographic and temporal analysis of ghost sightings for natural language queries'
AI_SQL_GENERATION 'When asked about sightings, encounters, or observations, query this view. For location-based questions use location_name, latitude, longitude. For temporal analysis use sighting_timestamp, sighting_date, sighting_hour, day_of_week, sighting_month. For environmental data use emf_reading, temperature_celsius, paranormal_activity_level. Verification status is in the verified column (TRUE/FALSE).';

-- Grant access to analytics role
GRANT SELECT ON SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.SIGHTING_ANALYTICS_SV 
    TO ROLE GHOST_DETECTION_ANALYST;
