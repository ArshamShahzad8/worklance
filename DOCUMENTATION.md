# WORKLANCE — Project Documentation (Flutter Learner's Guide)

This file explains **what was requested, what was built, and how the code works**, written
for the student who will submit this project. Read it alongside the code — every section
points to real files.

---

## Section 1 — Project Overview

**What WORKLANCE is**
WORKLANCE is a freelancing marketplace mobile application. Clients browse categories
(Web Development, Mobile Development, UI/UX Design, Graphic Design, Digital Marketing,
Content Writing), search services, read freelancer profiles, and can favorite or "order"
services. Tagline: *Find talent. Get things done.*

**What the Week 1 task required**
Build a complete **UI foundation**: Flutter project setup, an application structure, a
splash screen, welcome/home screen, marketplace with categories and freelancer/service
cards, login and registration, navigation, responsive design — plus tests and
documentation. Everything must run on **local/mock data only**.

**What the application currently does**
Every screen is real and interactive: splash → welcome → login/register → marketplace
(4 tabs) → service details → profile → logout. Search, category filtering, favorites,
form validation, navigation and UI states all work. Data comes from model classes backed
by one mock-data file.

**What is intentionally outside the scope**
Week 1 deliberately has **no backend**: no Firebase, no real authentication, no payments,
no real messaging, no database, no admin panel. Those are later weeks. Any action that
would need a server (login, order, contact) shows a SnackBar and navigates locally.

---

## Section 2 — Assignment Requirements (and where each one lives)

1. **Set up Flutter project** — `pubspec.yaml`, `lib/main.dart`, platform folders
   (`android/`, `ios/`, `web/`, ...), `analysis_options.yaml`.
2. **Application structure** — a clean `lib/` layout (see Section 6 for the rationale):
   `app/`, `core/`, `models/`, `data/`, `widgets/`, `screens/`.
3. **Splash screen** — `lib/screens/splash/splash_screen.dart`.
4. **Home/welcome screen** — `lib/screens/welcome/welcome_screen.dart`.
5. **Marketplace categories** — `lib/models/category.dart`,
   `lib/screens/categories/categories_screen.dart`, `lib/widgets/category_card.dart`.
6. **Freelancer/service cards** — `lib/models/freelancer.dart`,
   `lib/models/service.dart`, `lib/widgets/service_card.dart`, data in
   `lib/data/mock_data.dart`.
7. **Login and registration** — `lib/screens/auth/login_screen.dart`,
   `lib/screens/auth/registration_screen.dart`, validation in
   `lib/core/utils/validators.dart`.
8. **Navigation** — `lib/app/routes.dart` (named routes) and
   `lib/widgets/app_bottom_navigation.dart` (bottom tabs).
9. **Responsive design** — `LayoutBuilder`, `MediaQuery`, `Flexible`, `Expanded`,
   `SafeArea`, `SingleChildScrollView` used across all screens (verified on 320×568 and
   tablet sizes in `test/widget_test.dart`).
10. **Run/test the application** — `flutter pub get`, `flutter run`, `flutter analyze`,
    `flutter test` (63 tests).

---

## Section 3 — Complete User Flow

```
Splash ──(2.4s, auto)──▶ Welcome ──Get Started──▶ Registration
                              │                        │
                              │                        └──(valid)──▶ Marketplace
                              │                                    ▲
                              └────────Login───────────────────────┘
        (login applies the entered email to the local profile)
Marketplace (bottom navigation)
  ├── Home        ── tap service card ──▶ Service Detail ──▶ back
  ├── Categories  ── tap category ──▶ Services tab (filtered)
  ├── Services    ── search / filter ──▶ empty state if no results
  └── Profile     ── Edit Profile (dialog) / Settings ── Log Out ──▶ Welcome
```

- Splash uses `pushReplacementNamed` so the back button never returns to it.
- Login/Registration use `pushNamedAndRemoveUntil` so the user can't go "back" into the
  auth screens after entering the marketplace.
