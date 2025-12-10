# FetanSuki — Smart POS & Micro-Credit Shop Management
FetanSuki is a lightweight, offline-first Point-of-Sale and micro-credit management system built for small shops. It helps shop owners record sales, issue digital receipts, track customer credit, manage inventory, and analyze sales — with simple mobile and web interfaces and a Supabase backend.

## 🔑 Key Features
- Fast POS / New Sale workflow with cart & quick product search
- Digital receipt generation, print & share (SMS/WhatsApp/Email)
- Micro-credit recording, installment tracking, due-date reminders
- Inventory management (add/edit products, low-stock alerts)
- Sales analytics (daily/weekly/monthly summaries) and export (CSV/PDF)
- Integrated payments (Chapa, TeleBirr) — optional adapters
- Offline-first support with cloud sync when online (Supabase)
- Role-based access (Owner, Cashier, Accountant, Admin)
- Localization: Amharic & English

## 📁 Repository Structure
```
FetanSuki/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── app/                     # Mobile App (Flutter recommended)
│   ├── lib/
│   │   ├── ui/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── models/
│   │   └── main.dart
│   ├── assets/
│   └── pubspec.yaml
│
├── web-dashboard/           # Optional admin dashboard (React/Next)
│
├── backend/                 # Supabase SQL + Edge Functions
│   ├── sql/
│   │   ├── schema.sql
│   │   ├── policies.sql
│   │   └── seed.sql
│   ├── functions/           # Edge functions (TypeScript)
│   └── storage/             # Buckets configuration (receipts, product-images)
│
├── api-docs/                # OpenAPI / endpoints examples
├── design/                  # Wireframes & UI assets
└── docs/                    # SRS, architecture, ERD, UX flows
```

## 🛠️ Tech Stack (recommended)
- Mobile app: Flutter (Android-first), Dart
- Backend: Supabase (Postgres + Auth + Storage + Realtime)
- Edge functions / serverless: TypeScript (optional)
- Payments: Chapa, TeleBirr integrations (adapter layer)
- Storage: Supabase Storage for receipts & images
- CI/CD: GitHub Actions (optional)

## 🗄️ Database Schema (summary)
Tables included (see backend/sql/schema.sql for SQL):
- users — id, full_name, phone, email, password_hash, role
- shops — id, owner_id, name, address, created_at
- products — id, shop_id, name, category, unit_price, stock_qty, image_url
- sales — id, shop_id, cashier_id, payment_type, total_amount, created_at
- sale_items — id, sale_id, product_id, quantity, price, subtotal
- credit_records — id, sale_id, debtor_name, phone, total_credit, remaining_balance, due_date, status
- credit_payments — id, credit_id, amount_paid, paid_date
- notifications — id, user_id, message, type, is_read, created_at

## ⚙️ Environment & Configuration
Create a .env for local dev (or set via Supabase/E2E environment):
```

# Supabase
SUPABASE_URL=https://your-supabase-url.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key   # server use only

# Payment Gateways (optional)
CHAPA_SECRET_KEY=your-chapa-key
TELEBIRR_CLIENT_ID=your-telebirr-id
TELEBIRR_SECRET=your-telebirr-secret

# App config
APP_ENV=development
APP_LOCALE=en
Important: Never commit secret keys. Use GitHub Secrets for CI/CD.
```

## 🔒 Security & Privacy
- Use Supabase Auth with phone verification for primary login.
- Encrypt sensitive data in transit (HTTPS) and rely on Supabase DB encryption at rest.
- Use Row Level Security (RLS) policies to restrict access by user_id / shop_id.
- Protect service keys; use server-side edge functions for operations that require the service role key.

## 📦 Packaging & Deployment
- Mobile: build release APK / App Bundle for Android; TestFlight/App Store for iOS (if required).
- Backend: Supabase hosted (managed) — deploy SQL and edge functions via CLI or dashboard.
- CI/CD: Add GitHub Actions to run tests and deploy edge functions on main.

## 🧪 Testing
- Flutter widget tests for screens and widget logic.
- Integration tests for sale creation and credit flows (use a test Supabase project).
- Mock payments in dev environment.

## 🤝 Contributing
- Fork the repo.
- Create a branch: feature/your-feature.
- Implement & add tests.
- Create a PR to dev.
- Maintain clean commit history; rebase when needed.
- Include CONTRIBUTING.md with code standards and review checklist.

## 📝 Documentation
Keep detailed docs under docs/:

docs/SRS/ — requirements (we already have SRS)

docs/architecture/ — diagrams and design decisions

docs/database/ — ERD + schema explanations

docs/api/ — OpenAPI spec & sample requests/responses

docs/ux/ — wireframes & navigation flows


## 📞 Contact / Support
Email: hawigirmamegersag@gmail.com
