import { NextResponse } from 'next/server';
import { acceptProviderEvent, validateProviderEvent, PROVIDER_GATEWAY_MODE, safetyPosture } from '@/lib/provider/gateway';

export async function POST(req: Request) {
  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ ok: false, mode: PROVIDER_GATEWAY_MODE, accepted: false, errors: ['invalid JSON body'], safety: safetyPosture }, { status: 400 });
  }
  const parsed = validateProviderEvent(body);
  if (!parsed.ok) {
    return NextResponse.json({ ok: false, mode: PROVIDER_GATEWAY_MODE, accepted: false, errors: parsed.errors, safety: safetyPosture }, { status: 400 });
  }
  return NextResponse.json(acceptProviderEvent(parsed.event));
}
