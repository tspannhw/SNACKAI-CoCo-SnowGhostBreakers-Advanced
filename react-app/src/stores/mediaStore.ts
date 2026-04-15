import { create } from 'zustand';

interface MediaRecordingState {
  isRecording: boolean;
  recordingType: 'audio' | 'video' | null;
  duration: number;
  blob: Blob | null;
  previewUrl: string | null;
}

interface MediaStore {
  recording: MediaRecordingState;
  capturedPhoto: { blob: Blob; previewUrl: string } | null;
  startRecording: (type: 'audio' | 'video') => void;
  stopRecording: (blob: Blob) => void;
  setDuration: (d: number) => void;
  capturePhoto: (blob: Blob) => void;
  clearCapture: () => void;
}

export const useMediaStore = create<MediaStore>((set, get) => ({
  recording: { isRecording: false, recordingType: null, duration: 0, blob: null, previewUrl: null },
  capturedPhoto: null,
  startRecording: (type) => set({
    recording: { isRecording: true, recordingType: type, duration: 0, blob: null, previewUrl: null },
    capturedPhoto: null,
  }),
  stopRecording: (blob) => {
    const prev = get().recording.previewUrl;
    if (prev) URL.revokeObjectURL(prev);
    set({
      recording: {
        ...get().recording,
        isRecording: false,
        blob,
        previewUrl: URL.createObjectURL(blob),
      },
    });
  },
  setDuration: (d) => set({ recording: { ...get().recording, duration: d } }),
  capturePhoto: (blob) => {
    const prev = get().capturedPhoto?.previewUrl;
    if (prev) URL.revokeObjectURL(prev);
    set({ capturedPhoto: { blob, previewUrl: URL.createObjectURL(blob) }, recording: { isRecording: false, recordingType: null, duration: 0, blob: null, previewUrl: null } });
  },
  clearCapture: () => {
    const r = get().recording.previewUrl;
    const p = get().capturedPhoto?.previewUrl;
    if (r) URL.revokeObjectURL(r);
    if (p) URL.revokeObjectURL(p);
    set({
      recording: { isRecording: false, recordingType: null, duration: 0, blob: null, previewUrl: null },
      capturedPhoto: null,
    });
  },
}));
