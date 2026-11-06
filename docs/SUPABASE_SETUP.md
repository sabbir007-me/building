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

## 4. Realtime behavior

The client helper [`src/lib/supabase-data.js`](../src/lib/supabase-data.js) loads all permitted records and subscribes to Postgres changes. Realtime is filtered by the database's RLS policies; it is not a replacement for authorization. The app does not persist the dataset in browser localStorage when Supabase is configured. The current dashboard mutation handlers still need to be moved to explicit Supabase inserts/updates before production use.

## 5. Seed data

In Supabase SQL Editor, run [`supabase/seed.sql`](../supabase/seed.sql) after the migration. It creates five confirmed demo accounts and all current sample records. Demo logins are:

| Role | Email | Password |
|---|---|---|
| Tenant | `tenantdemo@gmail.com` | `demo@1234` |
| Tenant | `tenant2@rentease.demo` | `Tenant123!` |
| Landlord | `landlord@gmail.com` | `demo@1234` |
| Landlord | `landlord2@rentease.demo` | `Landlord123!` |
| Admin | `admin123@gmail.com` | `demo@1234` |

These are illustrative credentials only. Change or remove them before production.

## 6. Run

```powershell
npm install
npm run dev
```
