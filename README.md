# Loan App

Flutter Web customer and admin portals with a TypeScript API for a loan application flow. The original product rules remain unchanged:

- Currency: PHP
- Loan amount: 70,000 to 1,500,000
- Interest: 0.5% flat interest per month
- Terms: 4, 12, 24, or 36 months

## Architecture

```text
Flutter Web / mobile customer client + admin portal
        |
        | HTTPS + Bearer access token
        v
Fastify API (`server/`)
        |
        +-- Prisma ORM --> Managed PostgreSQL (Neon, Supabase, Railway, etc.)
        +-- Private document storage --> local volume for development
```

The API is the source of truth for loan calculations, loan status changes, repayment schedules, notifications, transaction records, and audit records. The client only displays a quote; it cannot change the approved product rules.

## Features

- Customer registration, login, refresh-token sessions, and logout
- One active device session per account; a new login immediately revokes the previous session
- Online/offline presence for customers, staff, and administrators
- One pending loan per customer; new applications stay disabled until the current review finishes
- Resumable loan drafts with final submission only after ID, selfie, and signature uploads succeed
- Server-side validation and exact repayment schedule generation
- Responsive staff/admin dashboard to review, approve, or reject applications
- DashLite-inspired admin portal with grouped/collapsible navigation, dashboard, applications, packages, customers, repayments, transactions, reports, branches, users, and profile modules
- Separate customer registration and back-office user management modules
- Database-backed roles, permissions, user access overrides, loan packages, branches, deposits, and withdrawals
- In-app notification inbox with polling fallback and optional Firebase Cloud Messaging delivery
- Light/dark themes, a consistent three-color design system, motion, and mobile-width customer web screens
- Private document downloads restricted to the borrower or authorized staff
- PostgreSQL schema for users, loans, products, branches, documents, repayments, transactions, notifications, and audits
- OpenAPI/Swagger API documentation at `/docs`
- Responsive Flutter Web support and configurable API URL

## Local Setup

### 1. Configure the API

```powershell
Copy-Item server\.env.example server\.env
```

Edit `server/.env` and set `DATABASE_URL` to your cloud PostgreSQL URL. Use the provider's SSL connection string, normally ending with `?sslmode=require`. Generate unique `JWT_ACCESS_SECRET` and `JWT_REFRESH_SECRET` values with at least 32 characters.

```powershell
Set-Location server
npm install
npm run db:generate
npm run db:migrate -- --name initial_schema
npm run db:seed
npm run dev
```

The API runs at `http://localhost:4000`; interactive API documentation is available at `http://localhost:4000/docs`.

The seeded administrator account opens the admin portal at `http://localhost:8080/#/admin`. Set `ADMIN_EMAIL` and `ADMIN_PASSWORD` before running `npm run db:seed`; never deploy the example credentials.

To enable Firebase push delivery from the backend, set `FIREBASE_SERVICE_ACCOUNT_JSON` in `server/.env` to the complete single-line service-account JSON downloaded from Firebase Console. This is a backend secret and must never be added to Flutter, committed, or exposed in a web build. Database notifications continue working without it.

### 2. Run the Flutter web app

From the project root:

```powershell
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:4000/api/v1 --dart-define=FIREBASE_WEB_VAPID_KEY=YOUR_PUBLIC_VAPID_KEY
```

For a release build, set the deployed API address at build time:

```powershell
flutter build web --release --no-wasm-dry-run --dart-define=API_BASE_URL=https://api.your-domain.example/api/v1 --dart-define=FIREBASE_WEB_VAPID_KEY=YOUR_PUBLIC_VAPID_KEY
```

`--no-wasm-dry-run` skips Flutter's optional WebAssembly compatibility compile and reduces peak RAM usage. Serve the generated `build/web/` folder with any lightweight static server.

For the lowest local RAM use, run the compiled web output instead of `flutter run`:

```powershell
node scripts/serve-web.mjs
```

`API_BASE_URL` is public configuration, never a database URL or secret. The `.env.example` file is only a local development fallback.

## Cloud PostgreSQL

This project works with any standard managed PostgreSQL service. Create an empty database, copy the provider's SSL `DATABASE_URL` into `server/.env`, then run `npm run db:deploy` during deployment. Use `npm run db:migrate` only during local development when creating a new migration.

For production, configure the API host with:

- `DATABASE_URL` — managed PostgreSQL URL with TLS enabled
- `JWT_ACCESS_SECRET` and `JWT_REFRESH_SECRET` — two independent long random values
- `CORS_ORIGIN` — the exact deployed Flutter web origin, such as `https://app.your-domain.example`
- `UPLOAD_DIRECTORY` — a persistent private volume path

## Admin Portal API

Authenticated staff and admin users can use:

- `GET /api/v1/admin/overview`
- `GET /api/v1/admin/loans`, `PATCH /api/v1/admin/loans/:id/status`
- `GET|POST|PATCH /api/v1/admin/customers`
- `GET /api/v1/admin/repayments`
- `GET /api/v1/admin/transactions`
- `GET /api/v1/admin/reports/summary`
- `GET|POST|PATCH /api/v1/admin/loan-products`
- `GET|POST|PATCH /api/v1/admin/branches`
- `GET|POST|PATCH /api/v1/admin/users`
- `GET /api/v1/admin/permissions`

Every admin route checks effective permissions loaded from PostgreSQL. Role defaults can be customized per user from **Users & Permissions** without changing application code.

Customer accounts are managed under **Customers**. Staff and administrator
accounts are managed separately under **Users & Permissions**.

## Deployment Notes

- Deploy the API from `server/` with the included `Dockerfile`, then run `npm run db:deploy` as a release step.
- Deploy the contents of `build/web/` to a static web host, with SPA route fallback to `index.html`.
- Configure the public Firebase Web Push VAPID key at Flutter build time and keep the Firebase Admin service account only on the API host.
- Keep uploaded identity documents out of PostgreSQL. The included local storage adapter is for development or a server with an encrypted persistent volume. Before a serverless deployment, replace it with a private S3-compatible object-storage adapter.
- The approval endpoint records a completed disbursement transaction but deliberately does **not** transfer real money. Connect an approved banking/payment provider before using it for live disbursements or repayments.
- Password reset email/SMS is not enabled because no email/SMS provider or sender identity is configured yet.
- For a high-security public web deployment, place the API and web app behind the same HTTPS domain and move refresh credentials to secure HttpOnly cookies.

## Validation

Run these after dependencies are available:

```powershell
flutter analyze
flutter test

Set-Location server
npm run build
npm test
```

## Project Layout

```text
lib/core/              App configuration, networking, auth session, loan policy
lib/features/          API integrations for auth and loans
lib/features/admin/    Responsive staff/admin loan-management dashboard
lib/auth/              Customer sign-in, registration, and splash screens
lib/modules/loan/      Existing loan wizard UI, now backed by the API
server/prisma/         PostgreSQL schema and initial admin seed
server/src/routes/     Authentication, loans, dashboard, notifications, staff APIs
server/src/lib/        Security, configuration, calculations, serialization, storage
```
