"""
SnowGhostBreakers Test Data Generator
Generates 10,000 ghost sighting rows + ~50 new ghost entities
for the GHOST_DETECTION.APP schema in Snowflake.

Themed data:
- Leprechauns around St. Patrick's Day (Mar 17)
- Evil Rabbits around Easter (Apr 5, 2026)
- Ghouls concentrated around Princeton, NJ
- Mix of Apparitions, Poltergeists, Shadow Entities, Orbs across NY/NJ/New England
"""

import os
import random
import uuid
import json
from datetime import datetime, timedelta
import snowflake.connector

CONN_NAME = os.getenv("SNOWFLAKE_CONNECTION_NAME") or "tspann1"

START_DATE = datetime(2025, 10, 1)
END_DATE = datetime(2026, 3, 31)
TOTAL_SIGHTINGS = 10000

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
        ("Staten Island Ferry Terminal", "4 Whitehall St, Manhattan, NY", 40.7013, -74.0132),
        ("Bronx Zoo Area", "2300 Southern Blvd, Bronx, NY", 40.8506, -73.8769),
        ("Flushing Meadows Park", "Flushing Meadows, Queens, NY", 40.7400, -73.8408),
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
        ("Einstein's House", "112 Mercer St, Princeton, NJ", 40.3485, -74.6551),
        ("Institute for Advanced Study", "1 Einstein Dr, Princeton, NJ", 40.3291, -74.6696),
        ("Princeton Battlefield", "500 Mercer Rd, Princeton, NJ", 40.3291, -74.6757),
        ("Carnegie Lake", "Princeton, NJ", 40.3410, -74.6389),
        ("Prospect Garden", "Princeton University, NJ", 40.3461, -74.6565),
        ("McCarter Theatre", "91 University Pl, Princeton, NJ", 40.3482, -74.6594),
        ("Princeton Junction Station", "Alexander Rd, Princeton Junction, NJ", 40.3173, -74.6240),
    ],
    "nj_other": [
        ("Liberty State Park", "200 Morris Pesin Dr, Jersey City, NJ", 40.7095, -74.0554),
        ("Hoboken Waterfront", "1 Sinatra Dr, Hoboken, NJ", 40.7440, -74.0324),
        ("Newark Penn Station", "Raymond Blvd, Newark, NJ", 40.7345, -74.1642),
        ("Trenton State House", "125 W State St, Trenton, NJ", 40.2206, -74.7700),
        ("Cape May Lighthouse", "215 Light House Ave, Cape May, NJ", 38.9332, -74.9604),
        ("Asbury Park Boardwalk", "Ocean Ave, Asbury Park, NJ", 40.2201, -74.0001),
        ("Princeton Battlefield State Park", "500 Mercer Rd, Princeton, NJ", 40.3270, -74.6720),
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
        ("Salem Witch Museum", "19 1/2 N Washington Sq, Salem, MA", 42.5195, -70.8967),
        ("Witch House", "310 Essex St, Salem, MA", 42.5211, -70.8932),
        ("Charter Street Cemetery", "45 Charter St, Salem, MA", 42.5222, -70.8930),
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
        ("Grove Street Cemetery", "227 Grove St, New Haven, CT", 41.3138, -72.9287),
        ("East Rock Park", "41 Cold Spring St, New Haven, CT", 41.3278, -72.9012),
    ],
    "rural_ne": [
        ("Burlington Waterfront", "College St, Burlington, VT", 44.4759, -73.2211),
        ("Stowe Village", "Stowe, VT", 44.4654, -72.6874),
        ("Portland Head Light", "12 Captain Strout Cir, Cape Elizabeth, ME", 43.6231, -70.2078),
        ("Acadia National Park", "Bar Harbor, ME", 44.3386, -68.2733),
        ("White Mountain National Forest", "Lincoln, NH", 44.0740, -71.6892),
        ("Franconia Notch", "Franconia Notch, NH", 44.1366, -71.6811),
        ("Nantucket", "Nantucket, MA", 41.2835, -70.0995),
        ("Martha's Vineyard", "Martha's Vineyard, MA", 41.3805, -70.6456),
    ],
}

