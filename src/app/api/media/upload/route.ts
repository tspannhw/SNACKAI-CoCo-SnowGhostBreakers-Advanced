import { NextResponse } from 'next/server';
import { getConnection, executeQuery, putFileToStage } from '@/lib/snowflake';
import { writeFile, unlink } from 'fs/promises';
import { join } from 'path';
import { tmpdir } from 'os';
import { v4 as uuidv4 } from 'uuid';

export const dynamic = 'force-dynamic';

export async function POST(request: Request) {
  let tempPath = '';
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File | null;

    if (!file) {
      return NextResponse.json({ error: 'File is required' }, { status: 400 });
    }

    if (file.size > 100 * 1024 * 1024) {
      return NextResponse.json({ error: 'File must be under 100MB' }, { status: 400 });
    }

    // Determine media type from file
    let mediaType: 'audio' | 'image' | 'video' | 'document' = 'document';
    if (file.type.startsWith('audio/') || file.name.match(/\.(wav|mp3|ogg|m4a|flac)$/i)) {
      mediaType = 'audio';
    } else if (file.type.startsWith('image/') || file.name.match(/\.(jpg|jpeg|png|gif|webp|bmp)$/i)) {
      mediaType = 'image';
    } else if (file.type.startsWith('video/') || file.name.match(/\.(mp4|webm|mov|avi)$/i)) {
      mediaType = 'video';
    }

    // Extract metadata from form
    const metaRaw: Record<string, string> = {};
    formData.forEach((value, key) => {
      if (key !== 'file' && typeof value === 'string') metaRaw[key] = value;
    });

    const location = metaRaw.location_name || metaRaw.location || 'Unknown';
    const latitude = Number(metaRaw.latitude || 0);
    const longitude = Number(metaRaw.longitude || 0);
    const description = metaRaw.description || metaRaw.notes || '';
    const sightingId = metaRaw.sighting_id || '';
    const ghostId = metaRaw.ghost_id || '';

    const id = `MED-${uuidv4().slice(0, 8).toUpperCase()}`;
    const ext = file.name.split('.').pop() || 'bin';
    const stageFileName = `${id}.${ext}`;

    // Determine which stage to use
    const stage = mediaType === 'audio'
      ? '@GHOST_DETECTION.APP.GHOST_AUDIO_STAGE'
      : '@GHOST_DETECTION.APP.GHOST_IMAGES_STAGE';

    // Write to temp and upload
    const bytes = await file.arrayBuffer();
    tempPath = join(tmpdir(), `media_${id}.${ext}`);
    await writeFile(tempPath, Buffer.from(bytes));

    const conn = await getConnection();
    await putFileToStage(conn, tempPath, stage);

    // For audio files, run AI_TRANSCRIBE
    let transcript = '';
    let audioDuration: number | null = null;
    let speakerSegments: any[] = [];

    if (mediaType === 'audio') {
      try {
        const transcribeResults = await executeQuery(conn, `
          SELECT AI_TRANSCRIBE(
            TO_FILE('${stage}', '${stageFileName}'),
            {'timestamp_granularity': 'speaker'}
          ) AS transcription
        `);
        const transcription = transcribeResults[0]?.TRANSCRIPTION;
        if (transcription) {
          const parsed = typeof transcription === 'string' ? JSON.parse(transcription) : transcription;
          transcript = parsed.text || '';
          audioDuration = parsed.audio_duration ?? null;
          speakerSegments = parsed.segments || [];
        }
      } catch (err: any) {
        console.warn('AI_TRANSCRIBE not available:', err.message);
      }
    }

    // Insert into GHOST_EVIDENCE for images/video, or SPIRIT_BOX_RECORDINGS for audio
    if (mediaType === 'audio') {
      const recordingId = id.replace('MED-', 'SBR-');
      await executeQuery(conn, `
        INSERT INTO GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS (
          RECORDING_ID, SIGHTING_ID, GHOST_ID, FILE_NAME, STAGE_PATH,
          FILE_SIZE_BYTES, MIME_TYPE, RECORDING_DATETIME,
          LOCATION_NAME, LATITUDE, LONGITUDE,
          AUDIO_TRANSCRIPT, AUDIO_DURATION_SECONDS, SPEAKER_SEGMENTS,
          PROCESSING_STATUS
        ) VALUES (
          '${recordingId}',
          ${sightingId ? `'${sightingId.replace(/'/g, "''")}'` : 'NULL'},
          ${ghostId ? `'${ghostId.replace(/'/g, "''")}'` : 'NULL'},
          '${file.name.replace(/'/g, "''")}',
          '${stage}/${stageFileName}',
          ${file.size},
          '${file.type || `audio/${ext}`}',
          CURRENT_TIMESTAMP(),
          '${location.replace(/'/g, "''")}',
          ${latitude}, ${longitude},
          ${transcript ? `'${transcript.replace(/'/g, "''")}'` : 'NULL'},
          ${audioDuration !== null ? audioDuration : 'NULL'},
          ${speakerSegments.length > 0 ? `PARSE_JSON('${JSON.stringify(speakerSegments).replace(/'/g, "''")}')` : 'NULL'},
          'Uploaded'
        )
      `);
    } else {
      await executeQuery(conn, `
        INSERT INTO GHOST_DETECTION.APP.GHOST_EVIDENCE (
          EVIDENCE_ID, SIGHTING_ID, EVIDENCE_TYPE, FILE_NAME, FILE_PATH,
          DESCRIPTION, FILE_SIZE, UPLOAD_DATE
        ) VALUES (
          '${id}',
          ${sightingId ? `'${sightingId.replace(/'/g, "''")}'` : 'NULL'},
          '${mediaType === 'image' ? 'Photo' : 'Video'}',
          '${file.name.replace(/'/g, "''")}',
          '${stage}/${stageFileName}',
          '${description.replace(/'/g, "''")}',
          ${file.size},
          CURRENT_TIMESTAMP()
        )
      `);
    }

    conn.destroy(() => {});

    return NextResponse.json({
      success: true,
      id: mediaType === 'audio' ? id.replace('MED-', 'SBR-') : id,
      media_type: mediaType,
      file_name: file.name,
      stage_path: `${stage}/${stageFileName}`,
      transcript: transcript || null,
      audio_duration: audioDuration,
    });
  } catch (error: any) {
    console.error('Media upload error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  } finally {
    if (tempPath) {
      await unlink(tempPath).catch(() => {});
    }
  }
}
