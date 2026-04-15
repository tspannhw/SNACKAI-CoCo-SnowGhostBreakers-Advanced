'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Radio, MapPin, AlertTriangle, Brain, FileAudio, Loader2, ArrowLeft } from 'lucide-react';
import Link from 'next/link';

interface RecordingDetail {
  id: string;
  sighting_id: string;
  ghost_id: string;
  file_name: string;
  stage_path: string;
  file_size: number | null;
  mime_type: string;
  duration_seconds: number | null;
  datetime: string;
  location: string;
  lat: number | null;
  lng: number | null;
  frequency_mhz: number | null;
  sweep_rate: string;
  device_model: string;
  transcript: string;
  audio_duration_seconds: number | null;
  speaker_segments: SpeakerSegment[];
  summary: string;
  entities: any[];
  sentiment: number | null;
  classification: string;
  anomaly_detected: boolean;
  anomaly_description: string;
  status: string;
  processing_ms: number | null;
  error: string;
  processed_at: string;
  created_at: string;
}

interface SpeakerSegment {
  speaker: string;
  start: number;
  end: number;
  text: string;
}

interface GhostInfo {
  id: string;
  name: string;
  type: string;
  threat_level: string;
}

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1048576) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1048576).toFixed(1)} MB`;
}

function formatTimestamp(seconds: number) {
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}:${s.toString().padStart(2, '0')}`;
}

