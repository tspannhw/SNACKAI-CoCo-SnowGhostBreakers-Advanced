/*=============================================================================
  SNOWGHOSTBREAKERS - Investigation Analytics Semantic View
  Case management analytics for ghost investigations
  
  This semantic view enables Cortex Analyst to answer questions about:
  - Investigation case status and progress
  - Investigator performance and assignments
  - Case outcomes and success rates
  - Priority and urgency analysis
=============================================================================*/

USE DATABASE GHOST_DETECTION;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.INVESTIGATION_ANALYTICS_SV
TABLES (
    -- Primary investigations table
    investigations AS GHOST_DETECTION.APP.INVESTIGATIONS
        PRIMARY KEY (investigation_id)
        WITH SYNONYMS = ('investigation', 'case', 'inquiry', 'assignment', 'mission', 'operation', 'case file')
        COMMENT = 'Investigation case records with status, assignments, and outcomes',
    
    -- Ghost sightings for investigation context
    sightings AS GHOST_DETECTION.APP.GHOST_SIGHTINGS
        PRIMARY KEY (sighting_id)
        WITH SYNONYMS = ('sighting', 'encounter', 'incident')
        COMMENT = 'Sightings linked to investigations',
    
    -- Ghosts for threat context
    ghosts AS GHOST_DETECTION.APP.GHOSTS
        PRIMARY KEY (ghost_id)
        WITH SYNONYMS = ('ghost', 'entity', 'target')
        COMMENT = 'Ghost registry for investigation targets',
    
    -- Evidence for case documentation
    evidence AS GHOST_DETECTION.APP.GHOST_EVIDENCE
        PRIMARY KEY (evidence_id)
        WITH SYNONYMS = ('evidence', 'proof', 'documentation')
        COMMENT = 'Evidence collected during investigations'
)

RELATIONSHIPS (
    sightings (ghost_id) REFERENCES ghosts,
    evidence (ghost_id) REFERENCES ghosts
)

FACTS (
    -- Investigation facts
    investigations.case_record AS investigation_id
        WITH SYNONYMS = ('case id', 'investigation number', 'case number', 'file number')
        COMMENT = 'Unique identifier for the investigation',
    
    -- Sighting facts
    sightings.sighting_record AS sighting_id
        WITH SYNONYMS = ('sighting id', 'encounter id')
        COMMENT = 'Sighting identifier for related encounters',
    
    -- Evidence facts
    evidence.evidence_record AS evidence_id
        WITH SYNONYMS = ('evidence id', 'proof id')
        COMMENT = 'Evidence identifier for case documentation',
    
    -- Ghost facts
    ghosts.ghost_record AS ghost_id
        WITH SYNONYMS = ('ghost id', 'entity id')
        COMMENT = 'Ghost identifier for investigation targets'
)

