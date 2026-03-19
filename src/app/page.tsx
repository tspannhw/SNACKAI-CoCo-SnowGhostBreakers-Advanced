'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import StatsCard from '@/components/StatsCard';
import { Ghost, Eye, MapPin, AlertTriangle, Zap, Clock, Loader2 } from 'lucide-react';
import Link from 'next/link';

const threatColors: Record<string, string> = {
  Low: 'text-green-400 bg-green-500/20 border-green-500/30',
  Medium: 'text-yellow-400 bg-yellow-500/20 border-yellow-500/30',
  High: 'text-orange-400 bg-orange-500/20 border-orange-500/30',
  Extreme: 'text-red-400 bg-red-500/20 border-red-500/30',
};

const barColors: Record<string, string> = {
  Ghoul: 'bg-red-500',
  Leprechaun: 'bg-green-500',
  'Evil Rabbit': 'bg-yellow-500',
  Apparition: 'bg-ghost-purple',
  Poltergeist: 'bg-orange-500',
  'Shadow Entity': 'bg-indigo-500',
  Orb: 'bg-cyan-500',
};

function timeAgo(dateStr: string) {
  const d = new Date(dateStr);
  const now = new Date();
  const diffMs = now.getTime() - d.getTime();
  const diffH = Math.floor(diffMs / 3600000);
  if (diffH < 1) return 'just now';
  if (diffH < 24) return `${diffH}h ago`;
  const diffD = Math.floor(diffH / 24);
  if (diffD < 30) return `${diffD}d ago`;
  return `${Math.floor(diffD / 30)}mo ago`;
}

interface Stats {
  total_entities: number;
  total_sightings: number;
  hotspots: number;
  extreme_threats: number;
  by_type: { type: string; count: number; pct: number }[];
  recent: { id: string; entity: string; type: string; location: string; threat: string; datetime: string }[];
}

export default function Dashboard() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch('/api/stats')
      .then(r => r.json())
      .then(data => {
        if (data.error) throw new Error(data.error);
        setStats(data);
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="w-8 h-8 text-ghost-green animate-spin" />
      </div>
    );
  }

  if (error || !stats) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="p-6 bg-red-500/10 border border-red-500/30 rounded-2xl text-red-400">
          Failed to load dashboard data: {error || 'Unknown error'}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} className="mb-10">
        <h1 className="text-5xl font-creepy text-ghost-green text-glow tracking-wider">
          Paranormal Command Center
        </h1>
        <p className="text-gray-400 mt-2">Real-time ghost detection and tracking across NY, NJ & New England</p>
      </motion.div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-10">
        <StatsCard title="Total Entities" value={stats.total_entities.toLocaleString()} icon={Ghost} color="green" subtitle="Registered ghosts" />
        <StatsCard title="Total Sightings" value={stats.total_sightings.toLocaleString()} icon={Eye} color="purple" subtitle="Oct 2025 - Mar 2026" />
        <StatsCard title="Hotspots" value={stats.hotspots.toLocaleString()} icon={MapPin} color="yellow" subtitle="Unique locations" />
        <StatsCard title="Extreme Threats" value={stats.extreme_threats.toLocaleString()} icon={AlertTriangle} color="red" subtitle="Requires attention" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="lg:col-span-2 bg-ghost-card border border-ghost-border rounded-2xl p-6"
        >
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-bold text-white flex items-center gap-2">
              <Clock className="w-5 h-5 text-ghost-green" />
              Recent Sightings
            </h2>
            <Link href="/sightings" className="text-sm text-ghost-green hover:underline">View all</Link>
          </div>
          <div className="space-y-3">
            {stats.recent.map((s, i) => (
              <Link key={s.id} href={`/sighting/${s.id}`}>
                <motion.div
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.1 * i }}
                  className="flex items-center justify-between p-4 rounded-xl bg-ghost-dark border border-ghost-border hover:border-ghost-green/30 hover:bg-ghost-green/5 transition-all cursor-pointer mb-3"
                >
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-lg bg-ghost-green/10 flex items-center justify-center">
                      <Ghost className="w-5 h-5 text-ghost-green" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-white">{s.entity}</p>
                      <p className="text-xs text-gray-500 flex items-center gap-1">
                        <MapPin className="w-3 h-3" /> {s.location}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className={`text-xs px-2.5 py-1 rounded-full border ${threatColors[s.threat] || ''}`}>
                      {s.threat}
                    </span>
                    <span className="text-xs text-gray-500">{timeAgo(s.datetime)}</span>
                  </div>
                </motion.div>
              </Link>
            ))}
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="bg-ghost-card border border-ghost-border rounded-2xl p-6"
        >
          <h2 className="text-lg font-bold text-white mb-6 flex items-center gap-2">
            <Zap className="w-5 h-5 text-ghost-purple" />
            Quick Actions
          </h2>
          <div className="space-y-3">
            <Link
              href="/upload"
              className="flex items-center gap-3 p-4 rounded-xl bg-ghost-green/10 border border-ghost-green/30 hover:bg-ghost-green/20 hover:shadow-ghost transition-all group"
            >
              <div className="p-2 rounded-lg bg-ghost-green/20">
                <Zap className="w-5 h-5 text-ghost-green" />
              </div>
              <div>
                <p className="text-sm font-medium text-ghost-green">Report New Sighting</p>
                <p className="text-xs text-gray-500">Upload ghost data & evidence</p>
              </div>
            </Link>
            <Link
              href="/sightings"
              className="flex items-center gap-3 p-4 rounded-xl bg-ghost-purple/10 border border-ghost-purple/30 hover:bg-ghost-purple/20 hover:shadow-purple transition-all"
            >
              <div className="p-2 rounded-lg bg-ghost-purple/20">
                <MapPin className="w-5 h-5 text-ghost-purple" />
              </div>
              <div>
                <p className="text-sm font-medium text-ghost-purple">View Sightings Map</p>
                <p className="text-xs text-gray-500">Interactive paranormal hotspot map</p>
              </div>
            </Link>
            <div className="mt-6 p-4 rounded-xl bg-ghost-dark border border-ghost-border">
              <p className="text-xs text-gray-500 mb-2">ENTITY TYPE BREAKDOWN</p>
              {stats.by_type.map((item) => (
                <div key={item.type} className="flex items-center gap-2 mb-2">
                  <span className="text-xs text-gray-400 w-24 truncate">{item.type}</span>
                  <div className="flex-1 h-2 rounded-full bg-ghost-dark">
                    <motion.div
                      initial={{ width: 0 }}
                      animate={{ width: `${item.pct}%` }}
                      transition={{ duration: 1, delay: 0.5 }}
                      className={`h-full rounded-full ${barColors[item.type] || 'bg-gray-500'}`}
                    />
                  </div>
                  <span className="text-xs text-gray-500 w-8">{item.pct}%</span>
                </div>
              ))}
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
