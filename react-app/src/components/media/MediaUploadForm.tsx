import { useState } from 'react';
import { Upload, Loader2, CheckCircle, AlertTriangle } from 'lucide-react';
import { useMediaStore } from '@/stores/mediaStore';
import { useUploadMedia } from '@/lib/api';

export function MediaUploadForm(): JSX.Element {
  const { recording, capturedPhoto, clearCapture } = useMediaStore();
  const upload = useUploadMedia();
  const [meta, setMeta] = useState({
    location_name: '',
    latitude: '',
    longitude: '',
    description: '',
    sighting_id: '',
    ghost_id: '',
    frequency_mhz: '100',
    sweep_rate: 'Medium',
    device_model: '',
  });

  const hasMedia = !!(recording.blob || capturedPhoto);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const blob = recording.blob || capturedPhoto?.blob;
    if (!blob) return;

    const ext = recording.blob
      ? (recording.recordingType === 'video' ? 'webm' : 'webm')
      : 'jpg';
    const fileName = `capture_${Date.now()}.${ext}`;

    const formData = new FormData();
    formData.append('file', blob, fileName);
    Object.entries(meta).forEach(([k, v]) => {
      if (v) formData.append(k, v);
    });

    upload.mutate(formData, {
      onSuccess: () => {
        clearCapture();
        setMeta({ location_name: '', latitude: '', longitude: '', description: '', sighting_id: '', ghost_id: '', frequency_mhz: '100', sweep_rate: 'Medium', device_model: '' });
      },
    });
  };

  if (!hasMedia) {
    return (
      <div className="rounded-xl border border-dashed border-ghost-purple-600/50 bg-ghost-purple-900/20 p-8 text-center">
        <p className="text-ghost-purple-400">Record audio, take a photo, or record video first</p>
      </div>
    );
  }

  return (
    <form onSubmit={(e) => void handleSubmit(e)} className="space-y-4">
      {upload.isSuccess && (
        <div className="flex items-center gap-2 rounded-lg bg-green-500/10 border border-green-500/30 p-3 text-sm text-green-400">
          <CheckCircle className="h-4 w-4" /> Upload successful!
        </div>
      )}
      {upload.isError && (
        <div className="flex items-center gap-2 rounded-lg bg-red-500/10 border border-red-500/30 p-3 text-sm text-red-400">
          <AlertTriangle className="h-4 w-4" /> {upload.error.message}
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-2">
        <label className="space-y-1">
          <span className="text-sm text-ghost-purple-300">Location *</span>
          <input
            required
            value={meta.location_name}
            onChange={(e) => setMeta({ ...meta, location_name: e.target.value })}
            className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
            placeholder="Investigation location"
          />
        </label>
        <label className="space-y-1">
          <span className="text-sm text-ghost-purple-300">Description</span>
          <input
            value={meta.description}
            onChange={(e) => setMeta({ ...meta, description: e.target.value })}
            className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
            placeholder="Notes about this capture"
          />
        </label>
        <label className="space-y-1">
          <span className="text-sm text-ghost-purple-300">Latitude</span>
          <input
            type="number" step="any"
            value={meta.latitude}
            onChange={(e) => setMeta({ ...meta, latitude: e.target.value })}
            className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
            placeholder="40.7128"
          />
        </label>
        <label className="space-y-1">
          <span className="text-sm text-ghost-purple-300">Longitude</span>
          <input
            type="number" step="any"
            value={meta.longitude}
            onChange={(e) => setMeta({ ...meta, longitude: e.target.value })}
            className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
            placeholder="-74.0060"
          />
        </label>
        <label className="space-y-1">
          <span className="text-sm text-ghost-purple-300">Sighting ID</span>
          <input
            value={meta.sighting_id}
            onChange={(e) => setMeta({ ...meta, sighting_id: e.target.value })}
            className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
            placeholder="Link to sighting"
          />
        </label>
        <label className="space-y-1">
          <span className="text-sm text-ghost-purple-300">Ghost ID</span>
          <input
            value={meta.ghost_id}
            onChange={(e) => setMeta({ ...meta, ghost_id: e.target.value })}
            className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
            placeholder="Link to ghost entity"
          />
        </label>
      </div>

      {recording.blob && recording.recordingType === 'audio' && (
        <div className="grid gap-4 md:grid-cols-3">
          <label className="space-y-1">
            <span className="text-sm text-ghost-purple-300">Frequency (MHz)</span>
            <input
              type="number" step="0.1"
              value={meta.frequency_mhz}
              onChange={(e) => setMeta({ ...meta, frequency_mhz: e.target.value })}
              className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white focus:border-ghost-purple-500 focus:outline-none"
            />
          </label>
          <label className="space-y-1">
            <span className="text-sm text-ghost-purple-300">Sweep Rate</span>
            <select
              value={meta.sweep_rate}
              onChange={(e) => setMeta({ ...meta, sweep_rate: e.target.value })}
              className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white focus:border-ghost-purple-500 focus:outline-none"
            >
              <option value="Slow">Slow</option>
              <option value="Medium">Medium</option>
              <option value="Fast">Fast</option>
              <option value="Variable">Variable</option>
            </select>
          </label>
          <label className="space-y-1">
            <span className="text-sm text-ghost-purple-300">Device Model</span>
            <input
              value={meta.device_model}
              onChange={(e) => setMeta({ ...meta, device_model: e.target.value })}
              className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
              placeholder="Spirit Box model"
            />
          </label>
        </div>
      )}

      <button
        type="submit"
        disabled={upload.isPending}
        className="flex w-full items-center justify-center gap-2 rounded-lg bg-ghost-purple-600 px-4 py-3 text-sm font-medium text-white transition hover:bg-ghost-purple-500 disabled:opacity-50"
      >
        {upload.isPending ? (
          <><Loader2 className="h-4 w-4 animate-spin" /> Uploading...</>
        ) : (
          <><Upload className="h-4 w-4" /> Upload &amp; Analyze</>
        )}
      </button>
    </form>
  );
}
