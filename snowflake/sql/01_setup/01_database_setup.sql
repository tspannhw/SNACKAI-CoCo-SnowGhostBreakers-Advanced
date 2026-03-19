/*
================================================================================
SnowGhostBreakers - Database Setup Script
================================================================================
Description: Creates database, schemas, warehouse, roles and grants for the
             Ghost Detection application.
Author: SnowGhostBreakers Team
Created: 2024
================================================================================
*/

-- ============================================================================
-- SECTION 1: DATABASE CREATION
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Create the main database for ghost detection operations
CREATE OR REPLACE DATABASE GHOST_DETECTION
    COMMENT = 'Primary database for SnowGhostBreakers ghost detection and investigation application';

-- ============================================================================
-- SECTION 2: SCHEMA CREATION
-- ============================================================================

-- APP Schema: Core application tables and views
CREATE OR REPLACE SCHEMA GHOST_DETECTION.APP
    COMMENT = 'Core application schema containing operational tables for ghost tracking, sightings, and investigations';

-- ANALYTICS Schema: Analytical views and aggregated data
CREATE OR REPLACE SCHEMA GHOST_DETECTION.ANALYTICS
    COMMENT = 'Analytics schema for reporting, dashboards, and aggregated ghost activity metrics';

-- AI Schema: AI/ML models, analysis results, and Cortex integration
CREATE OR REPLACE SCHEMA GHOST_DETECTION.AI
    COMMENT = 'AI and machine learning schema for Cortex functions, model results, and paranormal pattern analysis';

-- MCP Schema: Model Context Protocol and agent configurations
CREATE OR REPLACE SCHEMA GHOST_DETECTION.MCP
    COMMENT = 'MCP schema for Cortex Agent configurations, tools, and semantic model definitions';

-- ============================================================================
-- SECTION 3: WAREHOUSE CREATION
-- ============================================================================

-- Create X-SMALL warehouse for cost-effective operations
CREATE OR REPLACE WAREHOUSE GHOST_DETECTION_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 60                    -- Suspend after 1 minute of inactivity
    AUTO_RESUME = TRUE                   -- Auto-resume when queries arrive
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    INITIALLY_SUSPENDED = FALSE
    COMMENT = 'Primary warehouse for SnowGhostBreakers application workloads';

-- ============================================================================
-- SECTION 4: ROLE CREATION
-- ============================================================================

-- GHOSTBUSTER Role: Standard user role for field investigators
CREATE OR REPLACE ROLE GHOSTBUSTER
    COMMENT = 'Standard user role for field investigators - can view and create sightings, run investigations';

-- GHOST_ADMIN Role: Administrative role for system management
CREATE OR REPLACE ROLE GHOST_ADMIN
    COMMENT = 'Administrative role for managing ghost database, users, and system configuration';

-- GHOST_ANALYST Role: Analyst role for reporting and analytics
CREATE OR REPLACE ROLE GHOST_ANALYST
    COMMENT = 'Analyst role for running reports, creating dashboards, and analyzing paranormal patterns';

-- ============================================================================
-- SECTION 5: ROLE HIERARCHY
-- ============================================================================

-- Establish role hierarchy: GHOST_ADMIN inherits from GHOSTBUSTER and GHOST_ANALYST
GRANT ROLE GHOSTBUSTER TO ROLE GHOST_ADMIN;
GRANT ROLE GHOST_ANALYST TO ROLE GHOST_ADMIN;

-- Grant admin role to SYSADMIN for management
GRANT ROLE GHOST_ADMIN TO ROLE SYSADMIN;

-- ============================================================================
-- SECTION 6: DATABASE GRANTS
-- ============================================================================

-- Grant database usage to all roles
GRANT USAGE ON DATABASE GHOST_DETECTION TO ROLE GHOSTBUSTER;
GRANT USAGE ON DATABASE GHOST_DETECTION TO ROLE GHOST_ANALYST;
GRANT USAGE ON DATABASE GHOST_DETECTION TO ROLE GHOST_ADMIN;

-- Full database privileges for admin
GRANT ALL PRIVILEGES ON DATABASE GHOST_DETECTION TO ROLE GHOST_ADMIN;

-- ============================================================================
-- SECTION 7: SCHEMA GRANTS
-- ============================================================================

-- GHOSTBUSTER grants (APP schema - read/write for operational data)
GRANT USAGE ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOSTBUSTER;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA GHOST_DETECTION.APP TO ROLE GHOSTBUSTER;
GRANT SELECT, INSERT, UPDATE ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.APP TO ROLE GHOSTBUSTER;

