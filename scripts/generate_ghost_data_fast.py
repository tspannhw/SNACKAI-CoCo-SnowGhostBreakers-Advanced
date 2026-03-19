"""
SnowGhostBreakers FAST Bulk Data Generator
Uses write_pandas for fast bulk loading, then updates GEOGRAPHY column via SQL.
"""

import os
import random
import uuid
import pandas as pd
from datetime import datetime, timedelta
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

CONN_NAME = os.getenv("SNOWFLAKE_CONNECTION_NAME") or "tspann1"

START_DATE = datetime(2025, 10, 1)
END_DATE = datetime(2026, 3, 31)
REMAINING_SIGHTINGS = 9000

ST_PATRICKS = datetime(2026, 3, 17)
EASTER = datetime(2026, 4, 5)

LOCATIONS = {
    "nyc": [
        ("Times Square", "Times Square, Manhattan, NY", 40.7580, -73.9855),
        ("Central Park", "Central Park, Manhattan, NY", 40.7829, -73.9654),
        ("Brooklyn Bridge", "Brooklyn Bridge, Brooklyn, NY", 40.7061, -73.9969),
        ("Grand Central Terminal", "89 E 42nd St, Manhattan, NY", 40.7527, -73.9772),
        ("Empire State Building", "350 5th Ave, Manhattan, NY", 40.7484, -73.9857),
        ("Coney Island", "Coney Island, Brooklyn, NY", 40.5749, -73.9706),
        ("Staten Island Ferry", "4 Whitehall St, Manhattan, NY", 40.7013, -74.0132),
        ("Bronx Zoo Area", "2300 Southern Blvd, Bronx, NY", 40.8506, -73.8769),
        ("Flushing Meadows", "Flushing Meadows, Queens, NY", 40.7400, -73.8408),
        ("NYC Subway 42nd St", "42nd St Station, Manhattan, NY", 40.7558, -73.9870),
        ("Wall Street", "Wall Street, Manhattan, NY", 40.7074, -74.0113),
        ("Harlem", "125th St, Harlem, NY", 40.8075, -73.9465),
    ],
    "sleepy_hollow": [
        ("Sleepy Hollow Cemetery", "540 N Broadway, Sleepy Hollow, NY", 41.0870, -73.8621),
        ("Old Dutch Church", "430 N Broadway, Sleepy Hollow, NY", 41.0854, -73.8585),
        ("Philipsburg Manor", "381 N Broadway, Sleepy Hollow, NY", 41.0827, -73.8561),
        ("Headless Horseman Bridge", "Sleepy Hollow, NY", 41.0892, -73.8638),
    ],
    "hudson_valley": [
        ("Bear Mountain", "Bear Mountain State Park, NY", 41.3126, -73.9893),
        ("West Point", "West Point, NY", 41.3915, -73.9560),
        ("Cold Spring", "Cold Spring, NY", 41.4200, -73.9548),
    ],
    "nj_princeton": [
        ("Nassau Hall", "1 Nassau Hall, Princeton, NJ", 40.3487, -74.6593),
        ("Princeton Cemetery", "29 Greenview Ave, Princeton, NJ", 40.3478, -74.6628),
        ("Palmer Square", "Palmer Square, Princeton, NJ", 40.3502, -74.6596),
        ("Einstein House", "112 Mercer St, Princeton, NJ", 40.3485, -74.6551),
        ("Inst for Advanced Study", "1 Einstein Dr, Princeton, NJ", 40.3291, -74.6696),
        ("Princeton Battlefield", "500 Mercer Rd, Princeton, NJ", 40.3291, -74.6757),
        ("Carnegie Lake", "Princeton, NJ", 40.3410, -74.6389),
        ("Prospect Garden", "Princeton University, NJ", 40.3461, -74.6565),
        ("McCarter Theatre", "91 University Pl, Princeton, NJ", 40.3482, -74.6594),
        ("Princeton Junction", "Alexander Rd, Princeton Jct, NJ", 40.3173, -74.6240),
    ],
    "nj_other": [
        ("Liberty State Park", "200 Morris Pesin Dr, Jersey City, NJ", 40.7095, -74.0554),
        ("Hoboken Waterfront", "1 Sinatra Dr, Hoboken, NJ", 40.7440, -74.0324),
        ("Newark Penn Station", "Raymond Blvd, Newark, NJ", 40.7345, -74.1642),
        ("Trenton State House", "125 W State St, Trenton, NJ", 40.2206, -74.7700),
        ("Cape May Lighthouse", "215 Light House Ave, Cape May, NJ", 38.9332, -74.9604),
        ("Asbury Park", "Ocean Ave, Asbury Park, NJ", 40.2201, -74.0001),
    ],
    "boston": [
        ("Boston Common", "139 Tremont St, Boston, MA", 42.3554, -71.0655),
        ("Faneuil Hall", "4 S Market St, Boston, MA", 42.3601, -71.0561),
        ("Boston Harbor", "Boston Harbor, MA", 42.3521, -71.0404),
        ("MIT Campus", "77 Massachusetts Ave, Cambridge, MA", 42.3601, -71.0942),
        ("Harvard Yard", "Cambridge, MA", 42.3744, -71.1169),
        ("Fenway Park Area", "4 Jersey St, Boston, MA", 42.3467, -71.0972),
    ],
    "salem": [
        ("Salem Witch Museum", "19 N Washington Sq, Salem, MA", 42.5195, -70.8967),
        ("Witch House", "310 Essex St, Salem, MA", 42.5211, -70.8932),
        ("Charter St Cemetery", "45 Charter St, Salem, MA", 42.5222, -70.8930),
        ("Gallows Hill", "Gallows Hill, Salem, MA", 42.5278, -70.8970),
    ],
    "providence": [
        ("Benefit Street", "Benefit Street, Providence, RI", 41.8240, -71.4065),
        ("Roger Williams Park", "1000 Elmwood Ave, Providence, RI", 41.7911, -71.4134),
        ("WaterPlace Park", "Memorial Blvd, Providence, RI", 41.8280, -71.4128),
    ],
    "hartford": [
        ("Mark Twain House", "351 Farmington Ave, Hartford, CT", 41.7671, -72.7010),
        ("Bushnell Park", "1 Jewell St, Hartford, CT", 41.7635, -72.6823),
        ("Old State House", "800 Main St, Hartford, CT", 41.7678, -72.6734),
    ],
    "new_haven": [
        ("Yale Old Campus", "College St, New Haven, CT", 41.3083, -72.9279),
        ("Grove St Cemetery", "227 Grove St, New Haven, CT", 41.3138, -72.9287),
        ("East Rock Park", "41 Cold Spring St, New Haven, CT", 41.3278, -72.9012),
    ],
    "rural_ne": [
        ("Burlington Waterfront", "College St, Burlington, VT", 44.4759, -73.2211),
        ("Stowe Village", "Stowe, VT", 44.4654, -72.6874),
        ("Portland Head Light", "12 Captain Strout Cir, Cape Elizabeth, ME", 43.6231, -70.2078),
        ("Acadia National Park", "Bar Harbor, ME", 44.3386, -68.2733),
        ("White Mountain NF", "Lincoln, NH", 44.0740, -71.6892),
        ("Franconia Notch", "Franconia Notch, NH", 44.1366, -71.6811),
        ("Nantucket", "Nantucket, MA", 41.2835, -70.0995),
        ("Marthas Vineyard", "Marthas Vineyard, MA", 41.3805, -70.6456),
    ],
}