GHOST_TYPES_CONFIG = {
    "Leprechaun": {
        "names": [
            "Emerald Trickster", "Lucky Larry", "Shamrock Shade", "Pot o' Gold Phantom",
            "Clover Creeper", "Green Gleam", "Dublin Danny", "Celtic Sprite",
            "Blarney Bandit", "Rainbow Wraith"
        ],
        "threat_levels": ["Low", "Low", "Low", "Medium"],
        "frequencies": ["Occasional", "Frequent", "Rare"],
        "descriptions": [
            "Small green entity spotted leaving gold coins near {loc}",
            "Tiny bearded figure in green clothing dancing a jig at {loc}",
            "Mischievous entity hiding small gold objects around {loc}",
            "Green luminous figure spotted at {loc}, witnesses report hearing Irish fiddle music",
            "Impish creature approximately 2 feet tall observed near {loc}, causing minor pranks",
        ],
        "origin_stories": [
            "Ancient Irish spirit said to guard hidden treasures in the New World",
            "Folklore entity that crossed the Atlantic during the Great Famine",
            "Trickster spirit bound to sites of Irish immigrant communities",
        ],
        "conditions": ["Green mist observed", "Temperature drop, faint Irish music", "Gold dust residue", "Rainbow-like light refraction", "Shamrock scent detected"],
    },
    "Evil Rabbit": {
        "names": [
            "Cottontail Terror", "Harbinger Hare", "Red-Eye Jack", "The Doom Bunny",
            "Flopsy the Fearsome", "Shadow Rabbit", "Wicked Whiskers", "Carrion Cottontail",
            "Thumper of Doom", "The Dark Warren"
        ],
        "threat_levels": ["Medium", "Medium", "High", "High"],
        "frequencies": ["Occasional", "Frequent", "Frequent"],
        "descriptions": [
            "Oversized rabbit with glowing red eyes spotted at {loc}",
            "Aggressive rabbit-like entity with sharp teeth observed near {loc}",
            "Giant shadow in the shape of a rabbit seen at {loc}, causing livestock panic",
            "Demonic rabbit creature spotted at {loc}, left claw marks on trees",
            "Large lagomorph entity with unnatural proportions seen at {loc}",
        ],
        "origin_stories": [
            "Cursed Easter rabbit from a botched 1800s ritual in Connecticut",
            "Manifestation of collective childhood fears during spring festivals",
            "Vengeful spirit of a rabbit colony destroyed by development",
        ],
        "conditions": ["Scratching sounds heard", "Fur tufts found on-site", "Carrot-shaped EMF anomalies", "Claw marks on surfaces", "Animal distress in area"],
    },
    "Ghoul": {
        "names": [
            "Princeton Ghoul", "Nassau Nightcrawler", "Graveyard Ghoul", "Einstein's Shadow",
            "Institute Lurker", "Campus Creeper", "Mercer Street Monster", "The IAS Horror",
            "Palmer Square Ghast", "Carnegie Crawler", "Library Ghoul", "Chapel Ghoul",
            "Prospect Garden Phantom", "Tiger Ghoul", "McCarter Specter"
        ],
        "threat_levels": ["High", "High", "Extreme", "Extreme"],
        "frequencies": ["Frequent", "Frequent", "Constant"],
        "descriptions": [
            "Hunched, pale figure with elongated limbs spotted lurking near {loc}",
            "Corpse-like entity digging near {loc} under moonlight",
            "Ghoulish creature with sunken eyes observed feeding near {loc}",
            "Shambling gray figure spotted emerging from shadows at {loc}",
            "Tall gaunt entity with an inhuman gait seen near {loc}",
            "Pack of ghouls spotted at {loc}, moving in coordinated formation",
        ],
        "origin_stories": [
            "Ancient entity drawn to Princeton's concentration of intellectual energy",
            "Restless spirit of a 18th-century Princeton battle casualty",
            "Creature from the underground tunnels beneath Princeton University",
            "Entity that feeds on the residual energy of great scientific minds",
        ],
        "conditions": ["Grave soil disturbance", "Decomposition smell", "Temperature drop of 15°C", "Scratching from underground", "All electronics failed", "Multiple witnesses frozen in fear"],
    },
    "Apparition": {
        "names": [
            "Lady Liberty Ghost", "Harbor Phantom", "Colonial Specter", "Victorian Lady",
            "The Wandering Scholar", "Midnight Sailor", "Revolutionary Ghost", "The Weeping Bride"
        ],
        "threat_levels": ["Low", "Low", "Low", "Medium"],
        "frequencies": ["Rare", "Occasional", "Occasional"],
        "descriptions": [
            "Translucent humanoid figure observed at {loc}",
            "Victorian-era woman in white spotted drifting through {loc}",
            "Colonial-era gentleman seen walking through walls at {loc}",
            "Faint glowing figure observed at {loc}, vanished when approached",
        ],
        "origin_stories": [
            "Spirit of a historical figure unable to leave their former dwelling",
            "Residual haunting replaying events from centuries past",
            "Lost soul searching for something in the afterlife",
        ],
        "conditions": ["Cold spot near location", "Faint whispers heard", "Translucent figure visible", "Old perfume scent detected", "Photographs show anomalies"],
    },
    "Poltergeist": {
        "names": [
            "The Rattler", "Subway Smasher", "Kitchen Chaos", "The Tosser",
            "Downtown Destructor", "Office Poltergeist", "The Stacker", "Plate Breaker"
        ],
        "threat_levels": ["Medium", "High", "High", "Extreme"],
        "frequencies": ["Frequent", "Frequent", "Constant"],
        "descriptions": [
            "Invisible force throwing objects at {loc}",
            "Aggressive unseen entity slamming doors and breaking windows at {loc}",
            "Furniture moving on its own at {loc}, witnesses terrified",
            "Violent paranormal disturbance at {loc}, multiple objects levitating",
        ],
        "origin_stories": [
            "Energy manifestation from extreme emotional distress at the location",
            "Mischievous entity bound to the building since its construction",
        ],
        "conditions": ["Objects levitating", "Doors slamming", "Temperature fluctuations", "Electrical malfunctions", "Multiple objects levitating, temperature fluctuations"],
    },
    "Shadow Entity": {
        "names": [
            "Tunnel Shadow", "Subway Shade", "Alley Lurker", "The Dark Form",
            "Midnight Silhouette", "Underground Phantom", "The Void Walker", "Darkness Itself"
        ],
        "threat_levels": ["High", "High", "Extreme", "Medium"],
        "frequencies": ["Frequent", "Occasional", "Frequent"],
        "descriptions": [
            "Dark humanoid shadow spotted in {loc}, caused electronic failures",
            "Pitch-black figure gliding through {loc} at night",
            "Shadow entity with no source observed at {loc}, all lights dimmed",
            "Tall shadow figure with red eyes seen in {loc}",
        ],
        "origin_stories": [
            "Unknown origin, manifests in dark underground spaces",
            "Entity drawn to areas of high human traffic and fear",
        ],
        "conditions": ["All lights dimmed", "Electronics malfunctioned", "Extreme cold detected", "EMF readings off the charts", "Witnesses reported paralysis"],
    },
    "Orb": {
        "names": [
            "Vermont Orbs", "Forest Lights", "Mountain Glow", "Coastal Orb",
            "Pine Light", "Lake Luminance", "Ridge Radiance", "Hilltop Haze"
        ],
        "threat_levels": ["Low", "Low", "Low", "Medium"],
        "frequencies": ["Rare", "Rare", "Occasional"],
        "descriptions": [
            "Group of luminous blue-white orbs floating at {loc}",
            "Single large glowing orb observed at {loc}, pulsating rhythmically",
            "Multiple small light orbs seen drifting through {loc}",
            "Bright sphere of light hovering at {loc}, disappeared rapidly",
        ],
        "origin_stories": [
            "Possibly natural phenomenon or residual spiritual energy",
            "Manifestation of ley line energy at rural intersections",
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
    "Ghoul": 3500,
    "Leprechaun": 1500,
    "Evil Rabbit": 1200,
    "Apparition": 1500,
    "Poltergeist": 1000,
    "Shadow Entity": 800,
    "Orb": 500,
}


def random_date_weighted(entity_type):
    total_days = (END_DATE - START_DATE).days

    if entity_type == "Leprechaun":
        if random.random() < 0.55:
            offset = random.gauss(0, 3)
            d = ST_PATRICKS + timedelta(days=offset)
            if START_DATE <= d <= END_DATE:
                return d
        if random.random() < 0.2:
            march_start = datetime(2026, 3, 1)
            march_end = datetime(2026, 3, 31)
            d = march_start + timedelta(days=random.randint(0, (march_end - march_start).days))
            return d

    elif entity_type == "Evil Rabbit":
        if random.random() < 0.55:
            offset = random.gauss(0, 4)
            d = EASTER + timedelta(days=offset)
            if d > END_DATE:
                d = END_DATE - timedelta(days=random.randint(0, 7))
            if START_DATE <= d <= END_DATE:
                return d
        if random.random() < 0.2:
            d = datetime(2026, 3, 20) + timedelta(days=random.randint(0, 12))
            if d <= END_DATE:
                return d

    elif entity_type == "Ghoul":
        if random.random() < 0.3:
            halloween = datetime(2025, 10, 31)
            offset = random.gauss(0, 5)
            d = halloween + timedelta(days=offset)
            if START_DATE <= d <= END_DATE:
                return d

    d = START_DATE + timedelta(days=random.randint(0, total_days))
    hour = random.choices(range(24), weights=[1]*6 + [2]*4 + [3]*2 + [2]*2 + [1]*2 + [2]*2 + [4]*4 + [5]*2, k=1)[0]
    minute = random.randint(0, 59)
    second = random.randint(0, 59)
    return d.replace(hour=hour, minute=minute, second=second)


def jitter_coords(lat, lng, radius_deg=0.01):
    return (
        lat + random.uniform(-radius_deg, radius_deg),
        lng + random.uniform(-radius_deg, radius_deg),
    )


def generate_ghost_entities():
    ghosts = []
    for ghost_type, config in GHOST_TYPES_CONFIG.items():
        for name in config["names"]:
            ghost_id = f"GH_{uuid.uuid4().hex[:8].upper()}"
            threat = random.choice(config["threat_levels"])
            freq = random.choice(config["frequencies"])
            desc = random.choice(config["descriptions"]).format(loc="various locations")
            origin = random.choice(config["origin_stories"])
            first_detected = START_DATE + timedelta(days=random.randint(0, 30))
            last_seen = END_DATE - timedelta(days=random.randint(0, 30))
            confidence = round(random.uniform(0.6, 0.99), 2)

            ghosts.append((
                ghost_id, name, ghost_type, threat, desc, freq, origin,
                first_detected.strftime("%Y-%m-%d %H:%M:%S"),
                last_seen.strftime("%Y-%m-%d %H:%M:%S"),
                "Active", confidence,
            ))
    return ghosts


def generate_sightings(ghosts_by_type):
    sightings = []

    for entity_type, count in SIGHTING_DISTRIBUTION.items():
        available_ghosts = ghosts_by_type.get(entity_type, [])
        if not available_ghosts:
            continue

        config = GHOST_TYPES_CONFIG[entity_type]
        location_keys = ENTITY_TYPE_LOCATIONS[entity_type]

        available_locations = []
        for k in location_keys:
            available_locations.extend(LOCATIONS[k])

        for _ in range(count):
            ghost = random.choice(available_ghosts)
            ghost_id = ghost[0]
            threat = ghost[3]

            loc = random.choice(available_locations)
            loc_name, loc_addr, lat, lng = loc
            lat, lng = jitter_coords(lat, lng)

            sighting_dt = random_date_weighted(entity_type)
            sighting_id = f"SIGHT_{uuid.uuid4().hex[:8].upper()}"

            witness_num = random.randint(1, 9999)
            witness_name = f"Witness {witness_num}"
            witness_contact = f"witness{witness_num}@ghostreport.com"

            conditions = random.choice(config["conditions"])

            month = sighting_dt.month
            if month in [12, 1, 2]:
                base_temp = random.uniform(-5, 5)
            elif month in [3, 4]:
                base_temp = random.uniform(2, 15)
            elif month in [10, 11]:
                base_temp = random.uniform(5, 18)
            else:
                base_temp = random.uniform(15, 30)

            if threat in ["High", "Extreme"]:
                base_temp -= random.uniform(5, 15)
            temp = round(base_temp, 1)

            if threat == "Extreme":
                emf = round(random.uniform(30, 50), 2)
            elif threat == "High":
                emf = round(random.uniform(15, 35), 2)
            elif threat == "Medium":
                emf = round(random.uniform(5, 20), 2)
            else:
                emf = round(random.uniform(0.5, 10), 2)

            desc = random.choice(config["descriptions"]).format(loc=loc_name)
            evidence_type = random.choice(["Visual", "EMF", "Temperature", "Audio", "Photograph", "Multiple"])

            if threat == "Extreme":
                activity = random.randint(7, 10)
            elif threat == "High":
                activity = random.randint(5, 9)
            elif threat == "Medium":
                activity = random.randint(3, 7)
            else:
                activity = random.randint(1, 5)

            notes = f"Investigation report for {entity_type} sighting at {loc_name}. Threat level: {threat}."
            verified = random.random() < 0.7

            sightings.append((
                sighting_id, ghost_id, loc_name, loc_addr,
                round(lat, 6), round(lng, 6),
                sighting_dt.strftime("%Y-%m-%d %H:%M:%S"),
                witness_name, witness_contact,
                conditions, temp, emf, desc, evidence_type,
                activity, notes, verified,
            ))

    random.shuffle(sightings)
    return sightings


def main():
    print("Connecting to Snowflake...")
    conn = snowflake.connector.connect(connection_name=CONN_NAME)
    cur = conn.cursor()

    print("Generating ghost entities...")
    ghosts = generate_ghost_entities()

    ghosts_by_type = {}
    for g in ghosts:
        gtype = g[2]
        if gtype not in ghosts_by_type:
            ghosts_by_type[gtype] = []
        ghosts_by_type[gtype].append(g)

    print(f"Inserting {len(ghosts)} new ghost entities...")
    ghost_sql = """
        INSERT INTO GHOST_DETECTION.APP.GHOSTS
        (GHOST_ID, GHOST_NAME, GHOST_TYPE, THREAT_LEVEL, DESCRIPTION, MANIFESTATION_FREQUENCY,
         ORIGIN_STORY, FIRST_DETECTED_DATE, LAST_SEEN_DATE, STATUS, CONFIDENCE_SCORE)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    for g in ghosts:
        cur.execute(ghost_sql, g)
    print(f"  Inserted {len(ghosts)} ghosts.")

    print("Generating sightings...")
    sightings = generate_sightings(ghosts_by_type)
    print(f"Generated {len(sightings)} sightings.")

    batch_size = 500
    for i in range(0, len(sightings), batch_size):
        batch = sightings[i:i + batch_size]
        for s in batch:
            sid, gid, loc_name, loc_addr, lat, lng = s[0], s[1], s[2], s[3], s[4], s[5]
            sdt, wname, wcontact, cond, temp, emf, desc, etype, alevel, notes, verified = s[6:]
            sql = f"""
                INSERT INTO GHOST_DETECTION.APP.GHOST_SIGHTINGS
                (SIGHTING_ID, GHOST_ID, LOCATION_NAME, LOCATION_ADDRESS,
                 LATITUDE, LONGITUDE, LOCATION_COORDINATES,
                 SIGHTING_DATETIME, WITNESS_NAME, WITNESS_CONTACT,
                 ENVIRONMENTAL_CONDITIONS, TEMPERATURE_CELSIUS, EMF_READING,
                 DESCRIPTION, EVIDENCE_TYPE, PARANORMAL_ACTIVITY_LEVEL,
                 INVESTIGATION_NOTES, VERIFIED)
                SELECT %s, %s, %s, %s, %s, %s, ST_MAKEPOINT({lng}, {lat}),
                       %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            """
            params = [sid, gid, loc_name, loc_addr, lat, lng,
                      sdt, wname, wcontact, cond, temp, emf, desc, etype, alevel, notes, verified]
            cur.execute(sql, params)
        inserted = min(i + batch_size, len(sightings))
        print(f"  Inserted {inserted}/{len(sightings)} sightings...")

    conn.commit()

    cur.execute("SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS")
    total = cur.fetchone()[0]
    print(f"\nDone! Total sightings in table: {total}")

    cur.execute("SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOSTS")
    total_ghosts = cur.fetchone()[0]
    print(f"Total ghosts in table: {total_ghosts}")

    cur.execute("""
        SELECT GHOST_TYPE, COUNT(*) as cnt
        FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
        JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
        GROUP BY GHOST_TYPE
        ORDER BY cnt DESC
    """)
    print("\nSightings by ghost type:")
    for row in cur.fetchall():
        print(f"  {row[0]}: {row[1]}")

    cur.close()
    conn.close()
    print("\nAll done!")


if __name__ == "__main__":
    main()