-- GHOSTBUSTER grants (AI schema - read for analysis results)
GRANT USAGE ON SCHEMA GHOST_DETECTION.AI TO ROLE GHOSTBUSTER;
GRANT SELECT ON ALL TABLES IN SCHEMA GHOST_DETECTION.AI TO ROLE GHOSTBUSTER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.AI TO ROLE GHOSTBUSTER;

-- GHOST_ANALYST grants (all schemas - read access)
GRANT USAGE ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ANALYST;
GRANT USAGE ON SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ANALYST;
GRANT USAGE ON SCHEMA GHOST_DETECTION.AI TO ROLE GHOST_ANALYST;
GRANT USAGE ON SCHEMA GHOST_DETECTION.MCP TO ROLE GHOST_ANALYST;

GRANT SELECT ON ALL TABLES IN SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA GHOST_DETECTION.AI TO ROLE GHOST_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA GHOST_DETECTION.MCP TO ROLE GHOST_ANALYST;

GRANT SELECT ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.AI TO ROLE GHOST_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.MCP TO ROLE GHOST_ANALYST;

-- GHOST_ANALYST grants (ANALYTICS schema - full access for creating reports)
GRANT ALL PRIVILEGES ON SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ANALYST;

-- GHOST_ADMIN grants (all schemas - full access)
GRANT ALL PRIVILEGES ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON SCHEMA GHOST_DETECTION.AI TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON SCHEMA GHOST_DETECTION.MCP TO ROLE GHOST_ADMIN;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA GHOST_DETECTION.AI TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA GHOST_DETECTION.MCP TO ROLE GHOST_ADMIN;

GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.ANALYTICS TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.AI TO ROLE GHOST_ADMIN;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA GHOST_DETECTION.MCP TO ROLE GHOST_ADMIN;

-- ============================================================================
-- SECTION 8: WAREHOUSE GRANTS
-- ============================================================================

-- Grant warehouse usage to all roles
GRANT USAGE ON WAREHOUSE GHOST_DETECTION_WH TO ROLE GHOSTBUSTER;
GRANT USAGE ON WAREHOUSE GHOST_DETECTION_WH TO ROLE GHOST_ANALYST;
GRANT ALL PRIVILEGES ON WAREHOUSE GHOST_DETECTION_WH TO ROLE GHOST_ADMIN;

-- ============================================================================
-- SECTION 9: ADDITIONAL PRIVILEGES
-- ============================================================================

-- Grant create privileges for procedures and functions
GRANT CREATE PROCEDURE ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ADMIN;
GRANT CREATE FUNCTION ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ADMIN;
GRANT CREATE PROCEDURE ON SCHEMA GHOST_DETECTION.AI TO ROLE GHOST_ADMIN;
GRANT CREATE FUNCTION ON SCHEMA GHOST_DETECTION.AI TO ROLE GHOST_ADMIN;

-- Grant stage creation for file uploads (evidence)
GRANT CREATE STAGE ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ADMIN;
GRANT CREATE STAGE ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOSTBUSTER;

-- Grant stream and task creation for real-time processing
GRANT CREATE STREAM ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ADMIN;
GRANT CREATE TASK ON SCHEMA GHOST_DETECTION.APP TO ROLE GHOST_ADMIN;

-- ============================================================================
-- SECTION 10: SET DEFAULT CONTEXT
-- ============================================================================

-- Set default warehouse and database for the session
USE WAREHOUSE GHOST_DETECTION_WH;
USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify database creation
SHOW DATABASES LIKE 'GHOST_DETECTION';

-- Verify schema creation
SHOW SCHEMAS IN DATABASE GHOST_DETECTION;

-- Verify warehouse creation
SHOW WAREHOUSES LIKE 'GHOST_DETECTION_WH';

-- Verify role creation
SHOW ROLES LIKE 'GHOST%';

-- Display grants summary
SHOW GRANTS TO ROLE GHOSTBUSTER;
SHOW GRANTS TO ROLE GHOST_ANALYST;
SHOW GRANTS TO ROLE GHOST_ADMIN;

/*
================================================================================
SETUP COMPLETE
================================================================================
Next Steps:
1. Run 02_tables/01_core_tables.sql to create core application tables
2. Run 02_tables/02_vocabulary_tables.sql to create vocabulary/ontology tables
3. Run 02_tables/03_audit_tables.sql to create audit logging tables
4. Run sample data scripts to populate test data
================================================================================
*/
