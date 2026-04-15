import { useState } from 'react';
import { Link } from 'react-router-dom';
import { FileAudio, Image, Video, AlertTriangle, Loader2, Radio } from 'lucide-react';
import { useMedia } from '@/lib/api';
import type { MediaItem } from '@/lib/api';
import { format } from 'date-fns';

function MediaTypeIcon({ type }: { type: string }): JSX.Element {
  switch (type) {
    case 'audio': return <FileAudio className="h-5 w-5 text-ghost-purple-400" />;
    case 'image': return <Image className="h-5 w-5 text-ghost-blue-400" />;
    case 'video': return <Video className="h-5 w-5 text-green-400" />;
    default: return <Radio className="h-5 w-5 text-gray-400" />;
  }
}

function formatFileSize(bytes: number | null): string {
  if (!bytes) return '\u2014';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1048576) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1048576).toFixed(1)} MB`;
}

export default function MediaDashboard(): JSX.Element {
  const [typeFilter, setTypeFilter] = useState<string>('all');
  const { data, isLoading, error } = useMedia(typeFilter);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white">Media Dashboard</h1>
          <p className="mt-2 text-ghost-purple-300">All captured audio, images, and video evidence</p>
        </div>
        <Link
          to="/capture"
          className="rounded-lg bg-ghost-purple-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-ghost-purple-500"
        >
          + New Capture
        </Link>
      </div>

      {data?.stats && (
        <div className="grid gap-4 md:grid-cols-4">
          <StatCard icon={<FileAudio className="h-6 w-6 text-ghost-purple-400" />} label="Audio Recordings" value={data.stats.audio_count} />
          <StatCard icon={<Image className="h-6 w-6 text-ghost-blue-400" />} label="Evidence Items" value={data.stats.evidence_count} />
          <StatCard icon={<Radio className="h-6 w-6 text-green-400" />} label="Ghosts Cataloged" value={data.stats.ghost_count} />
          <StatCard icon={<AlertTriangle className="h-6 w-6 text-yellow-400" />} label="Total Sightings" value={data.stats.sighting_count} />
        </div>
      )}

      <div className="flex gap-2">
        {['all', 'audio', 'image', 'video'].map((t) => (
          <button
            key={t}
            onClick={() => setTypeFilter(t)}
            className={`rounded-lg px-3 py-1.5 text-sm transition ${
              typeFilter === t
                ? 'bg-ghost-purple-600 text-white'
                : 'bg-ghost-purple-900/50 text-ghost-purple-300 hover:bg-ghost-purple-800/50'
            }`}
          >
            {t.charAt(0).toUpperCase() + t.slice(1)}
          </button>
        ))}
      </div>

      {isLoading && (
        <div className="flex justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-ghost-purple-400" />
        </div>
      )}

      {error && (
        <div className="rounded-lg bg-red-500/10 border border-red-500/30 p-4 text-red-400">
          {error.message}
        </div>
      )}

      {data?.media && data.media.length > 0 && (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {data.media.map((item: MediaItem) => (
            <MediaCard key={item.id} item={item} />
          ))}
        </div>
      )}

      {data?.media && data.media.length === 0 && (
        <div className="rounded-xl border border-dashed border-ghost-purple-700/50 bg-ghost-purple-900/20 p-12 text-center">
          <p className="text-ghost-purple-400">No media found. Start capturing!</p>
        </div>
      )}
    </div>
  );
}

function StatCard({ icon, label, value }: { icon: React.ReactNode; label: string; value: number }): JSX.Element {
  return (
    <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
      <div className="flex items-center gap-4">
        <div className="rounded-lg bg-ghost-purple-600/20 p-3">{icon}</div>
        <div>
          <p className="text-sm text-ghost-purple-300">{label}</p>
          <p className="text-2xl font-bold text-white">{value.toLocaleString()}</p>
        </div>
      </div>
    </div>
  );
}

function MediaCard({ item }: { item: MediaItem }): JSX.Element {
  return (
    <Link to={`/media/${item.id}`} className="card bg-ghost-purple-900/50 border-ghost-purple-700/50 transition hover:border-ghost-purple-500/50 block">
      <div className="flex items-start gap-3">
        <MediaTypeIcon type={item.media_type} />
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-white">{item.file_name}</p>
          <p className="text-xs text-ghost-purple-400">{item.location || 'Unknown location'}</p>
        </div>
        {item.anomaly && (
          <AlertTriangle className="h-4 w-4 flex-shrink-0 text-red-400" />
        )}
      </div>
      <div className="mt-3 flex items-center gap-3 text-xs text-ghost-purple-400">
        <span>{item.media_type}</span>
        <span>&middot;</span>
        <span>{formatFileSize(item.file_size)}</span>
        {item.date && (
          <>
            <span>&middot;</span>
            <span>{format(new Date(item.date), 'MMM d, yyyy')}</span>
          </>
        )}
      </div>
      {item.summary && (
        <p className="mt-2 line-clamp-2 text-xs text-ghost-purple-300">{item.summary}</p>
      )}
      {item.classification && (
        <span className="mt-2 inline-block rounded-full bg-ghost-purple-800/50 px-2 py-0.5 text-xs text-ghost-purple-300">
          {item.classification}
        </span>
      )}
    </Link>
  );
}