GHOST_TYPES_CONFIG = {
    "Leprechaun": {
        "threat_levels": ["Low", "Low", "Low", "Medium"],
        "descriptions": [
            "Small green entity spotted leaving gold coins near {}",
            "Tiny bearded figure in green clothing dancing a jig at {}",
            "Mischievous entity hiding gold objects around {}",
            "Green luminous figure at {}, witnesses report Irish fiddle music",
            "Impish creature ~2 feet tall observed near {}, causing minor pranks",
        ],
        "conditions": ["Green mist observed", "Temperature drop with faint Irish music", "Gold dust residue", "Rainbow-like light refraction", "Shamrock scent detected"],
    },
    "Evil Rabbit": {
        "threat_levels": ["Medium", "Medium", "High", "High"],
        "descriptions": [
            "Oversized rabbit with glowing red eyes spotted at {}",
            "Aggressive rabbit-like entity with sharp teeth observed near {}",
            "Giant rabbit shadow seen at {}, causing livestock panic",
            "Demonic rabbit creature at {}, left claw marks on trees",
            "Large lagomorph entity with unnatural proportions seen at {}",
        ],
        "conditions": ["Scratching sounds heard", "Fur tufts found on-site", "Carrot-shaped EMF anomalies", "Claw marks on surfaces", "Animal distress in area"],
    },
    "Ghoul": {
        "threat_levels": ["High", "High", "Extreme", "Extreme"],
        "descriptions": [
            "Hunched pale figure with elongated limbs spotted near {}",
            "Corpse-like entity digging near {} under moonlight",
            "Ghoulish creature with sunken eyes observed feeding near {}",
            "Shambling gray figure emerging from shadows at {}",
            "Tall gaunt entity with inhuman gait seen near {}",
            "Pack of ghouls at {}, moving in coordinated formation",
        ],
        "conditions": ["Grave soil disturbance", "Decomposition smell", "Temperature drop of 15C", "Scratching from underground", "All electronics failed", "Witnesses frozen in fear"],
    },
    "Apparition": {
        "threat_levels": ["Low", "Low", "Low", "Medium"],
        "descriptions": [
            "Translucent humanoid figure observed at {}",
            "Victorian-era woman in white drifting through {}",
            "Colonial-era gentleman walking through walls at {}",
            "Faint glowing figure at {}, vanished when approached",
        ],
        "conditions": ["Cold spot near location", "Faint whispers heard", "Translucent figure visible", "Old perfume scent detected", "Photo anomalies"],
    },
    "Poltergeist": {
        "threat_levels": ["Medium", "High", "High", "Extreme"],
        "descriptions": [
            "Invisible force throwing objects at {}",
            "Aggressive entity slamming doors and breaking windows at {}",
            "Furniture moving on its own at {}, witnesses terrified",
            "Violent paranormal disturbance at {}, multiple objects levitating",
        ],
        "conditions": ["Objects levitating", "Doors slamming", "Temperature fluctuations", "Electrical malfunctions", "Multiple objects levitating"],
    },
    "Shadow Entity": {
        "threat_levels": ["High", "High", "Extreme", "Medium"],
        "descriptions": [
            "Dark humanoid shadow at {}, caused electronic failures",
            "Pitch-black figure gliding through {} at night",
            "Shadow entity at {}, all lights dimmed",
            "Tall shadow figure with red eyes seen in {}",
        ],
        "conditions": ["All lights dimmed", "Electronics malfunctioned", "Extreme cold detected", "EMF readings maxed", "Witnesses reported paralysis"],
    },
    "Orb": {
        "threat_levels": ["Low", "Low", "Low", "Medium"],
        "descriptions": [
            "Group of luminous blue-white orbs floating at {}",
            "Single large glowing orb at {}, pulsating rhythmically",
            "Multiple small light orbs drifting through {}",
            "Bright sphere of light hovering at {}, disappeared rapidly",
        ],
        "conditions": ["Unusual light patterns", "Camera anomalies", "Mild EMF fluctuation", "Warm spot in cold environment", "Static electricity in air"],
    },
}

