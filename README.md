# Expense Tracker 💰

A beautiful, cross-platform expense tracking app for university students built with Flutter. Features offline-first architecture, stunning animations, and clean architecture patterns.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### Core Functionality
- **📊 Expense Tracking** - Add, edit, and delete expenses with ease
- **🎯 Budget Management** - Set monthly budgets with animated progress rings
- **📈 Analytics** - Visualize spending with interactive pie and bar charts
- **🏷️ Student Categories** - Food, Transport, Hostel, Books, Subscriptions, Entertainment

### Technical Highlights
- **🔐 Biometric Security** - Fingerprint/Face ID lock
- **📴 Offline-First** - Works without internet using Hive
- **☁️ Cloud Sync** - Firebase integration for data backup
- **📤 Export Data** - CSV and PDF export with sharing

### UI/UX
- **🌙 Dark/Light Mode** - Animated theme switching
- **✨ Beautiful Animations** - Lottie, Flutter Animate, custom transitions
- **📱 Adaptive Design** - Material 3 & Cupertino widgets
- **💫 Micro-interactions** - Haptic feedback throughout

## 📸 Screenshots

| Home | Analytics | Add Expense | Settings |
|------|-----------|-------------|----------|
| ![Home](screenshots/home.png) | ![Analytics](screenshots/analytics.png) | ![Add](screenshots/add.png) | ![Settings](screenshots/settings.png) |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Dart 3.0 or higher
- Android Studio / Xcode

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/expense_tracker.git
   cd expense_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup (Optional)

1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Add Android app:
   - Package name: `com.studentapp.expense_tracker`
   - Download `google-services.json`
   - Place in `android/app/`

3. Add iOS app:
   - Bundle ID: `com.studentapp.expenseTracker`
   - Download `GoogleService-Info.plist`
   - Add to Xcode project

4. Enable Authentication (Email/Password, Google)

5. Create Firestore database

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # MaterialApp configuration
├── core/
│   ├── constants/         # Colors, strings, dimensions
│   ├── theme/             # App themes & theme provider
│   ├── router/            # GoRouter configuration
│   ├── utils/             # Extensions & helpers
│   └── widgets/           # Shared widgets
├── features/
│   ├── expenses/          # Expense management
│   ├── budget/            # Budget tracking
│   ├── analytics/         # Charts & analytics
│   └── settings/          # App settings
└── services/              # Biometric, export services
```

## 🏗️ Architecture

- **Clean Architecture** - Separation of concerns
- **MVVM Pattern** - ViewModels with Riverpod
- **Feature-based Structure** - Modular code organization

### Layer Responsibilities
- **Domain**: Entities, repository interfaces
- **Data**: Models, data sources, repository implementations
- **Presentation**: Screens, widgets, providers

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `hive_flutter` | Local offline storage |
| `firebase_core` | Firebase integration |
| `go_router` | Navigation |
| `fl_chart` | Charts & graphs |
| `lottie` | Animations |
| `flutter_animate` | Animation utilities |
| `local_auth` | Biometric auth |
| `pdf` | PDF export |

## 🛠️ Build

### Android Release

```bash
# Generate release bundle
flutter build appbundle

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Release

```bash
# Build for iOS (macOS only)
flutter build ipa

# Output: build/ios/ipa/expense_tracker.ipa
```

## 📲 Deploy

### Google Play Store

1. Create Google Play Developer account (₹2,100 one-time)
2. Go to [Play Console](https://play.google.com/console)
3. Create new app
4. Upload `app-release.aab`
5. Complete store listing
6. Submit for review

### Apple App Store

1. Create Apple Developer account (₹8,300/year)
2. Open Xcode → Archive
3. Upload via Transporter
4. Configure in App Store Connect
5. Submit for review

## 🎨 Design System

### Colors
- **Primary**: #6366F1 (Indigo)
- **Secondary**: #10B981 (Emerald)
- **Categories**: Custom vibrant palette

### Typography
- **Font**: Outfit (Google Fonts)
- **Weights**: Regular, Medium, SemiBold, Bold

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All the open-source package contributors
- UI inspiration from iOS Human Interface & Material You

---

<p align="center">Made with ❤️ using Flutter</p>
