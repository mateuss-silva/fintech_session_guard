# Session Guard Fintech App 🛡️

**Welcome to the future of secure investing.**

This isn't just another fintech app; it's a fortress for your finances. We've built an investment platform that takes security as seriously as you do, using advanced session management and biometric verification to keep your data safe.

Built with meaningful engineering principles (**Clean Architecture**) and robust state management (**Flutter BLoC**).

---

## 🚀 Features

### 🔐 Uncompromising Security

We believe your session is sacred.

- **Smart Sessions**: We don't just set a timer; we actively monitor for inactivity (15 mins) and unauthorized device access.
- **Biometric Guard**: Want to move money or redeem assets? Proving it's you via FaceID or Fingerprint is mandatory.
- **Device Locking**: Your session is bound to your specific device. If someone steals your token, it's useless elsewhere.
- **Secure by Default**: We use native secure storage (Keychain/Keystore) because `SharedPreferences` just doesn't cut it for sensitive data.
- **Privacy Mode**: In a public place? One tap blurs your balances so prying eyes see nothing.

### 💸 A Premium Fintech Experience

Security doesn't have to be ugly.

- **Adaptive Interface**: Whether you're on your phone or your laptop, the app adjusts its layout to fit your screen perfectly (Navigation Rail on Desktop vs. Bottom Bar on Mobile).
- **Real-Time Portfolio**: Track your assets, view profit/loss in real-time, and manage your investments with a beautiful, dark-themed UI.
- **Transaction History**: Filterable history of all your redemptions and transfers.

---

## 🛡️ Security Architecture

We've implemented a defense-in-depth strategy to protect user data:

| Feature              | Implementation Details                                                                                                                                          |
| :------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Secure Storage**   | Uses `flutter_secure_storage` to store JWT tokens and session IDs in the device's secure enclave (Keychain/Keystore).                                           |
| **Biometrics**       | Uses `local_auth` to gate sensitive actions. On mobile, this triggers native FaceID/Fingerprint prompts.                                                        |
| **PIN Fallback**     | For platforms without standard biometrics (like Web), we force a secure PIN verification step.                                                                  |
| **Session Control**  | The app tracks "last active" timestamps. If you're idle for 15 minutes, we automatically lock the session.                                                      |
| **Network Security** | All API calls use `Dio` interceptors to inject auth tokens automatically and handle 401 (Unauthorized) errors by attempting a token refresh or logging you out. |

---

## 🏗️ State Management

We use **Flutter BLoC** (Business Logic Component) to keep our code clean, testable, and predictable.

- **Events & States**: Every action (e.g., "User tapped Redeem") is an `Event`. The BLoC processes it and emits a new `State` (e.g., "Loading", "Success").
- **Sealed Classes**: We use Dart's sealed classes for states, ensuring the UI handles every possible scenario (no missing error states!).
- **Separation of Concerns**: The UI never talks to the API directly. It just sends events to the BLoC.

**Example Flow:**

1. **Ui**: User taps "Redeem".
2. **Event**: `TransactionRedeemRequested` is added to `TransactionBloc`.
3. **BLoC**: Calls `AuthRepository` to verify PIN/Biometrics.
4. **BLoC**: If verified, calls `TransactionRepository` to execute the trade.
5. **State**: Emits `TransactionActionSuccess`.
6. **UI**: Shows a success snackbar and refreshes the list.

---

## 📦 Tech Stack & Packages

We carefully selected packages that are well-maintained and industry-standard.

- **Core Framework**: Flutter 3.10+
- **State Management**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) & [`equatable`](https://pub.dev/packages/equatable)
- **Navigation**: [`go_router`](https://pub.dev/packages/go_router) (Declarative routing)
- **Networking**: [`dio`](https://pub.dev/packages/dio) (Powerful HTTP client)
- **Dependency Injection**: [`get_it`](https://pub.dev/packages/get_it) (Service Locator)
- **Security**:
  - [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage)
  - [`local_auth`](https://pub.dev/packages/local_auth)
  - [`crypto`](https://pub.dev/packages/crypto)
- **UI Components**:
  - [`google_fonts`](https://pub.dev/packages/google_fonts)
  - [`fl_chart`](https://pub.dev/packages/fl_chart) (Charts)
  - [`shimmer`](https://pub.dev/packages/shimmer) (Loading effects)
  - [`gap`](https://pub.dev/packages/gap) (Spacing)
- **Utilities**: [`dartz`](https://pub.dev/packages/dartz) (Functional programming / Either types), [`intl`](https://pub.dev/packages/intl), [`logger`](https://pub.dev/packages/logger)

---

## 📂 Project Structure

The app follows **Clean Architecture** principles with strict layer separation:

```
lib/
├── core/                   # Shared kernels (Network, Security, DI, Theme)
├── features/               # Feature-based modules
│   ├── auth/               # Login, Register, Session Management
│   ├── portfolio/          # Dashboard, Asset Listing
│   ├── transactions/       # History, Redeem, Transfer
│   └── security/           # Security Settings, Device Status
└── main.dart               # Entry point & App Configuration
```

Each feature folder is further divided into:

- **Domain**: Entities, Repositories (Interfaces), Use Cases (Pure Dart, no Flutter)
- **Data**: Models, Data Sources (API calls), Repository Implementations
- **Presentation**: BLoCs, Pages, Widgets

---

## 🛠️ Setup & Running

1. **Prerequisites**:
   - Flutter SDK (v3.x)
   - Android Studio / Xcode
   - Backend API running locally

2. **Install Dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```
   _Note: For biometric features to work on emulators, you must enroll a fingerprint/face in the emulator settings._

---

## 🧪 Testing

Run unit and widget tests:

```bash
flutter test
```

## 📜 License

MIT
