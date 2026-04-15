import { NextResponse } from 'next/server';
import { getConnection, executeQuery, putFileToStage } from '@/lib/snowflake';
import { spiritBoxUploadSchema } from '@/lib/validation';
import { writeFile, unlink } from 'fs/promises';
import { join } from 'path';
import { tmpdir } from 'os';
import { v4 as uuidv4 } from 'uuid';

export const dynamic = 'force-dynamic';

export async function POST(request: Request) {
  let tempPath = '';
  try {
    const formData = await request.formData();
    const audioFile = formData.get('audio') as File | null;

    if (!audioFile) {
      return NextResponse.json({ success: false, error: 'Audio file is required' }, { status: 400 });
    }

    const allowedTypes = ['audio/wav', 'audio/mpeg', 'audio/ogg', 'audio/mp4', 'audio/x-m4a', 'audio/flac', 'audio/x-wav', 'audio/mp3'];
    if (!allowedTypes.some(t => audioFile.type.startsWith('audio/') || audioFile.name.match(/\.(wav|mp3|ogg|m4a|flac)$/i))) {
      return NextResponse.json({ success: false, error: 'File must be an audio file (.wav, .mp3, .ogg, .m4a, .flac)' }, { status: 400 });
    }

    if (audioFile.size > 50 * 1024 * 1024) {
      return NextResponse.json({ success: false, error: 'File must be under 50MB' }, { status: 400 });
    }

    const metaRaw: Record<string, any> = {};
    formData.forEach((value, key) => {
      if (key !== 'audio') metaRaw[key] = value;
    });
    metaRaw.latitude = Number(metaRaw.latitude || 0);
    metaRaw.longitude = Number(metaRaw.longitude || 0);
    metaRaw.frequency_mhz = Number(metaRaw.frequency_mhz || 100);

    const parsed = spiritBoxUploadSchema.safeParse(metaRaw);
    if (!parsed.success) {
      return NextResponse.json({ success: false, errors: parsed.error.flatten().fieldErrors }, { status: 400 });
    }
    const meta = parsed.data;

    const recordingId = `SBR-${uuidv4().slice(0, 8).toUpperCase()}`;
    const ext = audioFile.name.split('.').pop() || 'wav';
    const stageFileName = `${recordingId}.${ext}`;
    const stagePath = `@GHOST_DETECTION.APP.GHOST_AUDIO_STAGE/${stageFileName}`;

    // Write audio to temp file for PUT upload
    const bytes = await audioFile.arrayBuffer();
    tempPath = join(tmpdir(), `spiritbox_${recordingId}.${ext}`);
    await writeFile(tempPath, Buffer.from(bytes));

    const conn = await getConnection();
    const startTime = Date.now();

    // Upload to internal stage
    await putFileToStage(conn, tempPath, '@GHOST_DETECTION.APP.GHOST_AUDIO_STAGE');

    // Insert initial record
    await executeQuery(conn, `
      INSERT INTO GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS (
        RECORDING_ID, SIGHTING_ID, GHOST_ID, FILE_NAME, STAGE_PATH,
        FILE_SIZE_BYTES, MIME_TYPE, RECORDING_DATETIME,
        LOCATION_NAME, LATITUDE, LONGITUDE,
        FREQUENCY_MHZ, SWEEP_RATE, DEVICE_MODEL,
        PROCESSING_STATUS
      ) VALUES (
        '${recordingId}',
        ${meta.sighting_id ? `'${meta.sighting_id.replace(/'/g, "''")}'` : 'NULL'},
        ${meta.ghost_id ? `'${meta.ghost_id.replace(/'/g, "''")}'` : 'NULL'},
        '${audioFile.name.replace(/'/g, "''")}',
        '${stagePath}',
        ${audioFile.size},
        '${audioFile.type || `audio/${ext}`}',
        '${meta.recording_datetime}',
        '${meta.location_name.replace(/'/g, "''")}',
        ${meta.latitude},
        ${meta.longitude},
        ${meta.frequency_mhz},
        '${meta.sweep_rate}',
        '${meta.device_model.replace(/'/g, "''")}',
        'Processing'
      )
    `);

    // Run AI analysis pipeline via Cortex functions
    // Step 1: Use AI_TRANSCRIBE to transcribe the audio file with speaker diarization
    let transcript = '';
    let audioDuration: number | null = null;
    let speakerSegments: any[] = [];

    try {
      const transcribeResults = await executeQuery(conn, `
        SELECT AI_TRANSCRIBE(
          TO_FILE('@GHOST_DETECTION.APP.GHOST_AUDIO_STAGE', '${stageFileName}'),
          {'timestamp_granularity': 'speaker'}
        ) AS transcription
      `);

      const transcription = transcribeResults[0]?.TRANSCRIPTION;
      if (transcription) {
        const parsed = typeof transcription === 'string' ? JSON.parse(transcription) : transcription;
        transcript = (parsed.text || '').replace(/'/g, "''");
        audioDuration = parsed.audio_duration ?? null;
        speakerSegments = parsed.segments || [];
      }
    } catch (transcribeErr: any) {
      console.warn('AI_TRANSCRIBE failed, falling back to metadata-based analysis:', transcribeErr.message);
      // Fallback: generate context from metadata if AI_TRANSCRIBE is unavailable
      const fallbackPrompt = `You are a paranormal audio analyst. A Spirit Box recording was captured at ${meta.location_name} on ${meta.recording_datetime}. Device: ${meta.device_model || 'Unknown'}, Frequency: ${meta.frequency_mhz} MHz, Sweep Rate: ${meta.sweep_rate}. ${meta.notes ? `Notes: ${meta.notes}` : ''} Generate a brief analysis note about what this session might contain.`;
      const fallbackResults = await executeQuery(conn, `
        SELECT SNOWFLAKE.CORTEX.COMPLETE('llama3.1-70b', '${fallbackPrompt.replace(/'/g, "''")}') AS transcript
      `);
      transcript = (fallbackResults[0]?.TRANSCRIPT || '').replace(/'/g, "''");
    }

    // Step 2: Run AI functions on the transcript
    const [extractResult, classifyResult, sentimentResult, summaryResult] = await Promise.all([
      executeQuery(conn, `
        SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
          '${transcript}',
          'What entity names, locations, or unusual words were communicated?'
        ) AS entities
      `),
      executeQuery(conn, `
        SELECT SNOWFLAKE.CORTEX.COMPLETE('llama3.1-70b',
          'Classify the following Spirit Box transcript into exactly one category: Intelligent Response, Residual Echo, Environmental Noise, Class A EVP, Class B EVP, Class C EVP, Anomalous Signal. Return only the category name.\n\nTranscript: ${transcript}'
        ) AS classification
      `),
      executeQuery(conn, `
        SELECT SNOWFLAKE.CORTEX.SENTIMENT('${transcript}') AS score
      `),
      executeQuery(conn, `
        SELECT SNOWFLAKE.CORTEX.SUMMARIZE('${transcript}') AS summary
      `),
    ]);

    const entities = extractResult[0]?.ENTITIES || '[]';
    const classification = (classifyResult[0]?.CLASSIFICATION || 'Unclassified').replace(/'/g, "''").trim();
    const sentiment = sentimentResult[0]?.SCORE ?? 0;
    const summary = (summaryResult[0]?.SUMMARY || '').replace(/'/g, "''");
    const processingMs = Date.now() - startTime;

    const anomalyDetected = sentiment < -0.5 || classification.includes('Class A') || classification.includes('Intelligent');
    const anomalyDesc = anomalyDetected
      ? `Anomalous activity detected: ${classification}. Sentiment: ${sentiment}.`
      : '';

    const searchableText = [
      meta.location_name,
      audioFile.name,
      transcript.replace(/''/g, "'"),
      summary.replace(/''/g, "'"),
      classification,
      anomalyDesc,
      meta.notes || '',
    ].filter(Boolean).join(' ');

    // Update record with AI results
    await executeQuery(conn, `
      UPDATE GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS
      SET
        AUDIO_TRANSCRIPT = '${transcript}',
        AUDIO_DURATION_SECONDS = ${audioDuration !== null ? audioDuration : 'NULL'},
        SPEAKER_SEGMENTS = ${speakerSegments.length > 0 ? `PARSE_JSON('${JSON.stringify(speakerSegments).replace(/'/g, "''")}')` : 'NULL'},
        AI_SUMMARY = '${summary}',
        EXTRACTED_ENTITIES = PARSE_JSON('${entities.replace(/'/g, "''")}'),
        SENTIMENT_SCORE = ${sentiment},
        CLASSIFICATION_RESULT = '${classification}',
        ANOMALY_DETECTED = ${anomalyDetected},
        ANOMALY_DESCRIPTION = '${anomalyDesc.replace(/'/g, "''")}',
        SEARCHABLE_TEXT = '${searchableText.replace(/'/g, "''")}',
        PROCESSING_STATUS = 'Completed',
        PROCESSING_DURATION_MS = ${processingMs},
        PROCESSED_AT = CURRENT_TIMESTAMP()
      WHERE RECORDING_ID = '${recordingId}'
    `);

    conn.destroy(() => {});

    return NextResponse.json({
      success: true,
      recording_id: recordingId,
      message: 'Spirit Box recording processed successfully',
      analysis: {
        transcript: transcript.replace(/''/g, "'"),
        audio_duration_seconds: audioDuration,
        speaker_segments: speakerSegments,
        summary: summary.replace(/''/g, "'"),
        classification,
        sentiment,
        anomaly_detected: anomalyDetected,
        anomaly_description: anomalyDesc,
        processing_ms: processingMs,
      },
    });
  } catch (error: any) {
    console.error('Spirit Box upload error:', error);
    return NextResponse.json(
      { success: false, error: error.message || 'Failed to process Spirit Box recording' },
      { status: 500 }
    );
  } finally {
    if (tempPath) {
      await unlink(tempPath).catch(() => {});
    }
  }
}

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const limit = Math.min(Number(searchParams.get('limit') || 50), 200);
    const status = searchParams.get('status');
    const anomaly = searchParams.get('anomaly');

    const conditions: string[] = [];
    if (status && status !== 'All') conditions.push(`PROCESSING_STATUS = '${status.replace(/'/g, "''")}'`);
    if (anomaly === 'true') conditions.push(`ANOMALY_DETECTED = TRUE`);
    const where = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';

    const conn = await getConnection();

    const recordings = await executeQuery(conn, `
      SELECT
        RECORDING_ID, FILE_NAME, LOCATION_NAME, RECORDING_DATETIME,
        FREQUENCY_MHZ, SWEEP_RATE, DEVICE_MODEL,
        CLASSIFICATION_RESULT, SENTIMENT_SCORE, ANOMALY_DETECTED,
        AI_SUMMARY, PROCESSING_STATUS, CREATED_AT
      FROM GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS
      ${where}
      ORDER BY CREATED_AT DESC
      LIMIT ${limit}
    `);

    conn.destroy(() => {});

    return NextResponse.json({
      recordings: recordings.map((r: any) => ({
        id: r.RECORDING_ID,
        file_name: r.FILE_NAME,
        location: r.LOCATION_NAME,
        datetime: r.RECORDING_DATETIME,
        frequency_mhz: r.FREQUENCY_MHZ,
        sweep_rate: r.SWEEP_RATE,
        device_model: r.DEVICE_MODEL,
        classification: r.CLASSIFICATION_RESULT,
        sentiment: r.SENTIMENT_SCORE != null ? Number(r.SENTIMENT_SCORE) : null,
        anomaly_detected: r.ANOMALY_DETECTED === true || r.ANOMALY_DETECTED === 'true',
        summary: r.AI_SUMMARY || '',
        status: r.PROCESSING_STATUS,
        created_at: r.CREATED_AT,
      })),
    });
  } catch (error: any) {
    console.error('Spirit Box list error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
