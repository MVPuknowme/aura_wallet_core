import { NextResponse } from 'next/server';
import { proofForRequest, PROVIDER_GATEWAY_MODE, safetyPosture } from '@/lib/provider/gateway';

export async function GET(_req: Request, { params }: { params: Promise<{ requestId: string }> }) {
  const { requestId } = await params;
  if (!requestId) return NextResponse.json({ ok: false, mode: PROVIDER_GATEWAY_MODE, errors: ['requestId is required'], safety: safetyPosture }, { status: 400 });
  return NextResponse.json(proofForRequest(requestId));
}