- Logout uses `pushNamedAndRemoveUntil` to return to Welcome with a clean stack.
- The marketplace is a single route (`/marketplace`) holding an `IndexedStack` of the four
  tabs — no duplicated routes.

---

## Section 4 — File-by-File Explanation

### `lib/main.dart`
- **Purpose:** Entry point. Calls `runApp(const WorklanceApp())`.
- **Why it exists:** Keeps the entry point trivial; the app configuration lives in
  `app/app.dart`.
- **Concepts:** `main()`, `runApp`.
- **Connections:** `app/app.dart`.

### `lib/app/app.dart`
- **Purpose:** Root `WorklanceApp` widget — wires theme, state store, and route table into
  the `MaterialApp`.
- **Why it exists:** One place to configure the whole app; tests can inject a fresh
  `AppStore`.
- **Concepts:** `StatelessWidget`, `MaterialApp`, `theme`, `initialRoute`,
  `onGenerateRoute`.
- **Connections:** `core/theme/app_theme.dart`, `core/state/app_store.dart`,
  `app/routes.dart`, `data/mock_data.dart`.

### `lib/app/routes.dart`
- **Purpose:** Every named route (`/`, `/welcome`, `/login`, `/register`, `/marketplace`,
  `/service-detail`) and how to build its screen. Service Detail receives its `Service`
  via route arguments.
- **Why it exists:** Centralizing routes means navigation is traceable and no screen
  string is duplicated.
- **Concepts:** `Navigator`, named routes, `RouteSettings.arguments`,
  `MaterialPageRoute`.
- **Connections:** all screens.

### `lib/core/theme/app_colors.dart`
- **Purpose:** The entire color palette (brand indigo, amber accent, neutrals, feedback
  colors, avatar palette).
- **Why it exists:** No random colors in widgets — rebranding is a one-file change.
- **Concepts:** `Color` constants, `abstract final class`.
- **Connections:** every theme file and most widgets.

### `lib/core/theme/app_text_styles.dart`
- **Purpose:** Builds the app `TextTheme` (sizes, weights, line heights, colors).
- **Why it exists:** Typography stays consistent and scales with the system text scale.
- **Concepts:** `TextTheme`, `copyWith`, `ThemeData.light().textTheme` as a base.
- **Connections:** `app_theme.dart`.

### `lib/core/theme/app_theme.dart`
- **Purpose:** `buildAppTheme()` returns the single Material 3 `ThemeData`: color scheme,
  app bar, cards, inputs, buttons, navigation bar, chips, snackbars, switches.
- **Why it exists:** Component styling is defined once and inherited everywhere.
- **Concepts:** `ThemeData`, `ColorScheme.fromSeed`, component theme data classes,
  `WidgetStateProperty`.
- **Connections:** `app/app.dart`.

### `lib/core/constants/app_constants.dart`
- **Purpose:** Branding strings, timing durations, spacing/radius scale, price and
  greeting helpers.
- **Why it exists:** No magic numbers scattered through the UI.
- **Concepts:** `abstract final class`, static constants, `Duration`.
- **Connections:** most screens and widgets.

### `lib/core/utils/validators.dart`
- **Purpose:** Pure validation functions (name, email, login password, registration
  password rules, confirm password, terms).
- **Why it exists:** Rules are testable, reusable, and kept out of the UI.
- **Important concepts:** the email regex rejects clearly invalid formats (`abc`,
  `abc@`, `abc@gmail`, `@gmail.com`) without any real email verification (out of
  scope); the registration password rule requires 8+ characters with an uppercase
  letter, a lowercase letter and a number.
- **Concepts:** pure functions, `RegExp`.
- **Connections:** login/registration screens, profile edit dialog, `test/validators_test.dart`.

### `lib/core/utils/password_strength.dart`
- **Purpose:** Pure password-strength scoring: `passwordStrength()` returns
  `weak`/`medium`/`strong` based on length and character classes.
