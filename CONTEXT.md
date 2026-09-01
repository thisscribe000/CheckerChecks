# CheckerChecks - Project Context & Architecture

CheckerChecks is a production-grade Flutter application built for creative professionals, production companies, and rental houses (photographers, videographers, audio engineers, filmmakers) to manage gear inventory, prep gig packing checklists, track client equipment rentals, and synchronize data with Firebase.

---

## 🏗️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (iOS, Android, macOS, Web, Windows)
- **Language**: Dart (3.11+)
- **State Management**: [Provider](https://pub.dev/packages/provider) (`AppProvider` with `ChangeNotifier`)
- **Local Persistence**: [SharedPreferences](https://pub.dev/packages/shared_preferences) (local-first offline storage)
- **Cloud Backend**: 
  - [Firebase Core](https://firebase.google.com) (`firebase_core`)
  - [Firebase Authentication](https://firebase.google.com/docs/auth) (`firebase_auth` - Anonymous device auth)
  - [Cloud Firestore](https://firebase.google.com/docs/firestore) (`cloud_firestore` - real-time cloud sync)
- **UI & Design System**: Custom `StitchTheme` (Modern dark/light adaptive theme, curated palette, custom typography).

---

## 📂 Project Structure

```
CheckerChecks/
├── android/                   # Native Android configuration (google-services.json)
├── ios/                       # Native iOS configuration (Podfile: iOS 15.0+, GoogleService-Info.plist)
├── lib/
│   ├── firebase_options.dart  # Multiplatform Firebase configurations
│   ├── main.dart              # Entrypoint, Firebase initialization, Anonymous auth
│   ├── models/
│   │   ├── checklist_item.dart# Gig checklist item model
│   │   ├── gig.dart           # Gig details model (client, date, checklist)
│   │   ├── inventory_item.dart# Inventory gear model (category, status, active rental ID)
│   │   └── rental.dart        # Equipment rental transaction model
│   ├── providers/
│   │   └── app_provider.dart  # Centralized app state, business logic, persistence hooks
│   ├── screens/
│   │   ├── gig_checklist_screen.dart # Interactive gear check-in/check-out with status warnings
│   │   ├── gigs_screen.dart          # Gigs listing, creation modal, status filter
│   │   ├── home_screen.dart          # Dashboard with shortcuts, recent gigs, upcoming events
│   │   ├── inventory_screen.dart     # Gear database, add/edit/delete, category filtering
│   │   ├── onboarding_screen.dart    # Role selection & profile onboarding
│   │   └── rentals_screen.dart       # Active & Past equipment rental tracking
│   ├── services/
│   │   └── firebase_sync_service.dart# Cloud Firestore synchronizer
│   └── theme/
│       └── stitch_theme.dart  # Core typography, color constants, button/card styling
├── pubspec.yaml               # Project dependencies
└── README.md
```

---

## ⚡ Core Feature Modules

### 1. Inventory Management
- Full cataloging of cameras, lenses, audio gear, lighting, and accessories.
- Fields: Name, Category, Brand, Serial Number, Quantity, Rental Status (`'Available'`, `'Rented Out'`), and `activeRentalId`.
- Automatic synchronization with gig checklists and active rentals.

### 2. Gigs & Intelligent Checklists
- Create production gigs with client info, shoot dates, location, and customized checklist items.
- Real-time packing validation with visual feedback:
  - **In Inventory** vs **Missing from Inventory** warning tags.
  - **RENTED OUT** alert badge if gear on the checklist is currently out on rental with another client.

### 3. Rental Management
- Manage client rentals with customer details, contact info, rental dates, and items checked out.
- Prevents double-booking by setting inventory items to `'Rented Out'`.
- Marking a rental as **Returned** automatically releases inventory back to `'Available'`.

### 4. Cloud Sync & Multi-Device Backend
- **Local-First**: Works 100% offline using `SharedPreferences`.
- **Automatic Cloud Backup**: Changes made to local inventory, gigs, or rentals asynchronously push to Cloud Firestore under the user's authenticated UID via `FirebaseSyncService`.

---

## 🔮 Roadmap: Public Rental Web Link (Phase 4 & 5)

1. **Public Web Showcase**:
   - Host a lightweight client-facing web application that reads available inventory from Firestore.
   - Shareable link for clients (e.g. `checkerchecks.app/rent/<userId>`).
2. **Client Gear Selection & Inquiries**:
   - Clients browse gear catalog, pick rental dates, and submit a rental request / cart.
3. **Payments & Checkout**:
   - Stripe payment link generation and payment gateway integration.
   - Auto-creation of Active Rentals in the mobile app once payment is confirmed.

---

## 🚀 Running & Building

- **Run in Debug (iOS Simulator)**:
  ```bash
  flutter run -d iPhone
  ```
- **Run in Debug (Android Emulator)**:
  ```bash
  flutter run -d android
  ```
- **Run Test Suite**:
  ```bash
  flutter test
  ```
