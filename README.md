# Eyadati Kit — Free

A complete, open-core **clinic booking starter** built with Flutter (web/mobile) and Supabase.

Patients discover doctors, book appointments online, and get confirmed. Doctors manage
their calendar, schedule, and patient history — all backed by your own Supabase project.

**License**: [PolyForm Shield 1.0.0](LICENSE) — free to use, modify, and
self-host for any purpose, including commercial clinic use. You may not resell
the code or offer Eyadati (or a rebranded version) as a competing booking service.

---

## What's included

| Area | Details |
|---|---|
| **Auth** | Supabase email/password auth, profile setup, password reset, role routing (doctor / patient). |
| **Doctor side** | Dashboard, appointment calendar (syncfusion), custom schedule with slots, patient history search, profile & practice setup, settings. |
| **Patient side** | Doctor search, doctor profile, booking flow (single + multi-slot), appointment list & details, favorites, profile. |
| **Database** | Supabase PostgreSQL + Realtime. Migrations for `doctors`, `patients`, `profiles`, `appointments`, `schedules`, availability helpers. |
| **Edge functions** | `available_slots`-style RPC helpers (`book_appointment`, `available_slots_v2`, …), `delete-account`, `patient-reset-password`. |
| **Backend** | **Your own Supabase project** — set `SUPABASE_URL` / `SUPABASE_ANON_KEY`. No lock-in. |
| **Adapters** | `MockPaymentAdapter`, `MockSmsAdapter`, `MockPushAdapter` behind stable ports (see below). |

### Not included (Premium)

Payment/SMS/push integrations (Chargily, Twilio, FCM), appointment reminders,
patient reliability tracking, visit notes, call logs, multi-doctor clinics
(alpha), subscriptions/billing, and video consultations.

See [Upgrade to Premium](#upgrade-to-premium).

---

## Getting started

### 1. Prerequisites

- Flutter SDK `^3.11.5` (`flutter --version`)
- A [Supabase](https://supabase.com) project (free tier works)

### 2. Install

```bash
flutter pub get
```

### 3. Configure the backend

```bash
cp .env.example .env
# edit .env — SUPABASE_URL and SUPABASE_ANON_KEY from your Supabase dashboard
```

Then set the compile-time variables (used by `lib/core/config/environment.dart`):

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### 4. Database

Apply the migrations in `supabase/migrations/` to your project, in filename order:

```bash
supabase db push          # or copy them into the SQL editor
```

### 5. Run

```bash
flutter run -d chrome      # web
flutter run                # any device
flutter build web --release
```

---

## Internationalization

The upstream product is Algeria-only; **this kit is not**. Locale-neutral
defaults ship everywhere and are configurable:

- **Phone numbers** — validation accepts international `E.164` (`+15551234567`)
  in addition to Algerian numbers.
- **City list** — `lib/core/constants/app_regions.dart`: replace the default
  list with your region's cities, or switch the field to free text.
- **Languages** — `flutter gen-l10n` (`l10n.yaml`): French (template) + Arabic.
  To add English: create `lib/l10n/app_en.arb` from `app_fr.arb`, run
  `flutter gen-l10n`, add `Locale('en')` to `supportedLocales` in `lib/main.dart`.
- **Payment / SMS / push** — stable ports with mock adapters; swap in any
  provider for your region (see [Swapping an adapter](#swapping-an-adapter)).

---

## Architecture

Hexagonal (ports & adapters) with feature-first folders:

```
lib/
├── core/
│   ├── domain/            # entities, value objects, repository interfaces
│   ├── ports/             # PaymentPort, SmsPort, PushPort  ← swap points
│   ├── infrastructure/
│   │   ├── mock/          # free tier: Mock*Adapter (no credentials needed)
│   │   └── premium/       # premium tier: Chargily / Twilio / FCM adapters
│   ├── routing/           # GoRouter + route names
│   ├── providers/         # shared Riverpod providers
│   └── widgets/, theme/, constants/, utils/
├── features/
│   ├── auth/              # sign in / sign up / onboarding
│   ├── doctor/            # calendar, schedule, patients, dashboard, settings
│   └── patient/           # search, booking, appointments, favorites, profile
├── models/                # freezed / json data models
├── repositories/          # Supabase data access
├── services/              # app-level services
└── main.dart
```

State management is **Riverpod** (annotation + codegen), routing is **GoRouter**,
models are **freezed**.

### Swapping an adapter

Every external capability is a port. To change the implementation, replace the
registration — nothing else in the app changes:

```dart
// lib/core/ports/payment_port.dart
abstract class PaymentPort {
  Future<String> createCheckout({
    required String planId,
    required String successUrl,
    required String failureUrl,
    Map<String, String>? metadata,
  });
}
```

Free tier ships `MockPaymentAdapter` (prints the checkout request and returns a
URL), `MockSmsAdapter` (logs the message), and `MockPushAdapter` (no-op).

---

## Project conventions

- `flutter analyze` must be clean before committing (`analysis_options.yaml`).
- Generated files (`*.g.dart`, `*.freezed.dart`) are produced with:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Localization: `flutter gen-l10n` (see `l10n.yaml`), French (template) + Arabic.

---

## Upgrade to Premium

Premium is the same codebase plus:

- **Payments**: Chargily checkout via `PaymentPort` (bring your own adapter for other PSPs), real webhooks and subscription state
- **Reminders**: SMS + push reminders to patients before appointments
- **Reliability**: no-show tracking, patient attendance rate, booking guards
- **Visit notes & call logs**: per-patient clinical notes, call logging with monthly call count
- **Clinics** *(alpha)*: multi-doctor groups, shared calendar, walk-in appointments (code included, UI entry point not yet enabled)
- **Billing**: plan management for your own end-user doctors
- **Video consultations**

Premium is licensed commercially (proprietary EULA) and is delivered from a
private repository. Contact: **eyadati.dz@gmail.com**

---

## Rebranding

This kit ships with the upstream "Eyadati" name (app title, localized
strings, legal pages). [REBRAND.md](REBRAND.md) lists every file to change —
edit the `.arb` sources and run `flutter gen-l10n` rather than the generated
localization files.

---

## Support

Open an issue in this repository.
