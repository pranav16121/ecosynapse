import { NextResponse } from 'next/server';
import { supabase, isSupabaseConfigured } from '@/lib/supabase';

export const dynamic = 'force-dynamic';
export const revalidate = 0;

// Feature: Telemetry Ingestion Endpoint with Supabase DB Persistence
export async function POST(request: Request) {
  try {
    const authHeader = request.headers.get('authorization') || request.headers.get('x-api-key');
    const isAuthenticated = authHeader === 'Bearer eco_synapse_sec_key_v1' || process.env.NODE_ENV !== 'production';

    if (!isAuthenticated) {
      return NextResponse.json(
        { success: false, error: 'RLS Unauthorized: Missing or invalid ESP32 API Key' },
        { status: 401 }
      );
    }

    const body = await request.json();

    let dbResult = null;
    if (isSupabaseConfigured() && body.binId) {
      const { data, error } = await supabase
        .from('bins')
        .upsert({
          id: body.binId,
          dry_fill: body.dryFill ?? 0,
          wet_fill: body.wetFill ?? 0,
          overall_fill: Math.round(((body.dryFill ?? 0) + (body.wetFill ?? 0)) / 2),
          weight: body.weight ?? 0.0,
          moisture_level: body.moistureLevel ?? 10,
          battery: body.battery ?? 100,
          is_online: true,
          last_updated: new Date().toISOString(),
        })
        .select();

      if (error) {
        console.error('[Supabase DB Error]:', error);
      } else {
        dbResult = data;
      }
    }

    return NextResponse.json({
      success: true,
      status: 'ACKNOWLEDGED',
      supabaseSynced: Boolean(dbResult),
      timestamp: new Date().toISOString(),
      receivedTelemetry: body,
    });
  } catch (error) {
    return NextResponse.json(
      { success: false, error: 'Invalid ESP32 Telemetry Payload' },
      { status: 400 }
    );
  }
}

export async function GET() {
  return NextResponse.json({
    status: 'ONLINE',
    system: 'EcoSynapse Telemetry Gateway',
    version: '1.0.0',
    database: isSupabaseConfigured() ? 'Connected (Supabase Cloud Postgres)' : 'Local Fallback Engine',
    supportedProtocols: ['HTTP/REST', 'MQTT-Bridge', 'Supabase Realtime'],
  });
}
