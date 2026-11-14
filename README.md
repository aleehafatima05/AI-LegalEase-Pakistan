# AI LegalEase Pakistan — nationwide + local legal research

A GitHub-ready Cloudflare Pages application with a responsive public website, Cloudflare Pages Functions (Workers runtime), D1 legal database, source-grounded Gemini AI integration, and a research-review workflow.

**Status:** Functional software foundation, not a complete or legally certified corpus. It ships with an official research portal directory but **zero approved statutory provisions and zero reviewed judgments**. Chat will explicitly decline unsupported legal questions until records are reviewed and imported. An API key alone does not populate legal sources.

## What the system supports

- Free Guest Mode without login; public research and chatbot.
- Two search modes: **Pakistan-wide** (national overview + reviewed regional differences) and **Area-specific** (selected province/territory + federal records).
- Topic navigation: women, students, teachers, government service, farmers, criminal law, property, labour, family, legal aid, business, cyber, disability, consumers, international.
- Structured AI report: original legal wording (only if stored as verified), exceptions, explanation, regional differences, judgments, procedures, escalation if an authority refuses, and uncertainties.
- Reviewer-controlled D1 tables for legislation, exact text, procedural steps, and judgments. Only verified records enter retrieval.
- Source links, reviewed dates, conservative answers, input validation, basic D1 rate limiting, secret-held Gemini API key.
- Local general complaint-letter drafting (browser only).

## Cloudflare Pages deployment (GitHub)

1. Install Node.js 20+ and run `npm install`.
2. Create a D1 database: `npx wrangler d1 create legalease-db`.
3. Replace `REPLACE_WITH_YOUR_D1_DATABASE_ID` in `wrangler.toml` with the returned database ID.
4. Apply schema: `npm run db:remote` and directory seed: `npm run db:seed:remote`.
5. Create a Cloudflare Pages project named `legalease-pakistan` connected to your GitHub repository. Set **build command** to empty and **build output directory** to `public`; use the repository root. Add a D1 binding named `DB` to the `legalease-db` database under Pages Settings → Functions → D1 database bindings. Deploy again after adding the binding.
6. Add a Pages secret `GEMINI_API_KEY` (Cloudflare dashboard: Pages → Settings → Variables and Secrets, mark encrypted). The `AI_MODEL` variable defaults to `gemini-2.5-flash`; model availability depends on your provider account. **Never put the API key in the frontend or GitHub.**
7. Test `/api/health`, `/api/laws`, and `/api/chat`. The AI will only answer when matching reviewed legal entries are in D1.
8. Configure a custom domain and review Cloudflare security/usage settings before public launch.

**CLI secret alternative:** `npx wrangler pages secret put GEMINI_API_KEY --project-name legalease-pakistan`.

**Cloudflare direct deployment:** `npm run deploy` deploys Pages without GitHub, but database bindings and secrets still need configuration. GitHub is recommended for version control, not required to host.

## Local development

- `npm install`
- `npm run db:local`
- `npm run db:seed:local`
- `npm run dev`
- Open the local URL printed by Wrangler. Without `GEMINI_API_KEY`, the frontend and library still work, but AI generation is disabled.

## How to populate verified law

The seed includes **official portal directory records only**; portal verification is not verification of individual laws. Follow `docs/LEGAL_REVIEW_WORKFLOW.md`. To add an entry:

1. Retrieve the actual law from an authoritative government gazette or official legislation repository; record jurisdiction, section, commencement, amendments and official URL.
2. Obtain qualified legal review of the provision and whether it is current. Record reviewer and review date.
3. Insert a `sources` row for that specific statute, not merely a portal home page, with `status='verified'` after review.
4. Insert `legal_entries` with original text **only if checked verbatim**; set `text_is_verified=1` only then. Include summary, plain explanation, limitations, scope and verification metadata.
5. Add `procedures` and `judgments` with authoritative citations and independently reviewed status.
6. Verify search results and generated reports with a qualified Pakistani legal reviewer. Review periodically and after legal changes.

**Important:** This schema uses `ALTER TABLE` statements in `db/schema.sql` to extend the V1 project. It is intended for a **fresh D1 database**. For an existing V1 database, use `db/migrations/002_research_fields.sql` instead of rerunning the entire schema; see migration file.

## Security and public launch notes

- The app does not create user accounts or store conversation transcripts. User questions are transmitted to the AI provider if verified sources are found and the API is configured. Do not collect names, identity documents, or confidential details through this interface.
- Rate limiting is a simple D1 counter; production use should add Cloudflare WAF/rate limiting, bot protection, budget limits, abuse monitoring, and privacy/retention disclosures.
- The model is explicitly instructed not to fabricate legal quotes or case law. **Prompts are not a guarantee**: legal reviewers must test outputs. For higher assurance, implement programmatic per-claim citation validation and block unsupported legal assertions before public launch.
- The model is not allowed to infer exact quotations. Store verbatim texts separately and show them directly from D1 in the library.
- Current full-text search is basic keyword FTS5; Urdu morphology, synonyms, semantic retrieval, and comprehensive national coverage require additional indexing and reviewed data.
- The current response schema is structured but is **not** a legal completeness guarantee. Emergency or case-specific advice needs qualified human support.
- International treaties are separate and are not presumed domestically enforceable.

## API

- `GET /api/health`
- `GET /api/laws?topic=all&scope=national&q=land`
- `GET /api/laws?topic=farmers&scope=local&province=PK-PB&q=land`
- `GET /api/sources`
- `POST /api/chat` with JSON `{ "question":"...", "topic":"all", "scope":"national", "province":null, "district":"", "detail":"complete", "language":"auto" }`

## Suggested next steps

1. Establish a legal research/reviewer team and source collection schedule.
2. Load federal constitutional and statutory sources, then provincial/territorial sources.
3. Add source versioning, amendment tracking, legal review dashboard, audit logs, and court judgment corpus.
4. Add robust retrieval for Urdu/Roman Urdu and citation validation.
5. Perform security, accessibility, privacy and legal accuracy audits before public launch.
6. Reuse the same HTTPS API in a future Android app (e.g. Capacitor).

This project is educational and does not provide legal representation.
