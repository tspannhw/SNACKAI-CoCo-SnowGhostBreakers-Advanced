import { NextResponse } from 'next/server';
import { getConnection, executeQuery } from '@/lib/snowflake';

export const dynamic = 'force-dynamic';

export async function GET(_request: Request, { params }: { params: { id: string } }) {
  try {
    const id = params.id;
    const conn = await getConnection();

    const rows = await executeQuery(conn, `
      SELECT
        s.SIGHTING_ID, s.GHOST_ID, s.LOCATION_NAME, s.LOCATION_ADDRESS,
        s.LATITUDE, s.LONGITUDE, s.SIGHTING_DATETIME,
        s.WITNESS_NAME, s.WITNESS_CONTACT, s.ENVIRONMENTAL_CONDITIONS,
        s.TEMPERATURE_CELSIUS, s.EMF_READING, s.DESCRIPTION AS SIGHTING_DESCRIPTION,
        s.EVIDENCE_TYPE, s.PARANORMAL_ACTIVITY_LEVEL, s.INVESTIGATION_NOTES,
        s.VERIFIED, s.CREATED_AT AS SIGHTING_CREATED_AT,
        g.GHOST_NAME, g.GHOST_TYPE, g.THREAT_LEVEL, g.DESCRIPTION AS GHOST_DESCRIPTION,
        g.MANIFESTATION_FREQUENCY, g.ORIGIN_STORY, g.FIRST_DETECTED_DATE,
        g.LAST_SEEN_DATE, g.STATUS, g.CONFIDENCE_SCORE
      FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
      JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
      WHERE s.SIGHTING_ID = '${id.replace(/'/g, "''")}'
      LIMIT 1
    `);

    conn.destroy(() => {});

    if (!rows.length) {
      return NextResponse.json({ error: 'Sighting not found' }, { status: 404 });
    }

    const r = rows[0] as any;
    return NextResponse.json({
      sighting: {
        id: r.SIGHTING_ID,
        ghost_id: r.GHOST_ID,
        location: r.LOCATION_NAME,
        address: r.LOCATION_ADDRESS || '',
        lat: Number(r.LATITUDE),
        lng: Number(r.LONGITUDE),
        datetime: r.SIGHTING_DATETIME,
        witness_name: r.WITNESS_NAME || '',
        witness_contact: r.WITNESS_CONTACT || '',
        environmental_conditions: r.ENVIRONMENTAL_CONDITIONS || '',
        temperature: r.TEMPERATURE_CELSIUS != null ? Number(r.TEMPERATURE_CELSIUS) : null,
        emf_reading: r.EMF_READING != null ? Number(r.EMF_READING) : null,
        description: r.SIGHTING_DESCRIPTION || '',
        evidence_type: r.EVIDENCE_TYPE || '',
        activity_level: r.PARANORMAL_ACTIVITY_LEVEL != null ? Number(r.PARANORMAL_ACTIVITY_LEVEL) : null,
        investigation_notes: r.INVESTIGATION_NOTES || '',
        verified: r.VERIFIED === true || r.VERIFIED === 'true',
        created_at: r.SIGHTING_CREATED_AT,
      },
      ghost: {
        id: r.GHOST_ID,
        name: r.GHOST_NAME,
        type: r.GHOST_TYPE,
        threat_level: r.THREAT_LEVEL,
        description: r.GHOST_DESCRIPTION || '',
        manifestation_frequency: r.MANIFESTATION_FREQUENCY || '',
        origin_story: r.ORIGIN_STORY || '',
        first_detected: r.FIRST_DETECTED_DATE,
        last_seen: r.LAST_SEEN_DATE,
        status: r.STATUS || '',
        confidence_score: r.CONFIDENCE_SCORE != null ? Number(r.CONFIDENCE_SCORE) : null,
      },
    });
  } catch (error: any) {
    console.error('Sighting detail API error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