- **Why it exists:** Strength logic is separate from the UI so it can be unit-tested
  and stays consistent with the validator rules.
- **Concepts:** enums, pure functions.
- **Connections:** `widgets/password_strength_indicator.dart`, `test/password_strength_test.dart`.

### `lib/core/utils/service_filters.dart`
- **Purpose:** `filterServices()` — case-insensitive search over service title,
  freelancer name/title and category name, with optional category filter; plus a
  category count helper.
- **Why it exists:** Search/filtering logic is pure and unit-testable, used by both the
  home tab and the Services tab.
- **Concepts:** higher-order functions, `where`/`contains`.
- **Connections:** marketplace & services screens, `test/service_filters_test.dart`.

### `lib/core/state/app_store.dart`
- **Purpose:** App runtime state: `FavoritesController` (in-memory bookmark set) and
  `UserController` (current user profile), combined in an `AppStore` exposed to the
  widget tree through an `AppScope` (`InheritedNotifier`).
- **Why it exists:** Screens read the user and favorites from one central place instead
  of hard-coding, and changes propagate automatically.
- **Important concepts:** `UserController.update()` stores the name/email entered at
  registration; `UserController.loginAs()` applies the email used at login (keeping
  the registered name when the email matches, otherwise deriving a display name from
  the email's local part). This is local state only — no backend.
- **Concepts:** `ChangeNotifier`, `InheritedNotifier`, `ListenableBuilder`.
- **Connections:** `app/app.dart`, screens, `widgets/service_card.dart`.

### `lib/models/category.dart`
- **Purpose:** `Category` model — id, name, icon, description.
- **Why it exists:** A typed model keeps data and UI separate.
- **Concepts:** model class, `IconData`.
- **Connections:** `mock_data.dart`, `category_card.dart`.

### `lib/models/freelancer.dart`
- **Purpose:** `Freelancer` model — name, title, avatar color, rating, review count, bio,
  skills, and an `initials` getter for the avatar.
- **Why it exists:** Freelancers are shared by services; reputation (rating/reviews)
  lives on the freelancer.
- **Concepts:** model class, getters.
- **Connections:** `mock_data.dart`, `service_card.dart`, `service_detail_screen.dart`.

### `lib/models/service.dart`
- **Purpose:** `Service` model — title, description, category, freelancer, price,
  delivery days, skills. `rating`/`reviewCount` delegate to the freelancer.
- **Why it exists:** Services are the core marketplace entity; the UI only consumes
  models.
- **Concepts:** composition (a service *has a* freelancer and category).
- **Connections:** `mock_data.dart`, cards, detail screen, filters.

### `lib/models/user.dart`
- **Purpose:** `UserProfile` — name, email, title, location, with `firstName`/`initials`
  helpers.
- **Why it exists:** The greeting and profile screen read one central user object.
- **Concepts:** model class, getters.
- **Connections:** `mock_data.dart`, `app_store.dart`.

### `lib/data/mock_data.dart`
- **Purpose:** All local data: 6 categories, 10 freelancers, 12 services, the current
  user.
- **Why it exists:** Data is never hard-coded inside widgets; swapping to a real API later
  means changing this one file.
- **Concepts:** static collections, object graphs.
- **Connections:** every marketplace screen and the tests.

### `lib/widgets/app_button.dart`
- **Purpose:** Reusable button with variants (primary/outline/text/danger) and a built-in
  loading spinner.
- **Why it exists:** All buttons look and behave the same, and loading state is handled
  once.
- **Concepts:** `StatelessWidget`, enums, `ButtonStyle`, `switch` expressions.
- **Connections:** welcome, auth, profile screens.

### `lib/widgets/app_text_field.dart`
- **Purpose:** Styled `TextFormField` with optional show/hide password toggle.
- **Why it exists:** Consistent form fields with validation support everywhere.
- **Concepts:** `StatefulWidget`, `TextFormField`, `FormFieldValidator`.
- **Connections:** login, registration, profile edit dialog.

### `lib/widgets/category_card.dart`
- **Purpose:** Category tile in two layouts: compact horizontal pill (home) and grid
  card (Categories tab) with service counts.
- **Why it exists:** One widget, two responsive presentations.
- **Concepts:** `AnimatedContainer`, `InkWell`, `Expanded` for overflow safety.
- **Connections:** marketplace home, categories screen.

### `lib/widgets/service_card.dart`
- **Purpose:** Reusable service card: avatar, freelancer, title, description, category
  chip, rating, price, delivery days and mock freelancer location, favorite button.
- **Why it exists:** The same card appears on Home, Services, and filtered views.
- **Concepts:** `Card`, `InkWell`, `ListenableBuilder`, `Flexible`/`Spacer` layout.
- **Connections:** marketplace & services screens, detail screen (route argument).

### `lib/widgets/password_strength_indicator.dart`
- **Purpose:** Live password feedback for Registration: a Weak/Medium/Strong meter plus
  a checklist of the four requirements (mirroring the validator rules).
- **Why it exists:** One reusable widget keeps the strength UI consistent and lets the
  Registration screen stay small.
- **Concepts:** `StatelessWidget`, `ValueListenableBuilder` (the screen rebuilds it as
  the password controller changes), color feedback.
- **Connections:** `core/utils/password_strength.dart`, `screens/auth/registration_screen.dart`.

### `lib/widgets/rating_widget.dart`
- **Purpose:** Star + numeric rating with optional review count.
- **Why it exists:** Rating display is identical everywhere; internally overflow-safe.
- **Concepts:** `Row`, `Flexible`, `TextOverflow.ellipsis`.
- **Connections:** service cards, detail screen.

### `lib/widgets/search_bar.dart`
- **Purpose:** `AppSearchBar` — search input with a clear button; the parent owns the
  controller and receives every change.
- **Why it exists:** Search UI is reused on Home and Services; filtering stays in screen
  state.
- **Concepts:** `StatefulWidget`, `TextEditingController` listener, `TextField`.
- **Connections:** marketplace home, services screen.

### `lib/widgets/section_header.dart`
- **Purpose:** Section title with optional subtitle and action ("See All" / "Clear").
- **Why it exists:** Consistent section headers across tabs.
- **Concepts:** `Row`, `Expanded`.
- **Connections:** marketplace home.

### `lib/widgets/freelancer_avatar.dart`
- **Purpose:** Colored initials avatar (no image assets needed).
- **Why it exists:** Zero broken assets, consistent identity, derived from the name.
- **Concepts:** `CircleAvatar`, string manipulation getter.
- **Connections:** cards, detail, profile, home header.

### `lib/widgets/empty_state.dart`
- **Purpose:** Centered icon + title + message + optional action for empty results.
- **Why it exists:** Screens never look blank; the "No services found" state is reused.
- **Concepts:** `Center`, `Column`, optional `TextButton`.
- **Connections:** home and services screens.

### `lib/widgets/loading_indicator.dart`
- **Purpose:** Centered spinner with optional label.
- **Why it exists:** One consistent loading look (used by auth flows).
- **Concepts:** `CircularProgressIndicator`.
- **Connections:** auth screens (through `AppButton`) and any future async UI.

### `lib/widgets/app_bottom_navigation.dart`
- **Purpose:** Material 3 `NavigationBar` with the four tabs.
- **Why it exists:** The parent owns the selected index; the bar is purely presentational.
- **Concepts:** `NavigationBar`, `NavigationDestination`, records.
- **Connections:** `marketplace_shell.dart`.

### `lib/screens/splash/splash_screen.dart`
- **Purpose:** Branded splash with fade/scale animation; auto-navigates after 2.4 s.
- **Why it exists:** First impression + guaranteed navigation (a `Timer` means it can
  never get stuck).
- **Concepts:** `AnimationController`, `FadeTransition`, `ScaleTransition`, `Timer`,
  `pushReplacementNamed`.
- **Connections:** `routes.dart`.

### `lib/screens/welcome/welcome_screen.dart`
- **Purpose:** Branding, headline, description, "Get Started" → registration,
  "Login" → login.
- **Why it exists:** Tells the user what WORKLANCE is and funnels them onward.
- **Concepts:** `SafeArea`, `LayoutBuilder`, `SingleChildScrollView`, `Wrap`.
- **Connections:** `routes.dart`.

### `lib/screens/auth/login_screen.dart`
- **Purpose:** Email + password with validation, show/hide password, remember me,
  forgot password, social placeholders, loading state; valid input → marketplace.
- **Why it exists:** Prototype auth UX with all the required interactions.
- **Concepts:** `Form`, `TextFormField`, `FormFieldState`, `Future.delayed` (simulated
  network), SnackBar, `pushNamedAndRemoveUntil`.
- **Connections:** `validators.dart`, `routes.dart`.

### `lib/screens/auth/registration_screen.dart`
- **Purpose:** Name, email, password (rules), confirm password, Terms checkbox with
  validation; valid input → marketplace.
- **Why it exists:** Same rationale as login, plus checkbox validation.
- **Concepts:** `FormField<bool>` for the checkbox, `TextEditingController` comparisons.
- **Connections:** `validators.dart`, `routes.dart`.

### `lib/screens/marketplace/marketplace_shell.dart`
- **Purpose:** The app shell after auth — `IndexedStack` of the four tabs +
  `AppBottomNavigation`; owns the Services-tab category filter hand-off.
- **Why it exists:** One route for the whole marketplace; tab state survives switching.
- **Concepts:** `IndexedStack`, callbacks (`ValueChanged`).
- **Connections:** the four tab screens.

### `lib/screens/marketplace/marketplace_screen.dart`
- **Purpose:** Home tab — the discovery dashboard: greeting, notifications, avatar,
  search, a preview of popular categories and a curated **Featured services** feed.
- **Why it exists:** Home is a discovery surface, not the full marketplace (that is the
  Services tab). Tapping a category here calls the shell's `onCategorySelected` to open
  the Services tab already filtered. Typing in the search bar switches Home into search
  mode across the whole marketplace, with an empty state for no matches.
- **Concepts:** `ListView`, `AppScope.of(context)`, local state (`setState`),
  `ValueKey` for testability.
- **Connections:** `service_filters.dart`, `mock_data.dart`, `routes.dart`, `marketplace_shell.dart`.

### `lib/screens/marketplace/service_detail_screen.dart`
- **Purpose:** Full service view: freelancer card, description, skills chips, delivery
  and price cards, Contact / Order Now actions (SnackBar feedback), favorite in the app
  bar.
- **Why it exists:** Turns a card tap into a rich, purchasable-looking page.
- **Concepts:** `SingleChildScrollView`, `Wrap` (chips), `SafeArea` bottom bar.
- **Connections:** receives its `Service` via route arguments.

### `lib/screens/categories/categories_screen.dart`
- **Purpose:** All categories in a responsive grid with service counts; tapping a
  category opens the Services tab filtered to it.
- **Why it exists:** The "See All" destination for categories.
- **Concepts:** `GridView.builder`, `SliverGridDelegateWithFixedCrossAxisCount`,
  `LayoutBuilder`.
- **Connections:** `marketplace_shell.dart` (callback).

### `lib/screens/services/services_screen.dart`
- **Purpose:** All services with search, category filter chips ("All" + each category),
  result count, and an empty state with "Clear filters".
- **Why it exists:** The browse-by-everything view.
- **Concepts:** `ChoiceChip`, `didUpdateWidget` (reacting to a new category filter),
  `filterServices`.
- **Connections:** `marketplace_shell.dart`, `routes.dart`.

### `lib/screens/profile/profile_screen.dart`
- **Purpose:** Avatar, name, email, location, edit-profile dialog (updates the greeting
  everywhere), settings placeholders, logout with confirmation → Welcome.
- **Why it exists:** Central user profile + settings + exit path.
- **Concepts:** `showDialog`, `AlertDialog`, `SwitchListTile`, `ListTile`,
  `pushNamedAndRemoveUntil`.
- **Connections:** `app_store.dart` (user updates), `routes.dart`.

---

## Section 5 — Flutter Concepts Used (explained through this project)

- **StatelessWidget** — a widget that never changes internally; it only renders what it's
  given (e.g. `WelcomeScreen`, `ServiceCard`). Build once per frame, no lifecycle.
- **StatefulWidget** — a widget that holds mutable state and re-renders when it changes
  via `setState` (e.g. `LoginScreen`'s loading flag, `MarketplaceScreen`'s search query,
  `SplashScreen`'s animation controller).
- **BuildContext** — the widget's position in the tree; it's how widgets reach ancestors
  like the theme (`Theme.of(context)`), the navigator (`Navigator.of(context)`) or our
  store (`AppScope.of(context)`).
- **MaterialApp** — the root Material widget that provides themes, localization,
  navigation, and scaffolds. Ours lives in `app/app.dart`.
- **ThemeData** — the single object describing colors, typography, and component styles;
  built once in `core/theme/app_theme.dart`.
- **Navigator** — manages the route stack. We push named routes (`pushNamed`),
  replace the splash (`pushReplacementNamed`), and clear the stack after auth/logout
  (`pushNamedAndRemoveUntil`).
- **Routes** — named destinations registered in `app/routes.dart`; arguments can travel
  with a route (the `Service` to show in the detail screen).
- **Form / TextFormField / TextEditingController / validation** — `Form` groups fields
  and can validate them all at once (`formKey.currentState!.validate()`); each
  `TextFormField` runs its `validator`; controllers hold the typed text (e.g. comparing
  password vs confirm password).
- **Password strength** — a pure function scores the password (length + character
  classes) into Weak/Medium/Strong; a dedicated widget renders the meter and a live
  requirements checklist that mirrors the validator rules.
- **ListView** — a scrollable, lazily-built list — the backbone of the Home and Services
  feeds.
- **GridView** — a scrollable grid, used for the Categories tab.
- **Card** — a Material surface with elevation/shape; used for services, categories, and
  the detail-page sections.
- **MediaQuery / LayoutBuilder** — `MediaQuery` gives screen facts (size, insets);
  `LayoutBuilder` gives the *available* size of the current widget so layouts adapt
  (e.g. auth forms cap their width on tablets, the grid changes column count).
- **Expanded / Flexible** — flex widgets inside `Row`/`Column` that share or shrink
  space; they are what prevents `RenderFlex overflow` on small screens.
- **State management** — a spectrum: local UI state with `setState`, and app-wide state
  with `ChangeNotifier` + `InheritedNotifier` (`AppScope`) so favorites and the user
  profile are readable from anywhere and update automatically.
- **Filtering** — pure functions in `core/utils/service_filters.dart` that take the
  query + category and return a new list; screens re-run them on every input change.
- **Reusable widgets** — small configurable components (buttons, fields, cards) that
  accept values through constructors instead of duplicating code.
- **Models** — plain Dart classes describing real entities (Category, Freelancer,
  Service, UserProfile) so the UI never works with raw maps/strings.
- **Mock data** — one file (`data/mock_data.dart`) that stands in for a backend.
- **SnackBar** — transient feedback (validation of prototype actions, notifications,
  profile save).
- **Bottom navigation** — Material 3 `NavigationBar` with an `IndexedStack` body so each
  tab keeps its state.

---

## Section 6 — Why This Architecture Was Used

- **Models are separated** — a `Service` knows about its category and freelancer, but not
  how it's drawn. When Week 3 adds a real API, only the data layer changes.
- **Mock data is separated** — screens consume `MockData.services` etc. rather than
  containing hard-coded lists; swapping data sources is a one-file change.
- **Widgets are reusable** — `ServiceCard` is used on Home, Services, and search results;
  `AppButton` powers every CTA with loading built in. One fix propagates everywhere.
- **Theme is centralized** — colors, typography, and component styling live in
  `core/theme/`, so the app looks cohesive and rebranding is trivial.
- **Validation is separated** — rules live in pure functions (`validators.dart`) so they
  can be unit-tested and reused by Login, Registration, and the Edit Profile dialog.
- **Screens are separated** — each screen is one focused file; no giant 1000-line widgets.
- **Routes are centralized** — one table maps names → screens, making the navigation
  flow obvious and keeping route strings out of screens.

---

## Section 7 — What Is Actually Functional vs Prototype

### Functional
- **Navigation** — splash → welcome → auth → marketplace tabs → detail → logout.
- **Form validation** — email format, required fields, password rules, confirm match,
  terms checkbox, with helpful messages.
- **Password strength** — live Weak/Medium/Strong meter + requirements checklist on
  Registration.
- **Local user profile** — the name/email entered at registration (or applied at
  login) drives the greeting, header avatar and Profile screen.
- **Search** — filters services by title, freelancer, or category as you type.
- **Filtering** — category pills/chips filter the feed; empty state + clear action.
- **Favorites** — bookmark toggles instantly (in-memory for the session).
- **Service details** — full listing rendered from the tapped service.
- **Logout** — confirmation dialog → returns to Welcome.
- **UI states** — loading (auth), empty (search), snackbar feedback.

### Prototype/placeholder
- **Authentication** — any valid input "logs in"; no account is created or stored.
  Registration writes the entered name/email into the local store, and login applies
  the entered email, so the UI flow stays consistent with no backend.
- **Contact Freelancer / Order Now** — show a SnackBar only.
- **Forgot Password** — shows a placeholder SnackBar.
- **Social Login** (Google/Apple) — placeholder buttons with SnackBar feedback.
- **Notifications, Settings, Help** — placeholder interactions.

---

## Section 8 — What Is NOT Included (by design, Week 1)

- **Backend / server code** — none.
- **Firebase** — none (no auth, no Firestore, no cloud functions).
- **Real authentication** — no credentials are stored or verified.
- **Payments** — no payment gateway or checkout.
- **Real messaging** — no chat.
- **Real freelancer registration** — freelancers are mock data.
- **Real service orders** — ordering shows feedback only.
- **Database** — persistence of any kind (favorites reset when the app restarts).
- **Admin panel** — none.

These are the natural next weeks of the internship. The architecture was chosen so they
can be added without rewriting the UI.

---

## Section 9 — What You Should Learn From This Project

A checklist tied directly to the code:

1. **Read `lib/data/mock_data.dart`** and understand how objects reference each other
   (services → freelancers → categories).
2. **Trace the flow from `lib/main.dart` → `app/app.dart` → `app/routes.dart`** and name
   every screen route.
3. **Open `core/theme/app_theme.dart`** and find the theme for buttons, cards, inputs —
   then look at a widget and see how it inherits styling automatically.
4. **Open `core/utils/validators.dart`** — add a new rule (e.g. "no spaces in password")
   and watch the registration screen pick it up.
5. **Open `core/utils/service_filters.dart`** — explain why search matches freelancer
   names too, and write a new test for it in `test/`.
6. **Open `core/state/app_store.dart`** — explain how tapping a heart on a card updates
   the icon without the card re-reading data.
7. **Look at `widgets/service_card.dart`** and list every `Flexible`/`Expanded` and what
   would break if you removed it on a 320 px screen.
8. **In `screens/marketplace/marketplace_screen.dart`**, follow how `_query` and
   `_selectedCategoryId` flow into `_filteredServices`.
9. **In `screens/auth/registration_screen.dart`**, explain how the Terms checkbox
   validator works via `FormField<bool>`.
10. **In `test/widget_test.dart`**, re-read the logout test and explain why the finders
    are scoped with `find.descendant` (IndexedStack keeps every tab mounted).

---

## Week 1 Submission Description (paste-ready)

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
