-- ============================================================================
-- Ghost Detection MCP Server - SPCS Deployment Script
-- ============================================================================
-- This script deploys the Ghost MCP Server to Snowpark Container Services.
-- 
-- Prerequisites:
-- 1. Docker image built and ready to push
-- 2. Appropriate privileges to create compute pools and services
-- 3. External access integration (if needed for external API calls)
-- ============================================================================

-- Use the appropriate role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE GHOST_DETECTION_WH;
USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;

-- ============================================================================
-- Step 1: Create Image Repository
-- ============================================================================
CREATE IMAGE REPOSITORY IF NOT EXISTS GHOST_DETECTION.APP.IMAGES;

-- Get the repository URL (use this for docker push)
SHOW IMAGE REPOSITORIES IN SCHEMA GHOST_DETECTION.APP;

-- The repository URL will be in the format:
-- <org>-<account>.registry.snowflakecomputing.com/ghost_detection/app/images

-- ============================================================================
-- Step 2: Create Compute Pool
-- ============================================================================
-- Create a compute pool for running the MCP server
CREATE COMPUTE POOL IF NOT EXISTS GHOST_MCP_POOL
    MIN_NODES = 1
    MAX_NODES = 2
    INSTANCE_FAMILY = CPU_X64_XS
    AUTO_RESUME = TRUE
    AUTO_SUSPEND_SECS = 3600
    COMMENT = 'Compute pool for Ghost Detection MCP Server';

-- Verify compute pool is created
DESCRIBE COMPUTE POOL GHOST_MCP_POOL;

-- Wait for compute pool to be ready
-- SELECT SYSTEM$WAIT_FOR_COMPUTE_POOL('GHOST_MCP_POOL', 600);

-- ============================================================================
-- Step 3: Create External Access Integration (if needed)
-- ============================================================================
-- This allows the service to make external network calls if required
CREATE OR REPLACE NETWORK RULE ghost_mcp_egress_rule
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('0.0.0.0:443', '0.0.0.0:80');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION GHOST_MCP_EAI
    ALLOWED_NETWORK_RULES = (ghost_mcp_egress_rule)
    ENABLED = TRUE
    COMMENT = 'External access for Ghost MCP Server';

-- ============================================================================
-- Step 4: Create Service
-- ============================================================================
-- Drop existing service if it exists (for redeployment)
DROP SERVICE IF EXISTS GHOST_DETECTION.APP.GHOST_MCP_SERVICE;

-- Create the SPCS service
CREATE SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE
    IN COMPUTE POOL GHOST_MCP_POOL
    FROM SPECIFICATION $$
    spec:
      container:
        - name: ghost-mcp-server
          image: /ghost_detection/app/images/ghost_mcp_server:latest
          env:
            SNOWFLAKE_DATABASE: GHOST_DETECTION
            SNOWFLAKE_SCHEMA: APP
            SNOWFLAKE_WAREHOUSE: GHOST_DETECTION_WH
            LOG_LEVEL: INFO
          readinessProbe:
            port: 8000
            path: /health
          resources:
            requests:
              memory: 1Gi
              cpu: 0.5
            limits:
              memory: 2Gi
              cpu: 1
      endpoint:
        - name: mcp-endpoint
          port: 8000
          public: true
    $$
    EXTERNAL_ACCESS_INTEGRATIONS = (GHOST_MCP_EAI)
    MIN_INSTANCES = 1
    MAX_INSTANCES = 2
    COMMENT = 'Ghost Detection MCP Server for AI assistant integration';

-- ============================================================================
-- Step 5: Verify Service Deployment
-- ============================================================================
-- Check service status
SHOW SERVICES IN SCHEMA GHOST_DETECTION.APP;

-- Get service details
DESCRIBE SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE;

-- Check service logs
SELECT SYSTEM$GET_SERVICE_LOGS('GHOST_DETECTION.APP.GHOST_MCP_SERVICE', 0, 'ghost-mcp-server', 100);

-- Get service status
SELECT SYSTEM$GET_SERVICE_STATUS('GHOST_DETECTION.APP.GHOST_MCP_SERVICE');

-- ============================================================================
-- Step 6: Get Service Endpoint
-- ============================================================================
-- Get the public endpoint URL for the MCP server
SHOW ENDPOINTS IN SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE;

-- ============================================================================
-- Step 7: Grant Access (if needed)
-- ============================================================================
-- Grant usage to other roles that need to access the service
-- GRANT USAGE ON SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE TO ROLE GHOST_DETECTION_USER;

-- ============================================================================
-- Helper Commands
-- ============================================================================

-- Suspend service (to save costs)
-- ALTER SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE SUSPEND;

-- Resume service
-- ALTER SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE RESUME;

-- Drop service
-- DROP SERVICE GHOST_DETECTION.APP.GHOST_MCP_SERVICE;

-- Drop compute pool
-- DROP COMPUTE POOL GHOST_MCP_POOL;

-- ============================================================================
-- Docker Build and Push Instructions
-- ============================================================================
/*
To build and push the Docker image:

1. Get the repository URL:
   SHOW IMAGE REPOSITORIES IN SCHEMA GHOST_DETECTION.APP;

2. Login to Snowflake registry:
   docker login <org>-<account>.registry.snowflakecomputing.com -u <username>

3. Build the image:
   cd /path/to/mcp_server
   docker build -t ghost_mcp_server:latest .

4. Tag the image:
   docker tag ghost_mcp_server:latest \
     <org>-<account>.registry.snowflakecomputing.com/ghost_detection/app/images/ghost_mcp_server:latest

5. Push the image:
   docker push <org>-<account>.registry.snowflakecomputing.com/ghost_detection/app/images/ghost_mcp_server:latest

6. Run this deployment script to create the service

*/

-- ============================================================================
-- Test the Service
-- ============================================================================
/*
Once deployed, you can test the service using the endpoint URL:

1. Health check:
   curl https://<endpoint-url>/health

2. Server info:
   curl https://<endpoint-url>/info

3. MCP initialize:
   curl -X POST https://<endpoint-url>/mcp \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}'

4. List tools:
   curl -X POST https://<endpoint-url>/mcp \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'

5. Query ghosts:
   curl -X POST https://<endpoint-url>/mcp \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"query_ghosts","arguments":{"limit":10}}}'

*/
