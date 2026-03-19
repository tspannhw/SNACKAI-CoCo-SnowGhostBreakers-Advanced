'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import Map, { Marker, NavigationControl } from 'react-map-gl/maplibre';
import { Ghost, MapPin, ArrowLeft, Shield, Thermometer, Radio, Eye, FileText, AlertTriangle, CheckCircle, Loader2 } from 'lucide-react';
import 'maplibre-gl/dist/maplibre-gl.css';

const MAP_STYLE = 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

const threatColors: Record<string, string> = {
  Low: '#22c55e',
  Medium: '#eab308',
  High: '#f97316',
  Extreme: '#ef4444',
};

const threatBg: Record<string, string> = {
  Low: 'bg-green-500/20 border-green-500/30 text-green-400',
  Medium: 'bg-yellow-500/20 border-yellow-500/30 text-yellow-400',
  High: 'bg-orange-500/20 border-orange-500/30 text-orange-400',
  Extreme: 'bg-red-500/20 border-red-500/30 text-red-400',
};

interface SightingDetail {
  sighting: {
    id: string; ghost_id: string; location: string; address: string;
    lat: number; lng: number; datetime: string; witness_name: string;
    witness_contact: string; environmental_conditions: string;
    temperature: number | null; emf_reading: number | null;
    description: string; evidence_type: string; activity_level: number | null;
    investigation_notes: string; verified: boolean; created_at: string;
  };
  ghost: {
    id: string; name: string; type: string; threat_level: string;
    description: string; manifestation_frequency: string; origin_story: string;
    first_detected: string; last_seen: string; status: string;
    confidence_score: number | null;
  };
}

function InfoRow({ icon: Icon, label, value, color }: { icon: any; label: string; value: string | number | null; color?: string }) {
  if (value === null || value === undefined || value === '') return null;
  return (
    <div className="flex items-start gap-3 py-3 border-b border-ghost-border/50 last:border-0">
      <Icon className={`w-4 h-4 mt-0.5 ${color || 'text-ghost-green'} shrink-0`} />
      <div>
        <p className="text-xs text-gray-500 uppercase tracking-wider">{label}</p>
        <p className="text-sm text-gray-200 mt-0.5 whitespace-pre-wrap">{String(value)}</p>
      </div>
    </div>
  );
}

function formatDate(d: string) {
  if (!d) return '';
  try { return new Date(d).toLocaleString(); } catch { return d; }
}

