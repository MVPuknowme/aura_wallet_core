import { NextResponse } from 'next/server';
import { providerStatus } from '@/lib/provider/gateway';

export async function GET() {
  return NextResponse.json(providerStatus());
}
