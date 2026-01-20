# CUCA CRM - AI-Powered Customer Care for Real Estate

**Demo Version for Gemini 3 Hackathon**

A Flutter mobile app that helps real estate sales professionals manage customer relationships with AI-powered insights, automated care reminders, and intelligent chat analysis.

---

## ✨ Features

### AI-Powered Insights
- **Chat Analysis**: Automatically analyze customer conversations to extract:
  - Sentiment analysis (positive, neutral, negative)
  - Customer intent (purchase inquiry, information seeking, etc.)
  - Buying signals and urgency levels
  - Recommended next actions

- **Smart Recommendations**:
  - Best time to follow up
  - Preferred communication channel
  - Suggested talking points
  - Content recommendations

### Customer Management
- Customer list with search and filtering
- Customer stages: Receive Info → Have Needs → Research → Explosion Point → Sales → After Sales
- Priority-based care reminders
- Tag-based organization

### Real-time Updates
- Live notifications for care reminders
- Task tracking and management
- Calendar integration

### CUCA AI Chat Assistant
- Interactive AI chatbot for sales guidance
- Customer-specific insights
- Best practice recommendations

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.2+ installed
- Dart SDK 3.2+
- Any IDE (VS Code, Android Studio)

### Running the Demo

```bash
# 1. Navigate to project
cd kts-cham-demo

# 2. Get dependencies
flutter pub get

# 3. Run the app (web, mobile, or desktop)
flutter run -d chrome      # Web browser
flutter run -d macos       # macOS
flutter run -d windows     # Windows
flutter run               # Default device/emulator
```

**That's it!** No API keys, no backend setup, no configuration needed.

The demo includes:
- 5 pre-loaded sample customers
- Mock AI analysis responses
- Simulated real-time updates
- Demo user auto-login

---

## 📱 Demo Walkthrough

1. **Home Screen**: See AI insights, reminders, and quick actions
2. **Customer List**: Browse and search all customers
3. **Customer Detail**: View customer info, AI analysis, and chat history
4. **CUCA Chat**: Ask the AI assistant for sales guidance
5. **Calendar**: View upcoming care reminders and tasks

---

## 🏗️ Architecture

This demo follows **Clean Architecture** principles:

```
lib/
├── core/
│   ├── mocks/              # Mock services (AI, Node API, Realtime)
│   ├── theme/              # App theming
│   ├── constants/          # App constants
│   └── widgets/            # Shared widgets
├── features/
│   ├── auth/               # Authentication (mock)
│   ├── customers/          # Customer management
│   ├── home/               # Home screen & insights
│   └── settings/           # Settings & profile
└── config/
    └── supabase/           # Mock Supabase config
```

### Mock Services

All backend services are mocked for the demo:

| Service | Mock Implementation |
|---------|-------------------|
| Supabase Auth | `MockSupabaseAuthClient` |
| Node API | `MockNodeApiService` |
| AI Analysis | `MockAiService` |
| Realtime Sync | `MockRealtimeService` |

---

## 🛠️ Tech Stack

- **Flutter 3.2+** - UI framework
- **Riverpod** - State management
- **Go Router** - Navigation
- **Hive** - Local database
- **ScreenUtil** - Responsive design

---

## 📸 Screenshots

| Home | Customer List | AI Chat |
|------|---------------|---------|
| *Home with AI insights* | *Customer management* | *CUCA AI assistant* |

---

## 🎯 What This Demo Shows

This is a **frontend-only demo** showcasing:
- ✅ Clean Flutter UI with Material Design 3
- ✅ Complex state management with Riverpod
- ✅ Mock AI integration patterns
- ✅ Customer management workflows
- ✅ Responsive design for mobile/tablet

**Not included** (proprietary/backend):
- ❌ Production API keys
- ❌ Real Supabase backend
- ❌ Actual Gemini 3 API calls
- ❌ Real database connections

---

## 🔧 Development

```bash
# Run tests
flutter test

# Build for production
flutter build web --release
flutter build apk --release
flutter build macos --release

# Run widgetbook (UI catalog)
flutter run -d chrome -t lib/widgetbook/main.dart
```

---

## 📝 License

© 2026 CUCA. Demo for Gemini 3 Hackathon.

---

## 🔗 Links

- **Hackathon**: [Gemini 3 Hackathon](https://gemini3.devpost.com)
- **Built with**: Flutter, Google Gemini 3 (mock), Supabase (mock)

---

**Built for Gemini 3 Hackathon 2026**
