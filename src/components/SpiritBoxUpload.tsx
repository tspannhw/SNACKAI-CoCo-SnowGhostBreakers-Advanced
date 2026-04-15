'use client';

import { useState, useCallback } from 'react';
import { useForm } from 'react-hook-form';
import { useDropzone } from 'react-dropzone';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Radio, Upload, MapPin, FileAudio, X, Loader2, Zap,
  ChevronRight, ChevronLeft, CheckCircle, AlertTriangle, Brain,
} from 'lucide-react';
import MapPicker from './MapPicker';

const SWEEP_RATES = ['Slow', 'Medium', 'Fast', 'Variable'];

interface FormData {
  location_name: string;
  latitude: number;
  longitude: number;
  recording_datetime: string;
  frequency_mhz: number;
  sweep_rate: string;
  device_model: string;
  sighting_id: string;
  ghost_id: string;
  notes: string;
}

interface AnalysisResult {
  recording_id: string;
  transcript: string;
  summary: string;
  classification: string;
  sentiment: number;
  anomaly_detected: boolean;
  anomaly_description: string;
  processing_ms: number;
}

const steps = [
  { id: 0, title: 'Audio', icon: FileAudio, desc: 'Upload recording' },
  { id: 1, title: 'Details', icon: Radio, desc: 'Session info' },
  { id: 2, title: 'Location', icon: MapPin, desc: 'Where recorded' },
  { id: 3, title: 'Analyze', icon: Brain, desc: 'AI processing' },
];

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1048576) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1048576).toFixed(1)} MB`;
}

export default function SpiritBoxUpload() {
  const [step, setStep] = useState(0);
  const [audioFile, setAudioFile] = useState<File | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState<AnalysisResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const { register, handleSubmit, watch, setValue, formState: { errors } } = useForm<FormData>({
    defaultValues: {
      latitude: 0,
      longitude: 0,
      frequency_mhz: 100,
      sweep_rate: 'Medium',
      device_model: '',
      sighting_id: '',
      ghost_id: '',
      notes: '',
      recording_datetime: new Date().toISOString().slice(0, 16),
    },
  });

  const formValues = watch();

  const onDrop = useCallback((accepted: File[]) => {
    if (accepted.length > 0) setAudioFile(accepted[0]);
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'audio/*': ['.wav', '.mp3', '.ogg', '.m4a', '.flac'] },
    maxSize: 50 * 1024 * 1024,
    maxFiles: 1,
  });

  const onSubmit = async (data: FormData) => {
    if (!audioFile) return;
    setSubmitting(true);
    setError(null);

    try {
      const fd = new FormData();
      fd.append('audio', audioFile);
      Object.entries(data).forEach(([k, v]) => fd.append(k, String(v)));

      const res = await fetch('/api/spirit-box', { method: 'POST', body: fd });
      const json = await res.json();

      if (!res.ok || !json.success) {
        throw new Error(json.error || 'Processing failed');
      }

      setResult({
        recording_id: json.recording_id,
        ...json.analysis,
      });
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  };

  if (result) {
    return (
      <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="space-y-6">
        <div className="text-center py-6">
          <div className="text-6xl mb-4">{result.anomaly_detected ? '👻' : '📻'}</div>
          <h2 className="text-3xl font-creepy text-ghost-green text-glow mb-2">Analysis Complete</h2>
          <p className="text-gray-400">Recording ID: {result.recording_id}</p>
          <p className="text-xs text-gray-500 mt-1">Processed in {(result.processing_ms / 1000).toFixed(1)}s</p>
        </div>

        {result.anomaly_detected && (
          <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/30 flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-red-400 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-sm font-bold text-red-400">Anomaly Detected</p>
              <p className="text-sm text-red-300/80">{result.anomaly_description}</p>
            </div>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="p-4 rounded-xl bg-ghost-card border border-ghost-border">
            <p className="text-xs text-gray-500 mb-1">Classification</p>
            <p className="text-sm font-medium text-ghost-green">{result.classification}</p>
          </div>
          <div className="p-4 rounded-xl bg-ghost-card border border-ghost-border">
            <p className="text-xs text-gray-500 mb-1">Sentiment</p>
            <p className={`text-sm font-medium ${result.sentiment < -0.3 ? 'text-red-400' : result.sentiment > 0.3 ? 'text-green-400' : 'text-yellow-400'}`}>
              {result.sentiment.toFixed(3)} ({result.sentiment < -0.3 ? 'Negative' : result.sentiment > 0.3 ? 'Positive' : 'Neutral'})
            </p>
          </div>
          <div className="p-4 rounded-xl bg-ghost-card border border-ghost-border">
            <p className="text-xs text-gray-500 mb-1">Anomaly</p>
            <p className={`text-sm font-medium ${result.anomaly_detected ? 'text-red-400' : 'text-green-400'}`}>
              {result.anomaly_detected ? 'Detected' : 'None'}
            </p>
          </div>
        </div>

        {result.summary && (
          <div className="p-4 rounded-xl bg-ghost-card border border-ghost-border">
            <p className="text-xs text-gray-500 mb-2">AI Summary</p>
            <p className="text-sm text-gray-300">{result.summary}</p>
          </div>
        )}

        {result.transcript && (
          <div className="p-4 rounded-xl bg-ghost-dark border border-ghost-border">
            <p className="text-xs text-gray-500 mb-2">Transcript</p>
            <pre className="text-sm text-gray-300 whitespace-pre-wrap font-mono max-h-80 overflow-y-auto">{result.transcript}</pre>
          </div>
        )}

        <div className="flex justify-center">
          <button
            onClick={() => { setResult(null); setAudioFile(null); setStep(0); }}
            className="px-6 py-3 bg-ghost-green/20 border border-ghost-green/50 rounded-xl text-ghost-green hover:bg-ghost-green/30 transition-all"
          >
            Upload Another Recording
          </button>
        </div>
      </motion.div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto">
      <div className="flex items-center justify-center gap-2 mb-10">
        {steps.map((s, i) => (
          <div key={s.id} className="flex items-center">
            <button
              onClick={() => setStep(i)}
              className={`flex items-center gap-2 px-4 py-2 rounded-xl transition-all duration-300 ${
                i === step
                  ? 'bg-ghost-green/20 border border-ghost-green/50 text-ghost-green shadow-ghost'
                  : i < step
                  ? 'bg-ghost-purple/20 border border-ghost-purple/30 text-ghost-purple'
                  : 'bg-ghost-card border border-ghost-border text-gray-500'
              }`}
            >
              <s.icon className="w-4 h-4" />
              <span className="text-sm font-medium hidden sm:inline">{s.title}</span>
            </button>
            {i < steps.length - 1 && <ChevronRight className="w-4 h-4 text-gray-600 mx-1" />}
          </div>
        ))}
      </div>

      <form onSubmit={handleSubmit(onSubmit)}>
        <AnimatePresence mode="wait">
          <motion.div
            key={step}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3 }}
          >
            {step === 0 && (
              <div className="space-y-6 bg-ghost-card border border-ghost-border rounded-2xl p-8">
                <h3 className="text-xl font-creepy text-ghost-green text-glow flex items-center gap-2">
                  <FileAudio className="w-6 h-6" /> Spirit Box Recording
                </h3>
                <p className="text-gray-400 text-sm">Upload an audio recording from a Spirit Box session. Supported: WAV, MP3, OGG, M4A, FLAC (max 50MB).</p>

                <div
                  {...getRootProps()}
                  className={`relative border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-all duration-300 ${
                    isDragActive
                      ? 'border-ghost-green bg-ghost-green/10 shadow-ghost'
                      : 'border-ghost-border hover:border-ghost-green/50 hover:bg-ghost-green/5'
                  }`}
                >
                  <input {...getInputProps()} />
                  <motion.div
                    animate={isDragActive ? { scale: 1.1, y: -5 } : { scale: 1, y: 0 }}
                    className="flex flex-col items-center gap-3"
                  >
                    <Upload className={`w-12 h-12 ${isDragActive ? 'text-ghost-green' : 'text-gray-500'}`} />
                    <div>
                      <p className="text-lg font-medium text-gray-300">
                        {isDragActive ? 'Drop your recording here...' : 'Drag & drop Spirit Box audio'}
                      </p>
                      <p className="text-sm text-gray-500 mt-1">WAV, MP3, OGG, M4A, or FLAC - up to 50MB</p>
                    </div>
                  </motion.div>
                </div>

                {audioFile && (
                  <motion.div
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    className="flex items-center gap-3 p-3 rounded-lg bg-ghost-dark border border-ghost-green/30"
                  >
                    <FileAudio className="w-5 h-5 text-ghost-green flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-gray-300 truncate">{audioFile.name}</p>
                      <p className="text-xs text-gray-500">{formatSize(audioFile.size)}</p>
                    </div>
                    <button
                      type="button"
                      onClick={() => setAudioFile(null)}
                      className="p-1 rounded-md hover:bg-red-500/20 text-gray-500 hover:text-red-400 transition-colors"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </motion.div>
                )}
              </div>
            )}

            {step === 1 && (
              <div className="space-y-6 bg-ghost-card border border-ghost-border rounded-2xl p-8">
                <h3 className="text-xl font-creepy text-ghost-green text-glow flex items-center gap-2">
                  <Radio className="w-6 h-6" /> Session Details
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <Field label="Recording Date & Time">
                    <input type="datetime-local" {...register('recording_datetime')} className="form-input" />
                  </Field>
                  <Field label="Frequency (MHz)">
                    <input type="number" step="0.1" {...register('frequency_mhz', { valueAsNumber: true })} className="form-input" placeholder="100" />
                  </Field>
                  <Field label="Sweep Rate">
                    <select {...register('sweep_rate')} className="form-input">
                      {SWEEP_RATES.map(s => <option key={s} value={s}>{s}</option>)}
                    </select>
                  </Field>
                  <Field label="Device Model">
                    <input {...register('device_model')} className="form-input" placeholder="SB-7 Spirit Box" />
                  </Field>
                  <Field label="Linked Sighting ID (optional)">
                    <input {...register('sighting_id')} className="form-input" placeholder="SIGHT_XXXXXXXX" />
                  </Field>
                  <Field label="Linked Ghost ID (optional)">
                    <input {...register('ghost_id')} className="form-input" placeholder="GH_XXXXXXXX" />
                  </Field>
                </div>
                <Field label="Investigator Notes">
                  <textarea {...register('notes')} rows={3} className="form-input resize-none" placeholder="Environmental conditions, observed phenomena..." />
                </Field>
              </div>
            )}

            {step === 2 && (
              <div className="space-y-6 bg-ghost-card border border-ghost-border rounded-2xl p-8">
                <h3 className="text-xl font-creepy text-ghost-green text-glow flex items-center gap-2">
                  <MapPin className="w-6 h-6" /> Recording Location
                </h3>
                <Field label="Location Name" error={errors.location_name?.message}>
                  <input {...register('location_name', { required: 'Location is required' })} className="form-input" placeholder="Old Cemetery, East Wing" />
                </Field>
                <MapPicker
                  latitude={formValues.latitude}
                  longitude={formValues.longitude}
                  onLocationChange={(lat, lng) => { setValue('latitude', lat); setValue('longitude', lng); }}
                />
              </div>
            )}

            {step === 3 && (
              <div className="space-y-6 bg-ghost-card border border-ghost-border rounded-2xl p-8">
                <h3 className="text-xl font-creepy text-ghost-green text-glow flex items-center gap-2">
                  <Brain className="w-6 h-6" /> Review & Analyze
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <ReviewSection title="Recording">
                    <ReviewItem label="File" value={audioFile?.name || 'No file'} />
                    <ReviewItem label="Size" value={audioFile ? formatSize(audioFile.size) : '—'} />
                    <ReviewItem label="Date" value={formValues.recording_datetime} />
                    <ReviewItem label="Frequency" value={`${formValues.frequency_mhz} MHz`} />
                    <ReviewItem label="Sweep Rate" value={formValues.sweep_rate} />
                  </ReviewSection>
                  <ReviewSection title="Location">
                    <ReviewItem label="Name" value={formValues.location_name} />
                    <ReviewItem label="Coords" value={`${formValues.latitude?.toFixed(4)}, ${formValues.longitude?.toFixed(4)}`} />
                    <ReviewItem label="Device" value={formValues.device_model || '—'} />
                    <ReviewItem label="Sighting" value={formValues.sighting_id || '—'} />
                    <ReviewItem label="Ghost" value={formValues.ghost_id || '—'} />
                  </ReviewSection>
                </div>
                {formValues.notes && (
                  <div className="p-4 rounded-lg bg-ghost-dark border border-ghost-border">
                    <p className="text-xs text-gray-500 mb-1">Notes</p>
                    <p className="text-sm text-gray-300">{formValues.notes}</p>
                  </div>
                )}
                <div className="p-4 rounded-xl bg-ghost-purple/10 border border-ghost-purple/30">
                  <p className="text-sm text-ghost-purple">
                    Submitting will upload the audio to Snowflake, then run Cortex AI functions for transcription, entity extraction, classification, sentiment analysis, and summarization. Results are stored and indexed for Cortex Search.
                  </p>
                </div>
                {error && (
                  <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/30">
                    <p className="text-sm text-red-400">{error}</p>
                  </div>
                )}
              </div>
            )}
          </motion.div>
        </AnimatePresence>

        <div className="flex justify-between mt-8">
          <button
            type="button"
            onClick={() => setStep(Math.max(0, step - 1))}
            className={`flex items-center gap-2 px-6 py-3 rounded-xl text-sm font-medium transition-all ${
              step === 0 ? 'invisible' : 'bg-ghost-card border border-ghost-border text-gray-400 hover:text-white hover:border-gray-500'
            }`}
          >
            <ChevronLeft className="w-4 h-4" /> Back
          </button>

          {step < 3 ? (
            <button
              type="button"
              onClick={() => setStep(Math.min(3, step + 1))}
              disabled={step === 0 && !audioFile}
              className="flex items-center gap-2 px-6 py-3 rounded-xl text-sm font-medium bg-ghost-green/20 border border-ghost-green/50 text-ghost-green hover:bg-ghost-green/30 hover:shadow-ghost transition-all disabled:opacity-30 disabled:cursor-not-allowed"
            >
              Next <ChevronRight className="w-4 h-4" />
            </button>
          ) : (
            <motion.button
              type="submit"
              disabled={submitting || !audioFile}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="flex items-center gap-2 px-8 py-3 rounded-xl text-sm font-bold bg-ghost-green text-ghost-darker hover:shadow-ghost-lg transition-all disabled:opacity-50"
            >
              {submitting ? (
                <><Loader2 className="w-4 h-4 animate-spin" /> Analyzing...</>
              ) : (
                <><Zap className="w-4 h-4" /> Upload & Analyze</>
              )}
            </motion.button>
          )}
        </div>
      </form>
    </div>
  );
}

function Field({ label, error, children }: { label: string; error?: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-400 mb-1.5">{label}</label>
      {children}
      {error && <p className="text-xs text-red-400 mt-1">{error}</p>}
    </div>
  );
}

function ReviewSection({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="p-4 rounded-lg bg-ghost-dark border border-ghost-border">
      <h4 className="text-sm font-bold text-ghost-purple mb-3">{title}</h4>
      <div className="space-y-2">{children}</div>
    </div>
  );
}

function ReviewItem({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between">
      <span className="text-xs text-gray-500">{label}</span>
      <span className="text-sm text-gray-300">{value || '—'}</span>
    </div>
  );
}