export default function SightingDetailPage() {
  const params = useParams();
  const router = useRouter();
  const [data, setData] = useState<SightingDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!params.id) return;
    fetch(`/api/sightings/${params.id}`)
      .then(r => r.json())
      .then(d => {
        if (d.error) throw new Error(d.error);
        setData(d);
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

  if (error || !data) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="p-6 bg-red-500/10 border border-red-500/30 rounded-2xl text-red-400">
          {error || 'Sighting not found'}
        </div>
      </div>
    );
  }

  const { sighting: s, ghost: g } = data;

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }}>
        <button onClick={() => router.back()} className="flex items-center gap-2 text-sm text-gray-400 hover:text-ghost-green mb-6 transition-colors">
          <ArrowLeft className="w-4 h-4" /> Back
        </button>
      </motion.div>

      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-6">
        <div className="flex items-center gap-4 flex-wrap">
          <div className="w-14 h-14 rounded-xl bg-ghost-green/10 flex items-center justify-center">
            <Ghost className="w-8 h-8 text-ghost-green" />
          </div>
          <div>
            <h1 className="text-3xl font-creepy text-ghost-green text-glow tracking-wider">{g.name}</h1>
            <p className="text-gray-400 mt-1">{s.location}</p>
          </div>
          <div className="flex gap-2 ml-auto flex-wrap">
            <span className={`px-3 py-1.5 rounded-full border text-sm font-medium ${threatBg[g.threat_level] || ''}`}>
              {g.threat_level} Threat
            </span>
            <span className="px-3 py-1.5 rounded-full border text-sm font-medium bg-ghost-purple/20 border-ghost-purple/30 text-ghost-purple">
              {g.type}
            </span>
            {s.verified && (
              <span className="px-3 py-1.5 rounded-full border text-sm font-medium bg-green-500/20 border-green-500/30 text-green-400 flex items-center gap-1">
                <CheckCircle className="w-3.5 h-3.5" /> Verified
              </span>
            )}
          </div>
        </div>
      </motion.div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.1 }} className="space-y-6">
          <div className="rounded-2xl overflow-hidden border border-ghost-border h-[300px]">
            <Map
              initialViewState={{ longitude: s.lng, latitude: s.lat, zoom: 13 }}
              mapStyle={MAP_STYLE}
              style={{ width: '100%', height: '100%' }}
              interactive={true}
            >
              <NavigationControl position="top-right" />
              <Marker latitude={s.lat} longitude={s.lng} anchor="bottom">
                <MapPin className="w-8 h-8 drop-shadow-lg" style={{ color: threatColors[g.threat_level] }} fill={`${threatColors[g.threat_level]}33`} />
              </Marker>
            </Map>
          </div>

          <div className="bg-ghost-card border border-ghost-border rounded-2xl p-5">
            <h2 className="text-sm font-bold text-white mb-3 flex items-center gap-2">
              <Eye className="w-4 h-4 text-ghost-green" /> Sighting Details
            </h2>
            <InfoRow icon={MapPin} label="Location" value={s.location} />
            {s.address && <InfoRow icon={MapPin} label="Address" value={s.address} />}
            <InfoRow icon={Eye} label="Date & Time" value={formatDate(s.datetime)} />
            <InfoRow icon={FileText} label="Description" value={s.description} />
            <InfoRow icon={Shield} label="Witness" value={s.witness_name} />
            <InfoRow icon={FileText} label="Evidence Type" value={s.evidence_type} />
            <InfoRow icon={Thermometer} label="Temperature" value={s.temperature !== null ? `${s.temperature.toFixed(1)} C` : null} color="text-cyan-400" />
            <InfoRow icon={Radio} label="EMF Reading" value={s.emf_reading !== null ? `${s.emf_reading.toFixed(1)} mG` : null} color="text-yellow-400" />
            <InfoRow icon={AlertTriangle} label="Activity Level" value={s.activity_level !== null ? `${s.activity_level}/10` : null} color="text-orange-400" />
            <InfoRow icon={FileText} label="Environmental Conditions" value={s.environmental_conditions} />
            <InfoRow icon={FileText} label="Investigation Notes" value={s.investigation_notes} />
            <div className="flex items-start gap-3 py-3 text-xs text-gray-500">
              <span>ID: {s.id}</span>
              <span>Recorded: {formatDate(s.created_at)}</span>
            </div>
          </div>
        </motion.div>

        <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.2 }} className="space-y-6">
          <div className="bg-ghost-card border border-ghost-border rounded-2xl p-5">
            <h2 className="text-sm font-bold text-white mb-3 flex items-center gap-2">
              <Ghost className="w-4 h-4 text-ghost-green" /> Entity Profile
            </h2>
            <InfoRow icon={Ghost} label="Name" value={g.name} />
            <InfoRow icon={Shield} label="Type" value={g.type} />
            <InfoRow icon={AlertTriangle} label="Threat Level" value={g.threat_level} color={`text-[${threatColors[g.threat_level]}]`} />
            <InfoRow icon={FileText} label="Description" value={g.description} />
            <InfoRow icon={FileText} label="Manifestation" value={g.manifestation_frequency} />
            <InfoRow icon={Eye} label="Status" value={g.status} />
            {g.confidence_score !== null && (
              <div className="flex items-start gap-3 py-3 border-b border-ghost-border/50">
                <Shield className="w-4 h-4 mt-0.5 text-ghost-purple shrink-0" />
                <div>
                  <p className="text-xs text-gray-500 uppercase tracking-wider">Confidence Score</p>
                  <div className="flex items-center gap-2 mt-1">
                    <div className="flex-1 h-2 rounded-full bg-ghost-dark max-w-[200px]">
                      <div className="h-full rounded-full bg-ghost-purple" style={{ width: `${(g.confidence_score * 100).toFixed(0)}%` }} />
                    </div>
                    <span className="text-sm text-gray-200">{(g.confidence_score * 100).toFixed(0)}%</span>
                  </div>
                </div>
              </div>
            )}
            <InfoRow icon={Eye} label="First Detected" value={formatDate(g.first_detected)} />
            <InfoRow icon={Eye} label="Last Seen" value={formatDate(g.last_seen)} />
          </div>

          {g.origin_story && (
            <div className="bg-ghost-card border border-ghost-border rounded-2xl p-5">
              <h2 className="text-sm font-bold text-white mb-3 flex items-center gap-2">
                <FileText className="w-4 h-4 text-ghost-purple" /> Origin Story
              </h2>
              <p className="text-sm text-gray-300 leading-relaxed whitespace-pre-wrap">{g.origin_story}</p>
            </div>
          )}

          <div className="bg-ghost-card border border-ghost-border rounded-2xl p-5">
            <h2 className="text-sm font-bold text-white mb-3 flex items-center gap-2">
              <MapPin className="w-4 h-4 text-ghost-green" /> Coordinates
            </h2>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p className="text-xs text-gray-500">Latitude</p>
                <p className="text-gray-200 font-mono">{s.lat.toFixed(6)}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Longitude</p>
                <p className="text-gray-200 font-mono">{s.lng.toFixed(6)}</p>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
