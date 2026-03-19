-- ============================================================================
-- GHOST TAXONOMY SAMPLE DATA
-- SnowGhostBreakers Application
-- Complete classification system for paranormal entities
-- ============================================================================

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;

-- Clear existing data (optional - comment out for production)
-- TRUNCATE TABLE GHOST_TAXONOMY;

INSERT INTO GHOST_TAXONOMY (
    TAXONOMY_ID,
    GHOST_TYPE,
    CLASSIFICATION_LEVEL,
    PARENT_TYPE,
    COMMON_CHARACTERISTICS,
    TYPICAL_MANIFESTATION_DURATION,
    AVERAGE_EMF_RANGE,
    TEMPERATURE_EFFECT,
    DETECTION_METHODS,
    NEUTRALIZATION_METHODS,
    DANGER_INDICATORS,
    HISTORICAL_EXAMPLES,
    SCIENTIFIC_THEORIES,
    RECOMMENDED_EQUIPMENT,
    INVESTIGATION_PROTOCOL,
    CREATED_AT,
    UPDATED_AT
)
VALUES
-- ============================================================================
-- PRIMARY CLASSIFICATIONS
-- ============================================================================
(
    'TAX-001',
    'Apparition',
    'Primary',
    NULL,
    '["Visible manifestation", "Translucent or opaque appearance", "Human form", "May be interactive or residual", "Often associated with specific location", "Can appear full-bodied or partial"]',
    '30-120 seconds typical, up to 5 minutes for strong manifestations',
    '2.0-8.0 mG',
    'Temperature drop of 5-15°C localized to manifestation area',
    '["Visual observation", "Photography (standard and full spectrum)", "Thermal imaging", "EMF detection", "Witness interviews"]',
    '["Cleansing rituals (sage, holy water)", "Resolution of unfinished business", "Exorcism for hostile entities", "Time and natural energy dissipation"]',
    '["Aggressive movement toward witnesses", "Physical interaction attempts", "Increasing manifestation frequency", "Hostile facial expressions"]',
    '["The Grey Lady of Willowmere", "Bloody Mary", "The White Lady of Loch Morar", "Anne Boleyn at Tower of London", "Lincoln''s Ghost at White House"]',
    '["Stone tape theory for residual", "Consciousness survival hypothesis", "Electromagnetic field interaction", "Quantum entanglement theories"]',
    '["Full spectrum camera", "Standard camera with tripod", "EMF meter", "Thermal camera", "Digital audio recorder", "Notepad for witness descriptions"]',
    'Standard observation protocol. Establish baseline readings. Document all manifestation details including duration, appearance, behavior. Attempt communication if intelligent haunt suspected. Multiple witness verification preferred.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-002',
    'Poltergeist',
    'Primary',
    NULL,
    '["Physical manipulation of objects", "Loud noises (knocking, banging)", "Electrical interference", "Often centered on focus person", "Escalating activity patterns", "Rarely visible but highly active"]',
    'Activity periods of 5-60 minutes with quiet intervals',
    '5.0-15.0+ mG during active phases',
    'Rapid temperature fluctuations of 10-20°C during episodes',
    '["EMF monitoring", "Motion-activated cameras", "Audio recording for knocks/voices", "Object position documentation", "Focus person identification"]',
    '["Focus person removal/counseling", "Energy clearing rituals", "Psychological intervention for focus person", "Location abandonment in extreme cases"]',
    '["Object trajectories targeting people", "Increasing violence of activity", "Fire starting behavior", "Attacks on specific individuals", "Scratches or marks appearing"]',
    '["Bell Witch of Tennessee", "Enfield Poltergeist", "Rosenheim Poltergeist", "Mackenzie Poltergeist", "South Shields Poltergeist"]',
    '["RSPK (Recurrent Spontaneous Psychokinesis)", "Stress-induced telekinesis", "Adolescent energy amplification", "Collective unconscious manifestation"]',
    '["Multiple EMF meters in grid pattern", "Motion sensors", "Object markers (flour, tape)", "Video surveillance system", "Audio recorders in multiple locations"]',
    'Document all object movements with photos/video. Establish object baseline positions. Identify potential focus person through activity correlation. Never provoke - activity can escalate dangerously. Team of minimum 4 investigators recommended.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-003',
    'Shadow_Figure',
    'Primary',
    NULL,
    '["Dark humanoid silhouette", "Absorbs rather than reflects light", "Peripheral vision sightings common", "Associated with feelings of dread", "Fast movement capability", "Often wears distinctive clothing (hat, coat)"]',
    '5-60 seconds typical, rarely exceeds 2 minutes',
    '4.0-10.0 mG',
    'Thermal void - no temperature reading or extreme cold',
    '["Peripheral observation", "Night vision cameras", "Thermal imaging (appears as void)", "EMF detection", "Sleep study correlation for Hat Man"]',
    '["Bright light exposure", "Positive energy cultivation", "Iron barriers", "Ultraviolet light", "Spiritual cleansing"]',
    '["Direct approach toward witness", "Physical touch attempts", "Following behavior", "Multiple simultaneous sightings", "Associated sleep paralysis"]',
    '["The Hat Man", "Shadow Crawler", "Hooded Shadow Figures", "Child-sized Shadow Figures"]',
    '["Hypnagogic state manifestation", "Interdimensional entity theory", "Negative thought-form manifestation", "Sleep paralysis hallucination (skeptical view)"]',
    '["Night vision cameras", "FLIR thermal camera", "EMF array", "UV light source", "Digital recorder", "Bright flashlights"]',
    'Low light investigation preferred. Document all details of appearance including clothing, height, behavior. Note emotional response of witnesses. Thermal cameras essential - shadow figures show as voids. Never investigate alone.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-004',
    'Orb',
    'Primary',
    NULL,
    '["Spherical light anomaly", "Self-luminescent", "Intelligent movement patterns", "Various colors reported", "Can pass through solid objects", "Often photographed, less often seen directly"]',
    '2-30 seconds per manifestation',
    '0.5-3.0 mG - lower than most entity types',
    'Minimal temperature effect - usually within 3°C of ambient',
    '["Photography (must rule out dust, moisture)", "Video recording", "Direct observation (rare)", "EMF monitoring", "Air quality sensors"]',
    '["Generally not required - most are benevolent", "Energy clearing if negative", "Salt barriers in rare cases"]',
    '["Red or black coloration", "Aggressive movement toward people", "Associated negative phenomena", "Multiple hostile orbs acting in concert"]',
    '["Gettysburg Battlefield Lights", "Blue Lady Orb of Moss Beach", "Marfa Lights", "Brown Mountain Lights"]',
    '["Spirit energy compressed into sphere", "Ball lightning (skeptical)", "Dust/moisture artifacts (most cases)", "Biophoton emission"]',
    '["High-resolution camera with clean lens", "Video camera", "EMF meter", "Air particle counter", "Hygrometer"]',
    'Rule out natural explanations first (dust, moisture, insects, lens flare). True orbs are self-luminous and show intelligent movement. Document color, size, trajectory. Multiple cameras at different angles help verification.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-005',
    'Residual_Haunt',
    'Primary',
    NULL,
    '["Repetitive manifestation pattern", "No awareness of observers", "Cannot interact or communicate", "Tied to specific location/time", "Often replays traumatic events", "Consistent across all sightings"]',
    'Fixed duration - same each manifestation (30 seconds to several hours)',
    '1.0-4.0 mG - consistent with each replay',
    'Predictable temperature patterns that repeat exactly',
    '["Pattern observation across multiple sessions", "Timeline documentation", "Environmental recording correlation", "Historical research"]',
    '["Cannot be neutralized conventionally", "Will fade naturally over centuries", "Location renovation may disrupt", "Rarely requires intervention"]',
    '["Residual haunts pose no direct danger", "Psychological impact on sensitive individuals", "May indicate stronger activity possible"]',
    '["Tower of London Princes", "Phantom Army of Edgehill", "Gettysburg Battle Sounds", "Lincoln Assassination Theater"]',
    '["Stone tape theory (primary)", "Psychic impression theory", "Location memory", "Quantum holography"]',
    '["Video recording equipment", "Audio recorders", "Stopwatch for duration timing", "Historical research materials", "EMF baseline equipment"]',
    'Document multiple occurrences to verify repetition. Time all durations precisely. Compare with historical records. No communication attempts necessary - entities cannot respond. Focus on documentation over interaction.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-006',
    'Intelligent_Haunt',
    'Primary',
    NULL,
    '["Aware of living observers", "Can interact and communicate", "Responds to questions/stimuli", "May show emotional responses", "Can modify behavior", "Often has specific purpose or message"]',
    'Variable - from seconds to extended periods based on energy and intent',
    '3.0-12.0 mG - fluctuates with communication attempts',
    'Dynamic temperature changes responding to interaction',
    '["EVP sessions", "Spirit box communication", "Direct observation", "Real-time EMF correlation", "Trigger object experiments"]',
    '["Resolve unfinished business", "Spiritual cleansing", "Religious intervention", "Compassionate communication", "Helping spirit cross over"]',
    '["Aggressive responses to questions", "Physical interaction attempts", "Possessive behavior toward location/people", "Escalating demands"]',
    '["The Grey Lady (when interactive)", "Captain Morgan", "Bell Witch", "The Headless Horseman"]',
    '["Consciousness survival after death", "Earthbound spirit theory", "Unfinished business anchoring", "Location attachment theory"]',
    '["EVP recorder", "Spirit box", "EMF meter", "Trigger objects", "Thermal camera", "Full spectrum camera", "Communication cards"]',
    'Approach with respect. Establish communication protocol early. Document all responses. Never make promises you cannot keep. Be prepared for emotional interaction. Have cleansing materials available. Team recommended.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-007',
    'Demonic',
    'Primary',
    NULL,
    '["Never human origin", "Extreme malevolence", "Capable of possession", "Superhuman strength manifestation", "Knowledge of hidden things", "Sulfur smell common", "Resistant to standard cleansing"]',
    'Variable - can maintain presence for extended periods',
    '10.0-20.0+ mG - often exceeds equipment capacity',
    'Extreme temperature drops of 20-30°C, sometimes localized heat',
    '["Professional demonologist assessment", "Religious authority evaluation", "Medical and psychological screening first", "EMF monitoring (extreme readings)"]',
    '["Formal exorcism by authorized religious authority", "Extended prayer and fasting", "Blessed objects and holy water", "Complete property blessing", "Potential property abandonment"]',
    '["Speaking in unknown languages", "Knowledge of private information", "Extreme aversion to sacred objects", "Physical attacks", "Possession symptoms", "Three scratch marks", "Inverted crosses"]',
    '["Zozo", "Demon of Brownsville Road", "Annabelle entity", "Sallie House entity"]',
    '["Interdimensional malevolent beings", "Fallen angels (religious view)", "Collective negative thoughtform", "Ancient non-human intelligence"]',
    '["Holy water", "Blessed salt", "Religious artifacts", "High-capacity EMF monitoring", "Medical supplies", "Communication with religious authority"]',
    'DO NOT INVESTIGATE WITHOUT PROFESSIONAL SUPPORT. Requires demonologist or religious authority. Full psychological and medical screening of affected individuals first. Never provoke. Have evacuation plan. Multiple exits. Prayer protection.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-008',
    'Elemental',
    'Primary',
    NULL,
    '["Bound to natural element or location", "Often ancient origin", "May predate humanity", "Territorial behavior", "Connected to ecosystem", "Can be helpful or harmful based on treatment of territory"]',
    'Highly variable - from seconds to continuous presence in territory',
    '0.5-5.0 mG - often shows natural field patterns',
    'Related to associated element (cold for ice, heat for fire, etc.)',
    '["Environmental observation", "Ecosystem health assessment", "Folklore research", "Pattern correlation with natural events", "Indigenous knowledge consultation"]',
    '["Respect for territory and element", "Environmental remediation", "Cultural protocols observation", "Offering and appeasement rituals", "Relocation only as last resort"]',
    '["Environmental destruction in territory", "Direct confrontation behavior", "Weather manipulation", "Animal aggression increase"]',
    '["Yuki-onna", "Green Man of Paviland", "Banshee", "Will-o-wisps", "La Llorona (water-bound)"]',
    '["Nature spirit traditions worldwide", "Genius loci concept", "Ecosystem consciousness", "Gaia hypothesis extensions"]',
    '["Environmental monitoring equipment", "Weather stations", "Wildlife cameras", "Cultural consultants", "Offerings appropriate to tradition"]',
    'Research local folklore and indigenous knowledge first. Approach with respect for environment. Never damage ecosystem. Observe cultural protocols. May require local guide or cultural consultant. Document environmental conditions.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- SECONDARY CLASSIFICATIONS (Subtypes)
-- ============================================================================
(
    'TAX-009',
    'Crisis Apparition',
    'Secondary',
    'Apparition',
    '["Appears at moment of death to loved ones", "Single manifestation event", "Carries message or farewell", "Appears to people with emotional connection", "Typically benevolent"]',
    '5-60 seconds - single occurrence',
    '1.0-3.0 mG - brief spike',
    'Minimal - slight localized cooling',
    '["Witness interview", "Death record correlation", "Timeline verification"]',
    '["No intervention needed", "Message acknowledgment helps", "Grief counseling for witnesses"]',
    '["None - always benevolent", "May cause emotional distress"]',
    '["Lincoln appearing to wife", "Soldier death visions", "Hospital deathbed visitors"]',
    '["Telepathic projection at death", "Soul visiting loved ones", "Crisis-triggered consciousness transfer"]',
    '["Standard documentation equipment", "Interview recording", "Timeline verification tools"]',
    'Focus on witness support. Verify death timing correlation. Document all details for records. No investigation needed at manifestation location. Grief counseling referral if appropriate.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-010',
    'Anniversary Ghost',
    'Secondary',
    'Residual_Haunt',
    '["Manifests on specific date annually", "Tied to traumatic historical event", "Highly predictable", "Cannot deviate from pattern", "Often battle or disaster related"]',
    'Same duration each year - can range from minutes to hours',
    '1.5-4.0 mG - consistent with location',
    'Predictable pattern matching historical event',
    '["Calendar-based observation scheduling", "Historical date research", "Multi-year pattern verification"]',
    '["Cannot be neutralized", "Will continue until energy naturally dissipates", "No intervention recommended"]',
    '["None - pure playback", "Psychological impact on sensitive observers"]',
    '["Edgehill Phantom Army", "Gettysburg Anniversary Manifestations", "Pearl Harbor December 7 phenomena"]',
    '["Temporal imprint theory", "Collective trauma recording", "Anniversary energy amplification"]',
    '["Calendar planning", "Video/audio recording", "Historical documentation comparison"]',
    'Plan investigation for anniversary date. Multiple year documentation preferred. Compare with historical accounts. Focus on documentation not interaction. Share findings with historical societies.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-011',
    'Vengeful Spirit',
    'Secondary',
    'Intelligent_Haunt',
    '["Motivated by injustice or betrayal", "Targets specific individuals or types", "Highly aggressive", "Cannot easily cross over", "Often murder victims"]',
    'Variable - can persist for extended periods when target present',
    '6.0-15.0 mG - spikes during aggression',
    'Rapid temperature drops of 15-25°C during attacks',
    '["Historical injustice research", "Victim identification", "Target pattern analysis", "Genealogy research if family-targeted"]',
    '["Justice resolution if possible", "Formal apology rituals", "Religious intervention", "Descendant reconciliation", "Binding as last resort"]',
    '["Physical attacks", "Pursuit behavior", "Escalating violence", "Possession attempts", "Property damage"]',
    '["Bloody Mary", "La Llorona", "Woman in Black", "Headless Horseman"]',
    '["Unresolved trauma anchoring", "Justice-seeking consciousness", "Emotional energy trapping"]',
    '["Full protective equipment", "Blessed objects", "EMF array", "Thermal monitoring", "Escape route planning"]',
    'Research historical background thoroughly before investigation. Identify source of vengeance. Never provoke. Consider resolution options. Team of experienced investigators only. Have cleansing protocols ready.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-012',
    'Attachment Entity',
    'Secondary',
    'Shadow_Figure',
    '["Attaches to person rather than location", "Follows victim across locations", "Drains energy from host", "May escalate over time", "Often initially invited accidentally"]',
    'Continuous presence with host - varies in intensity',
    '3.0-8.0 mG - consistent around host',
    'Localized cold following host movement',
    '["Host interview", "Location independence testing", "Energy level assessment of host", "Invitation event identification"]',
    '["Spiritual cleansing of person (not location)", "Attachment severance ritual", "Host energy strengthening", "Boundary setting education"]',
    '["Host energy depletion", "Depression/anxiety in host", "Escalating negative events", "Physical symptoms", "Sleep disturbances"]',
    '["Ouija board attachments", "Graveyard attachments", "Occult ritual attachments"]',
    '["Energy parasitism", "Unconscious invitation theory", "Vulnerability exploitation"]',
    '["Personal EMF monitoring", "Energy assessment tools", "Cleansing materials for person", "Follow-up monitoring equipment"]',
    'Focus on host rather than location. Identify attachment origin event. Assess host energy levels. Perform cleansing on person. Follow up over weeks to ensure severance. May require multiple sessions.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-013',
    'Nature Guardian',
    'Secondary',
    'Elemental',
    '["Protects specific natural location", "Benevolent toward respectful visitors", "Hostile to environmental threats", "Often ancient presence", "Connected to indigenous traditions"]',
    'Continuous presence in protected territory',
    '0.3-2.0 mG - natural background levels',
    'Comfortable temperature maintenance in territory',
    '["Indigenous knowledge consultation", "Environmental observation", "Folklore research", "Respectful approach protocols"]',
    '["Not recommended unless truly necessary", "Relocation through cultural protocols", "Environmental restoration"]',
    '["Only hostile if environment threatened", "Warning signs include animal behavior changes", "Weather manipulation possible"]',
    '["Green Man of Paviland", "Mountain spirits", "Forest guardians", "Sacred grove keepers"]',
    '["Collective ecosystem consciousness", "Ancient spirit persistence", "Place-based deity concept"]',
    '["Environmental monitoring", "Cultural protocols guide", "Offerings as appropriate", "Wildlife observation equipment"]',
    'Consult with indigenous knowledge keepers first. Approach with environmental respect. Leave no trace. Make appropriate offerings per tradition. Document any communication. Share findings with cultural authorities.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-014',
    'Death Omen',
    'Secondary',
    'Elemental',
    '["Appears to warn of impending death", "Attached to family line or region", "Cannot be prevented or stopped", "Serves as messenger not cause", "Ancient cultural traditions"]',
    'Variable - from seconds to continuous wailing',
    '1.0-3.0 mG - subtle presence',
    'Slight temperature drop, often accompanied by wind',
    '["Family history research", "Death record correlation", "Cultural tradition study", "Witness interviews over generations"]',
    '["Cannot be neutralized", "Serves necessary function", "Acknowledgment may provide comfort", "Tradition preservation important"]',
    '["Does not cause death", "Psychological preparation function", "May cause fear in uninformed witnesses"]',
    '["Banshee of Irish tradition", "Black dog omens", "White ladies as death heralds"]',
    '["Cultural death preparation function", "Precognitive phenomenon", "Family line psychic connection"]',
    '["Audio recording equipment", "Family genealogy records", "Cultural consultation", "Death record access"]',
    'Research family traditions before investigation. Interview family members about previous occurrences. Document all aspects including sound, appearance, timing. Correlate with death records. Approach as cultural study not elimination.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- HYBRID/SPECIAL CLASSIFICATIONS
-- ============================================================================
(
    'TAX-015',
    'Thoughtform',
    'Special',
    NULL,
    '["Created by collective belief or individual focus", "Can gain independence over time", "Tulpa tradition origin", "May not have been human", "Powered by emotional energy"]',
    'Variable based on energy investment',
    '2.0-8.0 mG - correlates with believer proximity',
    'Minimal physical effects',
    '["Belief pattern analysis", "Creation event identification", "Energy source mapping", "Creator interview if known"]',
    '["Withdrawal of belief energy", "Creator dissolution ritual", "Collective disbelief", "Energy redirection"]',
    '["Potential for independence", "May resist dissolution", "Can influence creators", "Possible hostile evolution"]',
    '["Philip Experiment entity", "Slender Man (modern example)", "Cultural deity thoughtforms"]',
    '["Collective consciousness manifestation", "Psychic energy materialization", "Tulpa tradition"]',
    '["Psychological assessment tools", "Belief pattern documentation", "Standard paranormal equipment"]',
    'Identify creation source and method. Map energy network sustaining entity. Work with creators if possible. Document belief patterns. Dissolution requires addressing root belief system. May need psychological support for creators.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'TAX-016',
    'Portal Entity',
    'Special',
    NULL,
    '["Uses dimensional gateway for access", "May be interdimensional rather than deceased human", "Often associated with specific geographic locations", "Activity correlates with portal opening patterns", "Extremely varied appearance"]',
    'Tied to portal activity cycles',
    'Extreme readings 15+ mG near portal, normal elsewhere',
    'Localized extreme anomalies near portal point',
    '["Geographic pattern analysis", "Portal location identification", "Activity cycle documentation", "Dimensional signature monitoring"]',
    '["Portal sealing rituals", "Geographic barrier installation", "Dimensional blocking", "Sacred geometry protection"]',
    '["Unknown entity capabilities", "Potential for increased activity", "Portal may allow other entities", "Physical reality manipulation possible"]',
    '["Skinwalker Ranch entities", "Dimensional doorway phenomena", "Ley line intersection entities"]',
    '["Interdimensional travel theory", "Parallel universe access points", "Spacetime anomaly hypothesis"]',
    '["Advanced EMF monitoring", "Geographic survey equipment", "Portal detection technology", "Protective barrier materials"]',
    'Map geographic anomaly patterns first. Document portal activity cycles. Avoid direct interaction with unknown entities. Protective barriers essential. Research may require extended multi-year observation. Expert consultation recommended.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
);

-- Verify insert count and hierarchy
SELECT 
    CLASSIFICATION_LEVEL,
    COUNT(*) AS TYPE_COUNT
FROM GHOST_TAXONOMY
GROUP BY CLASSIFICATION_LEVEL
ORDER BY 
    CASE CLASSIFICATION_LEVEL 
        WHEN 'Primary' THEN 1 
        WHEN 'Secondary' THEN 2 
        WHEN 'Special' THEN 3 
    END;

SELECT 
    GHOST_TYPE,
    CLASSIFICATION_LEVEL,
    PARENT_TYPE,
    AVERAGE_EMF_RANGE,
    TEMPERATURE_EFFECT
FROM GHOST_TAXONOMY
ORDER BY 
    CASE CLASSIFICATION_LEVEL 
        WHEN 'Primary' THEN 1 
        WHEN 'Secondary' THEN 2 
        WHEN 'Special' THEN 3 
    END,
    GHOST_TYPE;