DIMENSIONS (
    -- Investigation identification
    investigations.case_name AS case_name
        WITH SYNONYMS = ('case title', 'investigation name', 'operation name', 'case description')
        COMMENT = 'Descriptive name of the investigation case',
    
    -- Status dimensions
    investigations.status AS investigation_status
        WITH SYNONYMS = ('case status', 'investigation state', 'current status', 'state')
        COMMENT = 'Investigation status: Open, In_Progress, Closed, Archived',
    
    investigations.outcome AS case_outcome
        WITH SYNONYMS = ('result', 'resolution', 'case outcome', 'finding', 'conclusion')
        COMMENT = 'Final outcome: Resolved, Unresolved, Inconclusive, Ongoing',
    
    -- Priority and urgency
    investigations.priority AS priority
        WITH SYNONYMS = ('case priority', 'urgency', 'importance', 'priority level', 'how urgent')
        COMMENT = 'Priority level: Low, Medium, High, Critical',
    
    -- Personnel
    investigations.lead_investigator AS lead_investigator
        WITH SYNONYMS = ('investigator', 'case lead', 'assigned investigator', 'who is investigating', 'team lead')
        COMMENT = 'Lead investigator assigned to the case',
    
    investigations.team_members AS team_members
        WITH SYNONYMS = ('team', 'investigation team', 'assigned team', 'crew')
        COMMENT = 'Team members assigned to the investigation',
    
    -- Location context
    investigations.location AS investigation_location
        WITH SYNONYMS = ('investigation location', 'case location', 'where', 'site')
        COMMENT = 'Primary location of the investigation',
    
    -- Temporal dimensions
    investigations.start_date AS start_date
        WITH SYNONYMS = ('case start', 'investigation start', 'opened date', 'when opened', 'began')
        COMMENT = 'Date the investigation was opened',
    
    investigations.end_date AS end_date
        WITH SYNONYMS = ('case end', 'closed date', 'completion date', 'when closed', 'finished')
        COMMENT = 'Date the investigation was closed',
    
    DATEDIFF('day', investigations.start_date, COALESCE(investigations.end_date, CURRENT_DATE())) AS case_duration_days
        WITH SYNONYMS = ('duration', 'how long', 'days open', 'case length')
        COMMENT = 'Number of days the case has been open',
    
    DATE_TRUNC('MONTH', investigations.start_date) AS start_month
        WITH SYNONYMS = ('month opened', 'start month')
        COMMENT = 'Month when the investigation started',
    
    YEAR(investigations.start_date) AS start_year
        WITH SYNONYMS = ('year opened', 'start year')
        COMMENT = 'Year when the investigation started',
    
    -- Case details
    investigations.description AS case_description
        WITH SYNONYMS = ('case description', 'details', 'notes', 'summary')
        COMMENT = 'Detailed description of the investigation',
    
    investigations.notes AS case_notes
        WITH SYNONYMS = ('case notes', 'investigator notes', 'comments')
        COMMENT = 'Additional notes and comments on the case',
    
    -- Ghost context
    ghosts.ghost_name AS target_ghost_name
        WITH SYNONYMS = ('target name', 'ghost name', 'entity name')
        COMMENT = 'Name of ghost being investigated',
    
    ghosts.ghost_type AS target_ghost_type
        WITH SYNONYMS = ('ghost type', 'target type', 'entity classification')
        COMMENT = 'Type of ghost being investigated',
    
    ghosts.threat_level AS target_threat_level
        WITH SYNONYMS = ('threat', 'danger level', 'risk')
        COMMENT = 'Threat level of ghost being investigated'
)

