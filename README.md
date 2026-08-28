# WORKLANCE

**Find talent. Get things done.**

WORKLANCE is a Flutter-based freelancing marketplace mobile application that allows users to discover services, browse categories, explore freelancer profiles, search and filter listings, view service details, and save favourite services.

The application is built with a modular and reusable Flutter architecture and currently uses local/mock marketplace data, making it suitable for future API and backend integration.

---

## Overview

WORKLANCE provides a complete marketplace browsing experience for clients looking for freelance services.

Users can:

* Browse available services
* Explore different freelancing categories
* Search for services, skills, and freelancers
* Filter and sort marketplace results
* View detailed service information
* Explore freelancer profiles
* View services offered by individual freelancers
* Save and remove favourite services
* Navigate between marketplace sections
* Manage their local profile

The application focuses on a polished and responsive mobile experience while keeping the marketplace data local for now.

---

## Features

### Marketplace

* Personalized marketplace home screen
* Featured and popular services
* Freelancer information
* Service cards with pricing and ratings
* Delivery time information
* Skills and category tags
* Responsive marketplace layout

### Search

* Search services by title
* Search by freelancer name
* Search by category
* Search by skills and tags
* Search through service descriptions
* Real-time local filtering
* Empty state for unavailable results

### Categories

* Browse services by category
* Horizontally scrollable category selection
* Category filtering
* Selected category states
* Category service counts

Current categories include:

* Web Development
* Mobile Development
* UI/UX Design
* Graphic Design
* Digital Marketing
* Content Writing
* Video Editing

### Service Listings

* Complete marketplace service listing
* Category filtering
* Search
* Advanced filters
* Sorting options
* Result states
* Reusable service cards

### Filtering & Sorting

Users can refine marketplace results using:

* Category
* Price range
* Minimum rating
* Delivery time

Services can also be sorted by:

* Recommended
* Highest rated
* Lowest price
* Highest price
* Fastest delivery

### Freelancer Profiles

Each freelancer profile includes:

* Profile avatar
* Freelancer name
* Professional title
* Location
* Rating
* Reviews
* Completed jobs
* Biography
* Skills
* Services offered

Users can open a freelancer profile directly from marketplace service information.

### Service Details

Each service has a dedicated details screen containing:

* Service title
* Freelancer information
* Rating and reviews
* Description
* Category
* Skills
* Starting price
* Delivery time
* Favourite/save action
* Contact Freelancer action
* Order Service action

### Favourites

* Save services using the favourite button
* Remove saved services
* Immediate visual feedback
* Favourite state shared across marketplace screens
* Saved services remain synchronized while navigating through the application

### Navigation

The application provides navigation between:

* Home
* Categories
* Services
* Service Details
* Freelancer Profiles
* Profile

Service and freelancer information can be opened directly from relevant marketplace cards.

### User Profile

* Local user profile
* Registration information reflected in the profile
* Editable profile information
* Profile avatar
* Settings section
* Logout functionality

---

## UI & UX

WORKLANCE uses a modern Material 3 interface with:

* Consistent typography
* Reusable components
* Responsive layouts
* Rounded cards and controls
* Category chips
* Interactive buttons
* Favourite states
* Filter states
* Empty states
* Smooth transitions and interactions
* Mobile-friendly spacing and layouts

The interface has been designed to work across different mobile screen sizes.

---

## Application Structure

```text
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   └── routes.dart
│
├── core/
│   ├── constants/
│   ├── state/
│   ├── theme/
│   └── utils/
│
├── models/
│   ├── category.dart
│   ├── freelancer.dart
│   ├── service.dart
│   └── user.dart
│
├── data/
│   └── mock_data.dart
│
├── widgets/
│   ├── app_button.dart
│   ├── category_card.dart
│   ├── service_card.dart
│   ├── freelancer_avatar.dart
│   ├── rating_widget.dart
│   └── ...
│
└── screens/
    ├── splash/
    ├── welcome/
    ├── auth/
    ├── marketplace/
    ├── categories/
    ├── services/
    └── profile/
```

The application separates data, models, UI screens, reusable widgets, routing, state management, and theme configuration to keep the codebase maintainable and ready for future expansion.

---

## Main Screens

| Screen             | Description                                    |
| ------------------ | ---------------------------------------------- |
| Splash             | Application launch and branding                |
| Welcome            | Entry point for users                          |
| Login              | Local login interface and validation           |
| Registration       | User registration and validation               |
| Marketplace        | Main service discovery experience              |
| Categories         | Browse available marketplace categories        |
| Services           | Full searchable and filterable service listing |
| Service Details    | Detailed information about a selected service  |
| Freelancer Profile | Freelancer information and listed services     |
| Profile            | User profile and account options               |

---

## Data & Architecture

The current marketplace uses local sample data rather than a live backend.

Marketplace information is represented through model classes such as:

* `Service`
* `Freelancer`
* `Category`
* `User`

Sample marketplace data is maintained separately from the UI, making it easier to replace the current data source with a REST API or other backend service in the future.

Application state is managed through the existing application store, including user information and favourite services.

---

## Technologies

* Flutter
* Dart
* Material 3
* Null Safety
* Local/mock marketplace data
* Flutter standard navigation
* Reusable Flutter widgets

No additional paid services or external marketplace APIs are required to run the current application.

---

## Testing

The project includes automated tests covering important application functionality, including:

* Input validation
* Password validation
* User profile state
* Marketplace filtering
* Search functionality
* Category filtering
* Favourite functionality
* Navigation
* Service data
* Responsive layouts
* Profile consistency

Before submission, the project should be checked with:

```bash
flutter analyze
flutter test
```

---

## Current Data

The application currently uses local marketplace data for demonstration purposes.

This includes:

* Multiple marketplace categories
* Multiple freelancers
* Multiple services
* Service ratings
* Review counts
* Pricing
* Delivery times
* Freelancer skills
* Freelancer profiles

The local data structure is designed so that a real API can be integrated later without requiring major changes to the UI.

---

## Future Improvements

Possible future enhancements include:

* Real backend/API integration
* Persistent user accounts
* Real freelancer registration
* Real service creation
* Messaging between clients and freelancers
* Order management
* Online payments
* Persistent favourites
* Reviews and ratings
* Notifications
* Real-time marketplace updates

---

## Getting Started

### Requirements

Make sure Flutter is installed and configured correctly.

Check your Flutter installation with:

```bash
flutter doctor
```

### Run the project

Clone the repository and navigate into the project directory:

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

## Project Status

**Completed**

WORKLANCE currently provides a complete marketplace browsing experience with service discovery, search, category navigation, filtering, sorting, freelancer profiles, service details, favourites, responsive layouts, reusable components, and local marketplace data.

The architecture is structured for future backend and API integration.

---

**WORKLANCE — Find talent. Get things done.**
