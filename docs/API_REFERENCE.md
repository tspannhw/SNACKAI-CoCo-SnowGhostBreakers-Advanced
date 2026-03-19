# SnowGhost Breakers - API Reference

## Overview

The SnowGhost Breakers API provides access to ghost detection data, AI-powered analysis, and investigation management through two interfaces:

1. **MCP (Model Context Protocol)** - For AI agent integration
2. **REST API** - For traditional web application integration

Base URL: `https://your-spcs-service.snowflakecomputing.app`

## Authentication

### SPCS Token Authentication (Default)
When running in Snowpark Container Services, authentication is automatic via service tokens.

### External Authentication
For external access, use Snowflake OAuth:

```http
Authorization: Bearer <snowflake_oauth_token>
```

---

## MCP Protocol

### Initialize

Establish MCP session with the server.

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "roots": {"listChanged": true}
    },
    "clientInfo": {
      "name": "your-client",
      "version": "1.0.0"
    }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "tools": {},
      "resources": {}
    },
    "serverInfo": {
      "name": "ghost-detection-mcp",
      "version": "1.0.0"
    }
  }
}
```

---

## MCP Tools

### query_ghosts

Query the ghost registry with optional filters.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `threat_level` | string | No | Filter: Low, Medium, High, Extreme |
| `ghost_type` | string | No | Filter by ghost type |
| `status` | string | No | Filter: Active, Dormant, Captured, Neutralized |
| `limit` | integer | No | Max results (default: 100) |

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 10,
  "method": "tools/call",
  "params": {
    "name": "query_ghosts",
    "arguments": {
      "threat_level": "High",
      "status": "Active",
      "limit": 10
    }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 10,
  "result": {
    "content": [{
      "type": "text",
      "text": "[{\"ghost_id\":\"GH001\",\"ghost_name\":\"The Grey Lady\",...}]"
    }]
  }
}
```

---

### analyze_sighting

Perform AI analysis on a ghost sighting.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `sighting_id` | string | Yes | ID of the sighting to analyze |

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 11,
  "method": "tools/call",
  "params": {
    "name": "analyze_sighting",
    "arguments": {
      "sighting_id": "SIGHT001"
    }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 11,
  "result": {
    "content": [{
      "type": "text",
      "text": "{\"sentiment_score\":-0.42,\"threat_assessment\":\"Medium\",\"recommendations\":[...]}"
    }]
  }
}
```

---

### generate_report

Generate a comprehensive AI report for a ghost entity.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ghost_id` | string | Yes | ID of the ghost |

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 12,
  "method": "tools/call",
  "params": {
    "name": "generate_report",
    "arguments": {
      "ghost_id": "GH001"
    }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 12,
  "result": {
    "content": [{
      "type": "text",
      "text": "## Ghost Investigation Report\n\n### Overview\nThe Grey Lady is a Class III Apparition..."
    }]
  }
}
```

---

### classify_ghost

Classify a ghost type from a description using AI.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `description` | string | Yes | Description of the paranormal encounter |

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 13,
  "method": "tools/call",
  "params": {
    "name": "classify_ghost",
    "arguments": {
      "description": "A transparent figure of a woman walking through walls"
    }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 13,
  "result": {
    "content": [{
      "type": "text",
      "text": "{\"type\":\"Apparition\",\"confidence\":0.87,\"reasoning\":\"Visual manifestation with wall-phasing ability indicates classic apparition behavior\"}"
    }]
  }
}
```

---

### search_vocabulary

Search the business vocabulary/ontology.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `search_term` | string | Yes | Term to search for |

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 14,
  "method": "tools/call",
  "params": {
    "name": "search_vocabulary",
    "arguments": {
      "search_term": "EMF"
    }
  }
}
```

---

### find_similar

Find similar ghosts or sightings using vector similarity.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `description` | string | Yes | Description to match against |
| `limit` | integer | No | Max results (default: 5) |

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 15,
  "method": "tools/call",
  "params": {
    "name": "find_similar",
    "arguments": {
      "description": "Cold spot with flickering lights",
      "limit": 5
    }
  }
}
```

---

### ask_database

Ask a natural language question about the data.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `question` | string | Yes | Natural language question |

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 16,
  "method": "tools/call",
  "params": {
    "name": "ask_database",
    "arguments": {
      "question": "What are the most active haunted locations?"
    }
  }
}
```

---

## MCP Resources

### List Resources

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 20,
  "method": "resources/list",
  "params": {}
}
```

### Available Resources

| URI | Description |
|-----|-------------|
| `snowflake://ghost-detection/ghosts` | Ghost registry |
| `snowflake://ghost-detection/sightings` | Sighting records |
| `snowflake://ghost-detection/evidence` | Evidence items |
| `snowflake://ghost-detection/investigations` | Investigation cases |
| `snowflake://ghost-detection/analytics/activity-summary` | Activity metrics |
| `snowflake://ghost-detection/analytics/hotspots` | Geographic hotspots |
| `snowflake://ghost-detection/vocabulary` | Business vocabulary |

### Read Resource

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 21,
  "method": "resources/read",
  "params": {
    "uri": "snowflake://ghost-detection/ghosts"
  }
}
```

---

## REST API Endpoints

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "snowflake_connected": true,
  "timestamp": "2024-03-03T12:00:00Z"
}
```

---

### GET /api/ghosts

Get ghosts with optional filtering.

