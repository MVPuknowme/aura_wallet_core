# SKYGRID/Aura-Core Identity Gate Bot

MVP web gate for consent-based pre-contact verification before anyone receives direct contact instructions for Michael Vincent Patrick / MVP.

## Privacy boundaries

- Does not deanonymize, scrape, stalk, trace, or bypass privacy systems.
- Does not automate Zangi or use unofficial Zangi APIs.
- Collects only information the requester voluntarily submits.
- Browser geolocation is requested only after explicit local-proof consent and reduced to coarse data before submission.
- Does not store precise GPS or biometrics.
- Denied request data can be deleted after `DENIED_RETENTION_DAYS`.

## Structure

- `app/verify/page.tsx` — public verification form.
- `app/admin/page.tsx` — MVP review dashboard grouped by pending, approved, denied, and blocked.
- `app/api/requests/route.ts` — create verification requests and audit creation.
- `app/api/requests/[id]/decision/route.ts` — approve, deny, or block with audit logging and one-time token issuance.
- `app/api/retention/route.ts` and `scripts/apply-retention.ts` — denied-data retention cleanup.
- `lib/risk.ts` — risk scoring module.
- `prisma/schema.prisma` — SQLite local MVP Prisma data model.

## Setup

```bash
cd identity-gate-bot
cp .env.example .env
npm install
npm run prisma:migrate -- --name init
npm run dev
```

Open `http://localhost:3000/verify` for requesters and `http://localhost:3000/admin` for MVP.

## Admin decisions

The dashboard shows a curl template for each request. Send one of `APPROVED`, `DENIED`, or `BLOCKED`:

```bash
curl -X POST http://localhost:3000/api/requests/<request-id>/decision \
  -H "x-admin-secret: $ADMIN_SHARED_SECRET" \
  -H "content-type: application/json" \
  -d '{"action":"APPROVED","note":"MVP approved"}'
```

Approved responses include a one-time token and configured contact instructions. Denied responses return a polite refusal.

## Environment variables

See `.env.example` for `DATABASE_URL`, `ADMIN_SHARED_SECRET`, `TRUSTED_PASSPHRASE_HASH`, `VERIFIED_BUSINESS_DOMAINS`, `ALLOWLIST_CONTACTS`, `APPROVED_CONTACT_INSTRUCTIONS`, and `DENIED_RETENTION_DAYS`.

## Risk scoring

`lib/risk.ts` implements `+30` for no proof, `+20` for refused reason, `+20` for disposable contact, `-30` for trusted passphrase, `-20` for verified business email, and `-40` for allowlisted contacts.

## Retention cleanup

```bash
npm run retention
```

or call `POST /api/retention` with `x-admin-secret`.
