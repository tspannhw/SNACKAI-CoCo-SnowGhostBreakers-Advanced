'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { motion, AnimatePresence } from 'framer-motion';
import { Ghost, MapPin, FileSearch, CheckCircle, ChevronRight, ChevronLeft, Loader2, Zap } from 'lucide-react';
import MapPicker from './MapPicker';
import FileDropZone from './FileDropZone';

const GHOST_TYPES = ['Apparition', 'Poltergeist', 'Shadow Entity', 'Ectoplasmic Entity', 'Orb', 'Living Skeleton', 'Leprechaun', 'Evil Rabbit', 'Ghoul', 'Banshee', 'Wraith', 'Specter'];
const THREAT_LEVELS = ['Low', 'Medium', 'High', 'Extreme'];
const EVIDENCE_TYPES = ['Visual', 'EMF', 'Temperature', 'Audio', 'Photograph', 'Multiple'];
const STATUSES = ['Active', 'Dormant', 'Captured', 'Neutralized'];
const FREQUENCIES = ['Rare', 'Occasional', 'Frequent', 'Constant'];

interface FormData {
  ghost_name: string;
  ghost_type: string;
  threat_level: string;
  description: string;
  origin_story: string;
  manifestation_frequency: string;
  status: string;
  confidence_score: number;
  location_name: string;
  location_address: string;
  latitude: number;
  longitude: number;
  sighting_datetime: string;
  witness_name: string;
  witness_contact: string;
  environmental_conditions: string;
  temperature_celsius: number;
  emf_reading: number;
  evidence_type: string;
  paranormal_activity_level: number;
  investigation_notes: string;
}

const steps = [
  { id: 0, title: 'Entity', icon: Ghost, desc: 'Ghost details' },
  { id: 1, title: 'Location', icon: MapPin, desc: 'Sighting info' },
  { id: 2, title: 'Evidence', icon: FileSearch, desc: 'Upload files' },
  { id: 3, title: 'Review', icon: CheckCircle, desc: 'Confirm & submit' },
];

