# WORKLANCE

**Find talent. Get things done.**

A Flutter-based freelancing marketplace app where clients can discover services and freelancers can create and manage their own listings.

---

## Features

### Client Features
- Browse marketplace with featured services and categories
- Search services by title, freelancer name, skills, or category
- Filter by category, price, rating, delivery time
- Sort by recommended, rating, price, or delivery
- View detailed service info and freelancer profiles
- Save favourite services
- Edit personal profile

### Freelancer Features
- Set up freelancer profile (bio, skills, title)
- Create, edit, and delete service listings
- View own freelancer profile
- Manage all services from one screen

### Auth
- Registration with form validation and password strength indicator
- Login with remember-me
- Forgot password (Firebase-powered password reset)
- User profile synced across screens

---

## Screens

| Screen | Description |
|---|---|
| Splash | Launch screen |
| Welcome | Entry point |
| Login / Register | Auth with validation |
| Forgot Password | Firebase password reset |
| Marketplace | Service discovery (Home, Services, Categories, Saved tabs) |
| Service Details | Full service info |
| Freelancer Profile | Freelancer info and services |
| Profile | User profile, freelancing tools, settings |
| Edit Profile | Edit name, email, title, location |
| My Freelancer Profile | View/edit own freelancer profile |
| My Services | Manage own service listings |
| Create Service | Create/edit a service listing |

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── app/           # App root and routing
├── core/          # Constants, state, theme, utils
├── models/        # User, Service, Freelancer, Category
├── data/          # Mock data and repositories
├── screens/       # All UI screens
└── widgets/       # Reusable components
```

---

## Getting Started

```bash
flutter pub get
flutter run
```

For testing:

```bash
flutter analyze
flutter test
```

---

## Tech Stack

- Flutter & Dart
- Material 3
- Firebase Auth (free tier, for password reset only)
- Local/mock data (no paid services)

---

## Tests

65 automated tests covering validation, state management, marketplace filtering, navigation, and UI.

---

**WORKLANCE — Find talent. Get things done.**
