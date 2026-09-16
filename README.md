# WORKLANCE

**Find talent. Get things done.**

A Flutter freelancing marketplace app for clients and freelancers to connect, manage jobs, proposals, and active projects. Built week-by-week as an internship project — current through **Week 5**.

## Features

### Marketplace & Jobs
- Browse, search, filter, and sort services and freelancers
- Find and post jobs, submit proposals, track proposal status

### Project Management
- **My Orders** — tabbed view of active and completed projects
- **Project Details** — client/freelancer info, budget, deadline, status, progress
- **Milestones** — advance through Pending → In Progress → Submitted → Completed
- **Delivery** — submit work with notes and attachments
- Order status indicators and progress bars across all screens

### Auth & Profile
- Login, registration, password reset (Firebase Auth)
- My Services, My Freelancer Profile, editable user profile

## Tech Stack
- Flutter + Material 3
- Firebase (`firebase_core`, `firebase_auth`)
- Local mock data and repositories

## Getting Started

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── app/                       # routes
├── core/                      # theme, state, constants
├── models/                    # Order, Milestone, Job, Proposal, Service, User
├── data/                      # mock data + repositories
├── widgets/                   # reusable components
└── screens/
    ├── marketplace/           # home, service detail, freelancer profile
    ├── services/              # my services, create service
    ├── jobs/                  # find jobs, post job, proposal status
    ├── orders/                # my orders, project details, milestones, delivery
    ├── auth/                  # login, registration, forgot password
    ├── profile/               # user and freelancer profile
    └── categories/
```
