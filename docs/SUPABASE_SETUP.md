# Supabase setup

## 1. Create the project

Create a Supabase project, then copy its **Project URL** and **anon public key** into `.env.local`:

```powershell
Copy-Item .env.example .env.local
```

Only `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` belong in the browser. Never put a `service_role` key in `.env.local` or commit it.

## 2. Install the schema

In Supabase Dashboard > SQL Editor, run the complete file [`supabase/migrations/001_rentease.sql`](../supabase/migrations/001_rentease.sql). It creates profiles, properties, applications, rentals, payments, maintenance, and notifications, plus Row Level Security and Realtime publication settings.

## 3. Authentication

The database trigger creates a profile whenever a user signs up through Supabase Auth. In Authentication > Providers, enable Email. If email confirmation is enabled, users must confirm their email before the first login.

## 4. Realtime behavior

The client helper [`src/lib/supabase-data.js`](../src/lib/supabase-data.js) loads all permitted records and subscribes to Postgres changes. Realtime is filtered by the database's RLS policies; it is not a replacement for authorization. The current dashboard mutation handlers still use the local demo store, so do not treat this stage as a production data migration until those handlers are moved to explicit Supabase inserts/updates.

## 5. Seed data

The existing records in [`src/data/rentease.js`](../src/data/rentease.js) are demo-only and use local IDs. Do not copy their passwords into Supabase. Create real users through Auth, then insert properties and related records using those users' profile UUIDs.

## 6. Run

```powershell
npm install
npm run dev
```
