# Loan App

Flutter Web client and a TypeScript API for a customer loan application flow. The original product rules remain unchanged:

- Currency: PHP
- Loan amount: 70,000 to 1,500,000
- Interest: 0.5% flat interest per month
- Terms: 4, 12, 24, or 36 months

## Architecture

```text
Flutter Web / mobile client
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
- Real loan application submission with ID, selfie, and signature uploads
- Server-side validation and exact repayment schedule generation
- Staff/admin API to review, approve, or reject applications
- Private document downloads restricted to the borrower or authorized staff
- PostgreSQL schema for users, loans, documents, repayments, transactions, notifications, and audits
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

### 2. Run the Flutter web app

From the project root:

```powershell
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:4000/api/v1
```

For a release build, set the deployed API address at build time:

```powershell
flutter build web --dart-define=API_BASE_URL=https://api.your-domain.example/api/v1
```

`API_BASE_URL` is public configuration, never a database URL or secret. The `.env.example` file is only a local development fallback.

## Cloud PostgreSQL

This project works with any standard managed PostgreSQL service. Create an empty database, copy the provider's SSL `DATABASE_URL` into `server/.env`, then run `npm run db:deploy` during deployment. Use `npm run db:migrate` only during local development when creating a new migration.

For production, configure the API host with:

- `DATABASE_URL` — managed PostgreSQL URL with TLS enabled
- `JWT_ACCESS_SECRET` and `JWT_REFRESH_SECRET` — two independent long random values
- `CORS_ORIGIN` — the exact deployed Flutter web origin, such as `https://app.your-domain.example`
- `UPLOAD_DIRECTORY` — a persistent private volume path

## Deployment Notes

- Deploy the API from `server/` with the included `Dockerfile`, then run `npm run db:deploy` as a release step.
- Deploy the contents of `build/web/` to a static web host, with SPA route fallback to `index.html`.
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
lib/auth/              Customer sign-in, registration, and splash screens
lib/modules/loan/      Existing loan wizard UI, now backed by the API
server/prisma/         PostgreSQL schema and initial admin seed
server/src/routes/     Authentication, loans, dashboard, notifications, staff APIs
server/src/lib/        Security, configuration, calculations, serialization, storage
```
