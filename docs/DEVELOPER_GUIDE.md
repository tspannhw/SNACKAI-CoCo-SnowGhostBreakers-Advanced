# SnowGhost Breakers - Developer Guide

## Overview

This guide covers the technical details for developers working on SnowGhost Breakers. It includes setup instructions, architecture details, coding standards, and contribution guidelines.

## Development Environment Setup

### Prerequisites

- **Node.js** 18+ (for React frontend)
- **Python** 3.11+ (for MCP server)
- **Docker** (for containerization)
- **Snowflake Account** with Cortex AI enabled
- **Git**

### Clone Repository

```bash
git clone https://github.com/yourorg/snowghostbreakers-advanced.git
cd snowghostbreakers-advanced
```

### Frontend Setup

```bash
cd react-app
npm install
cp .env.example .env.local
# Edit .env.local with your settings
npm run dev
```

### MCP Server Setup (Local)

```bash
cd snowflake/mcp_server
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
cp .env.example .env
# Edit .env with Snowflake credentials
uvicorn src.main:app --reload
```

### Snowflake Setup

```sql
-- Run setup scripts in order
!source snowflake/sql/01_setup/01_database_setup.sql
-- ... continue with other scripts
```

---

## Project Structure

```
snowghostbreakers-advanced/
├── react-app/                    # Frontend application
│   ├── src/
│   │   ├── components/           # Reusable UI components
│   │   │   ├── ui/               # Base UI primitives
│   │   │   ├── ghost/            # Ghost-related components
│   │   │   ├── charts/           # Visualization components
│   │   │   └── layout/           # Layout components
│   │   ├── pages/                # Route pages
│   │   ├── hooks/                # Custom React hooks
│   │   ├── services/             # API services
│   │   ├── store/                # Zustand stores
│   │   ├── types/                # TypeScript definitions
│   │   └── lib/                  # Utilities
│   └── tests/                    # Frontend tests
│
├── snowflake/
│   ├── sql/                      # SQL scripts (numbered order)
│   ├── mcp_server/               # MCP server code
│   │   ├── src/
│   │   │   ├── main.py           # FastAPI application
│   │   │   ├── tools.py          # MCP tool implementations
│   │   │   ├── resources.py      # MCP resource handlers
│   │   │   └── snowflake_client.py
│   │   ├── Dockerfile
│   │   └── spec.yaml             # SPCS spec
│   └── streamlit/                # Optional Streamlit app
│
├── tests/
│   ├── sql/                      # SQL validation tests
│   ├── integration/              # API integration tests
│   └── e2e/                      # End-to-end tests
│
└── docs/                         # Documentation
```

---

## Frontend Development

### Component Architecture

We use a layered component architecture:

```
Pages (routes)
    ↓
Features (domain-specific)
    ↓
Components (reusable)
    ↓
UI Primitives (shadcn/ui)
```

### Creating Components

```tsx
// src/components/ghost/GhostCard.tsx
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Ghost } from '@/types/ghost';
import { cn } from '@/lib/utils';

interface GhostCardProps {
  ghost: Ghost;
  onClick?: () => void;
  className?: string;
}

export function GhostCard({ ghost, onClick, className }: GhostCardProps) {
  const threatColors = {
    Low: 'bg-threat-low',
    Medium: 'bg-threat-medium',
    High: 'bg-threat-high',
    Extreme: 'bg-threat-extreme',
  };

  return (
    <Card 
      className={cn('cursor-pointer hover:shadow-lg transition-shadow', className)}
      onClick={onClick}
    >
      <CardHeader>
        <div className="flex justify-between items-center">
          <h3 className="font-semibold">{ghost.ghost_name}</h3>
          <Badge className={threatColors[ghost.threat_level]}>
            {ghost.threat_level}
          </Badge>
        </div>
      </CardHeader>
      <CardContent>
        <p className="text-sm text-muted-foreground">{ghost.ghost_type}</p>
        <p className="text-xs mt-2">{ghost.description?.slice(0, 100)}...</p>
      </CardContent>
    </Card>
  );
}
```

### State Management

We use Zustand for global state:

```tsx
// src/store/ghostStore.ts
import { create } from 'zustand';
import { Ghost } from '@/types/ghost';

interface GhostStore {
  selectedGhost: Ghost | null;
  filters: {
    threatLevel?: string;
    ghostType?: string;
    status?: string;
  };
  setSelectedGhost: (ghost: Ghost | null) => void;
  setFilters: (filters: Partial<GhostStore['filters']>) => void;
  clearFilters: () => void;
}

export const useGhostStore = create<GhostStore>((set) => ({
  selectedGhost: null,
  filters: {},
  setSelectedGhost: (ghost) => set({ selectedGhost: ghost }),
  setFilters: (filters) => set((state) => ({ 
    filters: { ...state.filters, ...filters } 
  })),
  clearFilters: () => set({ filters: {} }),
}));
```