METRICS (
    -- Investigation counts
    investigations.total_investigations AS COUNT(DISTINCT investigation_id)
        WITH SYNONYMS = ('case count', 'investigation count', 'how many cases', 'total cases')
        COMMENT = 'Total number of investigations',
    
    investigations.open_investigations AS COUNT(DISTINCT CASE WHEN status = 'Open' THEN investigation_id END)
        WITH SYNONYMS = ('open cases', 'pending cases', 'active investigations')
        COMMENT = 'Number of open investigations',
    
    investigations.in_progress_investigations AS COUNT(DISTINCT CASE WHEN status = 'In_Progress' THEN investigation_id END)
        WITH SYNONYMS = ('active cases', 'ongoing investigations', 'cases in progress')
        COMMENT = 'Number of in-progress investigations',
    
    investigations.closed_investigations AS COUNT(DISTINCT CASE WHEN status = 'Closed' THEN investigation_id END)
        WITH SYNONYMS = ('closed cases', 'completed investigations', 'finished cases')
        COMMENT = 'Number of closed investigations',
    
    investigations.archived_investigations AS COUNT(DISTINCT CASE WHEN status = 'Archived' THEN investigation_id END)
        WITH SYNONYMS = ('archived cases', 'historical cases')
        COMMENT = 'Number of archived investigations',
    
    -- Outcome counts
    investigations.resolved_cases AS COUNT(DISTINCT CASE WHEN outcome = 'Resolved' THEN investigation_id END)
        WITH SYNONYMS = ('successful cases', 'resolved investigations', 'wins')
        COMMENT = 'Number of resolved investigations',
    
    investigations.unresolved_cases AS COUNT(DISTINCT CASE WHEN outcome = 'Unresolved' THEN investigation_id END)
        WITH SYNONYMS = ('unsolved cases', 'unresolved investigations', 'cold cases')
        COMMENT = 'Number of unresolved investigations',
    
    investigations.inconclusive_cases AS COUNT(DISTINCT CASE WHEN outcome = 'Inconclusive' THEN investigation_id END)
        WITH SYNONYMS = ('inconclusive investigations', 'unclear outcomes')
        COMMENT = 'Number of inconclusive investigations',
    
    -- Success metrics
    investigations.success_rate AS ROUND(
        COUNT(DISTINCT CASE WHEN outcome = 'Resolved' THEN investigation_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT CASE WHEN status = 'Closed' THEN investigation_id END), 0), 2)
        WITH SYNONYMS = ('resolution rate', 'success percentage', 'win rate')
        COMMENT = 'Percentage of closed cases that were resolved',
    
    -- Priority counts
    investigations.critical_cases AS COUNT(DISTINCT CASE WHEN priority = 'Critical' THEN investigation_id END)
        WITH SYNONYMS = ('critical investigations', 'highest priority', 'urgent cases')
        COMMENT = 'Number of critical priority investigations',
    
    investigations.high_priority_cases AS COUNT(DISTINCT CASE WHEN priority = 'High' THEN investigation_id END)
        WITH SYNONYMS = ('high priority investigations', 'important cases')
        COMMENT = 'Number of high priority investigations',
    
    investigations.urgent_active_cases AS COUNT(DISTINCT CASE WHEN priority IN ('Critical', 'High') AND status IN ('Open', 'In_Progress') THEN investigation_id END)
        WITH SYNONYMS = ('urgent open cases', 'priority backlog', 'critical active')
        COMMENT = 'Active cases with critical or high priority',
    
    -- Duration metrics
    investigations.avg_case_duration AS AVG(DATEDIFF('day', start_date, COALESCE(end_date, CURRENT_DATE())))
        WITH SYNONYMS = ('average duration', 'mean case length', 'typical case time')
        COMMENT = 'Average number of days for a case',
    
    investigations.longest_case_duration AS MAX(DATEDIFF('day', start_date, COALESCE(end_date, CURRENT_DATE())))
        WITH SYNONYMS = ('longest case', 'maximum duration', 'slowest case')
        COMMENT = 'Duration of the longest case in days',
    
    investigations.shortest_case_duration AS MIN(DATEDIFF('day', start_date, end_date))
        WITH SYNONYMS = ('shortest case', 'minimum duration', 'fastest case')
        COMMENT = 'Duration of the shortest closed case in days',
    
    -- Investigator counts
    investigations.unique_investigators AS COUNT(DISTINCT lead_investigator)
        WITH SYNONYMS = ('investigator count', 'number of investigators', 'team size')
        COMMENT = 'Number of unique lead investigators',
    
    -- Related metrics
    sightings.related_sightings AS COUNT(DISTINCT sighting_id)
        WITH SYNONYMS = ('case sightings', 'related encounters')
        COMMENT = 'Number of sightings related to investigations',
    
    evidence.related_evidence AS COUNT(DISTINCT evidence_id)
        WITH SYNONYMS = ('case evidence', 'evidence collected')
        COMMENT = 'Number of evidence items related to investigations'
)
COMMENT = 'Case management analytics for ghost investigations and natural language queries'
AI_SQL_GENERATION 'When asked about investigations, cases, or assignments use this view. Status values are: Open, In_Progress, Closed, Archived. Priority values are: Low, Medium, High, Critical. Outcome values are: Resolved, Unresolved, Inconclusive, Ongoing. Use lead_investigator for questions about who is assigned to cases. Calculate duration using start_date and end_date.';

-- Grant access to analytics role
GRANT SELECT ON SEMANTIC VIEW GHOST_DETECTION.ANALYTICS.INVESTIGATION_ANALYTICS_SV 
    TO ROLE GHOST_DETECTION_ANALYST;
