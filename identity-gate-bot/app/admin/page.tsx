import { prisma } from '@/lib/prisma';

export default async function AdminPage() {
  const requests = await prisma.verificationRequest.findMany({ orderBy: { createdAt: 'desc' }, include: { auditLogs: { orderBy: { createdAt: 'desc' }, take: 3 } } });
  const groups = ['PENDING', 'APPROVED', 'DENIED', 'BLOCKED'];
  return <main className="p-8"><h1 className="text-3xl font-bold">MVP admin dashboard</h1><p className="mt-2 text-slate-300">Review consent-based requests. Use API decisions with the shared admin secret; approved responses return a one-time token.</p>{groups.map((group) => <section key={group} className="mt-8"><h2 className="text-2xl font-semibold">{group}</h2><div className="mt-4 grid gap-4">{requests.filter((r) => r.status === group).map((r) => <article key={r.id} className="rounded-xl border border-slate-800 bg-slate-900 p-5"><div className="flex flex-wrap justify-between gap-3"><h3 className="font-semibold">{r.claimedName}</h3><span className="rounded bg-slate-800 px-3 py-1 text-sm">risk {r.riskScore}</span></div><p className="mt-2 text-slate-300">{r.reasonForContact}</p><dl className="mt-3 grid gap-2 text-sm md:grid-cols-2"><div>Contact: {r.contactMethod} — {r.contactValue}</div><div>Proof: {r.proofMethod}</div><div>Local: {r.localStatus}</div><div>Coarse location: {r.coarseLocation ?? 'not provided'}</div><div>Risk reasons: {r.riskReasons}</div><div>ID: {r.id}</div></dl><DecisionHelp id={r.id} /><ul className="mt-3 text-xs text-slate-400">{r.auditLogs.map((log) => <li key={log.id}>{log.action} by {log.actor}: {log.note}</li>)}</ul></article>)}</div></section>)}</main>;
}
function DecisionHelp({ id }: { id: string }) { return <pre className="mt-4 overflow-x-auto rounded bg-slate-950 p-3 text-xs">{`curl -X POST /api/requests/${id}/decision \\
  -H 'x-admin-secret: $ADMIN_SHARED_SECRET' \\
  -H 'content-type: application/json' \\
  -d '{"action":"APPROVED","note":"MVP approved"}'`}</pre>; }
