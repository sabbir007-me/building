# RentEase — Smart Rental Property Management System

RentEase is a frontend-only university demonstration for rental discovery and management in Bangladesh. It retains the Horizon Estate site's existing layout, components, typography, colors, and responsive styling while adapting the content and workflows for tenants, landlords, and administrators.

## Run locally

Requirements: Node.js compatible with the installed Next.js version and npm.

```bash
npm install
Copy-Item .env.example .env.local
npm run dev
```

Open [http://localhost:3000](http://localhost:3000). Environment configuration is optional. See [docs/SETUP.md](docs/SETUP.md) for Windows and cross-platform commands.

## Roles and routes

- Public: `/`, `/properties`, `/properties/[slug]`, `/about`, `/contact`
- Authentication: `/login`, `/register`
- Tenant: `/tenant/dashboard`, `/tenant/applications`, `/tenant/rental`, `/tenant/payments`, `/tenant/maintenance`
- Landlord: `/landlord/dashboard`, `/landlord/properties`, `/landlord/properties/add`, `/landlord/tenants`, `/landlord/rent-collection`, `/landlord/maintenance`, `/landlord/applications`
- Administrator: `/admin/dashboard`, `/admin/users`, `/admin/properties`, `/admin/applications`, `/admin/reports`

Protected dashboard layouts check the locally stored demo session and redirect users to their role's dashboard. This is a front-end demonstration, not production access control.

## Demo accounts

The login page's Demo access controls can fill these sample credentials:

| Role | Email | Password |
|---|---|---|
| Tenant | `tenantdemo@gmail.com` | `demo@1234` |
| Landlord | `landlord@gmail.com` | `demo@1234` |
| Administrator | `admin123@gmail.com` | `demo@1234` |

Use only these illustrative credentials; do not enter a real password or confidential data.

## Persistence

In Supabase mode, the database seed is [`supabase/seed.sql`](supabase/seed.sql). The app clears the retired `rentease-demo-data` localStorage key and keeps synchronized records in memory only. Session identity is managed by Supabase Auth.

Profiles, listings, applications, rental agreements, rent and utility payment records, maintenance requests, and notifications are saved in one shared data object. Updates dispatch a same-tab event and browser storage events refresh open tabs. Use **Reset demo data** in the dashboard profile menu and confirm to restore original records and sign out.

With Supabase configured, authentication uses Supabase Auth, data is loaded from Postgres, and Realtime changes are held in memory for the current page. The local demo dataset and browser data persistence are disabled; dashboard write handlers must use Supabase CRUD operations. See [Supabase setup](docs/SUPABASE_SETUP.md).

## Quality checks

```bash
npm run lint
npm run build
```

Feature details, data limitations, setup, structure, and development notes are in the [documentation index](docs/PROJECT_OVERVIEW.md#documentation).
