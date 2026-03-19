-- ============================================================================
-- GHOST SAMPLE DATA
-- SnowGhostBreakers Application
-- Insert 15+ ghost entities with variety of types, threat levels, and statuses
-- ============================================================================

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;

-- Clear existing data (optional - comment out for production)
-- TRUNCATE TABLE GHOSTS;

INSERT INTO GHOSTS (
    GHOST_ID,
    NAME,
    GHOST_TYPE,
    THREAT_LEVEL,
    STATUS,
    DESCRIPTION,
    MANIFESTATION_PATTERN,
    FIRST_RECORDED,
    LAST_ACTIVITY,
    KNOWN_LOCATION,
    WEAKNESS,
    CREATED_AT,
    UPDATED_AT
)
VALUES
-- ============================================================================
-- APPARITIONS - Classic visible ghosts
-- ============================================================================
(
    'GHOST-001',
    'The Grey Lady of Willowmere',
    'Apparition',
    'Medium',
    'Active',
    'A translucent female figure in Victorian-era grey dress, often seen gliding through hallways. She is believed to be Lady Elizabeth Ashworth who died in 1847 waiting for her husband to return from war.',
    'Appears between 11 PM and 3 AM, predominantly on foggy nights. Manifests near windows facing east. Temperature drops 5-8°C precede sightings.',
    '1852-03-15',
    CURRENT_TIMESTAMP() - INTERVAL '2 DAYS',
    'Willowmere Manor, Yorkshire, England',
    'Exposure to direct sunlight, iron barriers, salt circles',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-002',
    'Bloody Mary',
    'Apparition',
    'High',
    'Active',
    'A vengeful spirit that appears in mirrors when summoned by name three times. Face is disfigured and bloodied. Known to scratch and attack those who summon her.',
    'Requires dark room with mirror and candle. Most active during new moon phases. Responds to verbal invocation. EMF spikes to 12+ mG during manifestation.',
    '1692-10-31',
    CURRENT_TIMESTAMP() - INTERVAL '5 DAYS',
    'Various locations worldwide - bound to mirrors',
    'Breaking the mirror during manifestation, holy water on reflective surface, speaking name backwards',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-003',
    'The White Lady of Loch Morar',
    'Apparition',
    'Low',
    'Dormant',
    'A benevolent spirit of a young woman in white robes who appears near the shores of Loch Morar. She is said to warn travelers of impending danger on stormy nights.',
    'Appears during severe weather, particularly before storms. Hovers above water surface. Non-threatening demeanor. Temperature remains stable during sightings.',
    '1745-08-20',
    CURRENT_TIMESTAMP() - INTERVAL '45 DAYS',
    'Loch Morar, Scottish Highlands, Scotland',
    'No known weaknesses - appears to be protective spirit',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- POLTERGEISTS - Noisy and disruptive spirits
-- ============================================================================
(
    'GHOST-004',
    'The Bell Witch',
    'Poltergeist',
    'Extreme',
    'Active',
    'One of Americas most famous poltergeists. Capable of speaking, physical attacks, and prophetic visions. Tormented the Bell family of Tennessee in the early 1800s and has persisted since.',
    'Most active during family gatherings or emotional events. Throws objects, slaps victims, speaks in multiple voices. EMF consistently above 8 mG in affected areas.',
    '1817-06-01',
    CURRENT_TIMESTAMP() - INTERVAL '1 DAY',
    'Adams, Tennessee, USA',
    'Exorcism rituals, abandonment of property, sage cleansing combined with electromagnetic disruption',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-005',
    'Der Poltergeist von Rosenheim',
    'Poltergeist',
    'High',
    'Captured',
    'A powerful poltergeist that disrupted electrical systems in a German law office in 1967. Caused lights to swing, phones to malfunction, and furniture to move on its own.',
    'Activity centered around specific individuals (focus persons). Electrical interference primary manifestation. Activity ceased when focus person left premises.',
    '1967-10-01',
    '1968-01-15',
    'Rosenheim, Bavaria, Germany',
    'Removal of focus person from location, Faraday cage containment',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-006',
    'The Enfield Poltergeist',
    'Poltergeist',
    'High',
    'Neutralized',
    'A notorious poltergeist that haunted the Hodgson family in Enfield, England from 1977-1978. Known for levitating children, throwing furniture, and speaking through an 11-year-old girl.',
    'Activity peaked during adolescent emotional distress. Knockings, furniture movement, voice phenomena. Required constant monitoring by SPR investigators.',
    '1977-08-31',
    '1978-09-10',
    'Enfield, London, England',
    'Extended cleansing rituals, family relocation, puberty completion of focus child',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- SHADOW FIGURES - Dark, humanoid entities
-- ============================================================================
(
    'GHOST-007',
    'The Hat Man',
    'Shadow_Figure',
    'High',
    'Active',
    'A tall shadow figure wearing what appears to be a wide-brimmed hat and long coat. Reported worldwide, often during sleep paralysis episodes. Exudes intense feelings of dread.',
    'Appears during sleep paralysis or hypnagogic states. Stands in doorways or corners. Never speaks but presence causes extreme fear. Often associated with electrical disturbances.',
    '1850-01-01',
    CURRENT_TIMESTAMP() - INTERVAL '3 DAYS',
    'Global - no fixed location',
    'Full wakefulness, bright light exposure, iron talismans',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-008',
    'The Shadow Crawler',
    'Shadow_Figure',
    'Medium',
    'Active',
    'A dark entity that moves along walls and ceilings in an unnatural crawling motion. Sightings often accompanied by whispered voices and a sulfuric smell.',
    'Most active in buildings with violent history. Moves counter-clockwise along surfaces. Avoids areas with running water. EMF readings fluctuate rapidly during presence.',
    '1923-11-15',
    CURRENT_TIMESTAMP() - INTERVAL '12 DAYS',
    'Abandoned St. Marys Hospital, Chicago, USA',
    'Ultraviolet light exposure, holy water misting, positive emotional energy',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- ORBS - Spherical energy manifestations
-- ============================================================================
(
    'GHOST-009',
    'The Gettysburg Lights',
    'Orb',
    'Low',
    'Active',
    'A collection of glowing orbs frequently photographed at Gettysburg battlefield. Believed to be the spirits of fallen Civil War soldiers. Appear as blue-white spheres of light.',
    'Most visible on battle anniversary dates. Concentrate near areas of heaviest casualties. Move in formation patterns reminiscent of military maneuvers.',
    '1863-07-03',
    CURRENT_TIMESTAMP() - INTERVAL '7 DAYS',
    'Gettysburg National Military Park, Pennsylvania, USA',
    'None known - appears to be residual energy, non-threatening',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-010',
    'The Blue Lady Orb',
    'Orb',
    'Low',
    'Active',
    'A single blue-tinged orb that appears at Moss Beach Distillery. Believed to be the spirit of a woman killed in the 1930s. Playful and interactive with visitors.',
    'Appears when music is played, especially jazz from the 1930s era. Moves through walls. Responds to direct communication. No temperature anomalies detected.',
    '1932-06-15',
    CURRENT_TIMESTAMP() - INTERVAL '14 DAYS',
    'Moss Beach Distillery, Half Moon Bay, California, USA',
    'None required - benevolent entity',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- RESIDUAL HAUNTS - Non-intelligent repeating phenomena
-- ============================================================================
(
    'GHOST-011',
    'The Tower of London Princes',
    'Residual_Haunt',
    'Low',
    'Active',
    'The spectral images of two young boys in white nightgowns, believed to be the Princes in the Tower murdered in 1483. They walk hand in hand through the Bloody Tower.',
    'Appear on specific dates - September 3rd most common. Always follow same path. Do not interact with observers. Duration approximately 47 seconds.',
    '1674-07-17',
    CURRENT_TIMESTAMP() - INTERVAL '180 DAYS',
    'Tower of London, London, England',
    'Cannot be neutralized - stone tape phenomenon. Energy will dissipate naturally over centuries.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-012',
    'The Phantom Army of Edgehill',
    'Residual_Haunt',
    'Low',
    'Active',
    'A spectral reenactment of the Battle of Edgehill from 1642. Witnesses report sounds of cannon fire, horses, and screaming soldiers. Full apparitions of armies clashing.',
    'Occurs on October 23rd anniversary. Most vivid between 2-4 AM. Covers several miles of battlefield. No interaction possible - pure playback.',
    '1642-12-25',
    CURRENT_TIMESTAMP() - INTERVAL '130 DAYS',
    'Edgehill, Warwickshire, England',
    'Stone tape phenomenon - no neutralization possible',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- INTELLIGENT HAUNTS - Aware and interactive spirits
-- ============================================================================
(
    'GHOST-013',
    'The Headless Horseman of Sleepy Hollow',
    'Intelligent_Haunt',
    'High',
    'Active',
    'A Hessian soldier decapitated by cannonball during the Revolutionary War. Rides nightly searching for his head. Aggressive toward travelers on the Old Dutch Church road.',
    'Most active between midnight and dawn. Rides a black horse with flaming hooves. Throws flaming pumpkins at targets. Can be outrun by crossing bridge to holy ground.',
    '1776-10-28',
    CURRENT_TIMESTAMP() - INTERVAL '4 DAYS',
    'Sleepy Hollow, New York, USA',
    'Holy ground, crossing running water, dawn light',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-014',
    'Captain Morgan of the Queen Anne',
    'Intelligent_Haunt',
    'Medium',
    'Active',
    'Spirit of a merchant ship captain who went down with his vessel in 1789. Appears on ships passing the wreck site, warning of approaching storms. Helpful but startling.',
    'Appears during severe weather approaches. Speaks in 18th century maritime language. Points toward shore. Vanishes when message delivered.',
    '1789-11-02',
    CURRENT_TIMESTAMP() - INTERVAL '21 DAYS',
    'Cape Hatteras, North Carolina, USA',
    'Acknowledgment of warning, verbal thanks dissipates apparition',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- DEMONIC ENTITIES - Malevolent supernatural beings
-- ============================================================================
(
    'GHOST-015',
    'The Demon of Brownsville Road',
    'Demonic',
    'Extreme',
    'Captured',
    'A powerful demonic entity that tormented the Cranmer family in Pittsburgh. Manifested as a black mass with glowing red eyes. Capable of possession and physical harm.',
    'Required multiple exorcism attempts over years. Activity increased during religious observances. Sulfur smell constant. Temperature drops of 20°C+ during manifestation.',
    '1988-01-01',
    '2006-08-15',
    'Brownsville Road, Pittsburgh, Pennsylvania, USA',
    'Extended exorcism ritual, blessed salt perimeter, relics of saints',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-016',
    'Zozo',
    'Demonic',
    'Extreme',
    'Active',
    'A demonic entity frequently contacted through Ouija boards. Known for initially appearing friendly before becoming threatening. Associated with multiple cases of possession.',
    'Manifests through divination tools. Announces presence by moving planchette to Z-O-Z-O repeatedly. Causes scratches in sets of three. EMF goes haywire during contact.',
    '1816-01-01',
    CURRENT_TIMESTAMP() - INTERVAL '8 DAYS',
    'Various locations - summoned entity',
    'Immediate session termination, burning of Ouija board, cleansing ritual within 24 hours',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- ELEMENTAL SPIRITS - Nature-bound entities
-- ============================================================================
(
    'GHOST-017',
    'The Green Man of Paviland',
    'Elemental',
    'Low',
    'Active',
    'An ancient nature spirit residing in the caves of Gower Peninsula. Appears as a humanoid figure covered in moss and leaves. Protective of the local ecosystem.',
    'Appears during solstices and equinoxes. Most active at dawn and dusk. Leaves tracks of wildflowers. Hostile only to those who damage the environment.',
    '-33000-01-01',
    CURRENT_TIMESTAMP() - INTERVAL '90 DAYS',
    'Paviland Cave, Gower Peninsula, Wales',
    'Ecological respect - do not harm local flora/fauna',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-018',
    'Yuki-onna',
    'Elemental',
    'High',
    'Active',
    'A Japanese snow spirit appearing as a beautiful woman in white kimono. Lures travelers into blizzards. Can freeze victims with her breath. Sometimes spares those who show kindness.',
    'Appears only during heavy snowstorms. Temperature drops to -30°C in her presence. Leaves no footprints. Can pass through solid objects.',
    '1700-01-01',
    CURRENT_TIMESTAMP() - INTERVAL '35 DAYS',
    'Mount Fuji region, Honshu, Japan',
    'Fire, warmth, acts of genuine kindness, shelter from storm',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-019',
    'The Banshee of Dunluce',
    'Elemental',
    'Medium',
    'Active',
    'An Irish death spirit attached to the MacDonnell clan. Her wailing cry announces impending death of family members. Appears as an old woman with long white hair and hollow eyes.',
    'Wailing heard up to 3 miles away. Appears 1-3 days before death occurs. Never seen directly - only heard and glimpsed at edges of vision.',
    '1584-01-01',
    CURRENT_TIMESTAMP() - INTERVAL '60 DAYS',
    'Dunluce Castle, County Antrim, Northern Ireland',
    'Cannot be neutralized - serves as death herald, not cause',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'GHOST-020',
    'La Llorona',
    'Intelligent_Haunt',
    'High',
    'Active',
    'The Weeping Woman - spirit of Maria who drowned her children in a river and now wanders waterways searching for them. Her cry of "Ay, mis hijos!" is heard before sightings.',
    'Appears near rivers and lakes at night. Dressed in white, face obscured by long black hair. Attempts to lure children toward water. Weeping audible from great distances.',
    '1550-01-01',
    CURRENT_TIMESTAMP() - INTERVAL '6 DAYS',
    'Rio Grande Valley, Texas/Mexico border',
    'Religious artifacts, staying away from water at night, iron barriers',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
);

-- Verify insert
SELECT 
    GHOST_TYPE,
    THREAT_LEVEL,
    STATUS,
    COUNT(*) AS COUNT
FROM GHOSTS
GROUP BY GHOST_TYPE, THREAT_LEVEL, STATUS
ORDER BY GHOST_TYPE, THREAT_LEVEL;
