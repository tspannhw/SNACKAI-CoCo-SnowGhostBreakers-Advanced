import { NextResponse } from 'next/server';
import { getConnection, executeQuery } from '@/lib/snowflake';

export const dynamic = 'force-dynamic';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { message, history = [] } = body;

    if (!message || typeof message !== 'string') {
      return NextResponse.json({ error: 'Message is required' }, { status: 400 });
    }

    const conn = await getConnection();

    // Step 1: Retrieve relevant context via search
    let context = '';
    try {
      const searchResults = await executeQuery(conn, `
        SELECT PARSE_JSON(
          SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'GHOST_DETECTION.APP.SPIRIT_BOX_SEARCH',
            '${message.replace(/'/g, "''")}',
            5
          )
        ) AS results
      `);
      const parsed = searchResults[0]?.RESULTS;
      const results = typeof parsed === 'string' ? JSON.parse(parsed) : (parsed || { results: [] });
      context = (results.results || [])
        .map((r: any) => r.SEARCHABLE_TEXT || r.searchable_text || '')
        .filter(Boolean)
        .join('\n---\n')
        .substring(0, 3000);
    } catch {
      // Cortex Search might be suspended, fall back to direct table query
      const fallback = await executeQuery(conn, `
        SELECT SEARCHABLE_TEXT FROM GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS
        WHERE SEARCHABLE_TEXT ILIKE '%${message.replace(/'/g, "''").substring(0, 50)}%'
        LIMIT 5
      `);
      context = fallback.map((r: any) => r.SEARCHABLE_TEXT || '').join('\n---\n').substring(0, 3000);
    }

    // Also get some general stats for context
    const stats = await executeQuery(conn, `
      SELECT 
        (SELECT COUNT(*) FROM GHOST_DETECTION.APP.SPIRIT_BOX_RECORDINGS) AS recordings,
        (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOSTS) AS ghosts,
        (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOST_SIGHTINGS) AS sightings,
        (SELECT COUNT(*) FROM GHOST_DETECTION.APP.GHOST_EVIDENCE) AS evidence
    `);

    const statsContext = stats[0] 
      ? `Database contains: ${stats[0].RECORDINGS} Spirit Box recordings, ${stats[0].GHOSTS} cataloged ghosts, ${stats[0].SIGHTINGS} sightings, ${stats[0].EVIDENCE} evidence items.`
      : '';

    // Step 2: Build conversation history
    const historyText = history
      .slice(-4)
      .map((h: any) => `${h.role === 'user' ? 'User' : 'Assistant'}: ${h.content}`)
      .join('\n');

    // Step 3: Generate response with CORTEX.COMPLETE using RAG context
    const systemPrompt = `You are a paranormal research AI assistant for the SnowGhostBreakers team. You have access to Spirit Box recordings, ghost sightings, and evidence data stored in Snowflake. Answer questions about the research data, provide insights about detected anomalies, and help analyze paranormal activity patterns.

${statsContext}

Relevant data from our research database:
${context || 'No specific data found for this query.'}

${historyText ? `Previous conversation:\n${historyText}` : ''}

User question: ${message}

Provide a helpful, scientifically-minded response based on the available data. If the data doesn't contain relevant information, say so clearly.`;

    const response = await executeQuery(conn, `
      SELECT SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        '${systemPrompt.replace(/'/g, "''")}'
      ) AS response
    `);

    conn.destroy(() => {});

    const answer = response[0]?.RESPONSE || 'I was unable to generate a response. Please try again.';

    return NextResponse.json({
      message: answer,
      context_used: context ? true : false,
      sources: context ? 'Spirit Box recordings and research database' : 'General knowledge',
    });
  } catch (error: any) {
    console.error('Chat error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
