import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(req: Request) {
  if (req.headers.get('x-admin-secret') !== process.env.ADMIN_SHARED_SECRET) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const days = Number(process.env.DENIED_RETENTION_DAYS ?? 30);
  const cutoff = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
  const stale = await prisma.verificationRequest.findMany({ where: { status: 'DENIED', decidedAt: { lt: cutoff } }, select: { id: true } });
  await prisma.auditLog.createMany({ data: stale.map((r) => ({ requestId: r.id, action: 'RETENTION_DELETED', actor: 'system', note: `Denied request older than ${days} days` })) });
  const result = await prisma.verificationRequest.deleteMany({ where: { id: { in: stale.map((r) => r.id) } } });
  return NextResponse.json({ deleted: result.count });
}
