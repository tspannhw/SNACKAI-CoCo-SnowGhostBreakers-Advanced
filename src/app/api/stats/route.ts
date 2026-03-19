import { NextResponse } from 'next/server';
import { getConnection, executeQuery } from '@/lib/snowflake';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    const conn = await getConnection();

    const [totals, byType, byThreat, recent] = await Promise.all([
      executeQuery(conn, `
        SELECT
          (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOSTS) AS total_entities,
          (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS) AS total_sightings,
          (SELECT COUNT(DISTINCT LOCATION_NAME) FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS) AS hotspots,
          (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
           JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
           WHERE g.THREAT_LEVEL = 'Extreme') AS extreme_threats
      `),
      executeQuery(conn, `
        SELECT g.GHOST_TYPE, COUNT(*) AS cnt
        FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
        JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
        GROUP BY g.GHOST_TYPE ORDER BY cnt DESC
      `),
      executeQuery(conn, `
        SELECT g.THREAT_LEVEL, COUNT(*) AS cnt
        FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
        JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
        GROUP BY g.THREAT_LEVEL
      `),
      executeQuery(conn, `
        SELECT s.SIGHTING_ID, g.GHOST_NAME, g.GHOST_TYPE, s.LOCATION_NAME,
               g.THREAT_LEVEL, s.SIGHTING_DATETIME
        FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS s
        JOIN GHOST_DETECTION.APP.GHOSTS g ON s.GHOST_ID = g.GHOST_ID
        ORDER BY s.SIGHTING_DATETIME DESC
        LIMIT 10
      `),
    ]);

    conn.destroy(() => {});

    const totalSightings = Number(totals[0]?.TOTAL_SIGHTINGS || 0);
    const breakdown = byType.map((r: any) => ({
      type: r.GHOST_TYPE,
      count: Number(r.CNT),
      pct: Math.round((Number(r.CNT) / totalSightings) * 100),
    }));

    return NextResponse.json({
      total_entities: Number(totals[0]?.TOTAL_ENTITIES || 0),
      total_sightings: totalSightings,
      hotspots: Number(totals[0]?.HOTSPOTS || 0),
      extreme_threats: Number(totals[0]?.EXTREME_THREATS || 0),
      by_type: breakdown,
      by_threat: byThreat.map((r: any) => ({ level: r.THREAT_LEVEL, count: Number(r.CNT) })),
      recent: recent.map((r: any) => ({
        id: r.SIGHTING_ID,
        entity: r.GHOST_NAME,
        type: r.GHOST_TYPE,
        location: r.LOCATION_NAME,
        threat: r.THREAT_LEVEL,
        datetime: r.SIGHTING_DATETIME,
      })),
    });
  } catch (error: any) {
    console.error('Stats API error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
