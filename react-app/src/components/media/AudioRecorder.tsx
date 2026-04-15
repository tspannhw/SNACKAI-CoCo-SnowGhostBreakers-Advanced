import { useRef, useState, useCallback, useEffect } from 'react';
import { Mic, Square, Pause, Play } from 'lucide-react';
import { useMediaStore } from '@/stores/mediaStore';

export function AudioRecorder(): JSX.Element {
  const mediaRecorder = useRef<MediaRecorder | null>(null);
  const chunks = useRef<Blob[]>([]);
  const timerRef = useRef<ReturnType<typeof setInterval>>();
  const [paused, setPaused] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { recording, startRecording, stopRecording, setDuration } = useMediaStore();

  const start = useCallback(async () => {
    try {
      setError(null);
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const recorder = new MediaRecorder(stream, { mimeType: 'audio/webm;codecs=opus' });
      chunks.current = [];

      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) chunks.current.push(e.data);
      };
      recorder.onstop = () => {
        const blob = new Blob(chunks.current, { type: 'audio/webm' });
        stopRecording(blob);
        stream.getTracks().forEach((t) => t.stop());
        if (timerRef.current) clearInterval(timerRef.current);
      };

      mediaRecorder.current = recorder;
      recorder.start(1000);
      startRecording('audio');
      let sec = 0;
      timerRef.current = setInterval(() => {
        sec++;
        setDuration(sec);
      }, 1000);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Microphone access denied');
    }
  }, [startRecording, stopRecording, setDuration]);

  const stop = useCallback(() => {
    mediaRecorder.current?.stop();
  }, []);

  const togglePause = useCallback(() => {
    if (!mediaRecorder.current) return;
    if (paused) {
      mediaRecorder.current.resume();
      setPaused(false);
    } else {
      mediaRecorder.current.pause();
      setPaused(true);
    }
  }, [paused]);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      mediaRecorder.current?.stream?.getTracks().forEach((t) => t.stop());
    };
  }, []);

  const formatTime = (s: number) => {
    const m = Math.floor(s / 60);
    const sec = s % 60;
    return `${m}:${sec.toString().padStart(2, '0')}`;
  };

  return (
    <div className="space-y-4">
      {error && (
        <div className="rounded-lg bg-red-500/10 border border-red-500/30 p-3 text-sm text-red-400">
          {error}
        </div>
      )}

      <div className="flex flex-col items-center gap-4 rounded-xl border border-ghost-purple-700/50 bg-ghost-purple-900/30 p-8">
        {!recording.isRecording && !recording.blob && (
          <button
            onClick={() => void start()}
            className="flex h-20 w-20 items-center justify-center rounded-full bg-red-500 text-white shadow-lg shadow-red-500/25 transition hover:bg-red-600 active:scale-95"
          >
            <Mic className="h-8 w-8" />
          </button>
        )}

        {recording.isRecording && (
          <>
            <div className="flex items-center gap-2">
              <span className="h-3 w-3 animate-pulse rounded-full bg-red-500" />
              <span className="font-mono text-2xl text-white">{formatTime(recording.duration)}</span>
            </div>
            <div className="flex gap-3">
              <button
                onClick={togglePause}
                className="flex h-12 w-12 items-center justify-center rounded-full bg-ghost-purple-700 text-white transition hover:bg-ghost-purple-600"
              >
                {paused ? <Play className="h-5 w-5" /> : <Pause className="h-5 w-5" />}
              </button>
              <button
                onClick={stop}
                className="flex h-12 w-12 items-center justify-center rounded-full bg-red-600 text-white transition hover:bg-red-700"
              >
                <Square className="h-5 w-5" />
              </button>
            </div>
          </>
        )}

        {recording.blob && recording.previewUrl && (
          <div className="w-full space-y-3">
            <audio controls src={recording.previewUrl} className="w-full" />
            <p className="text-center text-sm text-ghost-purple-300">
              {(recording.blob.size / 1024).toFixed(1)} KB recorded
            </p>
          </div>
        )}

        {!recording.isRecording && !recording.blob && (
          <p className="text-sm text-ghost-purple-400">Click to start recording audio</p>
        )}
      </div>
    </div>
  );
}
