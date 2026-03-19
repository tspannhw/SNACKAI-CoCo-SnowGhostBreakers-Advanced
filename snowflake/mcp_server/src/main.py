"""
FastAPI MCP Server for Ghost Detection - SPCS Deployment.

Implements the Model Context Protocol (MCP) for AI assistants to interact
with the Ghost Detection Snowflake database.
"""

import logging
import os
import sys
import json
from datetime import datetime
from typing import Any, Optional
from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI, HTTPException, Request, Response, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from .snowflake_client import get_snowflake_client, SnowflakeClient
from .tools import TOOL_DEFINITIONS, get_tool_executor, ToolExecutor
from .resources import (
    RESOURCE_DEFINITIONS, 
    RESOURCE_TEMPLATES,
    get_resource_handler, 
    ResourceHandler
)

# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

logging.basicConfig(
    format="%(message)s",
    stream=sys.stdout,
    level=logging.INFO,
)

logger = structlog.get_logger(__name__)

# Server metadata
SERVER_INFO = {
    "name": "ghost-mcp-server",
    "version": "1.0.0",
    "description": "MCP server for Ghost Detection database access",
    "vendor": "Snowflake Ghost Detection",
}

# MCP Protocol version
MCP_PROTOCOL_VERSION = "2024-11-05"


# Pydantic models for MCP protocol
class MCPInitializeParams(BaseModel):
    """Parameters for initialize request."""
    protocolVersion: str
    capabilities: dict = Field(default_factory=dict)
    clientInfo: dict = Field(default_factory=dict)


class MCPInitializeResult(BaseModel):
    """Result for initialize response."""
    protocolVersion: str
    capabilities: dict
    serverInfo: dict


class MCPToolCallParams(BaseModel):
    """Parameters for tool call request."""
    name: str
    arguments: dict = Field(default_factory=dict)


class MCPToolCallResult(BaseModel):
    """Result for tool call response."""
    content: list[dict]
    isError: bool = False


class MCPResourceReadParams(BaseModel):
    """Parameters for resource read request."""
    uri: str


class MCPResourceReadResult(BaseModel):
    """Result for resource read response."""
    contents: list[dict]


class MCPRequest(BaseModel):
    """Generic MCP JSON-RPC request."""
    jsonrpc: str = "2.0"
    id: Optional[str | int] = None
    method: str
    params: Optional[dict] = None


class MCPResponse(BaseModel):
    """Generic MCP JSON-RPC response."""
    jsonrpc: str = "2.0"
    id: Optional[str | int] = None
    result: Optional[Any] = None
    error: Optional[dict] = None


class MCPError(BaseModel):
    """MCP error object."""
    code: int
    message: str
    data: Optional[Any] = None


# Error codes
class MCPErrorCode:
    PARSE_ERROR = -32700
    INVALID_REQUEST = -32600
    METHOD_NOT_FOUND = -32601
    INVALID_PARAMS = -32602
    INTERNAL_ERROR = -32603


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    logger.info("Starting Ghost MCP Server")
    
    # Initialize Snowflake client on startup
    try:
        client = get_snowflake_client()
        if client.health_check():
            logger.info("Snowflake connection established")
        else:
            logger.warning("Snowflake connection check failed - will retry on demand")
    except Exception as e:
        logger.error("Failed to initialize Snowflake client", error=str(e))
    
    yield
    
    # Cleanup on shutdown
    logger.info("Shutting down Ghost MCP Server")
    try:
        client = get_snowflake_client()
        client.close()
    except Exception as e:
        logger.error("Error during shutdown", error=str(e))


