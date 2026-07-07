import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { createOneTimeToken } from '@/lib/tokens';

function authorized(req: Request) { return req.headers.get('x-admin-secret') === process.env.ADMIN_SHARED_SECRET; }

export async function POST(req: Request, { params }: { params: Promise<{ id: string }> }) {
  if (!authorized(req)) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const { id } = await params;
  const body = await req.json();
  const action = String(body.action).toUpperCase();
  if (!['APPROVED', 'DENIED', 'BLOCKED'].includes(action)) return NextResponse.json({ error: 'Invalid action' }, { status: 400 });
  const token = action === 'APPROVED' ? createOneTimeToken() : null;
  await prisma.verificationRequest.update({ where: { id }, data: { status: action as 'APPROVED' | 'DENIED' | 'BLOCKED', decisionNote: body.note, decidedAt: new Date(), oneTimeTokenHash: token?.tokenHash, tokenExpiresAt: token ? new Date(Date.now() + 1000 * 60 * 60 * 24 * 7) : null, auditLogs: { create: { action: action as 'APPROVED' | 'DENIED' | 'BLOCKED', actor: 'MVP', note: body.note } } } });
  return NextResponse.json({ status: action, one_time_token: token?.token, instructions: action === 'APPROVED' ? process.env.APPROVED_CONTACT_INSTRUCTIONS : 'Thank you for reaching out. MVP is not able to proceed with direct contact at this time.' });
}