export default function SpiritBoxDetailPage({ params }: { params: { id: string } }) {
  const [recording, setRecording] = useState<RecordingDetail | null>(null);
  const [ghost, setGhost] = useState<GhostInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch(`/api/spirit-box/${params.id}`)
      .then(r => r.json())
      .then(data => {
        if (data.error) throw new Error(data.error);
        setRecording(data.recording);
        setGhost(data.ghost);
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, [params.id]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="w-8 h-8 text-ghost-green animate-spin" />
      </div>
    );
  }

  if (error || !recording) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="p-6 bg-red-500/10 border border-red-500/30 rounded-2xl text-red-400">
          {error || 'Recording not found'}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Link href="/spirit-box" className="flex items-center gap-2 text-gray-400 hover:text-ghost-green transition-colors mb-6 text-sm">
        <ArrowLeft className="w-4 h-4" /> Back to recordings
      </Link>

      <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }}>
        <div className="flex items-start justify-between mb-8">
          <div>
            <h1 className="text-3xl font-creepy text-ghost-green text-glow tracking-wider flex items-center gap-3">
              <Radio className="w-8 h-8" /> {recording.file_name}
            </h1>
            <p className="text-gray-400 mt-1 flex items-center gap-2">
              <MapPin className="w-4 h-4" /> {recording.location}
              {recording.frequency_mhz && <> &middot; {recording.frequency_mhz} MHz</>}
              {recording.sweep_rate && <> &middot; {recording.sweep_rate}</>}
            </p>
          </div>
          <span className={`text-xs px-3 py-1.5 rounded-full border ${
            recording.status === 'Completed' ? 'text-green-400 bg-green-500/20 border-green-500/30'
            : recording.status === 'Processing' ? 'text-yellow-400 bg-yellow-500/20 border-yellow-500/30'
            : 'text-gray-400 bg-gray-500/20 border-gray-500/30'
          }`}>
            {recording.status}
          </span>
        </div>
      </motion.div>

      {recording.anomaly_detected && (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.1 }}
          className="p-4 rounded-xl bg-red-500/10 border border-red-500/30 flex items-start gap-3 mb-6"
        >
          <AlertTriangle className="w-5 h-5 text-red-400 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-bold text-red-400">Anomaly Detected</p>
            <p className="text-sm text-red-300/80">{recording.anomaly_description}</p>
          </div>
        </motion.div>
      )}

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <StatBox label="Classification" value={recording.classification || '—'} />
        <StatBox
          label="Sentiment"
          value={recording.sentiment != null ? recording.sentiment.toFixed(3) : '—'}
          color={recording.sentiment != null ? (recording.sentiment < -0.3 ? 'text-red-400' : recording.sentiment > 0.3 ? 'text-green-400' : 'text-yellow-400') : undefined}
        />
        <StatBox label="Anomaly" value={recording.anomaly_detected ? 'Yes' : 'No'} color={recording.anomaly_detected ? 'text-red-400' : 'text-green-400'} />
        <StatBox label="Duration" value={recording.audio_duration_seconds != null ? `${recording.audio_duration_seconds.toFixed(1)}s` : (recording.processing_ms ? `${(recording.processing_ms / 1000).toFixed(1)}s proc` : '—')} />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <InfoBox title="Recording Details" icon={<FileAudio className="w-5 h-5 text-ghost-green" />}>
          <InfoRow label="File" value={recording.file_name} />
          <InfoRow label="Size" value={recording.file_size ? formatSize(recording.file_size) : '—'} />
          <InfoRow label="Type" value={recording.mime_type || '—'} />
          <InfoRow label="Date" value={recording.datetime ? new Date(recording.datetime).toLocaleString() : '—'} />
          <InfoRow label="Device" value={recording.device_model || '—'} />
          <InfoRow label="Frequency" value={recording.frequency_mhz ? `${recording.frequency_mhz} MHz` : '—'} />
          <InfoRow label="Sweep" value={recording.sweep_rate || '—'} />
        </InfoBox>

        <InfoBox title="Linked Records" icon={<Brain className="w-5 h-5 text-ghost-purple" />}>
          <InfoRow label="Recording ID" value={recording.id} />
          <InfoRow label="Sighting ID" value={recording.sighting_id || '—'} />
          <InfoRow label="Ghost ID" value={recording.ghost_id || '—'} />
          {ghost && (
            <>
              <InfoRow label="Ghost Name" value={ghost.name} />
              <InfoRow label="Ghost Type" value={ghost.type} />
              <InfoRow label="Threat Level" value={ghost.threat_level} />
            </>
          )}
          <InfoRow label="Processed" value={recording.processed_at ? new Date(recording.processed_at).toLocaleString() : '—'} />
        </InfoBox>
      </div>

      {recording.summary && (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.2 }}
          className="p-5 rounded-xl bg-ghost-card border border-ghost-border mb-6"
        >
          <h3 className="text-sm font-bold text-ghost-purple mb-2 flex items-center gap-2">
            <Brain className="w-4 h-4" /> AI Summary
          </h3>
          <p className="text-sm text-gray-300 leading-relaxed">{recording.summary}</p>
        </motion.div>
      )}

      {(recording.transcript || recording.speaker_segments?.length > 0) && (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.3 }}
          className="p-5 rounded-xl bg-ghost-dark border border-ghost-border mb-6"
        >
          <h3 className="text-sm font-bold text-ghost-green mb-2">
            Transcript {recording.audio_duration_seconds != null && <span className="text-gray-500 font-normal ml-2">({recording.audio_duration_seconds.toFixed(1)}s audio)</span>}
          </h3>
          {recording.speaker_segments?.length > 0 ? (
            <div className="space-y-2 max-h-96 overflow-y-auto">
              {recording.speaker_segments.map((seg: SpeakerSegment, i: number) => (
                <div key={i} className="flex gap-3 text-sm">
                  <span className="text-ghost-purple font-mono text-xs min-w-[60px]">
                    {formatTimestamp(seg.start)}
                  </span>
                  <span className="text-ghost-green font-medium min-w-[80px]">
                    {seg.speaker || `Speaker ${i}`}
                  </span>
                  <span className="text-gray-300">{seg.text}</span>
                </div>
              ))}
            </div>
          ) : (
            <pre className="text-sm text-gray-300 whitespace-pre-wrap font-mono max-h-96 overflow-y-auto leading-relaxed">
              {recording.transcript}
            </pre>
          )}
        </motion.div>
      )}

      {recording.error && (
        <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/30 mb-6">
          <p className="text-xs text-gray-500 mb-1">Error</p>
          <p className="text-sm text-red-400">{recording.error}</p>
        </div>
      )}
    </div>
  );
}

function StatBox({ label, value, color }: { label: string; value: string; color?: string }) {
  return (
    <div className="p-4 rounded-xl bg-ghost-card border border-ghost-border text-center">
      <p className="text-xs text-gray-500 mb-1">{label}</p>
      <p className={`text-sm font-medium ${color || 'text-white'}`}>{value}</p>
    </div>
  );
}

function InfoBox({ title, icon, children }: { title: string; icon: React.ReactNode; children: React.ReactNode }) {
  return (
    <div className="p-5 rounded-xl bg-ghost-card border border-ghost-border">
      <h3 className="text-sm font-bold text-white mb-3 flex items-center gap-2">{icon} {title}</h3>
      <div className="space-y-2">{children}</div>
    </div>
  );
}

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between">
      <span className="text-xs text-gray-500">{label}</span>
      <span className="text-sm text-gray-300 truncate ml-4 max-w-[60%] text-right">{value || '—'}</span>
    </div>
  );
}