# Create FastAPI application
app = FastAPI(
    title="Ghost MCP Server",
    description="Model Context Protocol server for Ghost Detection database",
    version="1.0.0",
    lifespan=lifespan,
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Dependency injection
async def get_client() -> SnowflakeClient:
    """Get Snowflake client dependency."""
    return get_snowflake_client()


async def get_tools() -> ToolExecutor:
    """Get tool executor dependency."""
    return get_tool_executor()


async def get_resources() -> ResourceHandler:
    """Get resource handler dependency."""
    return get_resource_handler()


# Health check endpoint
@app.get("/health")
async def health_check(client: SnowflakeClient = Depends(get_client)):
    """Health check endpoint for SPCS readiness probe."""
    snowflake_healthy = client.health_check()
    pool_stats = client.pool_stats
    
    status = "healthy" if snowflake_healthy else "degraded"
    status_code = 200 if snowflake_healthy else 503
    
    return JSONResponse(
        status_code=status_code,
        content={
            "status": status,
            "timestamp": datetime.utcnow().isoformat(),
            "snowflake_connected": snowflake_healthy,
            "pool_stats": pool_stats,
            "server_info": SERVER_INFO,
        }
    )


# Server info endpoint
@app.get("/info")
async def server_info():
    """Get server information."""
    return {
        "server": SERVER_INFO,
        "protocol_version": MCP_PROTOCOL_VERSION,
        "capabilities": {
            "tools": {"listChanged": False},
            "resources": {"subscribe": False, "listChanged": False},
            "prompts": {"listChanged": False},
        }
    }


# MCP JSON-RPC endpoint
@app.post("/mcp")
async def mcp_handler(
    request: MCPRequest,
    tools: ToolExecutor = Depends(get_tools),
    resources: ResourceHandler = Depends(get_resources),
):
    """Main MCP JSON-RPC handler."""
    logger.info("MCP request received", method=request.method, id=request.id)
    
    try:
        result = await handle_mcp_method(request.method, request.params, tools, resources)
        return MCPResponse(
            id=request.id,
            result=result
        )
    except ValueError as e:
        return MCPResponse(
            id=request.id,
            error={
                "code": MCPErrorCode.INVALID_PARAMS,
                "message": str(e)
            }
        )
    except Exception as e:
        logger.error("MCP request failed", error=str(e), method=request.method)
        return MCPResponse(
            id=request.id,
            error={
                "code": MCPErrorCode.INTERNAL_ERROR,
                "message": str(e)
            }
        )


async def handle_mcp_method(
    method: str, 
    params: Optional[dict],
    tools: ToolExecutor,
    resources: ResourceHandler
) -> Any:
    """Route MCP method to appropriate handler."""
    handlers = {
        "initialize": handle_initialize,
        "tools/list": lambda p, t, r: handle_tools_list(),
        "tools/call": lambda p, t, r: handle_tools_call(p, t),
        "resources/list": lambda p, t, r: handle_resources_list(r),
        "resources/templates/list": lambda p, t, r: handle_resource_templates_list(r),
        "resources/read": lambda p, t, r: handle_resources_read(p, r),
        "prompts/list": lambda p, t, r: handle_prompts_list(),
        "ping": lambda p, t, r: {"pong": True},
    }
    
    handler = handlers.get(method)
    if not handler:
        raise ValueError(f"Method not found: {method}")
    
    return await handler(params, tools, resources) if method == "initialize" else handler(params, tools, resources)


async def handle_initialize(params: Optional[dict], tools: ToolExecutor, resources: ResourceHandler) -> dict:
    """Handle MCP initialize request."""
    client_version = params.get("protocolVersion", MCP_PROTOCOL_VERSION) if params else MCP_PROTOCOL_VERSION
    
    logger.info("MCP initialize", client_version=client_version)
    
    return {
        "protocolVersion": MCP_PROTOCOL_VERSION,
        "capabilities": {
            "tools": {"listChanged": False},
            "resources": {"subscribe": False, "listChanged": False},
            "prompts": {"listChanged": False},
        },
        "serverInfo": SERVER_INFO,
    }


def handle_tools_list() -> dict:
    """Handle tools/list request."""
    return {"tools": TOOL_DEFINITIONS}


async def handle_tools_call(params: Optional[dict], tools: ToolExecutor) -> dict:
    """Handle tools/call request."""
    if not params:
        raise ValueError("Missing parameters for tools/call")
    
    tool_name = params.get("name")
    arguments = params.get("arguments", {})
    
    if not tool_name:
        raise ValueError("Missing tool name")
    
    logger.info("Tool call", tool=tool_name, arguments=arguments)
    
    result = await tools.execute(tool_name, arguments)
    
    # Format as MCP content
    is_error = result.get("error") is not None or result.get("success") is False
    
    return {
        "content": [
            {
                "type": "text",
                "text": json.dumps(result, indent=2, default=str)
            }
        ],
        "isError": is_error
    }


def handle_resources_list(resources: ResourceHandler) -> dict:
    """Handle resources/list request."""
    return {"resources": RESOURCE_DEFINITIONS}


def handle_resource_templates_list(resources: ResourceHandler) -> dict:
    """Handle resources/templates/list request."""
    return {"resourceTemplates": RESOURCE_TEMPLATES}


async def handle_resources_read(params: Optional[dict], resources: ResourceHandler) -> dict:
    """Handle resources/read request."""
    if not params:
        raise ValueError("Missing parameters for resources/read")
    
    uri = params.get("uri")
    if not uri:
        raise ValueError("Missing resource URI")
    
    logger.info("Resource read", uri=uri)
    
    result = await resources.read_resource(uri)
    
    if "error" in result:
        raise ValueError(result["error"])
    
    return {
        "contents": [
            {
                "uri": result.get("uri", uri),
                "mimeType": result.get("mimeType", "application/json"),
                "text": json.dumps(result.get("content", result), indent=2, default=str)
            }
        ]
    }


def handle_prompts_list() -> dict:
    """Handle prompts/list request."""
    # Define available prompts
    prompts = [
        {
            "name": "analyze_ghost",
            "description": "Analyze a ghost entity from the database",
            "arguments": [
                {
                    "name": "ghost_id",
                    "description": "The ID of the ghost to analyze",
                    "required": True
                }
            ]
        },
        {
            "name": "investigate_location",
            "description": "Get investigation recommendations for a location",
            "arguments": [
                {
                    "name": "location",
                    "description": "The location to investigate",
                    "required": True
                }
            ]
        },
        {
            "name": "explain_term",
            "description": "Explain a ghost hunting term or concept",
            "arguments": [
                {
                    "name": "term",
                    "description": "The term to explain",
                    "required": True
                }
            ]
        }
    ]
    return {"prompts": prompts}


# REST API endpoints for direct access (non-MCP)
@app.get("/api/ghosts")
async def list_ghosts(
    limit: int = 100,
    classification: Optional[str] = None,
    tools: ToolExecutor = Depends(get_tools)
):
    """List ghosts via REST API."""
    args = {"limit": limit}
    if classification:
        args["classification"] = classification
    
    result = await tools.execute("query_ghosts", args)
    return result


@app.get("/api/ghosts/{ghost_id}")
async def get_ghost(
    ghost_id: str,
    resources: ResourceHandler = Depends(get_resources)
):
    """Get a specific ghost via REST API."""
    result = await resources.read_resource(f"ghost://ghosts/{ghost_id}")
    if "error" in result:
        raise HTTPException(status_code=404, detail=result["error"])
    return result


@app.get("/api/sightings")
async def list_sightings(
    limit: int = 100,
    resources: ResourceHandler = Depends(get_resources)
):
    """List sightings via REST API."""
    result = await resources.read_resource("ghost://sightings")
    return result


@app.get("/api/sightings/{sighting_id}")
async def get_sighting(
    sighting_id: str,
    resources: ResourceHandler = Depends(get_resources)
):
    """Get a specific sighting via REST API."""
    result = await resources.read_resource(f"ghost://sightings/{sighting_id}")
    if "error" in result:
        raise HTTPException(status_code=404, detail=result["error"])
    return result


@app.post("/api/sightings/{sighting_id}/analyze")
async def analyze_sighting(
    sighting_id: str,
    include_evidence: bool = True,
    include_similar: bool = False,
    tools: ToolExecutor = Depends(get_tools)
):
    """Analyze a sighting via REST API."""
    result = await tools.execute("analyze_sighting", {
        "sighting_id": sighting_id,
        "include_evidence": include_evidence,
        "include_similar": include_similar
    })
    return result


@app.post("/api/classify")
async def classify_ghost(
    description: str,
    behaviors: list[str] = [],
    environmental_data: Optional[dict] = None,
    tools: ToolExecutor = Depends(get_tools)
):
    """Classify a ghost based on description via REST API."""
    result = await tools.execute("classify_ghost", {
        "description": description,
        "behaviors": behaviors,
        "environmental_data": environmental_data
    })
    return result


@app.get("/api/analytics/{analytics_type}")
async def get_analytics(
    analytics_type: str,
    resources: ResourceHandler = Depends(get_resources)
):
    """Get analytics data via REST API."""
    valid_types = ["summary", "trends", "hotspots"]
    if analytics_type not in valid_types:
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid analytics type. Valid types: {valid_types}"
        )
    
    result = await resources.read_resource(f"ghost://analytics/{analytics_type}")
    return result


@app.get("/api/vocabulary")
async def search_vocabulary(
    query: str,
    category: Optional[str] = None,
    limit: int = 20,
    tools: ToolExecutor = Depends(get_tools)
):
    """Search vocabulary via REST API."""
    result = await tools.execute("search_vocabulary", {
        "query": query,
        "category": category,
        "limit": limit
    })
    return result


@app.post("/api/ask")
async def ask_database(
    question: str,
    context: Optional[str] = None,
    tools: ToolExecutor = Depends(get_tools)
):
    """Ask a natural language question about the database."""
    result = await tools.execute("ask_database", {
        "question": question,
        "context": context
    })
    return result


# Error handlers
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global exception handler."""
    logger.error("Unhandled exception", error=str(exc), path=request.url.path)
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "detail": str(exc) if os.getenv("DEBUG", "false").lower() == "true" else None
        }
    )


# Create __init__.py for the package
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
