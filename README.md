# Guardian Invest 🛡️

**Welcome to the future of secure investing.**

Guardian Invest is a premium, secure fintech application designed to be a fortress for your finances. This platform allows you to manage your portfolio, trade assets in real-time, and securely deposit or withdraw funds—all protected by advanced session management and biometric verification.

Built with meaningful engineering principles (**Clean Architecture**) and robust state management (**Flutter BLoC**).

---

## 🚀 Features

### 💸 Premium Fintech Experience

- **Real-Time Market Data**: Live asset pricing streams directly to your dashboard and trade screens using reactive programming.
- **Trading Platform**: Search for assets, view live prices, and execute Buy and Sell orders instantly.
- **Wallet Management**: Seamlessly deposit and withdraw funds directly from the app with instant balance updates. Smart withdrawal logic automatically prompts a liquidation flow if your cash balance is insufficient.
- **Portfolio Dashboard**: Track your assets and visually monitor your portfolio distribution.
- **Transaction History**: An organized, chronological list of all your deposits, withdrawals, and trades, including traded quantities and execution prices.
- **Adaptive Interface**: Whether you're on your phone or your laptop, the app adjusts its layout to fit your screen perfectly.

### 🔐 Uncompromising Security

- **Smart Sessions**: Active monitoring for inactivity (15 mins) and unauthorized device access. Automatic logout upon session expiration.
- **JWT Rotation**: Access tokens are kept short-lived, while refresh tokens automatically rotate in the background. Token reuse detection provides absolute protection against session hijacking.
- **Biometric & PIN Guard**: Sensitive actions (like buying, selling, or withdrawing) require you to prove your identity. Mobile platforms use native FaceID/Fingerprint, while Web utilizes a secure PIN fallback.
- **Secure Storage**: JWT tokens and sensitive keys are stored in the device's native secure enclave using `flutter_secure_storage`.

---

## 🏗️ State Management

We use **Flutter BLoC** (Business Logic Component) alongside **Provider** to keep our code clean, testable, and predictable.

- **Events & States**: Every action (e.g., "User tapped Buy") is an `Event`. The BLoC processes it and emits a new `State` (e.g., "Loading", "Success", "AuthRequired").
- **Reactive Streams**: For real-time data like asset prices, we employ `Stream`s and RxDart principles to push live updates from the backend WebSocket/SSE directly to the UI layer without blocking the main thread.

---

## 🧩 Architectural Patterns

The app strongly adheres to **Clean Architecture** principles to ensure absolute separation between business logic and the UI framework.

- **Domain Layer**: Houses the core business logic, Use Cases, and Entities. This layer is pure Dart and has no dependencies on Flutter.
- **Data Layer**: Contains API implementations (`RemoteDataSource`), DTOs (Models), and the `RepositoryImpl` that bridges the Network layer to the Domain layer.
- **Presentation Layer**: Contains the Flutter UI, Widgets, and BLoCs.

**Design Patterns utilized:**

- **Repository Pattern**: Abstracts data sources, allowing the app to swap between local cache, mock data, or remote APIs seamlessly.
- **Dependency Injection**: Facilitated via `get_it`, allowing us to inject singletons and factories across the app for loose coupling.
- **Interceptor Pattern**: Handled by `Dio`, automatically intercepting outgoing HTTP requests to append Authorization headers and catching 401s to invisibly rotate JWT tokens.

---

## 📦 Tech Stack & Relevant Packages

We carefully selected industry-standard packages for maximum performance:

- **Core Framework**: Flutter 3.10+
- **Backend API**: Node.js with Fastify (for HTTP/2 speed and efficient routing)
- **State Management**:
  - [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)
  - [`provider`](https://pub.dev/packages/provider)
  - [`equatable`](https://pub.dev/packages/equatable) (Value equality for states)
- **Networking & Data**:
  - [`dio`](https://pub.dev/packages/dio) (Advanced HTTP client with interceptors)
  - [`dartz`](https://pub.dev/packages/dartz) (Functional programming & Either types for Error/Success handling)
- **Dependency Injection**:
  - [`get_it`](https://pub.dev/packages/get_it) (Service Locator)
- **Security & Storage**:
  - [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) (Keychain/Keystore)
  - [`shared_preferences`](https://pub.dev/packages/shared_preferences)
  - [`local_auth`](https://pub.dev/packages/local_auth) (Biometric prompts)
- **UI Components**:
  - [`google_fonts`](https://pub.dev/packages/google_fonts)
  - [`confetti`](https://pub.dev/packages/confetti) (Success celebration animations)

---

## 📂 Project Structure

```
lib/
├── core/                   # Shared modules (Network, Security, DI, Theme, Exceptions)
├── features/               # Vertical slice architecture
│   ├── auth/               # Login, Register, Tokens
│   ├── home/               # Dashboard, Portfolio Service, Wallet Dialogs, History
│   ├── market/             # Asset Search Delegate
│   ├── trade/              # Buy/Sell Logic, Trade Bottom Sheet, Auth Prompts
├── main.dart               # Entry point
```

---

## 🛠️ Setup & Running

1. **Prerequisites**:
   - Flutter SDK (v3.x)
   - Node.js backend running on `localhost:3000`

2. **Install Dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```
   _Note: Using Google Chrome or Edge is recommended for Web._
