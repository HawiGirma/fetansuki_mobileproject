# FetanSuki — Smart POS & Micro-Credit Shop Management

FetanSuki is a lightweight, offline-first Point-of-Sale and micro-credit management system built for small shops. It helps shop owners record sales, issue digital receipts, track customer credit, manage inventory, and analyze sales — with simple mobile and web interfaces and a Firebase backend.

## 🔑 Key Features

- Fast POS / New Sale workflow with cart & quick product search
- Digital receipt generation, print & share (SMS/WhatsApp/Email)
- Micro-credit recording, installment tracking, due-date reminders
- Inventory management (add/edit products, low-stock alerts)
- Sales analytics (daily/weekly/monthly summaries) and export (CSV/PDF)
- Integrated payments (Chapa, TeleBirr) — optional adapters
- Offline-first support with cloud sync when online (Firebase/Firestore)
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
├── app/                     # Mobile App (Flutter)
│   ├── lib/
│   │   ├── features/        # Feature-driven architecture
│   │   ├── core/           # Shared logic, error handling, etc.
│   │   ├── di/             # Dependency injection
│   │   └── main.dart
│   ├── assets/
│   └── pubspec.yaml
│
├── backend/                 # Firebase configuration & legacy SQL
│   ├── sql/                # Legacy Supabase SQL (reference)
│   └── firebase/           # Firebase rules & indexes
│
├── api-docs/                # OpenAPI / endpoints examples
├── design/                  # Wireframes & UI assets
└── docs/                    # SRS, architecture, ERD, UX flows
```

## 🛠️ Tech Stack

- Mobile app: Flutter (Android-first), Dart
- Backend: Firebase (Firestore + Auth + Storage)
- Payments: Chapa, TeleBirr integrations (adapter layer)
- Storage: Firebase Storage for receipts & images
- CI/CD: GitHub Actions (optional)

## 🗄️ Database Schema (Firestore)

Collections:
- users — name, email, photoURL, metadata
- stock_items — user_id, name, price, stock_qty, category, image_url, created_at
- sales — user_id, total_amount, payment_type, created_at
- credits — user_id, customer_id, amount, status, created_at
- customers — user_id, name, phone, email, created_at

## ⚙️ Environment & Configuration

Refer to `lib/di/providers.dart` for environment-specific configurations.

## 🔒 Security & Privacy

- Use Firebase Auth for primary login (Email/Password & Google).
- Encrypt sensitive data in transit (HTTPS).
- Use Firestore Security Rules to restrict access by `user_id`.

## 📦 Packaging & Deployment

- Mobile: build release APK / App Bundle for Android; TestFlight/App Store for iOS.
- Backend: Firebase Project — deploy rules and indexes via Firebase CLI.

## 🧪 Testing

- Flutter widget tests for screens and widget logic.
- Mock payments in dev environment.

## 🤝 Contributing

- Fork the repo.
- Create a branch: feature/your-feature.
- Implement & add tests.
- Create a PR.

## 📝 Documentation

Keep detailed docs under docs/:
- docs/SRS/ — requirements
- docs/architecture/ — diagrams and design decisions
- docs/database/ — schema explanations
- docs/ux/ — wireframes & navigation flows

## 📞 Contact / Support

Email: hawigirmamegersag@gmail.com
