"""
SnowGhost Breakers - Integration Tests
Tests for MCP server and API integration
"""

import pytest
import httpx
import json
from typing import Any, Dict, Optional
import os
from dotenv import load_dotenv

load_dotenv()

# Configuration
MCP_SERVER_URL = os.getenv("MCP_SERVER_URL", "http://localhost:8000")
TIMEOUT = 30.0


class TestMCPProtocol:
    """Test MCP protocol compliance"""
    
    @pytest.fixture
    def client(self):
        return httpx.Client(base_url=MCP_SERVER_URL, timeout=TIMEOUT)
    
    def test_health_check(self, client):
        """Test server health endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "snowflake_connected" in data
    
    def test_mcp_initialize(self, client):
        """Test MCP initialize request"""
        request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "roots": {"listChanged": True}
                },
                "clientInfo": {
                    "name": "test-client",
                    "version": "1.0.0"
                }
            }
        }
        
        response = client.post("/mcp", json=request)
        assert response.status_code == 200
        
        data = response.json()
        assert data["jsonrpc"] == "2.0"
        assert data["id"] == 1
        assert "result" in data
        assert "protocolVersion" in data["result"]
        assert "capabilities" in data["result"]
        assert "serverInfo" in data["result"]
    
    def test_mcp_list_tools(self, client):
        """Test MCP tools/list request"""
        request = {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/list",
            "params": {}
        }
        
        response = client.post("/mcp", json=request)
        assert response.status_code == 200
        
        data = response.json()
        assert "result" in data
        assert "tools" in data["result"]
        
        tools = data["result"]["tools"]
        tool_names = [t["name"] for t in tools]
        
        # Verify required tools exist
        required_tools = [
            "query_ghosts",
            "analyze_sighting",
            "generate_report",
            "classify_ghost",
            "search_vocabulary",
            "find_similar",
            "ask_database"
        ]
        
        for tool in required_tools:
            assert tool in tool_names, f"Missing required tool: {tool}"
    
    def test_mcp_list_resources(self, client):
        """Test MCP resources/list request"""
        request = {
            "jsonrpc": "2.0",
            "id": 3,
            "method": "resources/list",
            "params": {}
        }
        
        response = client.post("/mcp", json=request)
        assert response.status_code == 200
        
        data = response.json()
        assert "result" in data
        assert "resources" in data["result"]
        
        resources = data["result"]["resources"]
        resource_uris = [r["uri"] for r in resources]
        
        # Verify required resources exist
        assert any("ghosts" in uri for uri in resource_uris)
        assert any("sightings" in uri for uri in resource_uris)


class TestMCPTools:
    """Test MCP tool execution"""
    
    @pytest.fixture
    def client(self):
        return httpx.Client(base_url=MCP_SERVER_URL, timeout=TIMEOUT)
    
    def call_tool(self, client, tool_name: str, arguments: Dict[str, Any]) -> Dict:
        """Helper to call an MCP tool"""
        request = {
            "jsonrpc": "2.0",
            "id": 100,
            "method": "tools/call",
            "params": {
                "name": tool_name,
                "arguments": arguments
            }
        }
        
        response = client.post("/mcp", json=request)
        assert response.status_code == 200
        return response.json()
    
    def test_query_ghosts_no_filter(self, client):
        """Test querying ghosts without filters"""
        result = self.call_tool(client, "query_ghosts", {"limit": 10})
        
        assert "result" in result
        assert "content" in result["result"]
        content = result["result"]["content"][0]
        assert content["type"] == "text"
        
        # Parse the JSON result
        ghosts = json.loads(content["text"])
        assert isinstance(ghosts, list)
    
    def test_query_ghosts_with_filter(self, client):
        """Test querying ghosts with threat level filter"""
        result = self.call_tool(client, "query_ghosts", {
            "threat_level": "High",
            "limit": 5
        })
        
        assert "result" in result
        content = result["result"]["content"][0]
        ghosts = json.loads(content["text"])
        
        # Verify filter was applied
        for ghost in ghosts:
            assert ghost.get("threat_level") == "High" or ghost.get("THREAT_LEVEL") == "High"
    
    def test_classify_ghost(self, client):
        """Test ghost classification from description"""
        result = self.call_tool(client, "classify_ghost", {
            "description": "A transparent figure of a woman in white, floating through walls"
        })
        
        assert "result" in result
        content = result["result"]["content"][0]
        classification = json.loads(content["text"])
        
        assert "type" in classification or "ghost_type" in classification
    
    def test_search_vocabulary(self, client):
        """Test vocabulary search"""
        result = self.call_tool(client, "search_vocabulary", {
            "search_term": "poltergeist"
        })
        
        assert "result" in result
        content = result["result"]["content"][0]
        vocab_results = json.loads(content["text"])
        
        assert isinstance(vocab_results, list)
    
    @pytest.mark.slow
    def test_generate_report(self, client):
        """Test report generation (slow - uses LLM)"""
        # First get a ghost ID
        ghosts_result = self.call_tool(client, "query_ghosts", {"limit": 1})
        ghosts = json.loads(ghosts_result["result"]["content"][0]["text"])
        
        if not ghosts:
            pytest.skip("No ghosts available for testing")
        
        ghost_id = ghosts[0].get("ghost_id") or ghosts[0].get("GHOST_ID")
        
        result = self.call_tool(client, "generate_report", {
            "ghost_id": ghost_id
        })
        
        assert "result" in result
        content = result["result"]["content"][0]
        assert len(content["text"]) > 100  # Report should have substantial content


class TestMCPResources:
    """Test MCP resource reading"""
    
    @pytest.fixture
    def client(self):
        return httpx.Client(base_url=MCP_SERVER_URL, timeout=TIMEOUT)
    
    def read_resource(self, client, uri: str) -> Dict:
        """Helper to read an MCP resource"""
        request = {
            "jsonrpc": "2.0",
            "id": 200,
            "method": "resources/read",
            "params": {
                "uri": uri
            }
        }
        
        response = client.post("/mcp", json=request)
        assert response.status_code == 200
        return response.json()
    
    def test_read_ghosts_resource(self, client):
        """Test reading ghosts resource"""
        result = self.read_resource(client, "snowflake://ghost-detection/ghosts")
        
        assert "result" in result
        assert "contents" in result["result"]
        
        content = result["result"]["contents"][0]
        ghosts = json.loads(content["text"])
        assert isinstance(ghosts, list)
    
    def test_read_sightings_resource(self, client):
        """Test reading sightings resource"""
        result = self.read_resource(client, "snowflake://ghost-detection/sightings")
        
        assert "result" in result
        assert "contents" in result["result"]
    
    def test_read_analytics_resource(self, client):
        """Test reading analytics resource"""
        result = self.read_resource(client, "snowflake://ghost-detection/analytics/activity-summary")
        
        assert "result" in result
        assert "contents" in result["result"]


class TestRESTAPI:
    """Test REST API endpoints"""
    
    @pytest.fixture
    def client(self):
        return httpx.Client(base_url=MCP_SERVER_URL, timeout=TIMEOUT)
    
    def test_get_ghosts(self, client):
        """Test GET /api/ghosts endpoint"""
        response = client.get("/api/ghosts")
        assert response.status_code == 200
        
        data = response.json()
        assert "data" in data
        assert isinstance(data["data"], list)
    
    def test_get_ghosts_with_filter(self, client):
        """Test GET /api/ghosts with query params"""
        response = client.get("/api/ghosts", params={
            "threat_level": "High",
            "status": "Active",
            "limit": 5
        })
        assert response.status_code == 200
        
        data = response.json()
        assert "data" in data
    
    def test_get_sightings(self, client):
        """Test GET /api/sightings endpoint"""
        response = client.get("/api/sightings")
        assert response.status_code == 200
        
        data = response.json()
        assert "data" in data
    
    def test_get_investigations(self, client):
        """Test GET /api/investigations endpoint"""
        response = client.get("/api/investigations")
        assert response.status_code == 200
        
        data = response.json()
        assert "data" in data
    
    def test_get_analytics_summary(self, client):
        """Test GET /api/analytics/summary endpoint"""
        response = client.get("/api/analytics/summary")
        assert response.status_code == 200
        
        data = response.json()
        assert "data" in data


class TestErrorHandling:
    """Test error handling scenarios"""
    
    @pytest.fixture
    def client(self):
        return httpx.Client(base_url=MCP_SERVER_URL, timeout=TIMEOUT)
    
    def test_invalid_tool_name(self, client):
        """Test calling non-existent tool"""
        request = {
            "jsonrpc": "2.0",
            "id": 300,
            "method": "tools/call",
            "params": {
                "name": "nonexistent_tool",
                "arguments": {}
            }
        }
        
        response = client.post("/mcp", json=request)
        assert response.status_code == 200
        
        data = response.json()
        assert "error" in data
    
    def test_invalid_resource_uri(self, client):
        """Test reading non-existent resource"""
        request = {
            "jsonrpc": "2.0",
            "id": 301,
            "method": "resources/read",
            "params": {
                "uri": "snowflake://ghost-detection/invalid"
            }
        }
        
        response = client.post("/mcp", json=request)
        assert response.status_code == 200
        
        data = response.json()
        assert "error" in data
    
    def test_missing_required_argument(self, client):
        """Test tool call with missing required argument"""
        request = {
            "jsonrpc": "2.0",
            "id": 302,
            "method": "tools/call",
            "params": {
                "name": "generate_report",
                "arguments": {}  # Missing ghost_id
            }
        }
        
        response = client.post("/mcp", json=request)
        data = response.json()
        
        # Should either return error or handle gracefully
        assert response.status_code == 200
        assert "error" in data or "result" in data


# Run with: pytest tests/integration/test_mcp_integration.py -v
if __name__ == "__main__":
    pytest.main([__file__, "-v"])
