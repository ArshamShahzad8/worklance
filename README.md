# WORKLANCE

**Find talent. Get things done.**

WORKLANCE is a Flutter-based freelancing marketplace where clients discover services, post jobs, hire freelancers, and track projects, while freelancers manage services, proposals, orders, and deliveries.

This project is developed week by week, preserving previous functionality while introducing new marketplace features.

## Features

* **Week 1 — UI Foundation:** Authentication screens, marketplace, categories, service details, reusable widgets, responsive layouts, and Material 3 design.
* **Week 2 — Discovery & Profiles:** Search, filtering, sorting, favourite services, freelancer profiles, profile editing, and password reset.
* **Week 3 — Freelancer Tools:** Profile setup, skills management, and create/edit services.
* **Week 4 — Jobs & Proposals:** Job listings, job posting, proposal submission, proposal tracking, and duplicate-submission protection.
* **Week 5 — Projects & Orders:** Orders, active/completed projects, milestones, progress tracking, deliveries, revisions, and project lifecycle management.
* **Week 6 — Communication:** Messaging, conversations, notifications, project completion updates, reviews, and star ratings.
* **Week 7 — Marketplace Enhancements:** Advanced marketplace search for services, jobs, freelancers, and categories; category browsing; price, rating, and delivery-time filters; sorting by price, rating, and popularity; favourites for services and freelancers; and a freelancer dashboard with project/order statistics.

## Tech Stack

* **Flutter + Dart**
* Material 3
* Firebase Authentication for password-reset emails
* ChangeNotifier and InheritedNotifier
* Local/mock data with repository classes

Marketplace functionality uses local/mock data where a backend is unavailable. No paid marketplace APIs are required.

## Getting Started

```bash
flutter pub get
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

## Testing

```bash
flutter analyze
dart format .
flutter test
```

Test search, categories, filters, sorting, favourites, dashboards, navigation, authentication, projects, messaging, notifications, and reviews.

## Project Structure

```text
lib/
├── app/
├── core/
├── models/
├── data/
├── widgets/
└── screens/
```

WORKLANCE is an evolving freelancing marketplace project. Week 7 extends the existing application with improved discovery, favourites, and freelancer dashboard functionality while preserving previous features.