**Query Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `threat_level` | string | Filter by threat level |
| `ghost_type` | string | Filter by type |
| `status` | string | Filter by status |
| `limit` | integer | Max results |
| `offset` | integer | Pagination offset |

**Response:**
```json
{
  "data": [
    {
      "ghost_id": "GH001",
      "ghost_name": "The Grey Lady",
      "ghost_type": "Apparition",
      "threat_level": "Medium",
      "status": "Active",
      "description": "A translucent female figure...",
      "confidence_score": 0.85
    }
  ],
  "total": 15,
  "limit": 100,
  "offset": 0
}
```

---

### GET /api/ghosts/{ghost_id}

Get a specific ghost by ID.

**Response:**
```json
{
  "data": {
    "ghost_id": "GH001",
    "ghost_name": "The Grey Lady",
    "ghost_type": "Apparition",
    "threat_level": "Medium",
    "status": "Active",
    "description": "...",
    "first_sighting": "2020-10-31T23:00:00Z",
    "last_sighting": "2024-02-14T03:30:00Z",
    "sighting_count": 47,
    "evidence_count": 12
  }
}
```

---

### GET /api/sightings

Get sightings with optional filtering.

**Query Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `ghost_id` | string | Filter by ghost |
| `location` | string | Filter by location name |
| `verified` | boolean | Filter by verification status |
| `start_date` | string | Filter: sightings after date |
| `end_date` | string | Filter: sightings before date |
| `limit` | integer | Max results |

---

### POST /api/sightings

Report a new sighting.

**Request Body:**
```json
{
  "ghost_id": "GH001",
  "location_name": "Old Manor House",
  "location_address": "123 Haunted Lane",
  "latitude": 51.5074,
  "longitude": -0.1278,
  "description": "Witnessed a figure in white...",
  "witness_name": "John Doe",
  "temperature_celsius": -2.5,
  "emf_reading": 8.3,
  "activity_level": 7
}
```

**Response:**
```json
{
  "success": true,
  "sighting_id": "SIGHT123456",
  "ai_analysis": {
    "sentiment_score": -0.65,
    "urgency": "MEDIUM"
  }
}
```

---

### GET /api/investigations

Get investigations.

**Query Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `status` | string | Filter: Open, In_Progress, Closed |
| `priority` | string | Filter: Low, Medium, High, Critical |

---

### POST /api/investigations

Create a new investigation.

**Request Body:**
```json
{
  "case_name": "Manor House Investigation",
  "description": "Multiple sightings reported at...",
  "ghost_ids": ["GH001", "GH002"],
  "lead_investigator": "Dr. Ray Stantz",
  "team_members": ["Peter Venkman", "Egon Spengler"],
  "priority": "High"
}
```

---

### GET /api/analytics/summary

Get aggregated analytics summary.

**Response:**
```json
{
  "data": {
    "total_ghosts": 15,
    "active_ghosts": 8,
    "total_sightings": 234,
    "sightings_this_month": 12,
    "open_investigations": 3,
    "threat_distribution": {
      "Low": 5,
      "Medium": 6,
      "High": 3,
      "Extreme": 1
    }
  }
}
```

---

### GET /api/analytics/hotspots

Get paranormal hotspot analysis.

**Response:**
```json
{
  "data": [
    {
      "location_name": "Tower of London",
      "latitude": 51.5081,
      "longitude": -0.0759,
      "total_sightings": 45,
      "unique_ghosts": 5,
      "classification": "Critical Hotspot"
    }
  ]
}
```

---

### POST /api/ai/classify

Classify a ghost from description.

**Request Body:**
```json
{
  "description": "Objects flying across the room"
}
```

**Response:**
```json
{
  "type": "Poltergeist",
  "confidence": 0.92,
  "reasoning": "Physical manipulation of objects is characteristic of poltergeist activity"
}
```

---

### POST /api/ai/analyze

Analyze text with Cortex AI.

**Request Body:**
```json
{
  "text": "I saw a terrifying shadow figure last night",
  "analysis_types": ["sentiment", "classification", "summary"]
}
```

---

## Error Responses

### MCP Errors
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32602,
    "message": "Invalid params",
    "data": "ghost_id is required"
  }
}
```

### REST API Errors
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Ghost with ID GH999 not found"
  }
}
```

### Error Codes
| Code | Description |
|------|-------------|
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid/missing auth |
| 404 | Not Found - Resource doesn't exist |
| 429 | Rate Limited - Too many requests |
| 500 | Internal Error - Server-side issue |

---

## Rate Limits

| Endpoint Type | Limit |
|---------------|-------|
| MCP Tools | 100 requests/minute |
| REST GET | 200 requests/minute |
| REST POST | 50 requests/minute |
| AI Analysis | 20 requests/minute |

---

## SDKs and Examples

### Python
```python
import httpx

client = httpx.Client(base_url="https://your-service.snowflakecomputing.app")

# Query ghosts
response = client.get("/api/ghosts", params={"threat_level": "High"})
ghosts = response.json()["data"]

# MCP tool call
mcp_request = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
        "name": "generate_report",
        "arguments": {"ghost_id": "GH001"}
    }
}
response = client.post("/mcp", json=mcp_request)
```

### JavaScript
```javascript
// REST API
const response = await fetch('/api/ghosts?threat_level=High');
const { data: ghosts } = await response.json();

// MCP
const mcpResponse = await fetch('/mcp', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: { name: 'query_ghosts', arguments: { limit: 10 } }
  })
});
```
