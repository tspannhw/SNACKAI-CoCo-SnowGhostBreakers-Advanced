import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:3000';

async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers: { ...init?.headers },
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: res.statusText }));
    throw new Error(err.error || `API error ${res.status}`);
  }
  return res.json();
}

// Types
export interface MediaItem {
  id: string;
  file_name: string;
  media_type: 'audio' | 'image' | 'video' | 'document';
  location: string;
  date: string;
  classification: string | null;
  sentiment: number | null;
  anomaly: boolean;
  summary: string;
  status: string;
  file_size: number | null;
  mime_type: string | null;
  duration: number | null;
}

export interface MediaStats {
  audio_count: number;
  evidence_count: number;
  ghost_count: number;
  sighting_count: number;
  total: number;
}

export interface SpiritBoxRecording {
  id: string;
  file_name: string;
  location: string;
  datetime: string;
  frequency_mhz: number | null;
  sweep_rate: string;
  device_model: string;
  classification: string;
  sentiment: number | null;
  anomaly_detected: boolean;
  summary: string;
  status: string;
  created_at: string;
}

export interface RecordingDetail {
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
  speaker_segments: Array<{ speaker: string; start: number; end: number; text: string }>;
  summary: string;
  entities: unknown[];
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

export interface SearchResult {
  query: string;
  results: Array<Record<string, unknown>>;
  count: number;
  fallback?: boolean;
}

export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface ChatResponse {
  message: string;
  context_used: boolean;
  sources: string;
}

// Hooks
export function useMedia(type?: string) {
  return useQuery({
    queryKey: ['media', type],
    queryFn: () => apiFetch<{ media: MediaItem[]; stats: MediaStats }>(
      `/api/media${type && type !== 'all' ? `?type=${type}` : ''}`
    ),
  });
}

export function useRecordings(filters?: { status?: string; anomaly?: string }) {
  const params = new URLSearchParams();
  if (filters?.status) params.set('status', filters.status);
  if (filters?.anomaly) params.set('anomaly', filters.anomaly);
  const qs = params.toString();
  return useQuery({
    queryKey: ['recordings', filters],
    queryFn: () => apiFetch<{ recordings: SpiritBoxRecording[] }>(
      `/api/spirit-box${qs ? `?${qs}` : ''}`
    ),
  });
}

export function useRecordingDetail(id: string) {
  return useQuery({
    queryKey: ['recording', id],
    queryFn: () => apiFetch<{ recording: RecordingDetail; ghost: { id: string; name: string; type: string; threat_level: string } | null }>(
      `/api/spirit-box/${id}`
    ),
    enabled: !!id,
  });
}

export function useSearch() {
  return useMutation({
    mutationFn: (params: { query: string; limit?: number }) =>
      apiFetch<SearchResult>('/api/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(params),
      }),
  });
}

export function useChat() {
  return useMutation({
    mutationFn: (params: { message: string; history?: ChatMessage[] }) =>
      apiFetch<ChatResponse>('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(params),
      }),
  });
}

export function useUploadMedia() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (formData: FormData) => {
      const res = await fetch(`${API_BASE}/api/media/upload`, {
        method: 'POST',
        body: formData,
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({ error: res.statusText }));
        throw new Error(err.error || 'Upload failed');
      }
      return res.json();
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['media'] });
      void queryClient.invalidateQueries({ queryKey: ['recordings'] });
    },
  });
}
