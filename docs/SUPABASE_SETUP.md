# Supabase setup

## 1. Create the project

Create a Supabase project, then copy its **Project URL** and **anon public key** into `.env.local`:

```powershell
Copy-Item .env.example .env.local
```

Only `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` belong in the browser. Never put a `service_role` key in `.env.local` or commit it.

## 2. Install the schema

In Supabase Dashboard > SQL Editor, run the complete file [`supabase/migrations/001_rentease.sql`](../supabase/migrations/001_rentease.sql). It creates profiles, properties, applications, rentals, payments, maintenance, and notifications, plus Row Level Security and Realtime publication settings.

## 3. Authentication

The database trigger creates a profile whenever a user signs up through Supabase Auth. In Authentication > Providers, enable Email. If email confirmation is enabled, users must confirm their email before the first login.
For a classroom/demo deployment, you can disable **Confirm email** under Authentication > Providers > Email to avoid confirmation-email rate limits. Production deployments should keep confirmation enabled and configure a real SMTP provider.

## 4. Realtime behavior

The client helper [`src/lib/supabase-data.js`](../src/lib/supabase-data.js) loads all permitted records and subscribes to Postgres changes. Realtime is filtered by the database's RLS policies; it is not a replacement for authorization. The app does not persist the dataset in browser localStorage when Supabase is configured. The current dashboard mutation handlers still need to be moved to explicit Supabase inserts/updates before production use.

## 5. Seed data

In Supabase SQL Editor, run [`supabase/seed.sql`](../supabase/seed.sql) after the migration. It creates five confirmed demo accounts and all current sample records. Demo logins are:

| Role | Email | Password |
|---|---|---|
| Tenant | `tenantdemo@gmail.com` | `demo@1234` |
| Tenant | `tenant2@rentease.demo` | `demo@1234` |
| Landlord | `landlord@gmail.com` | `demo@1234` |
| Landlord | `landlord2@rentease.demo` | `demo@1234` |
| Admin | `admin@rentease.demo` | `demo@1234` |

These are illustrative credentials only. Change or remove them before production.

The Supabase Table Editor can show profile rows without showing or changing their Auth passwords. Use only credentials that have been tested through Supabase Auth.

## Registration rate limits

If registration shows `email rate limit exceeded` or `429 over_email_send_rate_limit`, Supabase has throttled confirmation emails for the project. Disable **Confirm email** under Authentication > Providers > Email for a demo, wait for the quota to recover, or configure a custom SMTP provider. The frontend displays this specific cause instead of treating it as a generic login failure.

## 6. Run

```powershell
npm install
npm run dev
```
