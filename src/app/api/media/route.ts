import { NextResponse } from 'next/server';
import { getConnection, executeQuery } from '@/lib/snowflake';

export const dynamic = 'force-dynamic';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type'); // audio, image, video, all
    const limit = Math.min(Number(searchParams.get('limit') || 50), 200);
    const offset = Number(searchParams.get('offset') || 0);

    const conn = await getConnection();
    const results: any[] = [];

    // Spirit Box audio recordings
    if (!type || type === 'all' || type === 'audio') {
      const audio = await executeQuery(conn, `
        SELECT 
          RECORDING_ID AS ID, FILE_NAME, 'audio' AS MEDIA_TYPE,
          LOCATION_NAME, RECORDING_DATETIME AS CREATED_DATE,
          CLASSIFICATION_RESULT, SENTIMENT_SCORE, ANOMALY_DETECTED,
          AI_SUMMARY AS SUMMARY, PROCESSING_STATUS AS STATUS,
          FILE_SIZE_BYTES, MIME_TYPE, AUDIO_DURATION_SECONDS
        FROM GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS
        ORDER BY CREATED_AT DESC
        LIMIT ${limit} OFFSET ${offset}
      `);
      audio.forEach((r: any) => results.push({
        id: r.ID, file_name: r.FILE_NAME, media_type: 'audio',
        location: r.LOCATION_NAME, date: r.CREATED_DATE,
        classification: r.CLASSIFICATION_RESULT,
        sentiment: r.SENTIMENT_SCORE != null ? Number(r.SENTIMENT_SCORE) : null,
        anomaly: r.ANOMALY_DETECTED === true,
        summary: r.SUMMARY || '', status: r.STATUS,
        file_size: r.FILE_SIZE_BYTES ? Number(r.FILE_SIZE_BYTES) : null,
        mime_type: r.MIME_TYPE, duration: r.AUDIO_DURATION_SECONDS ? Number(r.AUDIO_DURATION_SECONDS) : null,
      }));
    }

    // Ghost evidence (images/video/documents)
    if (!type || type === 'all' || type === 'image' || type === 'video') {
      const evidenceType = type === 'image' ? "AND EVIDENCE_TYPE IN ('Photo', 'Image', 'image', 'photo')"
        : type === 'video' ? "AND EVIDENCE_TYPE IN ('Video', 'video')"
        : '';
      const evidence = await executeQuery(conn, `
        SELECT 
          EVIDENCE_ID AS ID, FILE_NAME,
          CASE 
            WHEN EVIDENCE_TYPE IN ('Photo', 'Image', 'image', 'photo') THEN 'image'
            WHEN EVIDENCE_TYPE IN ('Video', 'video') THEN 'video'
            ELSE 'document'
          END AS MEDIA_TYPE,
          e.DESCRIPTION AS SUMMARY,
          e.UPLOAD_DATE AS CREATED_DATE,
          e.FILE_SIZE,
          s.LOCATION AS LOCATION_NAME,
          s.SIGHTING_DATE
        FROM GHOST_DETECTION.APP.GHOST_EVIDENCE e
        LEFT JOIN GHOST_DETECTION.APP.GHOST_SIGHTINGS s ON e.SIGHTING_ID = s.SIGHTING_ID
        WHERE 1=1 ${evidenceType}
        ORDER BY e.UPLOAD_DATE DESC
        LIMIT ${limit} OFFSET ${offset}
      `);
      evidence.forEach((r: any) => results.push({
        id: r.ID, file_name: r.FILE_NAME, media_type: r.MEDIA_TYPE,
        location: r.LOCATION_NAME || '', date: r.CREATED_DATE || r.SIGHTING_DATE,
        classification: null, sentiment: null, anomaly: false,
        summary: r.SUMMARY || '', status: 'Available',
        file_size: r.FILE_SIZE ? Number(r.FILE_SIZE) : null,
        mime_type: null, duration: null,
      }));
    }

    // Get counts
    const counts = await executeQuery(conn, `
      SELECT 
        (SELECT COUNT(*) FROM GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS) AS AUDIO_COUNT,
        (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOST_EVIDENCE) AS EVIDENCE_COUNT,
        (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOSTS) AS GHOST_COUNT,
        (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS) AS SIGHTING_COUNT
    `);

    conn.destroy(() => {});

    return NextResponse.json({
      media: results,
      stats: {
        audio_count: Number(counts[0]?.AUDIO_COUNT || 0),
        evidence_count: Number(counts[0]?.EVIDENCE_COUNT || 0),
        ghost_count: Number(counts[0]?.GHOST_COUNT || 0),
        sighting_count: Number(counts[0]?.SIGHTING_COUNT || 0),
        total: results.length,
      },
    });
  } catch (error: any) {
    console.error('Media list error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
