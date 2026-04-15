import { Link } from 'react-router-dom';
import { Ghost, Activity, MapPin, AlertTriangle, FileAudio, Loader2 } from 'lucide-react';
import { useMedia } from '@/lib/api';
import type { MediaItem } from '@/lib/api';
import { format } from 'date-fns';

export default function Dashboard(): JSX.Element {
  const { data, isLoading, error } = useMedia();

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white">Dashboard</h1>
        <p className="mt-2 text-ghost-purple-300">
          Monitor paranormal activity across all sectors
        </p>
      </div>

      {isLoading && (
        <div className="flex justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-ghost-purple-400" />
        </div>
      )}

      {error && (
        <div className="rounded-lg bg-red-500/10 border border-red-500/30 p-4 text-red-400">
          Failed to load data: {error.message}
        </div>
      )}

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-4">
            <div className="rounded-lg bg-ghost-purple-600/20 p-3">
              <Ghost className="h-6 w-6 text-ghost-purple-400" />
            </div>
            <div>
              <p className="text-sm text-ghost-purple-300">Total Sightings</p>
              <p className="text-2xl font-bold text-white">{data?.stats.sighting_count?.toLocaleString() ?? '\u2014'}</p>
            </div>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-4">
            <div className="rounded-lg bg-threat-high-600/20 p-3">
              <AlertTriangle className="h-6 w-6 text-threat-high-400" />
            </div>
            <div>
              <p className="text-sm text-ghost-purple-300">Audio Recordings</p>
              <p className="text-2xl font-bold text-white">{data?.stats.audio_count?.toLocaleString() ?? '\u2014'}</p>
            </div>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-4">
            <div className="rounded-lg bg-ghost-blue-600/20 p-3">
              <MapPin className="h-6 w-6 text-ghost-blue-400" />
            </div>
            <div>
              <p className="text-sm text-ghost-purple-300">Evidence Items</p>
              <p className="text-2xl font-bold text-white">{data?.stats.evidence_count?.toLocaleString() ?? '\u2014'}</p>
            </div>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-4">
            <div className="rounded-lg bg-threat-low-600/20 p-3">
              <Activity className="h-6 w-6 text-threat-low-400" />
            </div>
            <div>
              <p className="text-sm text-ghost-purple-300">Ghosts Cataloged</p>
              <p className="text-2xl font-bold text-white">{data?.stats.ghost_count?.toLocaleString() ?? '\u2014'}</p>
            </div>
          </div>
        </div>
      </div>

      <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-semibold text-white">Recent Media</h2>
          <Link to="/media" className="text-sm text-ghost-purple-400 transition hover:text-white">
            View all
          </Link>
        </div>
        {data?.media && data.media.length > 0 ? (
          <div className="mt-4 space-y-3">
            {data.media.slice(0, 5).map((item: MediaItem) => (
              <Link
                key={item.id}
                to={`/media/${item.id}`}
                className="flex items-center gap-4 rounded-lg bg-ghost-purple-800/30 p-3 transition hover:bg-ghost-purple-800/50"
              >
                <FileAudio className="h-5 w-5 flex-shrink-0 text-ghost-purple-400" />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium text-white">{item.file_name}</p>
                  <p className="text-xs text-ghost-purple-400">
                    {item.location || 'Unknown location'}
                    {item.date && ` \u00b7 ${format(new Date(item.date), 'MMM d, yyyy')}`}
                  </p>
                </div>
                {item.anomaly && (
                  <AlertTriangle className="h-4 w-4 flex-shrink-0 text-red-400" />
                )}
                {item.classification && (
                  <span className="rounded-full bg-ghost-purple-700/50 px-2 py-0.5 text-xs text-ghost-purple-300">
                    {item.classification}
                  </span>
                )}
              </Link>
            ))}
          </div>
        ) : (
          <p className="mt-4 text-ghost-purple-300">
            {isLoading ? 'Loading...' : 'No media captured yet. Start by recording audio or taking photos.'}
          </p>
        )}
      </div>
    </div>
  );
}
