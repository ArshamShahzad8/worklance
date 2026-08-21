# WORKLANCE

**Find talent. Get things done.**

WORKLANCE is a freelancing marketplace mobile app where clients discover freelancers and
services across categories such as Web Development, Mobile Development, UI/UX Design,
Graphic Design, Digital Marketing, and Content Writing.

This repository contains the **Week 1 internship task**: a polished, responsive Flutter
UI foundation built entirely with local/mock data — no backend, no Firebase, no real
authentication.

---

## Project Description

WORKLANCE is a Flutter-based freelancing marketplace UI created for the Week 1 internship
task. It includes a complete onboarding flow (splash, welcome, login, registration), a
marketplace with searchable and filterable services, category browsing, service detail
pages, favorites, a profile screen with logout, and a centralized design system — all
powered by realistic mock data and reusable widgets.

The goal of Week 1 is a **UI foundation**: the app looks and behaves like a real product,
but every "backend" action (auth, orders, payments, chat) is a prototype placeholder.

## Features

- **Splash screen** with branded animation and automatic navigation
- **Welcome screen** with WORKLANCE branding and clear CTAs
- **Login** with email/password validation, show/hide password, remember me, forgot
  password and social-login placeholders, and a loading state
- **Registration** with full validation (name, email, password rules, confirm password,
  Terms & Conditions) and a loading state
- **Marketplace home (discovery dashboard)** — personalized greeting, working search,
  a preview of popular categories and a curated **Featured services** feed
- **Categories page** — every category in a grid; tapping one opens the Services tab
  already filtered to it
- **Services page (full marketplace)** — complete list with search, category filter
  chips, freelancer info, ratings, reviews, price and delivery, favorites, and an
  empty state
- **Category → Services flow** — pick a category on Home or Categories and the
  Services tab shows only that category's services; the filter can be cleared
- **Local user profile state** — the name/email entered at registration (or the
  email used at login) drives the greeting, header avatar and Profile screen; no
  hard-coded mock user is shown after registration
- **Email format validation** — rejects clearly invalid formats (`abc`, `abc@`,
  `abc@gmail`, `@gmail.com`) without any real email verification
- **Password strength validation** — registration requires 8+ characters with upper
  and lower case letters and a number, plus a live Weak/Medium/Strong meter and a
  requirements checklist
- **12 realistic services** from model classes + a dedicated mock-data file
- **Service detail screen** with freelancer info, skills, delivery time, price, and
  Contact / Order Now prototype actions
- **Favorites** — tap the bookmark to toggle it (in-memory)
- **Bottom navigation** — Home, Categories, Services, Profile
- **Profile screen** — avatar, edit profile (updates the greeting too), settings
  placeholders, and logout back to Welcome
- **Empty states** when search/filtering returns no results
- **Responsive layouts** verified on small (320×568) and large tablet-sized screens
- **Material 3** design system with a centralized theme, colors and text styles
- **63 automated tests** (validation, password strength, local user profile state,
  filtering, mock data, navigation, profile consistency, favorites, responsive layout)

## Technologies

- **Flutter** (stable, Material 3)
- **Dart** (null safety)
- Flutter's standard navigation system (named routes)
- Local/mock data only — no third-party packages beyond `cupertino_icons` and
  `flutter_lints`

## Screens

| Screen | Route | File |
| --- | --- | --- |
| Splash | `/` | `lib/screens/splash/splash_screen.dart` |
| Welcome | `/welcome` | `lib/screens/welcome/welcome_screen.dart` |
| Login | `/login` | `lib/screens/auth/login_screen.dart` |
| Registration | `/register` | `lib/screens/auth/registration_screen.dart` |
| Marketplace (Home tab) | `/marketplace` | `lib/screens/marketplace/marketplace_screen.dart` |
| Categories (tab) | `/marketplace` | `lib/screens/categories/categories_screen.dart` |
| Services (tab) | `/marketplace` | `lib/screens/services/services_screen.dart` |
| Profile (tab) | `/marketplace` | `lib/screens/profile/profile_screen.dart` |
| Service Details | `/service-detail` | `lib/screens/marketplace/service_detail_screen.dart` |

## How the Four Tabs Differ

- **Home** is the discovery/dashboard: greeting, search, a preview of popular
  categories and a **Featured services** feed (not the whole marketplace).
- **Categories** focuses on categories: a grid of all of them with service counts.
- **Services** is the full marketplace listing: every service with search, category
  filter chips, favorites, delivery/location details and an empty state.
- **Profile** shows the locally registered user (name, email, location), edit,
  settings and logout.

## Local Profile & Simulated Auth

Registration writes the entered **name** and **email** into the in-memory store
(`lib/core/state/app_store.dart`); the Profile screen, header avatar and Home greeting
all read from that same store, so the registered user's details are shown everywhere.
Login applies the entered email to the local profile (deriving a display name from the
email's local part when needed). This is **local state only** — no backend, no Firebase.


## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                 # Root widget: theme + store + routes
│   └── routes.dart              # All named routes in one place
├── core/
│   ├── theme/                   # app_colors, app_text_styles, app_theme
│   ├── constants/               # app_constants (branding, spacing, timing)
│   ├── utils/                   # validators, service_filters (pure logic)
│   └── state/                   # app_store (favorites + user controllers)
├── models/                      # category, freelancer, service, user
├── data/
│   └── mock_data.dart           # All local marketplace data
├── widgets/                     # Reusable components (AppButton, ServiceCard, ...)
└── screens/
    ├── splash/  welcome/  auth/  marketplace/  categories/  services/  profile/
```

`test/` contains unit tests (validators, filters, mock data) and widget tests
(navigation, validation UI, filtering, favorites, logout, responsive layout).


## Week 1 Requirement Mapping

| Week 1 Requirement | Where It Lives |
| --- | --- |
| Flutter project setup | `pubspec.yaml`, `lib/main.dart`, platform folders |
| Application structure | `lib/` layout described above |
| Splash screen | `lib/screens/splash/splash_screen.dart` |
| Welcome/Home screen | `lib/screens/welcome/welcome_screen.dart` |
| Login & Registration | `lib/screens/auth/login_screen.dart`, `registration_screen.dart` |
| Marketplace categories | `lib/widgets/category_card.dart`, `categories_screen.dart`, `mock_data.dart` |
| Freelancer/Service cards | `lib/widgets/service_card.dart`, `lib/data/mock_data.dart` |
| Search & filtering | `lib/core/utils/service_filters.dart`, used by marketplace/services screens |
| Service details | `lib/screens/marketplace/service_detail_screen.dart` |
| Navigation | `lib/app/routes.dart`, `widgets/app_bottom_navigation.dart` |
| Responsive UI | LayoutBuilder/MediaQuery/Flexible/Expanded across screens |
| Design system | `lib/core/theme/*` |
| Reusable components | `lib/widgets/*` |
| Mock marketplace data | `lib/models/*`, `lib/data/mock_data.dart` |
| Testing | `test/` |

## Week 1 Submission Description

> Completed the Week 1 internship task: set up a Flutter project and built the WORKLANCE
> freelancing marketplace UI foundation. Implemented the Splash, Welcome, Login,
> Registration, Marketplace, Categories, Services, and Profile screens with
> freelancer/service cards, working local search and category filtering, bottom
> navigation, a centralized Material 3 design system, reusable components, responsive
> layouts, mock marketplace data, and basic automated testing. All functionality uses
> local mock data with no backend; authentication, payments, and messaging are prototype
> placeholders as required for Week 1.

---

*WORKLANCE — Find talent. Get things done.*
