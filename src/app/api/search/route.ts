import { NextResponse } from 'next/server';
import { getConnection, executeQuery } from '@/lib/snowflake';

export const dynamic = 'force-dynamic';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { query, limit = 10, filter = {} } = body;

    if (!query || typeof query !== 'string') {
      return NextResponse.json({ error: 'Query string is required' }, { status: 400 });
    }

    const conn = await getConnection();

    // Build filter object for Cortex Search
    const filterParts: Record<string, any> = {};
    if (filter.location) filterParts['@eq'] = { LOCATION_NAME: filter.location };
    if (filter.classification) filterParts['@eq'] = { ...filterParts['@eq'], CLASSIFICATION_RESULT: filter.classification };
    if (filter.anomaly !== undefined) filterParts['@eq'] = { ...filterParts['@eq'], ANOMALY_DETECTED: filter.anomaly };

    const filterClause = Object.keys(filterParts).length > 0 
      ? `, 'filter': ${JSON.stringify(filterParts).replace(/'/g, "''")}`
      : '';

    const results = await executeQuery(conn, `
      SELECT PARSE_JSON(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
          'GHOST_DETECTION.APP.SPIRIT_BOX_SEARCH',
          '${query.replace(/'/g, "''")}',
          ${Math.min(limit, 50)}
        )
      ) AS results
    `);

    conn.destroy(() => {});

    const parsed = results[0]?.RESULTS;
    const searchResults = typeof parsed === 'string' ? JSON.parse(parsed) : (parsed || { results: [] });

    return NextResponse.json({
      query,
      results: searchResults.results || [],
      count: (searchResults.results || []).length,
    });
  } catch (error: any) {
    console.error('Search error:', error);
    // If Cortex Search is suspended, fall back to LIKE search
    if (error.message?.includes('suspended') || error.message?.includes('SEARCH_PREVIEW')) {
      try {
        const conn = await getConnection();
        const fallback = await executeQuery(conn, `
          SELECT RECORDING_ID, FILE_NAME, LOCATION_NAME, SEARCHABLE_TEXT,
                 CLASSIFICATION_RESULT, AI_SUMMARY
          FROM GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS
          WHERE SEARCHABLE_TEXT ILIKE '%${(request as any)._query || ''}%'
          LIMIT 10
        `);
        conn.destroy(() => {});
        return NextResponse.json({
          query: 'fallback',
          results: fallback.map((r: any) => ({
            RECORDING_ID: r.RECORDING_ID,
            FILE_NAME: r.FILE_NAME,
            LOCATION_NAME: r.LOCATION_NAME,
            SEARCHABLE_TEXT: r.SEARCHABLE_TEXT?.substring(0, 200),
            CLASSIFICATION_RESULT: r.CLASSIFICATION_RESULT,
            AI_SUMMARY: r.AI_SUMMARY,
          })),
          count: fallback.length,
          fallback: true,
        });
      } catch {
        return NextResponse.json({ error: error.message }, { status: 500 });
      }
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