ENTITY_TYPE_LOCATIONS = {
    "Leprechaun": ["nyc", "boston", "hartford", "providence", "nj_other", "salem"],
    "Evil Rabbit": ["nyc", "nj_other", "nj_princeton", "new_haven", "hartford", "boston", "rural_ne"],
    "Ghoul": ["nj_princeton"],
    "Apparition": ["nyc", "sleepy_hollow", "hudson_valley", "boston", "salem", "providence", "hartford", "new_haven", "rural_ne", "nj_other"],
    "Poltergeist": ["nyc", "nj_other", "boston", "hartford", "providence"],
    "Shadow Entity": ["nyc", "boston", "nj_other"],
    "Orb": ["rural_ne", "hudson_valley", "sleepy_hollow"],
}

SIGHTING_DISTRIBUTION = {
    "Ghoul": 3100,
    "Leprechaun": 1300,
    "Evil Rabbit": 1100,
    "Apparition": 1300,
    "Poltergeist": 900,
    "Shadow Entity": 800,
    "Orb": 500,
}

EVIDENCE_TYPES = ["Visual", "EMF", "Temperature", "Audio", "Photograph", "Multiple"]


def random_date_weighted(entity_type):
    total_days = (END_DATE - START_DATE).days

    if entity_type == "Leprechaun":
        if random.random() < 0.55:
            offset = random.gauss(0, 3)
            d = ST_PATRICKS + timedelta(days=offset)
            if START_DATE <= d <= END_DATE:
                hour = random.choices(range(24), weights=[1]*6+[2]*4+[3]*2+[2]*2+[1]*2+[2]*2+[4]*4+[5]*2, k=1)[0]
                return d.replace(hour=hour, minute=random.randint(0,59), second=random.randint(0,59))
        if random.random() < 0.2:
            d = datetime(2026, 3, 1) + timedelta(days=random.randint(0, 30))
            if d <= END_DATE:
                hour = random.randint(0, 23)
                return d.replace(hour=hour, minute=random.randint(0,59), second=random.randint(0,59))

    elif entity_type == "Evil Rabbit":
        if random.random() < 0.55:
            offset = random.gauss(0, 4)
            d = EASTER + timedelta(days=offset)
            if d > END_DATE:
                d = END_DATE - timedelta(days=random.randint(0, 7))
            if START_DATE <= d <= END_DATE:
                hour = random.choices(range(24), weights=[1]*6+[2]*4+[3]*2+[2]*2+[1]*2+[2]*2+[4]*4+[5]*2, k=1)[0]
                return d.replace(hour=hour, minute=random.randint(0,59), second=random.randint(0,59))
        if random.random() < 0.2:
            d = datetime(2026, 3, 20) + timedelta(days=random.randint(0, 12))
            if d <= END_DATE:
                return d.replace(hour=random.randint(0,23), minute=random.randint(0,59), second=random.randint(0,59))

    elif entity_type == "Ghoul":
        if random.random() < 0.3:
            halloween = datetime(2025, 10, 31)
            d = halloween + timedelta(days=random.gauss(0, 5))
            if START_DATE <= d <= END_DATE:
                hour = random.choices(range(24), weights=[3]*2+[1]*4+[0]*6+[1]*4+[2]*2+[3]*2+[5]*4, k=1)[0]
                return d.replace(hour=hour, minute=random.randint(0,59), second=random.randint(0,59))

    d = START_DATE + timedelta(days=random.randint(0, total_days))
    hour = random.choices(range(24), weights=[1]*6+[2]*4+[3]*2+[2]*2+[1]*2+[2]*2+[4]*4+[5]*2, k=1)[0]
    return d.replace(hour=hour, minute=random.randint(0,59), second=random.randint(0,59))


