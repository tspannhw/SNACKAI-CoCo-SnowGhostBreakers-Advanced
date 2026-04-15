'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Radio, AlertTriangle, FileAudio, Loader2, Upload } from 'lucide-react';
import Link from 'next/link';

interface Recording {
  id: string;
  file_name: string;
  location: string;
  datetime: string;
  frequency_mhz: number;
  sweep_rate: string;
  device_model: string;
  classification: string;
  sentiment: number | null;
  anomaly_detected: boolean;
  summary: string;
  status: string;
  created_at: string;
}

const classColors: Record<string, string> = {
  'Class A EVP': 'text-red-400 bg-red-500/20 border-red-500/30',
  'Class B EVP': 'text-orange-400 bg-orange-500/20 border-orange-500/30',
  'Class C EVP': 'text-yellow-400 bg-yellow-500/20 border-yellow-500/30',
  'Intelligent Response': 'text-red-400 bg-red-500/20 border-red-500/30',
  'Residual Echo': 'text-purple-400 bg-purple-500/20 border-purple-500/30',
  'Environmental Noise': 'text-gray-400 bg-gray-500/20 border-gray-500/30',
  'Anomalous Signal': 'text-ghost-green bg-ghost-green/20 border-ghost-green/30',
};

export default function SpiritBoxPage() {
  const [recordings, setRecordings] = useState<Recording[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<'All' | 'anomaly'>('All');

  useEffect(() => {
    const params = new URLSearchParams();
    if (filter === 'anomaly') params.set('anomaly', 'true');

    fetch(`/api/spirit-box?${params}`)
      .then(r => r.json())
      .then(data => {
        if (data.error) throw new Error(data.error);
        setRecordings(data.recordings);
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, [filter]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="w-8 h-8 text-ghost-green animate-spin" />
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} className="flex items-center justify-between mb-10">
        <div>
          <h1 className="text-4xl font-creepy text-ghost-green text-glow tracking-wider flex items-center gap-3">
            <Radio className="w-10 h-10" /> Spirit Box Recordings
          </h1>
          <p className="text-gray-400 mt-2">AI-analyzed audio from Spirit Box research sessions</p>
        </div>
        <Link
          href="/spirit-box/upload"
          className="flex items-center gap-2 px-5 py-3 rounded-xl text-sm font-medium bg-ghost-green/20 border border-ghost-green/50 text-ghost-green hover:bg-ghost-green/30 hover:shadow-ghost transition-all"
        >
          <Upload className="w-4 h-4" /> New Recording
        </Link>
      </motion.div>

      <div className="flex gap-2 mb-6">
        {(['All', 'anomaly'] as const).map(f => (
          <button
            key={f}
            onClick={() => { setLoading(true); setFilter(f); }}
            className={`px-4 py-2 rounded-lg text-sm transition-all ${
              filter === f
                ? 'bg-ghost-green/20 border border-ghost-green/50 text-ghost-green'
                : 'bg-ghost-card border border-ghost-border text-gray-500 hover:text-gray-300'
            }`}
          >
            {f === 'All' ? 'All Recordings' : 'Anomalies Only'}
          </button>
        ))}
      </div>

      {error && (
        <div className="p-4 mb-6 bg-red-500/10 border border-red-500/30 rounded-xl text-red-400 text-sm">{error}</div>
      )}

      {recordings.length === 0 ? (
        <div className="text-center py-20">
          <FileAudio className="w-16 h-16 text-gray-600 mx-auto mb-4" />
          <p className="text-gray-400 text-lg">No recordings yet</p>
          <Link href="/spirit-box/upload" className="text-ghost-green hover:underline text-sm mt-2 inline-block">
            Upload your first Spirit Box recording
          </Link>
        </div>
      ) : (
        <div className="space-y-3">
          {recordings.map((rec, i) => (
            <Link key={rec.id} href={`/spirit-box/${rec.id}`}>
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.05 * i }}
                className="flex items-center justify-between p-4 rounded-xl bg-ghost-card border border-ghost-border hover:border-ghost-green/30 hover:bg-ghost-green/5 transition-all cursor-pointer mb-3"
              >
                <div className="flex items-center gap-4">
                  <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${rec.anomaly_detected ? 'bg-red-500/10' : 'bg-ghost-green/10'}`}>
                    {rec.anomaly_detected ? (
                      <AlertTriangle className="w-5 h-5 text-red-400" />
                    ) : (
                      <Radio className="w-5 h-5 text-ghost-green" />
                    )}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-white">{rec.file_name}</p>
                    <p className="text-xs text-gray-500">{rec.location} &middot; {rec.frequency_mhz} MHz &middot; {rec.sweep_rate}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  {rec.classification && (
                    <span className={`text-xs px-2.5 py-1 rounded-full border ${classColors[rec.classification] || 'text-gray-400 bg-gray-500/20 border-gray-500/30'}`}>
                      {rec.classification}
                    </span>
                  )}
                  <span className="text-xs text-gray-500">
                    {rec.datetime ? new Date(rec.datetime).toLocaleDateString() : ''}
                  </span>
                </div>
              </motion.div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
