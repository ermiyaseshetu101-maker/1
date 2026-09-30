# simplePOS

Restaurant point of sale for Ethiopian dining rooms — tickets, tables, kitchen display, bilingual English/Amharic, and plan-based billing.

This repo is ready to import into **Vercel**.

## What you get

- Owner registration and email sign-in
- 45-day trial, then Starter / Professional / Business plans (ETB)
- Staff PIN lock (admin, manager, cashier, waiter, kitchen)
- Floor plan, POS tickets, kitchen display
- Catalog, reports, and a super-admin platform panel

## Deploy on Vercel

1. Push this repository to GitHub (or GitLab / Bitbucket).
2. In [Vercel](https://vercel.com/new), **Import** the repo.
3. Leave the defaults:
   - **Framework:** detected from Nitro / Vite
   - **Build command:** `npm run build`
   - **Install command:** `npm install --omit=dev --no-audit --no-fund`
   - **Node.js:** 22.x
4. Add a **Postgres** database (Neon is the intended host). In Vercel: Storage → Create Database → Neon, or paste a connection string from [neon.tech](https://neon.tech).
5. Set these **Environment Variables** (Production + Preview):

| Variable | Required | Example |
|---|---|---|
| `DATABASE_URL` | yes | `postgresql://…` (Neon pooled URL) |
| `BETTER_AUTH_SECRET` | yes | 32+ random bytes, e.g. `openssl rand -hex 32` |
| `BETTER_AUTH_URL` | yes | `https://your-app.vercel.app` (no trailing slash) |
| `VITE_AUTH_ENABLED` | yes | `true` |

6. Deploy. `npm run build` applies SQL in `migrations/` to `DATABASE_URL`.
7. After the first production URL is known, set `BETTER_AUTH_URL` to that exact origin and redeploy. Email sign-in will fail with "Invalid origin" if this does not match.

Google / X sign-in uses the Grok auth broker and only works on Grok-hosted deploys. On your own Vercel project, use **email + password**.

## Local development

```bash
npm install
npm run dev
```

The app listens on port 8080. With no `DATABASE_URL`, it uses an in-memory Postgres (PGLite). Data resets when the process stops.

```bash
npm run build      # production build + migrations
npm run typecheck  # TypeScript
```

## First-run walkthrough

1. Open the landing page → **Create restaurant**.
2. Register with email and a password of at least 8 characters.
3. Confirm the verification step, then finish onboarding.
4. Unlock with a staff PIN:

| PIN | Role |
|---|---|
| `1234` | Admin |
| `2222` | Manager |
| `1111` | Cashier |
| `0000` | Waiter |
| `5555` | Kitchen |

The first account on a fresh database is the platform super-admin (`/platform`).

## Stack

TanStack Start, React 19, Tailwind v4, Better Auth, Postgres (Neon in production, PGLite in preview).

## License

Private — use and deploy as you like.
