# SnowGhostBreakers — Paranormal Data Upload App

Ghost sighting data management application for the **GHOST_DETECTION.APP** Snowflake schema. Built for the [Neo4j NODES AI conference demo](https://neo4j.com/nodes-ai/agenda/ghost-busting-with-neo4j-graph-analytics-in-snowflake/).


<img width="2247" height="1587" alt="image" src="https://github.com/user-attachments/assets/4d639326-13cf-4c48-b7df-98cb6cbc8875" />

<img width="2247" height="1584" alt="image" src="https://github.com/user-attachments/assets/a426cd62-815d-4a60-af06-734b87e8fe67" />


## Stack

- **Next.js 14** (App Router) + React 18 + TypeScript
- **TailwindCSS** with dark paranormal theme (Creepster font, ghost-green/purple)
- **Framer Motion** animations, **MapLibre GL** interactive map
- **Snowflake** via snowflake-sdk (key-pair auth)


<img width="2183" height="1822" alt="image" src="https://github.com/user-attachments/assets/1552f6c9-2bef-4ef6-9c9a-5d4a1acd6cb9" />


## Features

| Page | Description |
|------|-------------|
| `/` | Dashboard — live stats, recent sightings, entity breakdown |
| `/upload` | 4-step wizard form to report ghost sightings |
| `/sightings` | Interactive map with 1000 sightings, filters by type/threat |


<img width="2248" height="1829" alt="image" src="https://github.com/user-attachments/assets/5eedf92d-ea93-4133-99b8-43fbe504439c" />


## Quick Start

```bash
# 1. Setup
cp env.example .env
# Edit .env with your Snowflake credentials (key-pair auth)

# 2. Install & build
./manage.sh setup

# 3. Run
./manage.sh start
# Visit http://localhost:3000
```

## Management Script

```bash
./manage.sh install     # Install npm dependencies
./manage.sh setup       # Full setup: install, validate env, build
./manage.sh start       # Start dev server (background)
./manage.sh stop        # Stop server
./manage.sh restart     # Restart server
./manage.sh status      # Check if server is running
./manage.sh build       # Production build
./manage.sh logs        # Tail server logs
./manage.sh test        # Run tests
./manage.sh validate    # Validate .env configuration
./manage.sh clean       # Remove node_modules, .next, logs
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SNOWFLAKE_ACCOUNT` | Snowflake account identifier |
| `SNOWFLAKE_USER` | Snowflake username |
| `SNOWFLAKE_PRIVATE_KEY_PATH` | Path to RSA private key (.p8) |
| `SNOWFLAKE_PRIVATE_KEY_PASSPHRASE` | Key passphrase (if encrypted) |
| `SNOWFLAKE_DATABASE` | Database name (`GHOST_DETECTION`) |
| `SNOWFLAKE_SCHEMA` | Schema name (`APP`) |
| `SNOWFLAKE_WAREHOUSE` | Warehouse name |
| `SNOWFLAKE_ROLE` | Role (`ACCOUNTADMIN`) |

## Test Data

10,047 sightings across Oct 2025 – Mar 2026, covering NY, NJ, and New England:

| Entity Type | Count | Notes |
|------------|-------|-------|
| Ghoul | 3,421 | Concentrated around Princeton, NJ |
| Leprechaun | 1,438 | Clustered around St. Patrick's Day |
| Apparition | 1,447 | Spread across all regions |
| Evil Rabbit | 1,201 | Clustered around Easter |
| Poltergeist | 996 | NYC, NJ, Boston |
| Shadow Entity | 890 | NYC, Boston, NJ |
| Orb | 556 | Rural NE, Hudson Valley |

Regenerate test data: `SNOWFLAKE_CONNECTION_NAME=tspann1 python3 scripts/generate_ghost_data_fast.py`

## Snowflake Tables

- **GHOSTS** — 74 registered paranormal entities
- **GHOST_SIGHTINGS** — 10,047 sighting records with GEOGRAPHY coordinates

## API Routes

- `GET /api/stats` — Dashboard statistics
- `GET /api/sightings?type=&threat=&limit=` — Sightings data with filters
- `POST /api/upload` — Submit new ghost sighting
