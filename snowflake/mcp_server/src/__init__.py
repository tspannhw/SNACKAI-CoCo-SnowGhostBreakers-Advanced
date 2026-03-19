"""
Ghost Detection MCP Server Package.

Provides MCP (Model Context Protocol) endpoints for AI assistants
to interact with the Ghost Detection Snowflake database.
"""

from .main import app
from .snowflake_client import get_snowflake_client, SnowflakeClient
from .tools import TOOL_DEFINITIONS, get_tool_executor, ToolExecutor
from .resources import RESOURCE_DEFINITIONS, get_resource_handler, ResourceHandler

__version__ = "1.0.0"
__all__ = [
    "app",
    "get_snowflake_client",
    "SnowflakeClient",
    "TOOL_DEFINITIONS",
    "get_tool_executor",
    "ToolExecutor",
    "RESOURCE_DEFINITIONS",
    "get_resource_handler",
    "ResourceHandler",
]