### Data Fetching

Use TanStack Query for server state:

```tsx
// src/hooks/useGhosts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ghostService } from '@/services/ghostService';

export function useGhosts(filters?: GhostFilters) {
  return useQuery({
    queryKey: ['ghosts', filters],
    queryFn: () => ghostService.getGhosts(filters),
    staleTime: 30_000, // 30 seconds
  });
}

export function useGhost(ghostId: string) {
  return useQuery({
    queryKey: ['ghost', ghostId],
    queryFn: () => ghostService.getGhost(ghostId),
    enabled: !!ghostId,
  });
}

export function useCreateSighting() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ghostService.createSighting,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['sightings'] });
    },
  });
}
```

### API Service Layer

```tsx
// src/services/ghostService.ts
import { api } from '@/lib/api';
import { Ghost, Sighting, GhostFilters } from '@/types';

export const ghostService = {
  async getGhosts(filters?: GhostFilters) {
    const params = new URLSearchParams();
    if (filters?.threatLevel) params.set('threat_level', filters.threatLevel);
    if (filters?.status) params.set('status', filters.status);
    
    const response = await api.get(`/api/ghosts?${params}`);
    return response.data as Ghost[];
  },

  async getGhost(id: string) {
    const response = await api.get(`/api/ghosts/${id}`);
    return response.data as Ghost;
  },

  async createSighting(data: CreateSightingInput) {
    const response = await api.post('/api/sightings', data);
    return response.data;
  },

  async generateReport(ghostId: string) {
    const response = await api.post('/api/ai/report', { ghost_id: ghostId });
    return response.data;
  },
};
```

---

## Backend Development

### MCP Server Architecture

```
FastAPI App
    ├── /health          → Health check
    ├── /mcp             → MCP JSON-RPC endpoint
    │   ├── initialize
    │   ├── tools/list
    │   ├── tools/call
    │   ├── resources/list
    │   └── resources/read
    └── /api/*           → REST endpoints
```

### Adding a New MCP Tool

1. Define the tool in `tools.py`:

```python
# src/tools.py
from mcp.types import Tool

TOOLS = [
    # ... existing tools
    Tool(
        name="get_threat_trends",
        description="Analyze threat level trends over time",
        inputSchema={
            "type": "object",
            "properties": {
                "days": {
                    "type": "integer",
                    "description": "Number of days to analyze",
                    "default": 30
                },
                "ghost_type": {
                    "type": "string",
                    "description": "Optional filter by ghost type"
                }
            }
        }
    )
]
```

2. Implement the handler:

```python
# src/tools.py
async def handle_get_threat_trends(
    arguments: dict,
    session: Session
) -> list[TextContent]:
    days = arguments.get("days", 30)
    ghost_type = arguments.get("ghost_type")
    
    query = f"""
        SELECT 
            DATE_TRUNC('day', created_at) as date,
            threat_level,
            COUNT(*) as count
        FROM APP.GHOSTS
        WHERE created_at >= DATEADD(day, -{days}, CURRENT_DATE())
        {"AND ghost_type = '" + ghost_type + "'" if ghost_type else ""}
        GROUP BY date, threat_level
        ORDER BY date
    """
    
    result = session.sql(query).to_pandas()
    return [TextContent(
        type="text",
        text=result.to_json(orient="records")
    )]
```

3. Register in the tool dispatcher:

```python
# src/main.py
TOOL_HANDLERS = {
    "query_ghosts": handle_query_ghosts,
    "get_threat_trends": handle_get_threat_trends,
    # ...
}
```

### Adding a New REST Endpoint

```python
# src/main.py
from fastapi import APIRouter, Query
from typing import Optional

api_router = APIRouter(prefix="/api")

@api_router.get("/threat-trends")
async def get_threat_trends(
    days: int = Query(30, ge=1, le=365),
    ghost_type: Optional[str] = None
):
    """Get threat level trends over time."""
    session = get_session()
    
    try:
        result = await handle_get_threat_trends(
            {"days": days, "ghost_type": ghost_type},
            session
        )
        return {"data": json.loads(result[0].text)}
    except Exception as e:
        raise HTTPException(500, str(e))
```

### Snowflake Client Best Practices

```python
# src/snowflake_client.py
from contextlib import contextmanager
from snowflake.snowpark import Session
import threading

class SessionPool:
    """Thread-safe session pool for Snowflake connections."""
    
    def __init__(self, config: dict, pool_size: int = 5):
        self.config = config
        self.pool_size = pool_size
        self._pool: list[Session] = []
        self._lock = threading.Lock()
    
    def get_session(self) -> Session:
        with self._lock:
            if self._pool:
                return self._pool.pop()
        return Session.builder.configs(self.config).create()
    
    def return_session(self, session: Session):
        with self._lock:
            if len(self._pool) < self.pool_size:
                self._pool.append(session)
            else:
                session.close()
    
    @contextmanager
    def session(self):
        session = self.get_session()
        try:
            yield session
        finally:
            self.return_session(session)
```

