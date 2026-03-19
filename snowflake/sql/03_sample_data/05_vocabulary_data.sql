-- ============================================================================
-- BUSINESS VOCABULARY SAMPLE DATA
-- SnowGhostBreakers Application
-- Ghost hunting terminology, equipment definitions, and phenomena descriptions
-- ============================================================================

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;

-- Clear existing data (optional - comment out for production)
-- TRUNCATE TABLE BUSINESS_VOCABULARY;

INSERT INTO BUSINESS_VOCABULARY (
    TERM_ID,
    TERM,
    CATEGORY,
    DEFINITION,
    SYNONYMS,
    RELATED_TERMS,
    USAGE_CONTEXT,
    EXAMPLES,
    SOURCE,
    CREATED_AT,
    UPDATED_AT
)
VALUES
-- ============================================================================
-- GHOST TYPE DEFINITIONS
-- ============================================================================
(
    'VOCAB-001',
    'Apparition',
    'Ghost Type',
    'A visible ghost or spirit, typically appearing as a translucent human form. Apparitions can be full-bodied or partial, and may be interactive (intelligent) or repetitive (residual).',
    '["ghost", "phantom", "specter", "spirit", "shade", "wraith"]',
    '["manifestation", "haunting", "residual haunt", "intelligent haunt"]',
    'Used when categorizing visual paranormal encounters. Most common type of ghost sighting.',
    '["The Grey Lady is classified as a classic apparition", "Investigators captured photographic evidence of the apparition"]',
    'SnowGhostBreakers Classification System v2.0',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-002',
    'Poltergeist',
    'Ghost Type',
    'A type of ghost or spirit responsible for physical disturbances such as loud noises, objects being moved, and physical attacks. German for "noisy ghost". Often associated with a living focus person.',
    '["noisy ghost", "throwing ghost", "physical spirit"]',
    '["focus person", "psychokinesis", "telekinesis", "RSPK"]',
    'Used for cases involving physical manipulation of environment. Key indicator is objects moving without apparent cause.',
    '["The Bell Witch is Americas most famous poltergeist", "Poltergeist activity increased when the teenager was present"]',
    'SnowGhostBreakers Classification System v2.0',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-003',
    'Shadow Figure',
    'Ghost Type',
    'A dark, humanoid silhouette observed in peripheral vision or directly. Shadow figures are characterized by their lack of discernible features and their deep black coloration that seems to absorb light.',
    '["shadow person", "shadow man", "dark entity", "black mass"]',
    '["Hat Man", "sleep paralysis", "negative entity"]',
    'Used for dark, humanoid manifestations. Often associated with feelings of dread or malevolence.',
    '["The Hat Man is the most commonly reported shadow figure", "Security cameras captured a shadow figure moving across the hallway"]',
    'SnowGhostBreakers Classification System v2.0',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-004',
    'Orb',
    'Ghost Type',
    'A spherical anomaly captured in photographs or video, believed by some to represent spiritual energy. True paranormal orbs emit their own light and move with apparent purpose.',
    '["spirit orb", "light anomaly", "energy ball", "ghost light"]',
    '["dust orb", "moisture orb", "lens flare", "light artifact"]',
    'Controversial classification - must rule out dust, moisture, and lens effects. True orbs show self-luminescence and intelligent movement.',
    '["The Gettysburg Lights are documented as genuine paranormal orbs", "Analysis confirmed the orb was not a dust particle"]',
    'SnowGhostBreakers Classification System v2.0',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-005',
    'Residual Haunt',
    'Ghost Type',
    'A type of haunting where events from the past replay like a recording. The ghost has no awareness of the present and cannot interact with observers. Also known as stone tape theory.',
    '["residual haunting", "stone tape", "psychic impression", "place memory"]',
    '["intelligent haunt", "anniversary ghost", "replay haunting"]',
    'Used for hauntings that repeat without variation. Entities show no awareness or interaction capability.',
    '["The Tower Princes are a classic residual haunt", "The battle sounds repeat every anniversary - a textbook residual haunt"]',
    'SnowGhostBreakers Classification System v2.0',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-006',
    'Intelligent Haunt',
    'Ghost Type',
    'A haunting involving a spirit that is aware of and can interact with the living. These entities can respond to questions, show awareness of changes, and modify their behavior.',
    '["interactive spirit", "aware ghost", "responsive entity"]',
    '["residual haunt", "communication", "EVP session"]',
    'Used when entity demonstrates awareness and interaction capability. Can respond to investigators.',
    '["The Grey Lady made eye contact, confirming intelligent haunt classification", "EVP responses proved this is an intelligent haunt"]',
    'SnowGhostBreakers Classification System v2.0',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-007',
    'Demonic Entity',
    'Ghost Type',
    'A malevolent supernatural being that was never human. Characterized by extreme aggression, ability to possess living beings, and resistance to standard cleansing methods. Requires specialized intervention.',
    '["demon", "inhuman entity", "negative entity", "malevolent spirit"]',
    '["possession", "exorcism", "oppression", "infestation"]',
    'Highest threat classification. Requires demonologist or religious authority involvement. Never attempt amateur investigation.',
    '["Zozo is classified as a demonic entity", "The Brownsville Road case required multiple exorcisms due to demonic entity involvement"]',
    'SnowGhostBreakers Classification System v2.0',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-008',
    'Elemental Spirit',
    'Ghost Type',
    'A nature-based spirit associated with natural elements or locations. Often ancient, predating human history. May be protective or hostile depending on treatment of their territory.',
    '["nature spirit", "elemental", "land spirit", "genius loci"]',
    '["Green Man", "Yuki-onna", "fairy", "fae"]',
    'Used for entities tied to natural locations or phenomena. Respect for environment often key to safe interaction.',
    '["Yuki-onna is classified as an elemental spirit of winter", "The Green Man is an ancient elemental protecting the cave system"]',
    'SnowGhostBreakers Classification System v2.0',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- INVESTIGATION EQUIPMENT
-- ============================================================================
(
    'VOCAB-009',
    'EMF Meter',
    'Equipment',
    'Electromagnetic Field detector used to measure fluctuations in electromagnetic energy. Paranormal entities are believed to disrupt or emit EMF when present. Baseline readings typically 0.2-0.5 mG.',
    '["EMF detector", "electromagnetic field detector", "K-II meter", "Trifield meter"]',
    '["EMF reading", "electromagnetic interference", "baseline reading"]',
    'Primary detection tool. Document baseline before investigation. Spikes above 3 mG warrant investigation. Above 10 mG indicates significant activity.',
    '["EMF meter registered 8.5 mG during manifestation", "Establish EMF baseline before beginning EVP session"]',
    'Paranormal Investigation Equipment Manual',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-010',
    'Spirit Box',
    'Equipment',
    'A device that rapidly scans radio frequencies, creating white noise through which spirits allegedly communicate. Responses spanning multiple frequency stops are considered significant.',
    '["ghost box", "Frank''s Box", "SB7 Spirit Box", "radio sweep device"]',
    '["EVP", "ITC", "radio frequency", "white noise"]',
    'Use in conjunction with EVP recorders. Document all questions asked. Multi-word responses across frequencies are strongest evidence.',
    '["Spirit box session yielded clear name response", "Entity responded through spirit box with three-word phrase"]',
    'Paranormal Investigation Equipment Manual',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-011',
    'Thermal Camera',
    'Equipment',
    'Infrared imaging device that visualizes temperature variations. Cold spots and thermal anomalies may indicate paranormal presence. Used to detect invisible entities.',
    '["FLIR camera", "infrared camera", "thermal imaging device", "IR camera"]',
    '["cold spot", "thermal anomaly", "heat signature", "infrared spectrum"]',
    'Document ambient temperature before investigation. Anomalies of 10°C+ warrant attention. Shadow figures appear as thermal voids.',
    '["Thermal camera captured 15°C cold spot where apparition appeared", "Entity registered no heat signature on thermal imaging"]',
    'Paranormal Investigation Equipment Manual',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-012',
    'EVP Recorder',
    'Equipment',
    'Audio recording device used to capture Electronic Voice Phenomena - voices or sounds not heard during recording but present on playback. Digital recorders with high sample rates preferred.',
    '["digital voice recorder", "audio recorder", "EVP device", "ghost voice recorder"]',
    '["EVP session", "Class A EVP", "voice phenomena", "disembodied voice"]',
    'Use with external microphone for best results. Allow silence between questions. Review recordings at reduced speed for subtle phenomena.',
    '["EVP recorder captured Class A response: the name Robert", "Review EVP recordings within 24 hours of capture"]',
    'Paranormal Investigation Equipment Manual',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-013',
    'Full Spectrum Camera',
    'Equipment',
    'Camera modified to capture light beyond visible spectrum, including ultraviolet and infrared. May reveal entities invisible to standard cameras.',
    '["modified camera", "UV camera", "IR camera", "spectrum camera"]',
    '["infrared photography", "ultraviolet photography", "light spectrum"]',
    'Use in conjunction with standard photography. Compare results across spectrum ranges. Entities may be visible in one spectrum only.',
    '["Full spectrum camera captured figure invisible to naked eye", "Compare full spectrum and standard photos for anomalies"]',
    'Paranormal Investigation Equipment Manual',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-014',
    'REM Pod',
    'Equipment',
    'Radiating Electromagnetism Pod - device that creates its own electromagnetic field and alerts when that field is disturbed. Does not require external EMF sources.',
    '["radiating EM pod", "proximity detector", "field disturbance detector"]',
    '["EMF meter", "motion detector", "proximity sensor"]',
    'Place at strategic locations during investigation. Useful for detecting approaching entities. Can be used for yes/no communication.',
    '["REM Pod activated when entity approached doorway", "Entity touched REM Pod twice for yes response"]',
    'Paranormal Investigation Equipment Manual',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-015',
    'Ovilus',
    'Equipment',
    'Device that converts environmental readings into words from an internal dictionary. Theory suggests entities can manipulate energy to select relevant words.',
    '["word generator", "speech synthesis device", "environmental word converter"]',
    '["spirit box", "ITC device", "communication device"]',
    'Document all words generated and context. Look for relevant responses to questions. Multiple related words strengthen evidence.',
    '["Ovilus generated the word MOTHER when asked about the entitys identity", "Three consecutive Ovilus words formed coherent sentence"]',
    'Paranormal Investigation Equipment Manual',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- PARANORMAL PHENOMENA
-- ============================================================================
(
    'VOCAB-016',
    'Cold Spot',
    'Phenomena',
    'A localized area of significantly lower temperature compared to surrounding environment. Believed to occur when entities draw energy from the environment to manifest.',
    '["temperature anomaly", "thermal drop", "localized cold", "energy drain"]',
    '["manifestation", "thermal camera", "entity presence"]',
    'Document with thermal camera and thermometer. Significant when 10°C+ below ambient. Often precedes visual manifestation.',
    '["15°C cold spot detected at location of previous sightings", "Cold spot moved across room during investigation"]',
    'Paranormal Phenomena Reference Guide',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-017',
    'EVP',
    'Phenomena',
    'Electronic Voice Phenomena - voices or sounds captured on recording devices that were not audible to investigators at time of recording. Classified A (clear), B (discernible), C (faint).',
    '["electronic voice phenomena", "spirit voice", "ghost voice", "disembodied voice recording"]',
    '["EVP session", "Class A EVP", "audio evidence", "voice analysis"]',
    'Primary form of audio evidence. Always have multiple investigators review independently. Document exact timestamp and question asked.',
    '["Class A EVP captured: clear female voice saying Elizabeth", "EVP analysis revealed three distinct voices in recording"]',
    'Paranormal Phenomena Reference Guide',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-018',
    'Manifestation',
    'Phenomena',
    'The process by which a spirit becomes perceptible to human senses, whether visually, audibly, or through physical effects. Can be full or partial.',
    '["appearance", "materialization", "spirit presence", "ghost sighting"]',
    '["apparition", "cold spot", "EMF spike"]',
    'Document all aspects: duration, appearance, behavior, environmental readings. Full manifestations are rare and significant.',
    '["Full manifestation lasted 47 seconds before dissipating", "Partial manifestation showed only upper body"]',
    'Paranormal Phenomena Reference Guide',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-019',
    'Possession',
    'Phenomena',
    'The state in which a spirit or entity takes control of a living persons body. Can be partial (influence) or complete (takeover). Requires immediate professional intervention.',
    '["spirit possession", "entity attachment", "demonic possession", "bodily takeover"]',
    '["exorcism", "oppression", "demonic entity", "cleansing"]',
    'Medical evaluation must be completed first. Document all symptoms. Contact religious authority or demonologist immediately if confirmed.',
    '["Possession case required three exorcism sessions", "Subject showed classic possession signs: voice change, unusual strength, knowledge of unknown languages"]',
    'Paranormal Phenomena Reference Guide',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-020',
    'Stone Tape Theory',
    'Phenomena',
    'The hypothesis that emotionally charged events can be recorded by the environment (particularly stone and water) and replayed under certain conditions, explaining residual hauntings.',
    '["place memory", "environmental recording", "psychic impression", "location memory"]',
    '["residual haunt", "anniversary haunting", "replay ghost"]',
    'Explains hauntings that repeat without variation. Common in buildings with violent history. Cannot be neutralized - will fade over time.',
    '["The Princes manifestation is explained by stone tape theory", "Limestone walls may contribute to stone tape effect at this location"]',
    'Paranormal Phenomena Reference Guide',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- INVESTIGATION TERMS
-- ============================================================================
(
    'VOCAB-021',
    'Baseline',
    'Investigation Term',
    'Initial measurements taken before investigation begins to establish normal environmental conditions. Includes EMF, temperature, and ambient noise levels.',
    '["baseline reading", "initial measurement", "environmental baseline", "control reading"]',
    '["EMF meter", "temperature reading", "ambient conditions"]',
    'Always establish baseline before investigation. Document time, weather, and equipment used. Compare all readings against baseline.',
    '["Baseline EMF was 0.3 mG before activity began", "Document baseline conditions in investigation report"]',
    'Investigation Protocols and Procedures',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-022',
    'Cleansing',
    'Investigation Term',
    'Ritual or procedure intended to remove negative entities or energy from a location. Methods include sage smudging, salt barriers, holy water, and religious ceremonies.',
    '["spiritual cleansing", "smudging", "purification", "blessing"]',
    '["sage", "holy water", "exorcism", "salt barrier"]',
    'Should be performed by experienced practitioner. Document before and after EMF readings. May need repetition for stubborn entities.',
    '["Cleansing ritual reduced EMF readings by 80%", "Multiple cleansing sessions required for this location"]',
    'Investigation Protocols and Procedures',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-023',
    'Containment',
    'Investigation Term',
    'Methods used to restrict an entity to a specific location or prevent it from harming investigators. Includes salt circles, iron barriers, and protective sigils.',
    '["binding", "restriction", "protective barrier", "spiritual barrier"]',
    '["salt circle", "iron barrier", "protective sigil", "holy ground"]',
    'Use as safety measure during investigation. Maintain barrier integrity throughout session. Have escape route outside containment.',
    '["Containment circle kept entity from leaving room", "Demon containment held for full exorcism duration"]',
    'Investigation Protocols and Procedures',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-024',
    'Focus Person',
    'Investigation Term',
    'Individual whose presence appears to trigger or intensify poltergeist activity. Often an adolescent undergoing emotional stress. Removing focus person typically stops activity.',
    '["agent", "catalyst", "trigger person", "poltergeist agent"]',
    '["poltergeist", "psychokinesis", "adolescent", "emotional trigger"]',
    'Identify through activity patterns. Activity should follow focus person. Removing from location is often the solution.',
    '["The 12-year-old daughter was identified as the focus person", "Activity ceased when focus person left the property"]',
    'Investigation Protocols and Procedures',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-025',
    'Provocation',
    'Investigation Term',
    'Technique of deliberately angering or challenging an entity to elicit a response. High-risk method that should only be used by experienced investigators.',
    '["challenging", "antagonizing", "aggressive investigation", "confrontation"]',
    '["EVP session", "communication", "response elicitation"]',
    'Use only as last resort. Never provoke demonic entities. Have safety protocols and experienced team. Document all provocations.',
    '["Provocation resulted in physical response from entity", "Team lead authorized provocation after standard methods failed"]',
    'Investigation Protocols and Procedures',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- THREAT CLASSIFICATIONS
-- ============================================================================
(
    'VOCAB-026',
    'Low Threat',
    'Threat Classification',
    'Entity classification for ghosts that pose minimal risk to investigators or public. Typically residual haunts, benevolent spirits, or weak manifestations. Standard precautions sufficient.',
    '["minimal risk", "benign entity", "non-threatening", "safe classification"]',
    '["threat level", "risk assessment", "safety protocol"]',
    'Standard investigation protocols apply. Single investigator may be sufficient. No special protective equipment required.',
    '["The Blue Lady Orb is classified as low threat", "Low threat designation allows public access to location"]',
    'SnowGhostBreakers Threat Classification System',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-027',
    'Medium Threat',
    'Threat Classification',
    'Entity classification for ghosts capable of causing fear, minor injury, or psychological distress. Includes active shadow figures and some intelligent haunts. Enhanced protocols required.',
    '["moderate risk", "caution advised", "elevated threat", "standard risk"]',
    '["threat level", "investigation team", "safety equipment"]',
    'Minimum two investigators required. Basic protective equipment recommended. Emergency protocols must be established.',
    '["The Shadow Crawler holds medium threat classification", "Medium threat requires backup investigator on site"]',
    'SnowGhostBreakers Threat Classification System',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-028',
    'High Threat',
    'Threat Classification',
    'Entity classification for dangerous ghosts capable of significant physical harm, possession attempts, or severe psychological trauma. Full team and specialized equipment required.',
    '["elevated risk", "dangerous entity", "high risk", "significant threat"]',
    '["threat assessment", "specialized team", "protective protocols"]',
    'Full investigation team required. Religious or demonologist consultation advised. Medical personnel should be available.',
    '["The Bell Witch maintains high threat classification", "High threat investigation requires minimum four team members"]',
    'SnowGhostBreakers Threat Classification System',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-029',
    'Extreme Threat',
    'Threat Classification',
    'Highest entity classification reserved for demonic entities and the most dangerous ghosts. Capable of severe injury, death, or permanent possession. Expert intervention mandatory.',
    '["maximum risk", "critical danger", "extreme risk", "highest threat"]',
    '["demonic entity", "exorcist", "demonologist", "religious authority"]',
    'Professional demonologist or religious authority required. Do not attempt amateur investigation. Full protective protocols mandatory.',
    '["Zozo holds extreme threat classification", "Extreme threat designation restricts all access except authorized professionals"]',
    'SnowGhostBreakers Threat Classification System',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- STATUS DEFINITIONS
-- ============================================================================
(
    'VOCAB-030',
    'Active Status',
    'Entity Status',
    'Classification indicating an entity is currently manifesting and available for investigation. Activity may be continuous or periodic.',
    '["currently active", "manifesting", "present", "ongoing haunting"]',
    '["dormant", "captured", "neutralized"]',
    'Indicates investigation is appropriate. Document activity patterns. Update status if activity ceases.',
    '["The Grey Lady maintains active status with weekly manifestations", "Active status confirmed through recent sighting reports"]',
    'SnowGhostBreakers Status Classification System',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-031',
    'Dormant Status',
    'Entity Status',
    'Classification for entities that have not manifested for extended periods but are not confirmed neutralized. May reactivate under certain conditions.',
    '["inactive", "sleeping", "quiescent", "temporarily inactive"]',
    '["active", "reactivation", "trigger event"]',
    'Continue periodic monitoring. Document any environmental changes. Be prepared for reactivation.',
    '["White Lady of Loch Morar is currently dormant", "Dormant entity may reactivate during anniversary dates"]',
    'SnowGhostBreakers Status Classification System',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-032',
    'Captured Status',
    'Entity Status',
    'Classification for entities that have been contained or bound to a specific location or object through ritual or technological means. Requires ongoing maintenance.',
    '["contained", "bound", "restricted", "imprisoned"]',
    '["containment", "binding ritual", "maintenance protocol"]',
    'Document containment method and maintenance schedule. Regular verification required. Never attempt release without authorization.',
    '["The Brownsville demon is classified as captured", "Captured status requires annual containment verification"]',
    'SnowGhostBreakers Status Classification System',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'VOCAB-033',
    'Neutralized Status',
    'Entity Status',
    'Classification for entities that have been successfully cleansed, crossed over, or otherwise permanently removed. No further activity expected.',
    '["eliminated", "resolved", "crossed over", "cleansed", "banished"]',
    '["cleansing", "exorcism", "crossing over"]',
    'Close investigation file. Document resolution method. Conduct follow-up visits at 30, 90, 365 days to confirm.',
    '["Enfield Poltergeist holds neutralized status since 1978", "Neutralized classification confirmed after one-year follow-up"]',
    'SnowGhostBreakers Status Classification System',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
);

-- Verify insert count and categories
SELECT 
    CATEGORY,
    COUNT(*) AS TERM_COUNT
FROM BUSINESS_VOCABULARY
GROUP BY CATEGORY
ORDER BY TERM_COUNT DESC;

SELECT 
    TERM,
    CATEGORY,
    LEFT(DEFINITION, 80) AS DEFINITION_PREVIEW
FROM BUSINESS_VOCABULARY
ORDER BY CATEGORY, TERM;
