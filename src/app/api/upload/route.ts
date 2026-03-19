import { NextResponse } from 'next/server';
import { v4 as uuidv4 } from 'uuid';
import { ghostUploadSchema } from '@/lib/validation';

export async function POST(request: Request) {
  try {
    const raw = await request.json();
    const result = ghostUploadSchema.safeParse(raw);

    if (!result.success) {
      return NextResponse.json(
        { success: false, errors: result.error.flatten().fieldErrors },
        { status: 400 }
      );
    }

    const data = result.data;
    const ghostId = `GH_${uuidv4().slice(0, 8).toUpperCase()}`;
    const sightingId = `SIGHT_${uuidv4().slice(0, 8).toUpperCase()}`;

    return NextResponse.json({
      success: true,
      ghost_id: ghostId,
      sighting_id: sightingId,
      message: 'Ghost sighting recorded successfully!',
      data: {
        ghost_name: data.ghost_name,
        ghost_type: data.ghost_type,
        threat_level: data.threat_level,
        location_name: data.location_name,
        latitude: data.latitude,
        longitude: data.longitude,
      },
    });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message || 'Failed to upload ghost data' },
      { status: 500 }
    );
  }
}
