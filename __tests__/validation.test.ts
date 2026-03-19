import { ghostUploadSchema } from '../src/lib/validation';

describe('ghostUploadSchema', () => {
  const validData = {
    ghost_name: 'Princeton Ghoul',
    ghost_type: 'Ghoul',
    threat_level: 'Extreme',
    description: 'A terrifying pale figure spotted near Nassau Hall at dusk',
    location_name: 'Nassau Hall',
    location_address: '1 Nassau Hall, Princeton, NJ',
    latitude: 40.3487,
    longitude: -74.6593,
    sighting_datetime: '2026-03-18T22:30:00',
    witness_name: 'John Doe',
    witness_contact: 'john@ghost.com',
    environmental_conditions: 'Grave soil disturbance',
    temperature_celsius: -5.2,
    emf_reading: 42.5,
    evidence_type: 'Multiple',
    paranormal_activity_level: 9,
    investigation_notes: 'Pack of ghouls observed.',
  };

  test('accepts valid ghost upload data', () => {
    const result = ghostUploadSchema.safeParse(validData);
    expect(result.success).toBe(true);
  });

  test('rejects missing ghost_name', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, ghost_name: '' });
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.flatten().fieldErrors.ghost_name).toBeDefined();
    }
  });

  test('rejects missing description', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, description: '' });
    expect(result.success).toBe(false);
  });

  test('rejects invalid ghost_type', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, ghost_type: 'Unicorn' });
    expect(result.success).toBe(false);
  });

  test('rejects invalid threat_level', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, threat_level: 'Mega' });
    expect(result.success).toBe(false);
  });

  test('rejects latitude out of range', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, latitude: 91 });
    expect(result.success).toBe(false);
  });

  test('rejects longitude out of range', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, longitude: -181 });
    expect(result.success).toBe(false);
  });

  test('rejects confidence_score > 1', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, confidence_score: 1.5 });
    expect(result.success).toBe(false);
  });

  test('rejects paranormal_activity_level > 10', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, paranormal_activity_level: 11 });
    expect(result.success).toBe(false);
  });

  test('rejects invalid evidence_type', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, evidence_type: 'Telepathy' });
    expect(result.success).toBe(false);
  });

  test('applies defaults for optional fields', () => {
    const minimal = {
      ghost_name: 'Test Ghost',
      ghost_type: 'Orb',
      threat_level: 'Low',
      description: 'A simple test ghost sighting for validation',
      location_name: 'Test Location',
      latitude: 40.7,
      longitude: -74.0,
      sighting_datetime: '2026-03-01T10:00:00',
    };
    const result = ghostUploadSchema.safeParse(minimal);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.status).toBe('Active');
      expect(result.data.confidence_score).toBe(0.8);
      expect(result.data.evidence_type).toBe('Visual');
      expect(result.data.paranormal_activity_level).toBe(5);
    }
  });

  test('accepts all valid ghost types', () => {
    const types = ['Apparition', 'Poltergeist', 'Shadow Entity', 'Ectoplasmic Entity', 'Orb', 'Living Skeleton', 'Leprechaun', 'Evil Rabbit', 'Ghoul', 'Banshee', 'Wraith', 'Specter'];
    types.forEach(type => {
      const result = ghostUploadSchema.safeParse({ ...validData, ghost_type: type });
      expect(result.success).toBe(true);
    });
  });

  test('accepts all valid threat levels', () => {
    ['Low', 'Medium', 'High', 'Extreme'].forEach(level => {
      const result = ghostUploadSchema.safeParse({ ...validData, threat_level: level });
      expect(result.success).toBe(true);
    });
  });

  test('rejects temperature out of range', () => {
    expect(ghostUploadSchema.safeParse({ ...validData, temperature_celsius: -51 }).success).toBe(false);
    expect(ghostUploadSchema.safeParse({ ...validData, temperature_celsius: 61 }).success).toBe(false);
  });

  test('rejects emf_reading out of range', () => {
    expect(ghostUploadSchema.safeParse({ ...validData, emf_reading: -1 }).success).toBe(false);
    expect(ghostUploadSchema.safeParse({ ...validData, emf_reading: 101 }).success).toBe(false);
  });

  test('rejects ghost_name over 200 chars', () => {
    const result = ghostUploadSchema.safeParse({ ...validData, ghost_name: 'A'.repeat(201) });
    expect(result.success).toBe(false);
  });
});
