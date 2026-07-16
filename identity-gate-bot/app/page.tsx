import Link from 'next/link';
export default function Home() {
  return <main className="mx-auto max-w-3xl p-8"><h1 className="text-4xl font-bold">SKYGRID/Aura-Core Identity Gate</h1><p className="mt-4 text-slate-300">A consent-only web gate before direct contact with MVP. No covert identification, no Zangi automation, and no precise location retention.</p><Link className="mt-8 inline-block rounded-lg bg-cyan-500 px-5 py-3 font-semibold text-slate-950" href="/verify">Start verification</Link></main>;
}
