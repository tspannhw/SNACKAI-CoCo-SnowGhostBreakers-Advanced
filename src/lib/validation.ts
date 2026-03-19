import { z } from 'zod';

const GHOST_TYPES = ['Apparition', 'Poltergeist', 'Shadow Entity', 'Ectoplasmic Entity', 'Orb', 'Living Skeleton', 'Leprechaun', 'Evil Rabbit', 'Ghoul', 'Banshee', 'Wraith', 'Specter'] as const;
const THREAT_LEVELS = ['Low', 'Medium', 'High', 'Extreme'] as const;
const EVIDENCE_TYPES = ['Visual', 'EMF', 'Temperature', 'Audio', 'Photograph', 'Multiple'] as const;
const STATUSES = ['Active', 'Dormant', 'Captured', 'Neutralized'] as const;
const FREQUENCIES = ['Rare', 'Occasional', 'Frequent', 'Constant'] as const;

export const ghostUploadSchema = z.object({
  ghost_name: z.string().min(1, 'Ghost name is required').max(200, 'Name too long'),
  ghost_type: z.enum(GHOST_TYPES, { message: 'Invalid ghost type' }),
  threat_level: z.enum(THREAT_LEVELS, { message: 'Invalid threat level' }),
  description: z.string().min(1, 'Description is required').max(5000, 'Description too long'),
  origin_story: z.string().max(5000).optional().default(''),
  manifestation_frequency: z.enum(FREQUENCIES).optional().default('Occasional'),
  status: z.enum(STATUSES).optional().default('Active'),
  confidence_score: z.number().min(0).max(1).optional().default(0.8),
  location_name: z.string().min(1, 'Location name is required').max(200),
  location_address: z.string().max(500).optional().default(''),
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  sighting_datetime: z.string().min(1, 'Sighting date/time is required'),
  witness_name: z.string().max(200).optional().default(''),
  witness_contact: z.string().max(200).optional().default(''),
  environmental_conditions: z.string().max(1000).optional().default(''),
  temperature_celsius: z.number().min(-50).max(60).optional().default(20),
  emf_reading: z.number().min(0).max(100).optional().default(5),
  evidence_type: z.enum(EVIDENCE_TYPES).optional().default('Visual'),
  paranormal_activity_level: z.number().int().min(1).max(10).optional().default(5),
  investigation_notes: z.string().max(5000).optional().default(''),
});

export type GhostUploadData = z.infer<typeof ghostUploadSchema>;

export { GHOST_TYPES, THREAT_LEVELS, EVIDENCE_TYPES, STATUSES, FREQUENCIES };
