'use client';

import { useState, useEffect, useMemo } from 'react';
import Map, { Marker, Popup, NavigationControl } from 'react-map-gl/maplibre';
import { motion } from 'framer-motion';
import { Ghost, Filter, MapPin, Loader2, ExternalLink } from 'lucide-react';
import Link from 'next/link';
import 'maplibre-gl/dist/maplibre-gl.css';

interface Sighting {
  id: string;
  entity: string;
  type: string;
  location: string;
  lat: number;
  lng: number;
  threat: string;
  date: string;
  description: string;
}

const MAP_STYLE = 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

const markerColors: Record<string, string> = {
  Low: '#22c55e',
  Medium: '#eab308',
  High: '#f97316',
  Extreme: '#ef4444',
};

export default function SightingsPage() {
  const [sightings, setSightings] = useState<Sighting[]>([]);
  const [allTypes, setAllTypes] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<Sighting | null>(null);
  const [filterType, setFilterType] = useState<string>('All');
  const [filterThreat, setFilterThreat] = useState<string>('All');

  useEffect(() => {
    fetch('/api/sightings?limit=1000')
      .then(r => r.json())
      .then(data => {
        if (data.error) throw new Error(data.error);
        setSightings(data.sightings);
        setAllTypes(data.types);
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  const types = ['All', ...allTypes];
  const threats = ['All', 'Low', 'Medium', 'High', 'Extreme'];

  const filtered = useMemo(() => {
    return sightings.filter(s => {
      if (filterType !== 'All' && s.type !== filterType) return false;
      if (filterThreat !== 'All' && s.threat !== filterThreat) return false;
      return true;
    });
  }, [sightings, filterType, filterThreat]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="w-8 h-8 text-ghost-green animate-spin" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="p-6 bg-red-500/10 border border-red-500/30 rounded-2xl text-red-400">
          Failed to load sightings: {error}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} className="mb-6">
        <h1 className="text-4xl font-creepy text-ghost-green text-glow tracking-wider">
          Sightings Map
        </h1>
        <p className="text-gray-400 mt-2">Interactive view of paranormal activity across the region — {sightings.length} sightings loaded</p>
      </motion.div>

      <div className="flex flex-wrap gap-3 mb-6">
        <div className="flex items-center gap-2">
          <Filter className="w-4 h-4 text-gray-500" />
          <span className="text-sm text-gray-400">Filter:</span>
        </div>
        <select
          value={filterType}
          onChange={(e) => setFilterType(e.target.value)}
          className="px-3 py-1.5 rounded-lg bg-ghost-card border border-ghost-border text-sm text-gray-300 focus:border-ghost-green focus:outline-none"
        >
          {types.map(t => <option key={t} value={t}>{t === 'All' ? 'All Types' : t}</option>)}
        </select>
        <select
          value={filterThreat}
          onChange={(e) => setFilterThreat(e.target.value)}
          className="px-3 py-1.5 rounded-lg bg-ghost-card border border-ghost-border text-sm text-gray-300 focus:border-ghost-green focus:outline-none"
        >
          {threats.map(t => <option key={t} value={t}>{t === 'All' ? 'All Threats' : t}</option>)}
        </select>
        <span className="text-sm text-gray-500 ml-2">{filtered.length} sightings</span>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <div className="lg:col-span-3 rounded-2xl overflow-hidden border border-ghost-border h-[600px]">
          <Map
            initialViewState={{ longitude: -73.5, latitude: 41.2, zoom: 7 }}
            mapStyle={MAP_STYLE}
            style={{ width: '100%', height: '100%' }}
          >
            <NavigationControl position="top-right" />
            {filtered.map((s) => (
              <Marker
                key={s.id}
                latitude={s.lat}
                longitude={s.lng}
                anchor="bottom"
                onClick={(e) => { e.originalEvent.stopPropagation(); setSelected(s); }}
              >
                <div className="cursor-pointer relative group">
                  <MapPin
                    className="w-7 h-7 drop-shadow-lg transition-transform group-hover:scale-125"
                    style={{ color: markerColors[s.threat] }}
                    fill={`${markerColors[s.threat]}33`}
                  />
                </div>
              </Marker>
            ))}
            {selected && (
              <Popup
                latitude={selected.lat}
                longitude={selected.lng}
                onClose={() => setSelected(null)}
                closeOnClick={false}
                className="ghost-popup"
                maxWidth="300px"
              >
                <div className="p-3 bg-ghost-card rounded-lg text-sm">
                  <div className="flex items-center gap-2 mb-2">
                    <Ghost className="w-4 h-4 text-ghost-green" />
                    <span className="font-bold text-white">{selected.entity}</span>
                  </div>
                  <p className="text-xs text-gray-400 mb-1">{selected.location}</p>
                  <p className="text-xs text-gray-500 mb-2 line-clamp-2">{selected.description}</p>
                  <div className="flex justify-between items-center text-xs">
                    <span className="text-gray-500">{selected.date}</span>
                    <span style={{ color: markerColors[selected.threat] }}>{selected.threat}</span>
                  </div>
                  <Link
                    href={`/sighting/${selected.id}`}
                    className="mt-2 flex items-center gap-1 text-xs text-ghost-green hover:underline"
                  >
                    View full details <ExternalLink className="w-3 h-3" />
                  </Link>
                </div>
              </Popup>
            )}
          </Map>
        </div>

        <div className="space-y-3 max-h-[600px] overflow-y-auto pr-1">
          {filtered.slice(0, 50).map((s, i) => (
            <Link key={s.id} href={`/sighting/${s.id}`}>
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.02 }}
                className={`p-3 rounded-xl border cursor-pointer transition-all mb-3 ${
                  selected?.id === s.id
                    ? 'bg-ghost-green/10 border-ghost-green/50'
                    : 'bg-ghost-card border-ghost-border hover:border-ghost-green/30'
                }`}
              >
                <div className="flex items-center gap-2 mb-1">
                  <Ghost className="w-4 h-4 text-ghost-green" />
                  <span className="text-sm font-medium text-white">{s.entity}</span>
                </div>
                <p className="text-xs text-gray-500">{s.location}</p>
                <div className="flex justify-between mt-2 text-xs">
                  <span className="text-gray-500">{s.date}</span>
                  <span
                    className="px-2 py-0.5 rounded-full border"
                    style={{
                      color: markerColors[s.threat],
                      borderColor: `${markerColors[s.threat]}50`,
                      background: `${markerColors[s.threat]}15`,
                    }}
                  >
                    {s.threat}
                  </span>
                </div>
              </motion.div>
            </Link>
          ))}
          {filtered.length > 50 && (
            <p className="text-xs text-gray-500 text-center py-2">
              Showing 50 of {filtered.length} sightings on sidebar
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
