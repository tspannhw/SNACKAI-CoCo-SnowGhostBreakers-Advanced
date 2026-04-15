import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, FileAudio, AlertTriangle, Brain, Loader2 } from 'lucide-react';
import { useRecordingDetail } from '@/lib/api';

function formatTimestamp(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}:${s.toString().padStart(2, '0')}`;
}

export default function MediaDetail(): JSX.Element {
  const { id } = useParams<{ id: string }>();
  const { data, isLoading, error } = useRecordingDetail(id || '');

  if (isLoading) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-ghost-purple-400" />
      </div>
    );
  }

  if (error || !data?.recording) {
    return (
      <div className="mx-auto max-w-4xl px-4 py-8">
        <div className="rounded-xl bg-red-500/10 border border-red-500/30 p-6 text-red-400">
          {error?.message || 'Recording not found'}
        </div>
      </div>
    );
  }

  const r = data.recording;
  const ghost = data.ghost;

  return (
    <div className="space-y-6">
      <Link to="/media" className="flex items-center gap-2 text-sm text-ghost-purple-400 transition hover:text-white">
        <ArrowLeft className="h-4 w-4" /> Back to media
      </Link>

      <div className="flex items-start justify-between">
        <div>
          <h1 className="flex items-center gap-3 text-2xl font-bold text-white">
            <FileAudio className="h-7 w-7 text-ghost-purple-400" /> {r.file_name}
          </h1>
          <p className="mt-1 text-ghost-purple-400">
            {r.location} {r.frequency_mhz && `\u00b7 ${r.frequency_mhz} MHz`} {r.sweep_rate && `\u00b7 ${r.sweep_rate}`}
          </p>
        </div>
        <span className={`rounded-full border px-3 py-1 text-xs ${
          r.status === 'Completed'
            ? 'border-green-500/30 bg-green-500/20 text-green-400'
            : 'border-ghost-purple-500/30 bg-ghost-purple-500/20 text-ghost-purple-300'
        }`}>
          {r.status}
        </span>
      </div>

      {r.anomaly_detected && (
        <div className="flex items-start gap-3 rounded-xl bg-red-500/10 border border-red-500/30 p-4">
          <AlertTriangle className="h-5 w-5 flex-shrink-0 text-red-400" />
          <div>
            <p className="text-sm font-bold text-red-400">Anomaly Detected</p>
            <p className="text-sm text-red-300/80">{r.anomaly_description}</p>
          </div>
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-4">
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50 text-center">
          <p className="text-xs text-ghost-purple-400">Classification</p>
          <p className="mt-1 text-sm font-medium text-white">{r.classification || '\u2014'}</p>
        </div>
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50 text-center">
          <p className="text-xs text-ghost-purple-400">Sentiment</p>
          <p className={`mt-1 text-sm font-medium ${
            r.sentiment != null
              ? r.sentiment < -0.3 ? 'text-red-400' : r.sentiment > 0.3 ? 'text-green-400' : 'text-yellow-400'
              : 'text-white'
          }`}>{r.sentiment != null ? r.sentiment.toFixed(3) : '\u2014'}</p>
        </div>
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50 text-center">
          <p className="text-xs text-ghost-purple-400">Duration</p>
          <p className="mt-1 text-sm font-medium text-white">{r.audio_duration_seconds != null ? `${r.audio_duration_seconds.toFixed(1)}s` : '\u2014'}</p>
        </div>
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50 text-center">
          <p className="text-xs text-ghost-purple-400">Processing</p>
          <p className="mt-1 text-sm font-medium text-white">{r.processing_ms ? `${(r.processing_ms / 1000).toFixed(1)}s` : '\u2014'}</p>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <h3 className="mb-3 flex items-center gap-2 font-semibold text-white">
            <FileAudio className="h-5 w-5 text-ghost-purple-400" /> Recording Info
          </h3>
          <dl className="space-y-2 text-sm">
            <Row label="File" val={r.file_name} />
            <Row label="Size" val={r.file_size ? `${(r.file_size / 1024).toFixed(1)} KB` : '\u2014'} />
            <Row label="Type" val={r.mime_type || '\u2014'} />
            <Row label="Date" val={r.datetime ? new Date(r.datetime).toLocaleString() : '\u2014'} />
            <Row label="Device" val={r.device_model || '\u2014'} />
          </dl>
        </div>
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <h3 className="mb-3 flex items-center gap-2 font-semibold text-white">
            <Brain className="h-5 w-5 text-ghost-purple-400" /> Linked Records
          </h3>
          <dl className="space-y-2 text-sm">
            <Row label="Recording ID" val={r.id} />
            <Row label="Sighting" val={r.sighting_id || '\u2014'} />
            <Row label="Ghost" val={ghost ? `${ghost.name} (${ghost.type})` : (r.ghost_id || '\u2014')} />
            {ghost && <Row label="Threat" val={ghost.threat_level} />}
          </dl>
        </div>
      </div>

      {r.summary && (
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <h3 className="mb-2 flex items-center gap-2 font-semibold text-white">
            <Brain className="h-5 w-5 text-ghost-purple-400" /> AI Summary
          </h3>
          <p className="text-sm leading-relaxed text-ghost-purple-200">{r.summary}</p>
        </div>
      )}

      {(r.transcript || (r.speaker_segments && r.speaker_segments.length > 0)) && (
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <h3 className="mb-2 font-semibold text-white">
            Transcript {r.audio_duration_seconds != null && <span className="ml-2 text-xs font-normal text-ghost-purple-400">({r.audio_duration_seconds.toFixed(1)}s)</span>}
          </h3>
          {r.speaker_segments && r.speaker_segments.length > 0 ? (
            <div className="max-h-96 space-y-2 overflow-y-auto">
              {r.speaker_segments.map((seg, i) => (
                <div key={i} className="flex gap-3 text-sm">
                  <span className="min-w-[50px] font-mono text-xs text-ghost-purple-500">{formatTimestamp(seg.start)}</span>
                  <span className="min-w-[70px] font-medium text-ghost-purple-300">{seg.speaker || `Spk ${i}`}</span>
                  <span className="text-ghost-purple-200">{seg.text}</span>
                </div>
              ))}
            </div>
          ) : (
            <pre className="max-h-96 overflow-y-auto whitespace-pre-wrap font-mono text-sm leading-relaxed text-ghost-purple-200">
              {r.transcript}
            </pre>
          )}
        </div>
      )}
    </div>
  );
}

function Row({ label, val }: { label: string; val: string }): JSX.Element {
  return (
    <div className="flex justify-between">
      <dt className="text-ghost-purple-400">{label}</dt>
      <dd className="max-w-[60%] truncate text-right text-ghost-purple-200">{val}</dd>
    </div>
  );
}