---

## SQL Development

### Naming Conventions

- **Tables**: `UPPERCASE_SNAKE_CASE` (e.g., `GHOST_SIGHTINGS`)
- **Columns**: `lowercase_snake_case` (e.g., `ghost_id`)
- **Procedures**: `UPPERCASE_SNAKE_CASE` (e.g., `REGISTER_GHOST`)
- **Views**: `VW_` prefix (e.g., `VW_GHOST_ACTIVITY`)

### Stored Procedure Template

```sql
CREATE OR REPLACE PROCEDURE MY_PROCEDURE(
    P_PARAM1 VARCHAR,
    P_PARAM2 INT DEFAULT 10
)
RETURNS VARIANT
LANGUAGE SQL
COMMENT = 'Description of what this procedure does'
AS
DECLARE
    v_result VARIANT;
BEGIN
    -- Implementation
    
    RETURN OBJECT_CONSTRUCT(
        'success', TRUE,
        'data', :v_result
    );
EXCEPTION
    WHEN OTHER THEN
        RETURN OBJECT_CONSTRUCT(
            'success', FALSE,
            'error', SQLERRM
        );
END;
```

### Using Cortex AI in SQL

```sql
-- Sentiment analysis
SELECT 
    sighting_id,
    description,
    SNOWFLAKE.CORTEX.SENTIMENT(description) as fear_level
FROM GHOST_SIGHTINGS;

-- LLM completion
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    'Analyze this ghost description: ' || description
) as analysis
FROM GHOSTS
WHERE ghost_id = 'GH001';

-- Vector embedding
SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_1024(
    'voyage-multilingual-2',
    description
) as embedding
FROM GHOST_SIGHTINGS;

-- Similarity search
SELECT 
    a.sighting_id,
    VECTOR_COSINE_SIMILARITY(a.embedding, b.embedding) as similarity
FROM SIGHTING_EMBEDDINGS a
CROSS JOIN SIGHTING_EMBEDDINGS b
WHERE a.sighting_id != b.sighting_id
ORDER BY similarity DESC
LIMIT 10;
```

---

## Testing

### SQL Tests

Run SQL validation tests:

```sql
-- Run all tests
CALL RUN_ALL_TESTS();

-- Run specific test
CALL TEST_SCHEMA_EXISTS();
```

### Integration Tests

```bash
cd tests/integration
pytest test_mcp_integration.py -v
```

### Frontend Tests

```bash
cd react-app
npm run test           # Run tests
npm run test:coverage  # With coverage
npm run test:ui        # Interactive UI
```

### E2E Tests

```bash
cd tests/e2e
npx playwright test
```

### Writing Tests

**Frontend (Vitest):**
```tsx
// src/components/__tests__/GhostCard.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { GhostCard } from '../GhostCard';

const mockGhost = {
  ghost_id: 'GH001',
  ghost_name: 'Test Ghost',
  ghost_type: 'Apparition',
  threat_level: 'Medium',
};

describe('GhostCard', () => {
  it('renders ghost name', () => {
    render(<GhostCard ghost={mockGhost} />);
    expect(screen.getByText('Test Ghost')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<GhostCard ghost={mockGhost} onClick={handleClick} />);
    fireEvent.click(screen.getByRole('article'));
    expect(handleClick).toHaveBeenCalled();
  });
});
```

**Integration (Pytest):**
```python
# tests/integration/test_ghost_api.py
import pytest

class TestGhostAPI:
    def test_get_ghosts(self, client):
        response = client.get("/api/ghosts")
        assert response.status_code == 200
        assert "data" in response.json()
```

---

## Deployment

### Building for Production

**Frontend:**
```bash
cd react-app
npm run build
```

**MCP Server:**
```bash
cd snowflake/mcp_server
docker build -t ghost-mcp-server:latest .
```

### Deploying to SPCS

```bash
# Tag and push image
docker tag ghost-mcp-server:latest \
    <account>.registry.snowflakecomputing.com/ghost_detection/app/images/ghost_mcp_server:latest

docker push <account>.registry.snowflakecomputing.com/ghost_detection/app/images/ghost_mcp_server:latest

# Deploy via SQL
snowsql -f snowflake/mcp_server/deploy.sql
```

---

## Contributing

### Git Workflow

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes
3. Run tests: `npm test && pytest`
4. Commit: `git commit -m "feat: add new feature"`
5. Push: `git push origin feature/my-feature`
6. Create Pull Request

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No sensitive data exposed
- [ ] SQL injection prevented
- [ ] Error handling in place
