import { NextResponse } from 'next/server';
import { getConnection, executeQuery } from '@/lib/snowflake';

export const dynamic = 'force-dynamic';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type') || 'All';
    const threat = searchParams.get('threat') || 'All';
    const limit = Math.min(Number(searchParams.get('limit') || 500), 2000);

    let where = '';
    const conditions: string[] = [];
    if (type !== 'All') conditions.push(`g.GHOST_TYPE = '${type.replace(/'/g, "''")}'`);
    if (threat !== 'All') conditions.push(`g.THREAT_LEVEL = '${threat.replace(/'/g, "''")}'`);
    if (conditions.length > 0) where = 'WHERE ' + conditions.join(' AND ');

    const conn = await getConnection();

    const [sightings, types] = await Promise.all([
      executeQuery(conn, `
        SELECT s.SIGHTING_ID, g.GHOST_NAME, g.GHOST_TYPE, s.LOCATION_NAME,
               s.LATITUDE, s.LONGITUDE, g.THREAT_LEVEL, s.SIGHTING_DATETIME,
               s.DESCRIPTION
        FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
        JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
        ${where}
        ORDER BY s.SIGHTING_DATETIME DESC
        LIMIT ${limit}
      `),
      executeQuery(conn, `
        SELECT DISTINCT g.GHOST_TYPE
        FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
        JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
        ORDER BY g.GHOST_TYPE
      `),
    ]);

    conn.destroy(() => {});

    return NextResponse.json({
      sightings: sightings.map((r: any) => ({
        id: r.SIGHTING_ID,
        entity: r.GHOST_NAME,
        type: r.GHOST_TYPE,
        location: r.LOCATION_NAME,
        lat: Number(r.LATITUDE),
        lng: Number(r.LONGITUDE),
        threat: r.THREAT_LEVEL,
        date: r.SIGHTING_DATETIME ? new Date(r.SIGHTING_DATETIME).toISOString().split('T')[0] : '',
        description: r.DESCRIPTION || '',
      })),
      types: types.map((r: any) => r.GHOST_TYPE),
    });
  } catch (error: any) {
    console.error('Sightings API error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
