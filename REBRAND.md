# Rebranding the kit

This kit ships with the upstream **Eyadati** name in the app title, localized
strings and legal pages. Everything below is yours to change — no other code
depends on the brand.

Work top-down; after each step run `flutter gen-l10n` (where noted),
`flutter analyze` and `flutter test`.

## 1. Localized strings (source of truth: the `.arb` files)

Edit `lib/l10n/app_fr.arb`:

| Key | Default |
|---|---|
| `appName` | `Eyadati` |
| `authRegisterSubtitle` | `Rejoignez Eyadati` |
| `installBannerTitle` | `Installer Eyadati` |
| `installBannerSubtitle` | `Ajoutez Eyadati à votre écran d'accueil` |

then run:

```sh
flutter gen-l10n
```

**Do not hand-edit** `lib/l10n/app_localizations*.dart` — they are generated
and will be overwritten. `app_ar.arb` needs no change (the Arabic
translations contain no brand name).

## 2. App shell

| File | What to change |
|---|---|
| `web/index.html` | `<title>Eyadati</title>` and the `apple-mobile-web-app-title` meta |
| `lib/main.dart` | `title: 'Eyadati'` on `MaterialApp`; optionally rename the `EyadatiApp` class (cosmetic) |
| `lib/core/constants/app_constants.dart` | `appName = 'Eyadati'` |
| `lib/core/constants/app_strings.dart` | `appName` and `registerSubtitle` (`Rejoignez Eyadati`) |

## 3. Hardcoded UI strings

Replace the visible `'Eyadati'` / `'Rejoignez Eyadati'` literals in:

- `lib/features/auth/presentation/widgets/auth_header.dart`
- `lib/features/auth/presentation/pages/splash_page.dart`
- `lib/features/auth/presentation/pages/register_page.dart`
- `lib/features/doctor/presentation/pages/doctor_calendar_page.dart`

*Premium only:* `lib/services/push_notification_service.dart` — default
notification title (2 occurrences, `?? 'Eyadati'`).

## 4. Legal pages

These are shown to your users and are **your** legal documents — rewrite them
properly for your jurisdiction, not just the name:

- `assets/terms_of_service.md` (English)
- `assets/privacy_policy.md` (English)
- `lib/features/doctor/presentation/pages/doctor_terms_page.dart` — hardcoded
  French terms (multiple `'Eyadati ...'` strings)
- `lib/features/doctor/presentation/pages/doctor_privacy_page.dart` —
  hardcoded French privacy text

## 5. Package description (optional)

`pubspec.yaml` → `description:` (only visible on pub/dev pages).

## 6. Leave alone (unless you enjoy refactoring)

- **Package name `eyadati_kit`** — appears in every
  `import 'package:eyadati_kit/...'` line and `pubspec.yaml` `name:`.
  It is an internal identifier; end users never see it. Renaming it requires
  rewriting every import (e.g. `sed -i 's/package:eyadati_kit/package:YOUR_PKG/g'`)
  plus `pubspec.yaml` — do it as one atomic change if at all.
- **This repository's own docs** (`README.md`, `TESTING.md`) — they describe
  the kit itself, not your deployment.
- **`LICENSE`** — both licenses require keeping the copyright and license
  notices; rebranding the app does not change that.

## Final sweep

```sh
grep -rn -i "eyadati" lib assets web pubspec.yaml \
  --include="*.dart" --include="*.arb" --include="*.html" --include="*.md" \
  | grep -v "package:eyadati_kit"
```

Everything still matching is either a package import (fine) or one you missed.
