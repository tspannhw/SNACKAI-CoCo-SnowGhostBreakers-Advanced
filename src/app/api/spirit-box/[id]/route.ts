import { NextResponse } from 'next/server';
import { getConnection, executeQuery } from '@/lib/snowflake';

export const dynamic = 'force-dynamic';

export async function GET(_request: Request, { params }: { params: { id: string } }) {
  try {
    const id = params.id;
    const conn = await getConnection();

    const rows = await executeQuery(conn, `
      SELECT
        r.RECORDING_ID, r.SIGHTING_ID, r.GHOST_ID,
        r.FILE_NAME, r.STAGE_PATH, r.FILE_SIZE_BYTES, r.MIME_TYPE,
        r.DURATION_SECONDS, r.RECORDING_DATETIME,
        r.LOCATION_NAME, r.LATITUDE, r.LONGITUDE,
        r.FREQUENCY_MHZ, r.SWEEP_RATE, r.DEVICE_MODEL,
        r.AUDIO_TRANSCRIPT, r.AI_SUMMARY,
        r.AUDIO_DURATION_SECONDS, r.SPEAKER_SEGMENTS,
        r.EXTRACTED_ENTITIES, r.SENTIMENT_SCORE,
        r.CLASSIFICATION_RESULT, r.ANOMALY_DETECTED,
        r.ANOMALY_DESCRIPTION, r.PROCESSING_STATUS,
        r.PROCESSING_DURATION_MS, r.ERROR_MESSAGE,
        r.PROCESSED_AT, r.CREATED_AT,
        g.GHOST_NAME, g.GHOST_TYPE, g.THREAT_LEVEL
      FROM GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS r
      LEFT JOIN GHOST_DETECTION.APP.GHOSTS g ON r.GHOST_ID = g.GHOST_ID
      WHERE r.RECORDING_ID = '${id.replace(/'/g, "''")}'
      LIMIT 1
    `);

    conn.destroy(() => {});

    if (!rows.length) {
      return NextResponse.json({ error: 'Recording not found' }, { status: 404 });
    }

    const r = rows[0] as any;
    return NextResponse.json({
      recording: {
        id: r.RECORDING_ID,
        sighting_id: r.SIGHTING_ID,
        ghost_id: r.GHOST_ID,
        file_name: r.FILE_NAME,
        stage_path: r.STAGE_PATH,
        file_size: r.FILE_SIZE_BYTES ? Number(r.FILE_SIZE_BYTES) : null,
        mime_type: r.MIME_TYPE,
        duration_seconds: r.DURATION_SECONDS ? Number(r.DURATION_SECONDS) : null,
        datetime: r.RECORDING_DATETIME,
        location: r.LOCATION_NAME,
        lat: r.LATITUDE != null ? Number(r.LATITUDE) : null,
        lng: r.LONGITUDE != null ? Number(r.LONGITUDE) : null,
        frequency_mhz: r.FREQUENCY_MHZ ? Number(r.FREQUENCY_MHZ) : null,
        sweep_rate: r.SWEEP_RATE,
        device_model: r.DEVICE_MODEL,
        transcript: r.AUDIO_TRANSCRIPT || '',
        audio_duration_seconds: r.AUDIO_DURATION_SECONDS ? Number(r.AUDIO_DURATION_SECONDS) : null,
        speaker_segments: r.SPEAKER_SEGMENTS || [],
        summary: r.AI_SUMMARY || '',
        entities: r.EXTRACTED_ENTITIES || [],
        sentiment: r.SENTIMENT_SCORE != null ? Number(r.SENTIMENT_SCORE) : null,
        classification: r.CLASSIFICATION_RESULT || '',
        anomaly_detected: r.ANOMALY_DETECTED === true || r.ANOMALY_DETECTED === 'true',
        anomaly_description: r.ANOMALY_DESCRIPTION || '',
        status: r.PROCESSING_STATUS,
        processing_ms: r.PROCESSING_DURATION_MS ? Number(r.PROCESSING_DURATION_MS) : null,
        error: r.ERROR_MESSAGE || '',
        processed_at: r.PROCESSED_AT,
        created_at: r.CREATED_AT,
      },
      ghost: r.GHOST_NAME ? {
        id: r.GHOST_ID,
        name: r.GHOST_NAME,
        type: r.GHOST_TYPE,
        threat_level: r.THREAT_LEVEL,
      } : null,
    });
  } catch (error: any) {
    console.error('Spirit Box detail error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
