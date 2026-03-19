-- ============================================================================
-- INVESTIGATION SAMPLE DATA
-- SnowGhostBreakers Application
-- Insert 10+ investigations with various statuses and outcomes
-- ============================================================================

USE DATABASE GHOST_DETECTION;
USE SCHEMA APP;

-- Clear existing data (optional - comment out for production)
-- TRUNCATE TABLE INVESTIGATIONS;

INSERT INTO INVESTIGATIONS (
    INVESTIGATION_ID,
    INVESTIGATION_NAME,
    GHOST_ID,
    PRIMARY_SIGHTING_ID,
    STATUS,
    PRIORITY,
    START_DATE,
    END_DATE,
    LEAD_INVESTIGATOR,
    TEAM_MEMBERS,
    OBJECTIVE,
    METHODOLOGY,
    FINDINGS_SUMMARY,
    OUTCOME,
    RECOMMENDATIONS,
    BUDGET_USD,
    ACTUAL_COST_USD,
    RISK_ASSESSMENT,
    CREATED_AT,
    UPDATED_AT
)
VALUES
-- ============================================================================
-- ACTIVE INVESTIGATIONS
-- ============================================================================
(
    'INV-001',
    'Operation Grey Mist',
    'GHOST-001',
    'SIGHT-001',
    'In_Progress',
    'High',
    '2024-01-20',
    NULL,
    'Dr. Sarah Mitchell',
    '["Dr. Sarah Mitchell", "James O''Connor", "Emily Blackwood", "Technical Specialist Chen Wei"]',
    'Document and establish communication protocol with the Grey Lady of Willowmere Manor. Determine if entity has specific message or unfinished business that can be resolved.',
    'Extended observation periods during peak manifestation windows. Multi-spectrum photography, EVP sessions, historical research into Lady Elizabeth Ashworth. Non-aggressive interaction attempts.',
    'Entity appears intelligent and aware of investigators. Has made eye contact on multiple occasions. Manifestation patterns correlate with historical events from Lady Ashworths life. Evidence suggests she awaits specific event or person.',
    NULL,
    NULL,
    45000.00,
    32500.00,
    'Low risk - entity has never shown aggression. Team maintains respectful distance and avoids provocation.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'INV-002',
    'Operation Dark Mirror',
    'GHOST-002',
    'SIGHT-005',
    'In_Progress',
    'Extreme',
    '2024-08-01',
    NULL,
    'Dr. Elizabeth Warren',
    '["Dr. Elizabeth Warren", "Father Marcus Reid", "Isabella Chen", "Security Officer Tom Bradley", "Medical Officer Dr. Nina Patel"]',
    'Develop containment protocols for Bloody Mary manifestations. Create early warning system for summoning attempts. Establish emergency response procedures.',
    'Controlled summoning experiments under maximum safety protocols. Mirror surface analysis. Development of protective barrier methodologies. Training program for first responders.',
    'Manifestation confirmed responsive to mirror surface area and lighting conditions. Protective salt circles provide 73% reduction in scratch incidents. Silver-backed mirrors show 40% reduced manifestation strength.',
    NULL,
    NULL,
    150000.00,
    98750.00,
    'Extreme risk - entity capable of physical harm. All sessions require medical standby. Multiple exorcism-trained personnel required on site.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'INV-003',
    'Operation Frozen Tears',
    'GHOST-020',
    'SIGHT-017',
    'Open',
    'High',
    '2024-09-20',
    NULL,
    'Detective Maria Santos',
    '["Detective Maria Santos", "Cultural Advisor Rosa Martinez", "Child Safety Specialist Dr. Angela Cruz"]',
    'Map La Llorona activity zones across Texas-Mexico border region. Establish child safety protocols for high-risk areas. Document cultural variations in manifestation reports.',
    'Collaboration with local communities. Installation of monitoring equipment along waterways. Child safety awareness campaigns. Interview program with historical witnesses.',
    'Preliminary findings identify 12 high-risk waterway locations. Activity peaks during anniversaries of child drowning incidents in area. Entity appears drawn to children near water after dark.',
    NULL,
    NULL,
    75000.00,
    28000.00,
    'High risk to children near water at night. Public safety advisories issued. Coordination with local law enforcement ongoing.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- CLOSED INVESTIGATIONS - SUCCESSFUL
-- ============================================================================
(
    'INV-004',
    'Operation Rosenheim Residual',
    'GHOST-005',
    'SIGHT-035',
    'Closed',
    'Medium',
    '2024-05-01',
    '2024-06-30',
    'Dr. Hans Weber',
    '["Dr. Hans Weber", "Electrical Engineer Markus Schmidt", "Archivist Helga Braun"]',
    'Investigate residual poltergeist activity at former Rosenheim law office. Determine if original focus person connection still exists. Assess current threat level.',
    'EMF monitoring grid installation. Historical document analysis. Interview with surviving witnesses from 1967. Comparison with original investigation files.',
    'Activity confirmed at 15% of original 1967 levels. No focus person required for current manifestations - energy appears imprinted in location. Electrical systems show predictable interference patterns.',
    'Entity successfully contained through location-based protocols. Activity poses minimal risk to current museum operation. Regular monitoring schedule established.',
    'Continue quarterly monitoring. Maintain Faraday shielding around sensitive electronics. Document any activity changes for long-term study.',
    35000.00,
    31200.00,
    'Low risk - residual energy only. No intelligent interaction capability. Contained.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'INV-005',
    'Operation Bell Silence',
    'GHOST-004',
    'SIGHT-007',
    'Closed',
    'Extreme',
    '2024-07-01',
    '2024-09-15',
    'Robert Bell Jr.',
    '["Robert Bell Jr.", "Dr. Amanda Torres", "Paranormal Investigator Mike Chen", "Demonologist Father William O''Malley", "Historian Dr. Patricia Adams"]',
    'Assess current Bell Witch activity levels. Determine if entity aggression has increased. Develop updated safety protocols for Bell family descendants.',
    'Multi-week on-site investigation. EVP analysis. Physical manifestation documentation. Historical research correlation. Family history interviews.',
    'Bell Witch activity confirmed at highest levels since 1821. Entity demonstrates specific interest in Bell family descendants. Physical attacks documented. EVP communications hostile.',
    'Investigation concluded with updated threat assessment. Bell family descendants advised to avoid property. Warning system established. Demonologist blessing performed.',
    'Annual property inspection recommended. Bell family descendants should not visit alone. Emergency response protocol distributed to local authorities.',
    125000.00,
    142000.00,
    'Extreme risk - entity actively hostile to Bell family members. Physical attacks documented. Do not approach without demonologist support.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'INV-006',
    'Operation Enfield Echo',
    'GHOST-006',
    'SIGHT-024',
    'Closed',
    'Medium',
    '2024-08-15',
    '2024-09-30',
    'BBC Documentary Crew',
    '["BBC Documentary Team", "SPR Representative Dr. Paul Wilson", "Original Witness Janet Hodgson-Burrows", "Sound Engineer David Thompson"]',
    'Document residual Enfield Poltergeist activity for 45th anniversary documentary. Compare current activity with original 1977-78 investigation records.',
    'Recreation of original investigation protocols. Modern equipment deployment in original locations. Interview with surviving witnesses. Archive footage comparison.',
    'Residual activity confirmed at approximately 8% of original intensity. Knocking patterns match 1977 recordings exactly. Voice phenomena captured matching Janet Hodgson childhood voice.',
    'Documentary completed successfully. Activity documented as residual/imprint rather than active haunting. Entity appears to have moved on with Janet Hodgson focus person now adult.',
    'Maintain historical record. Annual monitoring recommended around anniversary dates. Property suitable for public visits with minimal precautions.',
    50000.00,
    48500.00,
    'Low risk - residual activity only. Original poltergeist attachment appears resolved with focus person maturation.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- CLOSED INVESTIGATIONS - CONTAINMENT SUCCESS
-- ============================================================================
(
    'INV-007',
    'Operation Brownsville Binding',
    'GHOST-015',
    'SIGHT-031',
    'Closed',
    'Extreme',
    '2024-01-01',
    '2024-02-28',
    'Father Thomas Maloney',
    '["Father Thomas Maloney", "Bishop Robert Donovan", "Demonologist Dr. Vincent Price III", "Structural Engineer Maria Santos", "Security Coordinator Frank Morrison"]',
    'Verify containment status of Brownsville Road demonic entity. Refresh binding protocols. Assess structural integrity of containment measures.',
    'Full exorcism ritual renewal. Blessed salt barrier replacement. Structural inspection of sealed areas. EMF monitoring during ritual. Thermal surveillance.',
    'Containment verified as holding. Entity responded to ritual with manifestation but could not breach barriers. Binding shows expected degradation - renewal successful.',
    'Containment successfully renewed for minimum 5-year period. Property remains sealed. Entity bound but not banished. Eternal vigilance required.',
    'Containment renewal required every 5 years maximum. Property must never be demolished - would release entity. Diocese maintains responsibility.',
    200000.00,
    187500.00,
    'Extreme risk - powerful demonic entity. Containment holding but entity remains present and hostile. Property condemned. Do not enter.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- ARCHIVED INVESTIGATIONS
-- ============================================================================
(
    'INV-008',
    'Operation Gettysburg Memorial',
    'GHOST-009',
    'SIGHT-018',
    'Archived',
    'Low',
    '2024-06-15',
    '2024-07-15',
    'Dr. Howard Lawrence',
    '["Dr. Howard Lawrence", "Angela Patterson", "National Park Service Liaison", "Civil War Historian Dr. James McPherson"]',
    'Annual documentation of Gettysburg orb activity during battle anniversary period. Contribute to long-term paranormal climate study.',
    'Multi-site monitoring across battlefield. Photography stations. Audio recording for battle sounds. Thermal imaging. Visitor experience documentation.',
    'Record-breaking orb activity documented - 47 distinct manifestations in single night. Battle sound phenomena captured. Formation patterns match historical troop positions.',
    'Annual documentation completed. Data added to 50-year longitudinal study. No threat identified. Activity classified as benevolent residual.',
    'Continue annual monitoring. Data valuable for understanding residual haunt phenomena. No intervention recommended - site serves as memorial.',
    25000.00,
    23800.00,
    'No risk - benevolent residual energy. Orbs show no awareness or interaction capability. Site is peaceful and suitable for public visits.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'INV-009',
    'Operation Tower Guard',
    'GHOST-011',
    'SIGHT-030',
    'Archived',
    'Low',
    '2024-08-20',
    '2024-09-20',
    'Yeoman Warder Thomas Brooks',
    '["Yeoman Warder Thomas Brooks", "Historic Royal Palaces Representative", "SPR Consultant Dr. Margaret Jones"]',
    'Document Tower Princes manifestation for historical archive. Verify 47-second duration consistency. Update visitor information.',
    'Overnight observation during known manifestation dates. Duration timing. Photography attempts. Historical record comparison.',
    'Manifestation duration confirmed at exactly 47 seconds - consistent across 350 years of records. Stone tape phenomenon hypothesis supported. No variation in manifestation details.',
    'Documentation completed. Manifestation classified as pure residual - no intelligence, no interaction, no threat. Historical mystery persists but paranormal aspects understood.',
    'No intervention possible or recommended. Stone tape will naturally fade over geological time. Site appropriate for continued public access.',
    15000.00,
    14200.00,
    'No risk - pure residual playback. Entities show no awareness. Duration is finite and predictable. Suitable for public tours.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'INV-010',
    'Operation Captain''s Warning',
    'GHOST-014',
    'SIGHT-026',
    'Archived',
    'Low',
    '2024-07-01',
    '2024-08-01',
    'Lieutenant Sarah Briggs',
    '["Lieutenant Sarah Briggs", "USCG Historian", "Maritime Paranormal Researcher Dr. David Chen"]',
    'Document protective ghost phenomena at Cape Hatteras. Verify warning pattern accuracy. Assess Coast Guard response protocols.',
    'Maritime patrol observation. Historical storm data correlation. Interview with mariners who received warnings. Weather prediction accuracy assessment.',
    'Captain Morgan manifestations correlate 100% with approaching severe weather. Average warning time 4-8 hours before storm arrival. No false positives documented in modern era.',
    'Entity classified as beneficial protective spirit. Warning accuracy superior to contemporary weather forecasting in some cases. No intervention recommended.',
    'Document all sightings. Treat warnings as supplementary weather advisory. No negative interaction protocols needed - entity is helpful.',
    20000.00,
    18500.00,
    'No risk - benevolent protective entity. Appears only to warn of danger. Has never harmed anyone. Beneficial presence.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),

-- ============================================================================
-- ADDITIONAL INVESTIGATIONS
-- ============================================================================
(
    'INV-011',
    'Operation Snow Maiden',
    'GHOST-018',
    'SIGHT-014',
    'In_Progress',
    'High',
    '2024-11-01',
    NULL,
    'Dr. Kenji Nakamura',
    '["Dr. Kenji Nakamura", "Mountain Rescue Specialist Yuki Tanaka", "Folklore Expert Dr. Aiko Sato", "Thermal Imaging Specialist Hiroshi Yamamoto"]',
    'Map Yuki-onna activity zones on Mount Fuji region. Develop winter hiker safety protocols. Document entity behavioral patterns.',
    'Winter observation posts. Thermal monitoring. Hiker interview program. Collaboration with mountain rescue services. Folklore correlation study.',
    'Activity confirmed in 8 distinct zones above 2000m elevation. Entity appears exclusively during blizzard conditions. Some encounters fatal, others result in rescue guidance. Pattern unclear.',
    NULL,
    NULL,
    85000.00,
    45000.00,
    'High risk - entity capable of causing death through hypothermia or luring. However, some evidence of protective behavior exists. Unpredictable.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'INV-012',
    'Operation Horseman''s Hollow',
    'GHOST-013',
    'SIGHT-012',
    'In_Progress',
    'High',
    '2024-10-15',
    NULL,
    'Dr. William Van Tassel',
    '["Dr. William Van Tassel", "Police Liaison Officer Patricia Moore", "Special Effects Analyst Jake Reynolds", "Historical Society Representative"]',
    'Comprehensive documentation of Headless Horseman activity. Determine safe observation protocols. Develop tourist safety guidelines for October season.',
    'Road monitoring during peak hours. Thermal and visual recording stations. Bridge crossing analysis. Pumpkin projectile collection. Historical research.',
    'Entity activity peaks October 25-31. Confirmed aggression toward travelers on specific road section. Bridge crossing terminates pursuit. Flaming projectiles cause real burns.',
    NULL,
    NULL,
    95000.00,
    78000.00,
    'High risk during October. Entity actively pursues travelers. Burns documented from projectiles. Road closure recommended during peak manifestation hours.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
),
(
    'INV-013',
    'Operation Shadow Hunt',
    'GHOST-007',
    'SIGHT-010',
    'Open',
    'Medium',
    '2024-09-01',
    NULL,
    'Sleep Research Institute',
    '["Dr. Michael Torres - Sleep Researcher", "Dr. Amanda Chen - Parapsychologist", "Statistical Analyst David Kim", "Field Investigator Network - 50 volunteers"]',
    'Global study of Hat Man phenomenon. Correlate sightings with sleep paralysis. Determine if single entity or multiple manifestations.',
    'Sleep study participant interviews. Global sighting database development. Sleep lab monitoring. EMF correlation studies. Pattern analysis.',
    'Preliminary data suggests single entity or connected consciousness. Sightings span every continent. Strong correlation with sleep paralysis but 12% occur during full wakefulness.',
    NULL,
    NULL,
    250000.00,
    120000.00,
    'Medium risk - entity causes psychological distress but no documented physical harm. Exposure typically brief. Long-term effects under study.',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
);

-- Verify insert count and distribution
SELECT 
    STATUS,
    PRIORITY,
    COUNT(*) AS INVESTIGATION_COUNT
FROM INVESTIGATIONS
GROUP BY STATUS, PRIORITY
ORDER BY STATUS, PRIORITY;

SELECT 
    INVESTIGATION_NAME,
    LEAD_INVESTIGATOR,
    STATUS,
    BUDGET_USD,
    ACTUAL_COST_USD,
    CASE WHEN ACTUAL_COST_USD IS NOT NULL 
         THEN ROUND((ACTUAL_COST_USD / BUDGET_USD) * 100, 1) 
         ELSE NULL END AS BUDGET_UTILIZATION_PCT
FROM INVESTIGATIONS
ORDER BY START_DATE DESC;
