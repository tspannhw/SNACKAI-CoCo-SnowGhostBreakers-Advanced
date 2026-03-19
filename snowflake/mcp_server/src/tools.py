"""
MCP Tool definitions and implementations for Ghost Detection.
"""

import logging
from typing import Any, Optional
from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field

from .snowflake_client import get_snowflake_client

logger = logging.getLogger(__name__)


class GhostClassification(str, Enum):
    """Ghost classification types."""
    RESIDUAL = "residual"
    INTELLIGENT = "intelligent"
    POLTERGEIST = "poltergeist"
    SHADOW = "shadow"
    APPARITION = "apparition"
    ORBS = "orbs"
    UNKNOWN = "unknown"


class ThreatLevel(str, Enum):
    """Threat level enumeration."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


# Tool Input Models
class QueryGhostsInput(BaseModel):
    """Input for querying ghosts."""
    location: Optional[str] = Field(None, description="Filter by location")
    classification: Optional[GhostClassification] = Field(None, description="Filter by ghost classification")
    threat_level: Optional[ThreatLevel] = Field(None, description="Filter by threat level")
    limit: int = Field(100, description="Maximum number of results", ge=1, le=1000)


class AnalyzeSightingInput(BaseModel):
    """Input for analyzing a sighting."""
    sighting_id: str = Field(..., description="The sighting ID to analyze")
    include_evidence: bool = Field(True, description="Include related evidence")
    include_similar: bool = Field(False, description="Include similar sightings")


class GenerateReportInput(BaseModel):
    """Input for generating reports."""
    report_type: str = Field(..., description="Type of report: summary, detailed, investigation")
    entity_id: Optional[str] = Field(None, description="Specific entity ID for the report")
    start_date: Optional[str] = Field(None, description="Start date for report range (YYYY-MM-DD)")
    end_date: Optional[str] = Field(None, description="End date for report range (YYYY-MM-DD)")


class ClassifyGhostInput(BaseModel):
    """Input for classifying a ghost."""
    description: str = Field(..., description="Description of the ghost sighting")
    behaviors: list[str] = Field(default_factory=list, description="Observed behaviors")
    environmental_data: Optional[dict] = Field(None, description="Environmental readings")


class SearchVocabularyInput(BaseModel):
    """Input for searching ghost vocabulary."""
    query: str = Field(..., description="Search query")
    category: Optional[str] = Field(None, description="Filter by category")
    limit: int = Field(20, description="Maximum results", ge=1, le=100)


class FindSimilarInput(BaseModel):
    """Input for finding similar entities."""
    entity_type: str = Field(..., description="Type: ghost, sighting, evidence")
    entity_id: str = Field(..., description="ID of the entity to find similar to")
    threshold: float = Field(0.7, description="Similarity threshold", ge=0.0, le=1.0)
    limit: int = Field(10, description="Maximum results", ge=1, le=50)


class AskDatabaseInput(BaseModel):
    """Input for natural language database queries."""
    question: str = Field(..., description="Natural language question about the data")
    context: Optional[str] = Field(None, description="Additional context for the query")


# Tool Definitions for MCP
TOOL_DEFINITIONS = [
    {
        "name": "query_ghosts",
        "description": "Query the ghost database with optional filters for location, classification, and threat level.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "location": {"type": "string", "description": "Filter by location"},
                "classification": {
                    "type": "string",
                    "enum": [c.value for c in GhostClassification],
                    "description": "Filter by ghost classification"
                },
                "threat_level": {
                    "type": "string",
                    "enum": [t.value for t in ThreatLevel],
                    "description": "Filter by threat level"
                },
                "limit": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 100}
            }
        }
    },
    {
        "name": "analyze_sighting",
        "description": "Perform detailed analysis of a specific ghost sighting, including evidence and similar cases.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "sighting_id": {"type": "string", "description": "The sighting ID to analyze"},
                "include_evidence": {"type": "boolean", "default": True},
                "include_similar": {"type": "boolean", "default": False}
            },
            "required": ["sighting_id"]
        }
    },
    {
        "name": "generate_report",
        "description": "Generate reports about ghost activity, investigations, or specific entities.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "report_type": {
                    "type": "string",
                    "enum": ["summary", "detailed", "investigation"],
                    "description": "Type of report to generate"
                },
                "entity_id": {"type": "string", "description": "Specific entity ID"},
                "start_date": {"type": "string", "format": "date"},
                "end_date": {"type": "string", "format": "date"}
            },
            "required": ["report_type"]
        }
    },
    {
        "name": "classify_ghost",
        "description": "Classify a ghost based on description, behaviors, and environmental data.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "description": {"type": "string", "description": "Description of the sighting"},
                "behaviors": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Observed behaviors"
                },
                "environmental_data": {
                    "type": "object",
                    "description": "Environmental readings (temperature, EMF, etc.)"
                }
            },
            "required": ["description"]
        }
    },
    {
        "name": "search_vocabulary",
        "description": "Search the ghost hunting vocabulary and terminology database.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "Search query"},
                "category": {"type": "string", "description": "Filter by category"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 100, "default": 20}
            },
            "required": ["query"]
        }
    },
    {
        "name": "find_similar",
        "description": "Find similar ghosts, sightings, or evidence using vector similarity search.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "entity_type": {
                    "type": "string",
                    "enum": ["ghost", "sighting", "evidence"],
                    "description": "Type of entity"
                },
                "entity_id": {"type": "string", "description": "ID of the entity"},
                "threshold": {"type": "number", "minimum": 0, "maximum": 1, "default": 0.7},
                "limit": {"type": "integer", "minimum": 1, "maximum": 50, "default": 10}
            },
            "required": ["entity_type", "entity_id"]
        }
    },
    {
        "name": "ask_database",
        "description": "Ask natural language questions about the ghost detection database.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "question": {"type": "string", "description": "Your question"},
                "context": {"type": "string", "description": "Additional context"}
            },
            "required": ["question"]
        }
    }
]


class ToolExecutor:
    """Executes MCP tools against Snowflake."""
    
    def __init__(self):
        self.client = get_snowflake_client()
    
    async def execute(self, tool_name: str, arguments: dict) -> dict[str, Any]:
        """Execute a tool by name with given arguments."""
        handlers = {
            "query_ghosts": self._query_ghosts,
            "analyze_sighting": self._analyze_sighting,
            "generate_report": self._generate_report,
            "classify_ghost": self._classify_ghost,
            "search_vocabulary": self._search_vocabulary,
            "find_similar": self._find_similar,
            "ask_database": self._ask_database,
        }
        
        handler = handlers.get(tool_name)
        if not handler:
            raise ValueError(f"Unknown tool: {tool_name}")
        
        try:
            return await handler(arguments)
        except Exception as e:
            logger.error(f"Tool execution failed for {tool_name}: {e}")
            return {"error": str(e), "success": False}
    
    async def _query_ghosts(self, args: dict) -> dict:
        """Query ghosts with filters."""
        input_data = QueryGhostsInput(**args)
        
        query = "SELECT * FROM GHOST_DETECTION.APP.GHOSTS WHERE 1=1"
        
        if input_data.location:
            query += f" AND LOCATION ILIKE '%{input_data.location}%'"
        if input_data.classification:
            query += f" AND CLASSIFICATION = '{input_data.classification.value}'"
        if input_data.threat_level:
            query += f" AND THREAT_LEVEL = '{input_data.threat_level.value}'"
        
        query += f" LIMIT {input_data.limit}"
        
        results = self.client.execute_query(query)
        return {
            "success": True,
            "count": len(results),
            "ghosts": results
        }
    
    async def _analyze_sighting(self, args: dict) -> dict:
        """Analyze a specific sighting."""
        input_data = AnalyzeSightingInput(**args)
        
        # Get sighting details
        sighting_query = f"""
            SELECT * FROM GHOST_DETECTION.APP.SIGHTINGS 
            WHERE SIGHTING_ID = '{input_data.sighting_id}'
        """
        sightings = self.client.execute_query(sighting_query)
        
        if not sightings:
            return {"success": False, "error": "Sighting not found"}
        
        result = {
            "success": True,
            "sighting": sightings[0],
        }
        
        # Get related evidence if requested
        if input_data.include_evidence:
            evidence_query = f"""
                SELECT * FROM GHOST_DETECTION.APP.EVIDENCE 
                WHERE SIGHTING_ID = '{input_data.sighting_id}'
            """
            result["evidence"] = self.client.execute_query(evidence_query)
        
        # Find similar sightings if requested
        if input_data.include_similar:
            similar_query = f"""
                SELECT s.*, 
                       VECTOR_COSINE_SIMILARITY(s.EMBEDDING, ref.EMBEDDING) as similarity
                FROM GHOST_DETECTION.APP.SIGHTINGS s,
                     (SELECT EMBEDDING FROM GHOST_DETECTION.APP.SIGHTINGS 
                      WHERE SIGHTING_ID = '{input_data.sighting_id}') ref
                WHERE s.SIGHTING_ID != '{input_data.sighting_id}'
                ORDER BY similarity DESC
                LIMIT 5
            """
            try:
                result["similar_sightings"] = self.client.execute_query(similar_query)
            except Exception as e:
                logger.warning(f"Similar sightings query failed: {e}")
                result["similar_sightings"] = []
        
        return result
    
    async def _generate_report(self, args: dict) -> dict:
        """Generate various reports."""
        input_data = GenerateReportInput(**args)
        
        if input_data.report_type == "summary":
            return await self._generate_summary_report(input_data)
        elif input_data.report_type == "detailed":
            return await self._generate_detailed_report(input_data)
        elif input_data.report_type == "investigation":
            return await self._generate_investigation_report(input_data)
        else:
            return {"success": False, "error": f"Unknown report type: {input_data.report_type}"}
    
    async def _generate_summary_report(self, input_data: GenerateReportInput) -> dict:
        """Generate a summary report."""
        summary_query = """
            SELECT 
                COUNT(*) as total_sightings,
                COUNT(DISTINCT GHOST_ID) as unique_ghosts,
                COUNT(DISTINCT LOCATION) as unique_locations,
                AVG(THREAT_LEVEL_NUMERIC) as avg_threat_level
            FROM GHOST_DETECTION.APP.SIGHTINGS
        """
        
        if input_data.start_date:
            summary_query += f" WHERE SIGHTING_DATE >= '{input_data.start_date}'"
        if input_data.end_date:
            if input_data.start_date:
                summary_query += f" AND SIGHTING_DATE <= '{input_data.end_date}'"
            else:
                summary_query += f" WHERE SIGHTING_DATE <= '{input_data.end_date}'"
        
        results = self.client.execute_query(summary_query)
        
        return {
            "success": True,
            "report_type": "summary",
            "generated_at": datetime.utcnow().isoformat(),
            "data": results[0] if results else {}
        }
    
    async def _generate_detailed_report(self, input_data: GenerateReportInput) -> dict:
        """Generate a detailed report."""
        if not input_data.entity_id:
            return {"success": False, "error": "entity_id required for detailed report"}
        
        ghost_query = f"""
            SELECT * FROM GHOST_DETECTION.APP.GHOSTS 
            WHERE GHOST_ID = '{input_data.entity_id}'
        """
        ghost = self.client.execute_query(ghost_query)
        
        sightings_query = f"""
            SELECT * FROM GHOST_DETECTION.APP.SIGHTINGS 
            WHERE GHOST_ID = '{input_data.entity_id}'
            ORDER BY SIGHTING_DATE DESC
        """
        sightings = self.client.execute_query(sightings_query)
        
        return {
            "success": True,
            "report_type": "detailed",
            "generated_at": datetime.utcnow().isoformat(),
            "ghost": ghost[0] if ghost else None,
            "sightings": sightings,
            "sighting_count": len(sightings)
        }
    
    async def _generate_investigation_report(self, input_data: GenerateReportInput) -> dict:
        """Generate an investigation report."""
        if not input_data.entity_id:
            return {"success": False, "error": "entity_id required for investigation report"}
        
        investigation_query = f"""
            SELECT i.*, 
                   COUNT(e.EVIDENCE_ID) as evidence_count
            FROM GHOST_DETECTION.APP.INVESTIGATIONS i
            LEFT JOIN GHOST_DETECTION.APP.EVIDENCE e ON i.INVESTIGATION_ID = e.INVESTIGATION_ID
            WHERE i.INVESTIGATION_ID = '{input_data.entity_id}'
            GROUP BY i.INVESTIGATION_ID
        """
        investigation = self.client.execute_query(investigation_query)
        
        return {
            "success": True,
            "report_type": "investigation",
            "generated_at": datetime.utcnow().isoformat(),
            "investigation": investigation[0] if investigation else None
        }
    
    async def _classify_ghost(self, args: dict) -> dict:
        """Classify a ghost based on description and behaviors."""
        input_data = ClassifyGhostInput(**args)
        
        # Use Cortex AI for classification
        classify_query = f"""
            SELECT SNOWFLAKE.CORTEX.COMPLETE(
                'mistral-large',
                'Classify the following ghost sighting into one of these categories: 
                 residual, intelligent, poltergeist, shadow, apparition, orbs, unknown.
                 
                 Description: {input_data.description}
                 Behaviors: {", ".join(input_data.behaviors) if input_data.behaviors else "None observed"}
                 Environmental data: {input_data.environmental_data or "Not available"}
                 
                 Respond with JSON containing: classification, confidence (0-1), reasoning'
            ) as classification_result
        """
        
        try:
            result = self.client.execute_query(classify_query)
            return {
                "success": True,
                "classification_result": result[0] if result else None
            }
        except Exception as e:
            logger.error(f"Classification failed: {e}")
            # Fallback to rule-based classification
            return await self._rule_based_classify(input_data)
    
    async def _rule_based_classify(self, input_data: ClassifyGhostInput) -> dict:
        """Fallback rule-based classification."""
        description_lower = input_data.description.lower()
        behaviors = [b.lower() for b in input_data.behaviors]
        
        classification = GhostClassification.UNKNOWN
        confidence = 0.5
        
        if any(word in description_lower for word in ["repeat", "loop", "same", "replay"]):
            classification = GhostClassification.RESIDUAL
            confidence = 0.7
        elif any(word in description_lower for word in ["respond", "interact", "aware", "intelligent"]):
            classification = GhostClassification.INTELLIGENT
            confidence = 0.7
        elif any(word in description_lower for word in ["throw", "move", "knock", "bang"]):
            classification = GhostClassification.POLTERGEIST
            confidence = 0.75
        elif any(word in description_lower for word in ["shadow", "dark", "silhouette"]):
            classification = GhostClassification.SHADOW
            confidence = 0.65
        elif any(word in description_lower for word in ["full body", "transparent", "human form"]):
            classification = GhostClassification.APPARITION
            confidence = 0.7
        elif any(word in description_lower for word in ["orb", "light", "ball", "sphere"]):
            classification = GhostClassification.ORBS
            confidence = 0.6
        
        return {
            "success": True,
            "classification": classification.value,
            "confidence": confidence,
            "method": "rule_based"
        }
    
    async def _search_vocabulary(self, args: dict) -> dict:
        """Search ghost hunting vocabulary."""
        input_data = SearchVocabularyInput(**args)
        
        query = f"""
            SELECT * FROM GHOST_DETECTION.APP.VOCABULARY
            WHERE TERM ILIKE '%{input_data.query}%' 
               OR DEFINITION ILIKE '%{input_data.query}%'
        """
        
        if input_data.category:
            query += f" AND CATEGORY = '{input_data.category}'"
        
        query += f" LIMIT {input_data.limit}"
        
        results = self.client.execute_query(query)
        return {
            "success": True,
            "count": len(results),
            "terms": results
        }
    
    async def _find_similar(self, args: dict) -> dict:
        """Find similar entities using vector search."""
        input_data = FindSimilarInput(**args)
        
        table_map = {
            "ghost": "GHOSTS",
            "sighting": "SIGHTINGS",
            "evidence": "EVIDENCE"
        }
        
        table = table_map.get(input_data.entity_type)
        if not table:
            return {"success": False, "error": f"Unknown entity type: {input_data.entity_type}"}
        
        id_column = f"{input_data.entity_type.upper()}_ID"
        
        query = f"""
            SELECT t.*, 
                   VECTOR_COSINE_SIMILARITY(t.EMBEDDING, ref.EMBEDDING) as similarity
            FROM GHOST_DETECTION.APP.{table} t,
                 (SELECT EMBEDDING FROM GHOST_DETECTION.APP.{table} 
                  WHERE {id_column} = '{input_data.entity_id}') ref
            WHERE t.{id_column} != '{input_data.entity_id}'
              AND VECTOR_COSINE_SIMILARITY(t.EMBEDDING, ref.EMBEDDING) >= {input_data.threshold}
            ORDER BY similarity DESC
            LIMIT {input_data.limit}
        """
        
        try:
            results = self.client.execute_query(query)
            return {
                "success": True,
                "count": len(results),
                "similar": results
            }
        except Exception as e:
            logger.error(f"Similarity search failed: {e}")
            return {"success": False, "error": str(e)}
    
    async def _ask_database(self, args: dict) -> dict:
        """Answer natural language questions about the database."""
        input_data = AskDatabaseInput(**args)
        
        # Use Cortex Analyst or text-to-SQL
        analyst_query = f"""
            SELECT SNOWFLAKE.CORTEX.COMPLETE(
                'mistral-large',
                'You are a helpful assistant that answers questions about a ghost detection database.
                 The database contains tables: GHOSTS, SIGHTINGS, EVIDENCE, INVESTIGATIONS, VOCABULARY.
                 
                 Question: {input_data.question}
                 Context: {input_data.context or "General ghost detection database query"}
                 
                 Generate a SQL query to answer this question and explain the results.'
            ) as answer
        """
        
        try:
            result = self.client.execute_query(analyst_query)
            return {
                "success": True,
                "question": input_data.question,
                "answer": result[0] if result else None
            }
        except Exception as e:
            logger.error(f"Ask database failed: {e}")
            return {"success": False, "error": str(e)}


# Singleton tool executor
_tool_executor: Optional[ToolExecutor] = None


def get_tool_executor() -> ToolExecutor:
    """Get the singleton tool executor instance."""
    global _tool_executor
    if _tool_executor is None:
        _tool_executor = ToolExecutor()
    return _tool_executor