def jitter(lat, lng, r=0.01):
    return round(lat + random.uniform(-r, r), 6), round(lng + random.uniform(-r, r), 6)


def main():
    print("Connecting to Snowflake...")
    conn = snowflake.connector.connect(connection_name=CONN_NAME)
    cur = conn.cursor()

    cur.execute("SELECT GHOST_ID, GHOST_TYPE FROM GHOST_DETECTION.APP.GHOSTS")
    ghosts_by_type = {}
    for row in cur.fetchall():
        gtype = row[1]
        if gtype not in ghosts_by_type:
            ghosts_by_type[gtype] = []
        ghosts_by_type[gtype].append(row[0])

    print(f"Found ghosts by type: { {k: len(v) for k, v in ghosts_by_type.items()} }")

    print(f"Generating {REMAINING_SIGHTINGS} sightings...")
    rows = []
    for entity_type, count in SIGHTING_DISTRIBUTION.items():
        available = ghosts_by_type.get(entity_type, [])
        if not available:
            print(f"  WARNING: No ghosts of type {entity_type}, skipping {count}")
            continue

        config = GHOST_TYPES_CONFIG[entity_type]
        locs = []
        for k in ENTITY_TYPE_LOCATIONS[entity_type]:
            locs.extend(LOCATIONS[k])

        for _ in range(count):
            ghost_id = random.choice(available)
            threat = random.choice(config["threat_levels"])
            loc = random.choice(locs)
            loc_name, loc_addr, lat0, lng0 = loc
            lat, lng = jitter(lat0, lng0)
            dt = random_date_weighted(entity_type)
            sid = f"SIGHT_{uuid.uuid4().hex[:8].upper()}"

            wnum = random.randint(1, 9999)
            desc = random.choice(config["descriptions"]).format(loc_name)
            cond = random.choice(config["conditions"])
            etype = random.choice(EVIDENCE_TYPES)

            month = dt.month
            if month in [12, 1, 2]:
                temp = random.uniform(-5, 5)
            elif month in [3, 4]:
                temp = random.uniform(2, 15)
            elif month in [10, 11]:
                temp = random.uniform(5, 18)
            else:
                temp = random.uniform(15, 30)
            if threat in ["High", "Extreme"]:
                temp -= random.uniform(5, 15)

            emf_ranges = {"Extreme": (30,50), "High": (15,35), "Medium": (5,20), "Low": (0.5,10)}
            emf = random.uniform(*emf_ranges[threat])

            act_ranges = {"Extreme": (7,10), "High": (5,9), "Medium": (3,7), "Low": (1,5)}
            activity = random.randint(*act_ranges[threat])

            rows.append({
                "SIGHTING_ID": sid,
                "GHOST_ID": ghost_id,
                "LOCATION_NAME": loc_name,
                "LOCATION_ADDRESS": loc_addr,
                "LATITUDE": lat,
                "LONGITUDE": lng,
                "SIGHTING_DATETIME": dt.strftime("%Y-%m-%d %H:%M:%S"),
                "WITNESS_NAME": f"Witness {wnum}",
                "WITNESS_CONTACT": f"witness{wnum}@ghostreport.com",
                "ENVIRONMENTAL_CONDITIONS": cond,
                "TEMPERATURE_CELSIUS": round(temp, 1),
                "EMF_READING": round(emf, 2),
                "DESCRIPTION": desc,
                "EVIDENCE_TYPE": etype,
                "PARANORMAL_ACTIVITY_LEVEL": activity,
                "INVESTIGATION_NOTES": f"Investigation report for {entity_type} sighting at {loc_name}. Threat: {threat}.",
                "VERIFIED": random.random() < 0.7,
            })

    random.shuffle(rows)
    print(f"Generated {len(rows)} rows. Creating DataFrame...")

    df = pd.DataFrame(rows)

    print("Creating staging table and bulk loading...")
    cur.execute("USE DATABASE GHOST_DETECTION")
    cur.execute("USE SCHEMA APP")

    cur.execute("""
        CREATE OR REPLACE TEMPORARY TABLE GHOST_DETECTION.APP.SIGHTINGS_STAGING (
            SIGHTING_ID VARCHAR(50),
            GHOST_ID VARCHAR(50),
            LOCATION_NAME VARCHAR(200),
            LOCATION_ADDRESS VARCHAR(16777216),
            LATITUDE FLOAT,
            LONGITUDE FLOAT,
            SIGHTING_DATETIME VARCHAR(30),
            WITNESS_NAME VARCHAR(200),
            WITNESS_CONTACT VARCHAR(200),
            ENVIRONMENTAL_CONDITIONS VARCHAR(16777216),
            TEMPERATURE_CELSIUS FLOAT,
            EMF_READING FLOAT,
            DESCRIPTION VARCHAR(16777216),
            EVIDENCE_TYPE VARCHAR(100),
            PARANORMAL_ACTIVITY_LEVEL NUMBER(38,0),
            INVESTIGATION_NOTES VARCHAR(16777216),
            VERIFIED BOOLEAN
        )
    """)

    success, nchunks, nrows, _ = write_pandas(
        conn, df, "SIGHTINGS_STAGING",
        database="GHOST_DETECTION", schema="APP",
        quote_identifiers=False
    )
    print(f"  write_pandas to staging: success={success}, chunks={nchunks}, rows={nrows}")

    print("Inserting from staging to GHOST_SIGHTINGS with proper types...")
    cur.execute("""
        INSERT INTO GHOST_DETECTION.APP.GHOST_SIGHTINGS
        (SIGHTING_ID, GHOST_ID, LOCATION_NAME, LOCATION_ADDRESS,
         LATITUDE, LONGITUDE, LOCATION_COORDINATES,
         SIGHTING_DATETIME, WITNESS_NAME, WITNESS_CONTACT,
         ENVIRONMENTAL_CONDITIONS, TEMPERATURE_CELSIUS, EMF_READING,
         DESCRIPTION, EVIDENCE_TYPE, PARANORMAL_ACTIVITY_LEVEL,
         INVESTIGATION_NOTES, VERIFIED)
        SELECT SIGHTING_ID, GHOST_ID, LOCATION_NAME, LOCATION_ADDRESS,
               LATITUDE, LONGITUDE, ST_MAKEPOINT(LONGITUDE, LATITUDE),
               SIGHTING_DATETIME::TIMESTAMP_NTZ, WITNESS_NAME, WITNESS_CONTACT,
               ENVIRONMENTAL_CONDITIONS, TEMPERATURE_CELSIUS, EMF_READING,
               DESCRIPTION, EVIDENCE_TYPE, PARANORMAL_ACTIVITY_LEVEL,
               INVESTIGATION_NOTES, VERIFIED
        FROM GHOST_DETECTION.APP.SIGHTINGS_STAGING
    """)
    inserted = cur.fetchone()[0]
    print(f"  Inserted {inserted} rows into GHOST_SIGHTINGS")

    cur.execute("DROP TABLE IF EXISTS GHOST_DETECTION.APP.SIGHTINGS_STAGING")

    cur.execute("SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS")
    total = cur.fetchone()[0]
    print(f"\nTotal sightings in table: {total}")

    cur.execute("SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOSTS")
    total_ghosts = cur.fetchone()[0]
    print(f"Total ghosts in table: {total_ghosts}")

    cur.execute("""
        SELECT g.GHOST_TYPE, COUNT(*) as cnt
        FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
        JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
        GROUP BY g.GHOST_TYPE ORDER BY cnt DESC
    """)
    print("\nSightings by ghost type:")
    for row in cur.fetchall():
        print(f"  {row[0]}: {row[1]}")

    cur.close()
    conn.close()
    print("\nDone!")


if __name__ == "__main__":
    main()
