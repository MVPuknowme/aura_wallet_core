import { z } from 'zod';

export const requestSchema = z.object({
  claimed_name: z.string().min(1).max(120),
  reason_for_contact: z.string().max(2000),
  local_status: z.enum(['local', 'not_local', 'prefer_not_to_say']),
  contact_method: z.enum(['email', 'phone', 'zangi', 'other']),
  contact_value: z.string().min(3).max(240),
  proof_method: z.enum(['passphrase', 'trusted_referral', 'business_email', 'id_check', 'video_check', 'none']),
  proof_details: z.string().max(1000).optional(),
  consent_checkbox: z.coerce.boolean().refine(Boolean),
  coarse_location: z.string().max(120).optional(),
});