export default function GhostForm() {
  const [step, setStep] = useState(0);
  const [files, setFiles] = useState<File[]>([]);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const { register, handleSubmit, watch, setValue, formState: { errors } } = useForm<FormData>({
    defaultValues: {
      ghost_type: 'Apparition',
      threat_level: 'Low',
      status: 'Active',
      manifestation_frequency: 'Occasional',
      confidence_score: 0.8,
      latitude: 0,
      longitude: 0,
      temperature_celsius: 20,
      emf_reading: 5,
      evidence_type: 'Visual',
      paranormal_activity_level: 5,
      sighting_datetime: new Date().toISOString().slice(0, 16),
    },
  });

  const formValues = watch();

  const onSubmit = async (data: FormData) => {
    setSubmitting(true);
    try {
      const res = await fetch('/api/upload', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (res.ok) {
        setSubmitted(true);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setSubmitting(false);
    }
  };

  if (submitted) {
    return (
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="text-center py-20"
      >
        <motion.div
          animate={{ rotate: [0, 10, -10, 0], scale: [1, 1.2, 1] }}
          transition={{ duration: 0.6 }}
          className="text-8xl mb-6 inline-block"
        >
          👻
        </motion.div>
        <h2 className="text-3xl font-creepy text-ghost-green text-glow mb-4">Sighting Recorded!</h2>
        <p className="text-gray-400 mb-8">The paranormal activity has been logged to the database.</p>
        <button
          onClick={() => { setSubmitted(false); setStep(0); }}
          className="px-6 py-3 bg-ghost-green/20 border border-ghost-green/50 rounded-xl text-ghost-green hover:bg-ghost-green/30 transition-all"
        >
          Report Another Sighting
        </button>
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
            {i < steps.length - 1 && (
              <ChevronRight className="w-4 h-4 text-gray-600 mx-1" />
            )}
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
                  <Ghost className="w-6 h-6" /> Paranormal Entity Details
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <Field label="Ghost Name" error={errors.ghost_name?.message}>
                    <input {...register('ghost_name', { required: 'Name is required' })} className="form-input" placeholder="The Shadowy Figure" />
                  </Field>
                  <Field label="Ghost Type">
                    <select {...register('ghost_type')} className="form-input">
                      {GHOST_TYPES.map(t => <option key={t} value={t}>{t}</option>)}
                    </select>
                  </Field>
                  <Field label="Threat Level">
                    <div className="flex gap-2">
                      {THREAT_LEVELS.map(t => (
                        <button
                          key={t}
                          type="button"
                          onClick={() => setValue('threat_level', t)}
                          className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
                            formValues.threat_level === t
                              ? t === 'Low' ? 'bg-green-500/20 border border-green-500/50 text-green-400'
                              : t === 'Medium' ? 'bg-yellow-500/20 border border-yellow-500/50 text-yellow-400'
                              : t === 'High' ? 'bg-orange-500/20 border border-orange-500/50 text-orange-400'
                              : 'bg-red-500/20 border border-red-500/50 text-red-400'
                              : 'bg-ghost-dark border border-ghost-border text-gray-500 hover:text-gray-300'
                          }`}
                        >
                          {t}
                        </button>
                      ))}
                    </div>
                  </Field>
                  <Field label="Status">
                    <select {...register('status')} className="form-input">
                      {STATUSES.map(s => <option key={s} value={s}>{s}</option>)}
                    </select>
                  </Field>
                  <Field label="Manifestation Frequency">
                    <select {...register('manifestation_frequency')} className="form-input">
                      {FREQUENCIES.map(f => <option key={f} value={f}>{f}</option>)}
                    </select>
                  </Field>
                  <Field label="Confidence Score">
                    <input type="number" step="0.01" min="0" max="1" {...register('confidence_score', { valueAsNumber: true })} className="form-input" />
                  </Field>
                </div>
                <Field label="Description">
                  <textarea {...register('description', { required: 'Description is required', minLength: { value: 10, message: 'Min 10 characters' }, maxLength: { value: 5000, message: 'Max 5000 characters' } })} rows={3} className="form-input resize-none" placeholder="Describe the entity..." />
                </Field>
                <Field label="Origin Story">
                  <textarea {...register('origin_story')} rows={2} className="form-input resize-none" placeholder="Known history of this entity..." />
                </Field>
              </div>
            )}

            {step === 1 && (
              <div className="space-y-6 bg-ghost-card border border-ghost-border rounded-2xl p-8">
                <h3 className="text-xl font-creepy text-ghost-green text-glow flex items-center gap-2">
                  <MapPin className="w-6 h-6" /> Sighting Location & Details
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <Field label="Location Name">
                    <input {...register('location_name', { required: 'Location is required' })} className="form-input" placeholder="Old Cemetery" />
                  </Field>
                  <Field label="Address">
                    <input {...register('location_address')} className="form-input" placeholder="123 Spooky Lane, NYC" />
                  </Field>
                </div>
                <MapPicker
                  latitude={formValues.latitude}
                  longitude={formValues.longitude}
                  onLocationChange={(lat, lng) => { setValue('latitude', lat); setValue('longitude', lng); }}
                />
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <Field label="Date & Time">
                    <input type="datetime-local" {...register('sighting_datetime')} className="form-input" />
                  </Field>
                  <Field label="Witness Name">
                    <input {...register('witness_name')} className="form-input" placeholder="John Doe" />
                  </Field>
                  <Field label="Witness Contact">
                    <input {...register('witness_contact')} className="form-input" placeholder="email@example.com" />
                  </Field>
                  <Field label="Evidence Type">
                    <select {...register('evidence_type')} className="form-input">
                      {EVIDENCE_TYPES.map(e => <option key={e} value={e}>{e}</option>)}
                    </select>
                  </Field>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <Field label="Temperature (°C)">
                    <input type="number" step="0.1" {...register('temperature_celsius', { valueAsNumber: true })} className="form-input" />
                  </Field>
                  <Field label="EMF Reading">
                    <input type="number" step="0.1" {...register('emf_reading', { valueAsNumber: true })} className="form-input" />
                  </Field>
                  <Field label="Activity Level (1-10)">
                    <input type="range" min="1" max="10" {...register('paranormal_activity_level', { valueAsNumber: true })} className="w-full accent-ghost-green mt-2" />
                    <span className="text-ghost-green text-sm font-bold">{formValues.paranormal_activity_level}</span>
                  </Field>
                </div>
                <Field label="Environmental Conditions">
                  <input {...register('environmental_conditions')} className="form-input" placeholder="Cold spot detected, EMF spike..." />
                </Field>
                <Field label="Investigation Notes">
                  <textarea {...register('investigation_notes')} rows={2} className="form-input resize-none" placeholder="Additional notes..." />
                </Field>
              </div>
            )}

            {step === 2 && (
              <div className="space-y-6 bg-ghost-card border border-ghost-border rounded-2xl p-8">
                <h3 className="text-xl font-creepy text-ghost-green text-glow flex items-center gap-2">
                  <FileSearch className="w-6 h-6" /> Evidence Upload
                </h3>
                <p className="text-gray-400 text-sm">Upload photos, audio recordings, or video evidence of the paranormal encounter.</p>
                <FileDropZone onFilesChange={setFiles} />
              </div>
            )}

            {step === 3 && (
              <div className="space-y-6 bg-ghost-card border border-ghost-border rounded-2xl p-8">
                <h3 className="text-xl font-creepy text-ghost-green text-glow flex items-center gap-2">
                  <CheckCircle className="w-6 h-6" /> Review & Submit
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <ReviewSection title="Entity">
                    <ReviewItem label="Name" value={formValues.ghost_name} />
                    <ReviewItem label="Type" value={formValues.ghost_type} />
                    <ReviewItem label="Threat" value={formValues.threat_level} />
                    <ReviewItem label="Status" value={formValues.status} />
                    <ReviewItem label="Confidence" value={String(formValues.confidence_score)} />
                  </ReviewSection>
                  <ReviewSection title="Sighting">
                    <ReviewItem label="Location" value={formValues.location_name} />
                    <ReviewItem label="Coordinates" value={`${formValues.latitude?.toFixed(4)}, ${formValues.longitude?.toFixed(4)}`} />
                    <ReviewItem label="Date" value={formValues.sighting_datetime} />
                    <ReviewItem label="Witness" value={formValues.witness_name} />
                    <ReviewItem label="Activity Level" value={String(formValues.paranormal_activity_level)} />
                  </ReviewSection>
                </div>
                {formValues.description && (
                  <div className="p-4 rounded-lg bg-ghost-dark border border-ghost-border">
                    <p className="text-xs text-gray-500 mb-1">Description</p>
                    <p className="text-sm text-gray-300">{formValues.description}</p>
                  </div>
                )}
                {files.length > 0 && (
                  <p className="text-sm text-gray-400">{files.length} evidence file(s) attached</p>
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
              className="flex items-center gap-2 px-6 py-3 rounded-xl text-sm font-medium bg-ghost-green/20 border border-ghost-green/50 text-ghost-green hover:bg-ghost-green/30 hover:shadow-ghost transition-all"
            >
              Next <ChevronRight className="w-4 h-4" />
            </button>
          ) : (
            <motion.button
              type="submit"
              disabled={submitting}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="flex items-center gap-2 px-8 py-3 rounded-xl text-sm font-bold bg-ghost-green text-ghost-darker hover:shadow-ghost-lg transition-all disabled:opacity-50"
            >
              {submitting ? (
                <><Loader2 className="w-4 h-4 animate-spin" /> Submitting...</>
              ) : (
                <><Zap className="w-4 h-4" /> Submit Sighting</>
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
