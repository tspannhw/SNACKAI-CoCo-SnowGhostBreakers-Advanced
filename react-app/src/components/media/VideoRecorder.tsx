import { useRef, useState, useCallback, useEffect } from 'react';
import { Video, Square } from 'lucide-react';
import { useMediaStore } from '@/stores/mediaStore';

export function VideoRecorder(): JSX.Element {
  const videoRef = useRef<HTMLVideoElement>(null);
  const mediaRecorder = useRef<MediaRecorder | null>(null);
  const chunks = useRef<Blob[]>([]);
  const timerRef = useRef<ReturnType<typeof setInterval>>();
  const [error, setError] = useState<string | null>(null);
  const { recording, startRecording, stopRecording, setDuration } = useMediaStore();

  const start = useCallback(async () => {
    try {
      setError(null);
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment', width: { ideal: 1280 }, height: { ideal: 720 } },
        audio: true,
      });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }

      const recorder = new MediaRecorder(stream, { mimeType: 'video/webm;codecs=vp9,opus' });
      chunks.current = [];
      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) chunks.current.push(e.data);
      };
      recorder.onstop = () => {
        const blob = new Blob(chunks.current, { type: 'video/webm' });
        stopRecording(blob);
        stream.getTracks().forEach((t) => t.stop());
        if (timerRef.current) clearInterval(timerRef.current);
      };
      mediaRecorder.current = recorder;
      recorder.start(1000);
      startRecording('video');
      let sec = 0;
      timerRef.current = setInterval(() => {
        sec++;
        setDuration(sec);
      }, 1000);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Camera/mic access denied');
    }
  }, [startRecording, stopRecording, setDuration]);

  const stop = useCallback(() => {
    mediaRecorder.current?.stop();
  }, []);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      mediaRecorder.current?.stream?.getTracks().forEach((t) => t.stop());
    };
  }, []);

  const formatTime = (s: number) => `${Math.floor(s / 60)}:${(s % 60).toString().padStart(2, '0')}`;

  return (
    <div className="space-y-4">
      {error && (
        <div className="rounded-lg bg-red-500/10 border border-red-500/30 p-3 text-sm text-red-400">
          {error}
        </div>
      )}

      {!recording.isRecording && !recording.blob && (
        <div className="flex flex-col items-center gap-4 rounded-xl border border-ghost-purple-700/50 bg-ghost-purple-900/30 p-8">
          <button
            onClick={() => void start()}
            className="flex h-20 w-20 items-center justify-center rounded-full bg-green-600 text-white shadow-lg shadow-green-600/25 transition hover:bg-green-700 active:scale-95"
          >
            <Video className="h-8 w-8" />
          </button>
          <p className="text-sm text-ghost-purple-400">Click to start recording video</p>
        </div>
      )}

      {recording.isRecording && (
        <div className="space-y-4">
          <div className="relative overflow-hidden rounded-xl border border-red-500/50">
            <video ref={videoRef} autoPlay playsInline muted className="w-full" />
            <div className="absolute top-3 right-3 flex items-center gap-2 rounded-full bg-black/60 px-3 py-1 backdrop-blur">
              <span className="h-2 w-2 animate-pulse rounded-full bg-red-500" />
              <span className="font-mono text-sm text-white">{formatTime(recording.duration)}</span>
            </div>
          </div>
          <div className="flex justify-center">
            <button
              onClick={stop}
              className="flex h-14 w-14 items-center justify-center rounded-full bg-red-600 text-white transition hover:bg-red-700"
            >
              <Square className="h-6 w-6" />
            </button>
          </div>
        </div>
      )}

      {recording.blob && recording.previewUrl && (
        <div className="space-y-3">
          <video controls src={recording.previewUrl} className="w-full rounded-xl" />
          <p className="text-center text-sm text-ghost-purple-300">
            {(recording.blob.size / 1024 / 1024).toFixed(1)} MB recorded
          </p>
        </div>
      )}
    </div>
  );
}
