import { useRef, useState, useCallback, useEffect } from 'react';
import { Camera, RotateCcw } from 'lucide-react';
import { useMediaStore } from '@/stores/mediaStore';

export function PhotoCapture(): JSX.Element {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const [cameraActive, setCameraActive] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { capturedPhoto, capturePhoto, clearCapture } = useMediaStore();

  const startCamera = useCallback(async () => {
    try {
      setError(null);
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment', width: { ideal: 1920 }, height: { ideal: 1080 } },
      });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }
      setCameraActive(true);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Camera access denied');
    }
  }, []);

  const takePhoto = useCallback(() => {
    if (!videoRef.current || !canvasRef.current) return;
    const video = videoRef.current;
    const canvas = canvasRef.current;
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    ctx.drawImage(video, 0, 0);
    canvas.toBlob((blob) => {
      if (blob) {
        capturePhoto(blob);
        streamRef.current?.getTracks().forEach((t) => t.stop());
        setCameraActive(false);
      }
    }, 'image/jpeg', 0.92);
  }, [capturePhoto]);

  const retake = useCallback(() => {
    clearCapture();
    void startCamera();
  }, [clearCapture, startCamera]);

  useEffect(() => {
    return () => {
      streamRef.current?.getTracks().forEach((t) => t.stop());
    };
  }, []);

  return (
    <div className="space-y-4">
      {error && (
        <div className="rounded-lg bg-red-500/10 border border-red-500/30 p-3 text-sm text-red-400">
          {error}
        </div>
      )}
      <canvas ref={canvasRef} className="hidden" />

      {!cameraActive && !capturedPhoto && (
        <div className="flex flex-col items-center gap-4 rounded-xl border border-ghost-purple-700/50 bg-ghost-purple-900/30 p-8">
          <button
            onClick={() => void startCamera()}
            className="flex h-20 w-20 items-center justify-center rounded-full bg-ghost-blue-600 text-white shadow-lg shadow-ghost-blue-600/25 transition hover:bg-ghost-blue-700 active:scale-95"
          >
            <Camera className="h-8 w-8" />
          </button>
          <p className="text-sm text-ghost-purple-400">Click to open camera</p>
        </div>
      )}

      {cameraActive && (
        <div className="relative overflow-hidden rounded-xl border border-ghost-purple-700/50">
          <video ref={videoRef} autoPlay playsInline muted className="w-full" />
          <div className="absolute bottom-4 left-0 right-0 flex justify-center">
            <button
              onClick={takePhoto}
              className="flex h-16 w-16 items-center justify-center rounded-full border-4 border-white bg-white/20 text-white backdrop-blur transition hover:bg-white/30 active:scale-95"
            >
              <div className="h-12 w-12 rounded-full bg-white" />
            </button>
          </div>
        </div>
      )}

      {capturedPhoto && (
        <div className="space-y-3">
          <img src={capturedPhoto.previewUrl} alt="Captured" className="w-full rounded-xl" />
          <div className="flex justify-center">
            <button
              onClick={retake}
              className="flex items-center gap-2 rounded-lg bg-ghost-purple-700 px-4 py-2 text-sm text-white transition hover:bg-ghost-purple-600"
            >
              <RotateCcw className="h-4 w-4" /> Retake
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
