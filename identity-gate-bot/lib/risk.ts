import { hashSecret } from './tokens';

export type RiskInput = {
  reasonForContact: string;
  contactMethod: 'email' | 'phone' | 'zangi' | 'other';
  contactValue: string;
  proofMethod: 'passphrase' | 'trusted_referral' | 'business_email' | 'id_check' | 'video_check' | 'none';
  proofDetails?: string | null;
};

const disposableDomains = ['mailinator.com', '10minutemail.com', 'guerrillamail.com', 'tempmail.com', 'yopmail.com'];

export function scoreRequest(input: RiskInput) {
  let score = 0;
  const reasons: string[] = [];

  if (input.proofMethod === 'none') {
    score += 30;
    reasons.push('+30 no proof method selected');
  }

  if (!input.reasonForContact.trim() || /prefer not|refus|n\/a|none/i.test(input.reasonForContact.trim())) {
    score += 20;
    reasons.push('+20 reason was empty or refused');
  }

  if (looksDisposable(input.contactMethod, input.contactValue)) {
    score += 20;
    reasons.push('+20 contact method appears disposable');
  }

  const trustedHash = process.env.TRUSTED_PASSPHRASE_HASH;
  if (input.proofMethod === 'passphrase' && input.proofDetails && trustedHash && hashSecret(input.proofDetails) === trustedHash) {
    score -= 30;
    reasons.push('-30 trusted passphrase matched');
  }

  if (input.proofMethod === 'business_email' && isVerifiedBusinessDomain(input.contactValue)) {
    score -= 20;
    reasons.push('-20 verified business email domain');
  }

  if (isAllowlisted(input.contactValue)) {
    score -= 40;
    reasons.push('-40 manually allowlisted contact');
  }

  return { score, reasons };
}

export function looksDisposable(method: string, value: string) {
  const normalized = value.toLowerCase();
  if (method === 'email') return disposableDomains.some((domain) => normalized.endsWith(`@${domain}`));
  if (method === 'phone') return /^(\+?1)?555/.test(value.replace(/[\s().-]/g, ''));
  if (method === 'other') return /temp|burner|throwaway|disposable/i.test(value);
  return false;
}

function isVerifiedBusinessDomain(value: string) {
  const domain = value.toLowerCase().split('@')[1];
  if (!domain) return false;
  return (process.env.VERIFIED_BUSINESS_DOMAINS ?? '').split(',').map((d) => d.trim().toLowerCase()).filter(Boolean).includes(domain);
}

function isAllowlisted(value: string) {
  const normalized = value.trim().toLowerCase();
  return (process.env.ALLOWLIST_CONTACTS ?? '').split(',').map((d) => d.trim().toLowerCase()).filter(Boolean).includes(normalized);
}
