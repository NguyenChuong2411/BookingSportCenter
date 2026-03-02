# SpotOn - Sport Court Booking Application

SpotOn is a modern, user-friendly mobile application for booking sports courts. Built with Flutter following SOLID principles and Clean Architecture.

## 🏗️ Architecture

This project follows **SOLID principles** and **Clean Architecture** with a clear separation of concerns:

```
lib/
├── main.dart                      # Application entry point
├── core/                          # Core utilities shared across features
│   ├── constants/
│   │   ├── app_colors.dart       # Application color palette
│   │   └── app_strings.dart      # Application strings/localization
│   ├── theme/
│   │   └── app_theme.dart        # Application theme configuration
│   └── utils/                     # Shared utilities
└── features/                      # Feature-based modules
    └── home/
        ├── presentation/          # UI Layer
        │   ├── pages/
        │   │   └── home_page.dart
        │   └── widgets/
        │       ├── booking_card.dart
        │       ├── court_card.dart
        │       ├── date_selector.dart
        │       └── rating_widget.dart
        ├── domain/                # Business Logic Layer
        │   └── entities/
        │       ├── booking.dart
        │       ├── court.dart
        │       └── user.dart
        └── data/                  # Data Layer
            └── models/
                ├── booking_model.dart
                └── court_model.dart
```

## 📱 Features

### Home Page

- **User Greeting**: Personalized header with user name and profile
- **Your Bookings**: Horizontal scrollable list of active bookings
- **Available Courts**: Browse nearby courts with:
  - Date selector for checking availability
  - Court details (name, location, rating)
  - One-tap booking
- **Bottom Navigation**: Quick access to main app sections

## 🎨 Design System

### Color Palette

- **Primary Blue**: `#0000FF` - Main brand color
- **Primary Green**: `#00FF00` - Action buttons and highlights
- **Card Background**: `#FFFFFF` - Clean white cards
- **Star Yellow**: `#FFD700` - Rating stars

### Components

- **Booking Cards**: Compact horizontal cards showing booking details
- **Court Cards**: Detailed cards with image, info, and booking button
- **Date Selector**: Interactive date picker with visual feedback
- **Rating Widget**: Star-based rating display

## 🧱 SOLID Principles Implementation

### Single Responsibility Principle (SRP)

- Each widget has a single, well-defined purpose
- Entities, models, and UI components are separated
- Business logic is isolated from presentation

### Open/Closed Principle (OCP)

- Entities and models are extensible without modification
- Theme and constants can be extended for different variants

### Liskov Substitution Principle (LSP)

- Models extend entities maintaining their contracts
- Widgets can be composed and replaced seamlessly

### Interface Segregation Principle (ISP)

- Widgets receive only the data they need via parameters
- Callbacks are specific to actions needed

### Dependency Inversion Principle (DIP)

- UI depends on domain entities, not data models
- High-level modules (presentation) don't depend on low-level modules (data)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**

   ```bash
   cd app_mobile
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production

**Android**

```bash
flutter build apk --release
```

**iOS**

```bash
flutter build ios --release
```

## 📦 Dependencies

The project uses minimal external dependencies to maintain simplicity:

- `flutter`: Core Flutter framework
- `flutter_test`: Testing framework

## 🧪 Testing

Run tests with:

```bash
flutter test
```

## 📝 Future Enhancements

- [ ] Authentication & User Management
- [ ] Real-time Booking System
- [ ] Payment Integration
- [ ] Court Reviews & Ratings
- [ ] Booking History
- [ ] Push Notifications
- [ ] Map Integration
- [ ] Search & Filters
- [ ] Favorites/Wishlist

## 🤝 Contributing

1. Follow the existing architecture patterns
2. Maintain SOLID principles
3. Write meaningful commit messages
4. Add tests for new features
5. Update documentation

## 📄 License

This project is part of the BookingSportApp suite.

## 👥 Authors

Built with ❤️ using Flutter

---

**Note**: This is the initial version with mock data. Backend integration and additional features will be added in future iterations.
