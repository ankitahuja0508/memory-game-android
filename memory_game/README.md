# 🧠 Memory Match

A beautiful, feature-rich memory card matching game built with Flutter. Match pairs of cards, collect coins, unlock themes, and compete for high scores!

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

### 🎮 Core Gameplay
- **Infinite Levels** - Procedurally generated levels with increasing difficulty
- **Star Rating** - Earn 1-3 stars based on performance
- **Streak System** - Bonus rewards for consecutive matches
- **Multiple Difficulty Tiers** - From beginner to expert

### 💰 Gamification
- **Dual Currency** - Coins (earned) and Gems (premium)
- **Power-ups** - Peek, Freeze, Hint, Magnet, and more
- **Daily Rewards** - 7-day reward cycle with streak bonuses
- **Achievements** - 20+ achievements to unlock

### 🎨 Customization
- **8 Themes** - Animals, Space, Food, Nature, Sports, Travel, Emotions, Music
- **Unlock System** - Earn coins to unlock new themes
- **Theme Progression** - Higher levels unlock more themes

### 📊 Progression
- **Player Levels** - XP-based leveling system
- **Level Progress Tracking** - Best times, moves, and stars
- **Statistics** - Track your gaming stats

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart 3.0 or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/memory_game.git
cd memory_game
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Release

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App widget with routing
│
├── core/
│   ├── constants/            # App constants, colors, strings
│   └── theme/                # App theme
│
├── data/
│   └── models/               # Data models
│       ├── card_model.dart
│       ├── level_model.dart
│       ├── player_model.dart
│       ├── power_up_model.dart
│       ├── achievement_model.dart
│       └── ...
│
├── domain/
│   └── services/             # Business logic services
│       ├── storage_service.dart
│       ├── level_generator_service.dart
│       ├── audio_service.dart
│       └── ...
│
├── state/                    # State management (Cubit)
│   ├── game/
│   ├── player/
│   └── app/
│
└── presentation/
    ├── screens/              # App screens
    │   ├── splash/
    │   ├── menu/
    │   ├── level_select/
    │   ├── game/
    │   ├── result/
    │   ├── shop/
    │   ├── settings/
    │   ├── achievements/
    │   └── daily_rewards/
    │
    └── widgets/              # Reusable widgets
        ├── common/
        ├── cards/
        └── dialogs/
```

## 🎯 Game Mechanics

### Level System

| Tier | Levels | Pairs | Time |
|------|--------|-------|------|
| 🟢 Beginner | 1-10 | 3-5 | 45-75s |
| 🟡 Easy | 11-30 | 5-10 | 60-90s |
| 🟠 Medium | 31-60 | 10-15 | 90-120s |
| 🔴 Hard | 61-100 | 15-18 | 120-150s |
| 🟣 Expert | 101+ | 18-20 | 120-180s |

### Star Calculation

- ⭐ 1 Star: Complete the level
- ⭐⭐ 2 Stars: Complete under move threshold OR time bonus
- ⭐⭐⭐ 3 Stars: Excellent performance (low moves + few mistakes)

### Power-ups

| Power-up | Effect | Cost |
|----------|--------|------|
| 👁️ Peek | Reveal all cards for 3s | 50 💰 |
| ❄️ Freeze | Pause timer for 10s | 40 💰 |
| 🔦 Hint | Highlight a matching pair | 30 💰 |
| 🧲 Magnet | Auto-match one pair | 75 💰 |
| ↩️ Undo | Undo last wrong match | 25 💰 |

## 🔧 Configuration

See [SETUP.md](SETUP.md) for detailed instructions on:
- Firebase setup
- AdMob integration
- In-app purchases
- Push notifications

## 📦 Dependencies

- `flutter_bloc` - State management
- `shared_preferences` - Local storage
- `audioplayers` - Sound effects
- `flutter_animate` - Animations
- `confetti` - Celebration effects
- `google_fonts` - Typography
- `percent_indicator` - Progress indicators

## 🎨 Screenshots

| Menu | Game | Result |
|------|------|--------|
| ![Menu](screenshots/menu.png) | ![Game](screenshots/game.png) | ![Result](screenshots/result.png) |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Emoji symbols for card themes
- Flutter team for the amazing framework
- Community for inspiration and feedback

---

Made with ❤️ and Flutter
