"""
MCP Resource definitions for Ghost Detection.
"""

import logging
from typing import Any, Optional
from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field

from .snowflake_client import get_snowflake_client

logger = logging.getLogger(__name__)


# Resource Definitions for MCP
RESOURCE_DEFINITIONS = [
    {
        "uri": "ghost://ghosts",
        "name": "Ghosts Database",
        "description": "Access to the ghosts database containing all known ghost entities.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://ghosts/{ghost_id}",
        "name": "Ghost Details",
        "description": "Detailed information about a specific ghost.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://sightings",
        "name": "Sightings Database",
        "description": "Access to all ghost sightings records.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://sightings/{sighting_id}",
        "name": "Sighting Details",
        "description": "Detailed information about a specific sighting.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://evidence",
        "name": "Evidence Database",
        "description": "Access to collected evidence from investigations.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://evidence/{evidence_id}",
        "name": "Evidence Details",
        "description": "Detailed information about a specific piece of evidence.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://investigations",
        "name": "Investigations Database",
        "description": "Access to investigation records and status.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://investigations/{investigation_id}",
        "name": "Investigation Details",
        "description": "Detailed information about a specific investigation.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://analytics/summary",
        "name": "Analytics Summary",
        "description": "Summary analytics of ghost detection activities.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://analytics/trends",
        "name": "Sighting Trends",
        "description": "Trend analysis of ghost sightings over time.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://analytics/hotspots",
        "name": "Activity Hotspots",
        "description": "Geographic hotspots of paranormal activity.",
        "mimeType": "application/json"
    },
    {
        "uri": "ghost://vocabulary",
        "name": "Ghost Vocabulary",
        "description": "Dictionary of ghost hunting terminology.",
        "mimeType": "application/json"
    }
]


# Resource URI Templates for dynamic resources
RESOURCE_TEMPLATES = [
    {
        "uriTemplate": "ghost://ghosts/{ghost_id}",
        "name": "Ghost by ID",
        "description": "Get details for a specific ghost by ID"
    },
    {
        "uriTemplate": "ghost://sightings/{sighting_id}",
        "name": "Sighting by ID",
        "description": "Get details for a specific sighting by ID"
    },
    {
        "uriTemplate": "ghost://evidence/{evidence_id}",
        "name": "Evidence by ID",
        "description": "Get details for a specific piece of evidence by ID"
    },
    {
        "uriTemplate": "ghost://investigations/{investigation_id}",
        "name": "Investigation by ID",
        "description": "Get details for a specific investigation by ID"
    }
]


