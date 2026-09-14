import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { scoreRequest } from '@/lib/risk';
import { requestSchema } from '@/lib/validation';

export async function POST(req: Request) {
  const form = Object.fromEntries((await req.formData()).entries());
  const parsed = requestSchema.safeParse(form);
  if (!parsed.success) return NextResponse.json({ error: 'Invalid request' }, { status: 400 });
  const data = parsed.data;
  const risk = scoreRequest({ reasonForContact: data.reason_for_contact, contactMethod: data.contact_method, contactValue: data.contact_value, proofMethod: data.proof_method, proofDetails: data.proof_details });
  const created = await prisma.verificationRequest.create({ data: { claimedName: data.claimed_name, reasonForContact: data.reason_for_contact, localStatus: data.local_status, contactMethod: data.contact_method, contactValue: data.contact_value, proofMethod: data.proof_method, proofDetails: data.proof_details, consentGiven: data.consent_checkbox, coarseLocation: data.coarse_location, riskScore: risk.score, riskReasons: risk.reasons.join('; ') || 'no risk modifiers', auditLogs: { create: { action: 'CREATED', actor: 'requester', note: `risk=${risk.score}` } } } });
  return NextResponse.json({ id: created.id, status: created.status });
}
