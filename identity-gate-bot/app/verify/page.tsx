'use client';
import { useState } from 'react';

export default function VerifyPage() {
  const [localProof, setLocalProof] = useState(false);
  const [coarseLocation, setCoarseLocation] = useState('');
  const [message, setMessage] = useState('');

  async function requestLocation() {
    if (!confirm('Share approximate browser location? Exact GPS will be reduced to coarse city/region before submission.')) return;
    navigator.geolocation.getCurrentPosition(async (pos) => {
      const { latitude, longitude } = pos.coords;
      setCoarseLocation(`approx:${latitude.toFixed(1)},${longitude.toFixed(1)}`);
    });
  }

  async function submit(formData: FormData) {
    if (coarseLocation) formData.set('coarse_location', coarseLocation);
    const res = await fetch('/api/requests', { method: 'POST', body: formData });
    setMessage(res.ok ? 'Request submitted. MVP will review it before any contact instructions are released.' : 'Submission failed. Check required fields and consent.');
  }

  return <main className="mx-auto max-w-3xl p-8"><h1 className="text-3xl font-bold">Consent verification request</h1><p className="mt-3 text-slate-300">Submit only information you voluntarily choose to provide. This form does not scrape Zangi or any third-party app, does not retain precise GPS, and does not store biometrics.</p><form action={submit} className="mt-8 space-y-5">
    <Field name="claimed_name" label="Claimed name" />
    <label>Reason for contact<textarea name="reason_for_contact" rows={4} required /></label>
    <label>Local status<select name="local_status" onChange={(e) => setLocalProof(e.target.value === 'local')}><option value="local">local</option><option value="not_local">not_local</option><option value="prefer_not_to_say">prefer_not_to_say</option></select></label>
    {localProof && <div className="rounded-lg border border-cyan-700 p-4"><p className="text-sm text-slate-300">Optional local proof: request browser geolocation only after your explicit consent. We submit a coarse approximation only.</p><button type="button" className="mt-3 rounded bg-cyan-500 px-4 py-2 font-semibold text-slate-950" onClick={requestLocation}>Share coarse local proof</button><p className="mt-2 text-xs text-slate-400">Stored: {coarseLocation || 'nothing'}</p></div>}
    <label>Contact method<select name="contact_method"><option value="email">email</option><option value="phone">phone</option><option value="zangi">zangi</option><option value="other">other</option></select></label>
    <Field name="contact_value" label="Contact value" />
    <label>Proof method<select name="proof_method"><option value="passphrase">passphrase</option><option value="trusted_referral">trusted_referral</option><option value="business_email">business_email</option><option value="id_check">id_check</option><option value="video_check">video_check</option><option value="none">none</option></select></label>
    <label>Voluntary proof details<textarea name="proof_details" rows={3} placeholder="Passphrase, referral name, provider reference, or other non-biometric note." /></label>
    <label className="flex gap-3"><input className="w-auto" type="checkbox" name="consent_checkbox" value="true" required /> I consent to submit this information for MVP review.</label>
    <button className="rounded-lg bg-cyan-500 px-5 py-3 font-semibold text-slate-950">Submit request</button>{message && <p className="text-cyan-300">{message}</p>}
  </form></main>;
}
function Field({ name, label }: { name: string; label: string }) { return <label>{label}<input name={name} required /></label>; }