class ResourceHandler:
    """Handles MCP resource requests."""
    
    def __init__(self):
        self.client = get_snowflake_client()
    
    async def read_resource(self, uri: str) -> dict[str, Any]:
        """Read a resource by URI."""
        try:
            # Parse the URI
            parts = uri.replace("ghost://", "").split("/")
            
            if len(parts) == 0:
                return {"error": "Invalid resource URI"}
            
            resource_type = parts[0]
            resource_id = parts[1] if len(parts) > 1 else None
            
            handlers = {
                "ghosts": self._read_ghosts,
                "sightings": self._read_sightings,
                "evidence": self._read_evidence,
                "investigations": self._read_investigations,
                "analytics": self._read_analytics,
                "vocabulary": self._read_vocabulary,
            }
            
            handler = handlers.get(resource_type)
            if not handler:
                return {"error": f"Unknown resource type: {resource_type}"}
            
            return await handler(resource_id, parts[2:] if len(parts) > 2 else [])
            
        except Exception as e:
            logger.error(f"Resource read failed for {uri}: {e}")
            return {"error": str(e)}
    
    async def _read_ghosts(self, ghost_id: Optional[str], extra_parts: list) -> dict:
        """Read ghost resources."""
        if ghost_id:
            # Get specific ghost
            query = f"""
                SELECT g.*,
                       (SELECT COUNT(*) FROM GHOST_DETECTION.APP.SIGHTINGS s 
                        WHERE s.GHOST_ID = g.GHOST_ID) as sighting_count,
                       (SELECT MAX(SIGHTING_DATE) FROM GHOST_DETECTION.APP.SIGHTINGS s 
                        WHERE s.GHOST_ID = g.GHOST_ID) as last_seen
                FROM GHOST_DETECTION.APP.GHOSTS g
                WHERE g.GHOST_ID = '{ghost_id}'
            """
            results = self.client.execute_query(query)
            
            if not results:
                return {"error": "Ghost not found", "ghost_id": ghost_id}
            
            return {
                "uri": f"ghost://ghosts/{ghost_id}",
                "mimeType": "application/json",
                "content": results[0]
            }
        else:
            # List all ghosts with summary
            query = """
                SELECT g.GHOST_ID, g.NAME, g.CLASSIFICATION, g.THREAT_LEVEL,
                       g.FIRST_SEEN, g.LAST_UPDATED,
                       COUNT(s.SIGHTING_ID) as sighting_count
                FROM GHOST_DETECTION.APP.GHOSTS g
                LEFT JOIN GHOST_DETECTION.APP.SIGHTINGS s ON g.GHOST_ID = s.GHOST_ID
                GROUP BY g.GHOST_ID, g.NAME, g.CLASSIFICATION, g.THREAT_LEVEL,
                         g.FIRST_SEEN, g.LAST_UPDATED
                ORDER BY sighting_count DESC
                LIMIT 100
            """
            results = self.client.execute_query(query)
            
            return {
                "uri": "ghost://ghosts",
                "mimeType": "application/json",
                "content": {
                    "count": len(results),
                    "ghosts": results
                }
            }
    
    async def _read_sightings(self, sighting_id: Optional[str], extra_parts: list) -> dict:
        """Read sighting resources."""
        if sighting_id:
            query = f"""
                SELECT s.*, g.NAME as ghost_name, g.CLASSIFICATION
                FROM GHOST_DETECTION.APP.SIGHTINGS s
                LEFT JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
                WHERE s.SIGHTING_ID = '{sighting_id}'
            """
            results = self.client.execute_query(query)
            
            if not results:
                return {"error": "Sighting not found", "sighting_id": sighting_id}
            
            # Get related evidence
            evidence_query = f"""
                SELECT * FROM GHOST_DETECTION.APP.EVIDENCE
                WHERE SIGHTING_ID = '{sighting_id}'
            """
            evidence = self.client.execute_query(evidence_query)
            
            return {
                "uri": f"ghost://sightings/{sighting_id}",
                "mimeType": "application/json",
                "content": {
                    "sighting": results[0],
                    "evidence": evidence
                }
            }
        else:
            query = """
                SELECT s.SIGHTING_ID, s.SIGHTING_DATE, s.LOCATION,
                       s.DESCRIPTION, s.WITNESS_COUNT,
                       g.NAME as ghost_name, g.CLASSIFICATION
                FROM GHOST_DETECTION.APP.SIGHTINGS s
                LEFT JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
                ORDER BY s.SIGHTING_DATE DESC
                LIMIT 100
            """
            results = self.client.execute_query(query)
            
            return {
                "uri": "ghost://sightings",
                "mimeType": "application/json",
                "content": {
                    "count": len(results),
                    "sightings": results
                }
            }
    
    async def _read_evidence(self, evidence_id: Optional[str], extra_parts: list) -> dict:
        """Read evidence resources."""
        if evidence_id:
            query = f"""
                SELECT e.*, s.LOCATION as sighting_location, s.SIGHTING_DATE
                FROM GHOST_DETECTION.APP.EVIDENCE e
                LEFT JOIN GHOST_DETECTION.APP.SIGHTINGS s ON e.SIGHTING_ID = s.SIGHTING_ID
                WHERE e.EVIDENCE_ID = '{evidence_id}'
            """
            results = self.client.execute_query(query)
            
            if not results:
                return {"error": "Evidence not found", "evidence_id": evidence_id}
            
            return {
                "uri": f"ghost://evidence/{evidence_id}",
                "mimeType": "application/json",
                "content": results[0]
            }
        else:
            query = """
                SELECT e.EVIDENCE_ID, e.EVIDENCE_TYPE, e.COLLECTED_DATE,
                       e.DESCRIPTION, e.CREDIBILITY_SCORE,
                       s.SIGHTING_ID, s.LOCATION
                FROM GHOST_DETECTION.APP.EVIDENCE e
                LEFT JOIN GHOST_DETECTION.APP.SIGHTINGS s ON e.SIGHTING_ID = s.SIGHTING_ID
                ORDER BY e.COLLECTED_DATE DESC
                LIMIT 100
            """
            results = self.client.execute_query(query)
            
            return {
                "uri": "ghost://evidence",
                "mimeType": "application/json",
                "content": {
                    "count": len(results),
                    "evidence": results
                }
            }
    
    async def _read_investigations(self, investigation_id: Optional[str], extra_parts: list) -> dict:
        """Read investigation resources."""
        if investigation_id:
            query = f"""
                SELECT i.*,
                       COUNT(e.EVIDENCE_ID) as evidence_count
                FROM GHOST_DETECTION.APP.INVESTIGATIONS i
                LEFT JOIN GHOST_DETECTION.APP.EVIDENCE e ON i.INVESTIGATION_ID = e.INVESTIGATION_ID
                WHERE i.INVESTIGATION_ID = '{investigation_id}'
                GROUP BY i.INVESTIGATION_ID
            """
            results = self.client.execute_query(query)
            
            if not results:
                return {"error": "Investigation not found", "investigation_id": investigation_id}
            
            # Get team members if available
            team_query = f"""
                SELECT * FROM GHOST_DETECTION.APP.INVESTIGATION_TEAM
                WHERE INVESTIGATION_ID = '{investigation_id}'
            """
            try:
                team = self.client.execute_query(team_query)
            except:
                team = []
            
            return {
                "uri": f"ghost://investigations/{investigation_id}",
                "mimeType": "application/json",
                "content": {
                    "investigation": results[0],
                    "team": team
                }
            }
        else:
            query = """
                SELECT i.INVESTIGATION_ID, i.TITLE, i.STATUS,
                       i.START_DATE, i.LOCATION, i.LEAD_INVESTIGATOR,
                       COUNT(e.EVIDENCE_ID) as evidence_count
                FROM GHOST_DETECTION.APP.INVESTIGATIONS i
                LEFT JOIN GHOST_DETECTION.APP.EVIDENCE e ON i.INVESTIGATION_ID = e.INVESTIGATION_ID
                GROUP BY i.INVESTIGATION_ID, i.TITLE, i.STATUS,
                         i.START_DATE, i.LOCATION, i.LEAD_INVESTIGATOR
                ORDER BY i.START_DATE DESC
                LIMIT 100
            """
            results = self.client.execute_query(query)
            
            return {
                "uri": "ghost://investigations",
                "mimeType": "application/json",
                "content": {
                    "count": len(results),
                    "investigations": results
                }
            }
    
    async def _read_analytics(self, analytics_type: Optional[str], extra_parts: list) -> dict:
        """Read analytics resources."""
        if analytics_type == "summary":
            query = """
                SELECT 
                    (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOSTS) as total_ghosts,
                    (SELECT COUNT(*) FROM GHOST_DETECTION.APP.SIGHTINGS) as total_sightings,
                    (SELECT COUNT(*) FROM GHOST_DETECTION.APP.EVIDENCE) as total_evidence,
                    (SELECT COUNT(*) FROM GHOST_DETECTION.APP.INVESTIGATIONS) as total_investigations,
                    (SELECT COUNT(*) FROM GHOST_DETECTION.APP.INVESTIGATIONS WHERE STATUS = 'active') as active_investigations
            """
            results = self.client.execute_query(query)
            
            return {
                "uri": "ghost://analytics/summary",
                "mimeType": "application/json",
                "content": {
                    "generated_at": datetime.utcnow().isoformat(),
                    "summary": results[0] if results else {}
                }
            }
        
        elif analytics_type == "trends":
            query = """
                SELECT 
                    DATE_TRUNC('month', SIGHTING_DATE) as month,
                    COUNT(*) as sighting_count,
                    COUNT(DISTINCT GHOST_ID) as unique_ghosts,
                    COUNT(DISTINCT LOCATION) as unique_locations
                FROM GHOST_DETECTION.APP.SIGHTINGS
                WHERE SIGHTING_DATE >= DATEADD(year, -1, CURRENT_DATE())
                GROUP BY DATE_TRUNC('month', SIGHTING_DATE)
                ORDER BY month DESC
            """
            results = self.client.execute_query(query)
            
            return {
                "uri": "ghost://analytics/trends",
                "mimeType": "application/json",
                "content": {
                    "generated_at": datetime.utcnow().isoformat(),
                    "period": "12_months",
                    "trends": results
                }
            }
        
        elif analytics_type == "hotspots":
            query = """
                SELECT 
                    LOCATION,
                    COUNT(*) as sighting_count,
                    COUNT(DISTINCT GHOST_ID) as unique_ghosts,
                    MAX(SIGHTING_DATE) as last_sighting,
                    AVG(THREAT_LEVEL_NUMERIC) as avg_threat_level
                FROM GHOST_DETECTION.APP.SIGHTINGS
                GROUP BY LOCATION
                HAVING COUNT(*) >= 3
                ORDER BY sighting_count DESC
                LIMIT 20
            """
            results = self.client.execute_query(query)
            
            return {
                "uri": "ghost://analytics/hotspots",
                "mimeType": "application/json",
                "content": {
                    "generated_at": datetime.utcnow().isoformat(),
                    "hotspots": results
                }
            }
        
        else:
            return {"error": f"Unknown analytics type: {analytics_type}"}
    
    async def _read_vocabulary(self, term_id: Optional[str], extra_parts: list) -> dict:
        """Read vocabulary resources."""
        if term_id:
            query = f"""
                SELECT * FROM GHOST_DETECTION.APP.VOCABULARY
                WHERE TERM_ID = '{term_id}' OR TERM ILIKE '{term_id}'
            """
            results = self.client.execute_query(query)
            
            if not results:
                return {"error": "Term not found", "term": term_id}
            
            return {
                "uri": f"ghost://vocabulary/{term_id}",
                "mimeType": "application/json",
                "content": results[0]
            }
        else:
            query = """
                SELECT TERM_ID, TERM, CATEGORY, 
                       SUBSTRING(DEFINITION, 1, 100) as definition_preview
                FROM GHOST_DETECTION.APP.VOCABULARY
                ORDER BY CATEGORY, TERM
            """
            results = self.client.execute_query(query)
            
            # Group by category
            by_category = {}
            for term in results:
                cat = term.get("CATEGORY", "Other")
                if cat not in by_category:
                    by_category[cat] = []
                by_category[cat].append(term)
            
            return {
                "uri": "ghost://vocabulary",
                "mimeType": "application/json",
                "content": {
                    "total_terms": len(results),
                    "categories": list(by_category.keys()),
                    "terms_by_category": by_category
                }
            }
    
    async def list_resources(self) -> list[dict]:
        """List all available resources."""
        return RESOURCE_DEFINITIONS
    
    async def list_resource_templates(self) -> list[dict]:
        """List all resource templates."""
        return RESOURCE_TEMPLATES


# Singleton resource handler
_resource_handler: Optional[ResourceHandler] = None


def get_resource_handler() -> ResourceHandler:
    """Get the singleton resource handler instance."""
    global _resource_handler
    if _resource_handler is None:
        _resource_handler = ResourceHandler()
    return _resource_handler
