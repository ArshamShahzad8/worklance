# WORKLANCE

**Find talent. Get things done.**

WORKLANCE is a Flutter-based freelancing marketplace where clients can browse services, post jobs, hire freelancers, and track projects, while freelancers can manage services, submit proposals, complete projects through milestones and deliveries, communicate with users, receive notifications, and submit or receive reviews.

This build is completed through **Week 6**, with each week extending the previous functionality without removing existing features.

## Features

### Week 1 — UI Foundation

* Flutter project architecture and Material 3 design system
* Splash, Welcome, Login and Registration
* Marketplace, Categories, Services and Service Details
* Profile and bottom navigation
* Reusable UI components
* Local mock data and tests
* Responsive layouts

### Week 2 — Auth & Discovery

* Firebase password reset
* Password-strength validation
* Search, filtering and sorting
* Save/Favourite services
* Freelancer profiles
* Edit Profile
* Loading, empty and no-result states
* Entrance animations

### Week 3 — Freelancer Tools

* Freelancer profile setup
* Skills management
* My Services
* Create/Edit Service
* Session-based service updates
* Freelancer feature gating

### Week 4 — Jobs & Proposals

* Find Jobs with search and filters
* Post a Job
* Job Details
* Submit Proposal
* My Proposals
* Proposal Status and timeline
* Duplicate proposal protection
* Jobs tab
* Demo Controls

### Week 5 — Projects & Orders

* Work tab with Orders, Projects and Completed
* My Orders
* Active Projects
* Project Details
* Milestones and progress tracking
* Delivery / Submission
* Revision handling
* Completed Projects
* Project status flow:
  **Pending → In Progress → Delivered → Completed**
* Cancelled projects
* Order Now and accepted proposals create trackable projects
* Profile statistics update after completion
* Active work displayed on Home
* Demo Controls for project lifecycle testing

### Week 6 — Messaging, Notifications & Reviews

* Messages screen
* Conversation list with user name, last message, time and profile image
* Unread message indicators
* Chat screen
* Message history and message bubbles
* Text input and send message functionality
* User information in conversations
* Notifications screen
* Unread notification states
* Notifications for new messages, accepted proposals, completed projects and received reviews
* Project completion notifications
* Review screen after project completion
* Star rating interaction
* Review submission
* User reviews display
* Review information including user name, rating, review and date
* Navigation between Home → Messages → Chat
* Navigation between Projects → Completed Project → Review
* Navigation from Notifications → Notification Details
* Reusable components and mobile-focused UX
* API-ready architecture for future backend integration

## Tech Stack

* **Flutter + Dart**
* **Material 3**
* `firebase_core` + `firebase_auth`
* `ChangeNotifier` with `InheritedNotifier`
* Local mock data with repository classes

No backend is used for marketplace functionality. Firebase is used only for password-reset emails.

## Getting Started

```bash
flutter pub get
flutter run
```

Example:

```bash
flutter run -d chrome
```

## Testing

```bash
flutter analyze
dart format .
flutter test
```

Tests cover authentication, navigation, marketplace functionality, project lifecycle, user state, mock-data integrity, filtering, validation, password strength and Week 6 communication and review workflows.

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

WORKLANCE is developed as a **week-by-week internship project**. Week 6 extends the complete project and order management workflow with **messaging, notifications, project completion updates, and user reviews**, while preserving all functionality developed in previous weeks.
