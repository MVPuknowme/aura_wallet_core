import { prisma } from '../lib/prisma';

async function main() {
  const days = Number(process.env.DENIED_RETENTION_DAYS ?? 30);
  const cutoff = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
  const stale = await prisma.verificationRequest.findMany({ where: { status: 'DENIED', decidedAt: { lt: cutoff } }, select: { id: true } });
  await prisma.auditLog.createMany({ data: stale.map((r) => ({ requestId: r.id, action: 'RETENTION_DELETED', actor: 'system', note: `Denied request older than ${days} days` })) });
  const result = await prisma.verificationRequest.deleteMany({ where: { id: { in: stale.map((r) => r.id) } } });
  console.log(`Deleted ${result.count} denied request(s).`);
}
main().finally(() => prisma.$disconnect());
