# Ano Tara — Codebase Guide

This guide describes the repository as inspected on 2 November 2026. It is
based on the checked-in Dart source and project configuration, not just the
names of files. The only file added for this request is this guide; application
source, generated files, and the existing working-tree changes were not edited.

## 1. Project overview

Ano Tara is a Flutter app concept for planning trips with groups. Its interface
includes sign-in and account creation, preference onboarding, a five-tab app
shell, trip planning and itinerary screens, group screens, chat, invitations,
expense updates, and member response views.

The codebase is a **hybrid of working backend flows and UI prototypes**:

* **Supabase-backed:** email/password and Google OAuth authentication,
  username-availability RPC, password recovery, and reading/writing a member's
  onboarding preferences. The trip repository also attempts inserts into
  Supabase tables.
* **Primarily local/demo UI:** group membership, invitations, expenses, chat,
  sample home/trip data, and much of the trip-planning interface are represented
  by in-memory sample values. There is no visible read API that populates the
  trip/group screens from Supabase.
* **Two generations of UI:** the root `screens/`, `widgets/`, and `theme/`
  implementation contains the live authentication/onboarding flow. A newer
  `features/` and `components/` implementation supplies the main shell and
  design-heavy screens, but its parallel auth/onboarding screens are not always
  the screens reached from the root flow.

### Technologies and architecture

| Area | Actual project use |
|---|---|
| Flutter / Dart | UI is composed from widgets; screen state uses `StatefulWidget`, `setState`, controllers, and Flutter navigation. |
| Supabase | Hosted authentication and database client, initialized in `lib/main.dart`. Data operations are direct from screens/services and `TripRepository`; there is no separate API server in this repository. |
| UI organization | Feature-oriented paths (`features/<feature>/presentation/...`) coexist with reusable atomic-design-style `components/atoms`, `molecules`, and `organisms`. |
| State management | No Provider, Riverpod, Bloc, or Redux was found. Local screen state is managed with `setState`; trip state uses `ValueNotifier`. Auth state uses a Supabase stream. |
| Routing | Named routes are centralized in `lib/core/routes/app_routes.dart`; some older flows navigate directly with `MaterialPageRoute`. |
| Persistence | Supabase preferences table and trip-related insert tables; most visible feature examples are static/in-memory. |

This is not a strict Clean Architecture implementation: presentation, Supabase
access, model mapping, and navigation are not consistently separated into
domain/data layers. `TripRepository` is one repository-like abstraction; auth
actions are still called directly in screen widgets.

## 2. Directory structure

### Application source (`lib/`)

```text
lib/
├── main.dart
├── app_routes.dart
├── components/
│   ├── atoms/
│   │   ├── app_avatar.dart
│   │   ├── app_badge.dart
│   │   ├── app_button.dart
│   │   ├── app_checkbox.dart
│   │   ├── app_icon.dart
│   │   ├── app_icon_button.dart
│   │   ├── app_input_field.dart
│   │   ├── app_otp_field.dart
│   │   ├── app_pressable.dart
│   │   ├── app_switch.dart
│   │   ├── app_text.dart
│   │   └── iconsax_solid_paths.dart
│   ├── molecules/
│   │   ├── app_availability_pill.dart
│   │   ├── app_availability_row.dart
│   │   ├── app_budget_slider.dart
│   │   ├── app_chat_message.dart
│   │   ├── app_dropdown_field.dart
│   │   ├── app_labeled_form_field.dart
│   │   ├── app_member_action_row.dart
│   │   ├── app_message_composer.dart
│   │   ├── app_navigation_item.dart
│   │   ├── app_option_card.dart
│   │   ├── app_pace_card.dart
│   │   ├── app_preference_choice.dart
│   │   ├── app_search_bar.dart
│   │   ├── app_search_filter_bar.dart
│   │   ├── app_segmented_tabs.dart
│   │   └── app_trip_metadata.dart
│   └── organisms/
│       ├── app_bottom_navigation.dart
│       ├── app_main_top_bar.dart
│       ├── app_top_bar.dart
│       ├── availability_panel.dart
│       ├── group_header_organism.dart
│       ├── member_panel.dart
│       ├── overview_summary_panel.dart
│       └── trip_summary_card.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_radii.dart
│   │   ├── app_spacing.dart
│   │   └── app_typography.dart
│   ├── routes/
│   │   └── app_routes.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── smooth_page_route.dart
│   └── utils/
│       └── app_responsive.dart
├── features/
│   ├── auth/presentation/screens/
│   │   ├── create_new_password_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart
│   │   ├── password_updated_screen.dart
│   │   ├── register_screen.dart
│   │   ├── verification_code_screen.dart
│   │   └── welcome_screen.dart
│   ├── chat/presentation/screens/group_chat_screen.dart
│   ├── expenses/presentation/screens/expense_updates_screen.dart
│   ├── groups/presentation/screens/
│   │   ├── create_group_flow_screen.dart
│   │   ├── group_detail_screen.dart
│   │   └── group_overview_screen.dart
│   ├── groups/presentation/widgets/shield_check_icon.dart
│   ├── notifications/presentation/screens/invitations_screen.dart
│   ├── onboarding/presentation/screens/onboarding_flow_screen.dart
│   ├── shell/presentation/screens/
│   │   ├── create_tab.dart
│   │   ├── groups_tab.dart
│   │   ├── home_tab.dart
│   │   ├── main_shell_screen.dart
│   │   ├── profile_tab.dart
│   │   └── trips_tab.dart
│   ├── shell/presentation/widgets/hero_banner_trio.dart
│   └── trips/
│       ├── data/trip_repository.dart
│       └── presentation/screens/
│           ├── member_responses_screen.dart
│           ├── plan_trip_screen.dart
│           └── trip_overview_screen.dart
├── models/member_preferences.dart
├── screens/
│   ├── auth/
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart
│   │   ├── new_password_screen.dart
│   │   ├── password_updated_screen.dart
│   │   ├── sign_up_screen.dart
│   │   ├── start_screen.dart
│   │   ├── validators.dart
│   │   └── verification_screen.dart
│   └── onboarding/
│       ├── onboarding_flow.dart
│       └── onboarding_steps.dart
├── services/
│   ├── auth_service.dart
│   └── preferences_service.dart
├── theme/app_theme.dart
└── widgets/
    ├── auth_widgets.dart
    └── onboarding_widgets.dart
```

### Other repository folders

```text
.
├── android/       Android Gradle project, manifest, Kotlin launcher, resources
├── assets/fonts/  Seven bundled TTF files (not declared as Flutter assets)
├── ios/           Xcode project, Swift launchers, plist, storyboards/assets
├── linux/         GTK/Flutter desktop runner and generated plugin registration
├── macos/         Xcode desktop runner and generated plugin registration
├── test/          Two Flutter widget test files
├── web/           Browser bootstrap page and web app metadata
├── windows/       Win32 runner and generated plugin registration
├── .widget_preview/  Present as a local preview/tooling package; not app source
├── build/         Generated build output; not maintained source
└── .dart_tool/    Generated Dart/Flutter package and build metadata
```

`build/`, `.dart_tool/`, Gradle caches, Flutter ephemeral files, and generated
plugin registrants are outputs/tooling artifacts, not application features.
The working tree already had modifications to Linux/Windows generated plugin
files and an untracked `.widget_preview/` folder before this documentation
change; those were left untouched.

## 3. File-by-file guide

### 3.1 Startup, routing, data model, and services

| File | Responsibility and connections |
|---|---|
| `lib/main.dart` | `main()` binds Flutter, awaits `Supabase.initialize`, then runs `AnoTaraApp`. It exposes the singleton `supabase` client. `MaterialApp` applies `core/theme/app_theme.dart`, routes from the core route table, and uses `AuthGate` as `home`. It excludes `/` from the route map because `home` is set, then handles `/` in `onGenerateRoute`. It also adds a legacy `/home` route to `MainShellScreen` and overrides `/onboarding` with the older `OnboardingFlow`. No credentials are reproduced here; configuration is currently inline in this source file. |
| `lib/app_routes.dart` | A small **legacy** `AppRoutes` class defining `/home`, `/onboarding`, and `/preferences/edit`. `main.dart` uses these constants for the compatibility routes. This is different from the other class with the same name in `core/routes/`. |
| `lib/core/routes/app_routes.dart` | The newer named-route catalog. `routes` maps the welcome/auth/onboarding/shell/trip/group/chat/invitation/expense/member-response paths to feature screens. `onGenerateRoute` passes string arguments to trip/group/chat screens and falls back to `WelcomeScreen` for unknown routes. `main.dart` imports it with the alias `core_routes`. |
| `lib/models/member_preferences.dart` | Immutable preference data object: activities, diets, allergies, budget, pace, available days, and notes. `fromMap` converts Supabase column values into Dart fields; `toMap` converts answers back to the database column names. It also declares the `TravelPace` enum. |
| `lib/services/auth_service.dart` | Despite its name, this file mainly implements `AuthGate` and `OnboardingCheck`. The gate listens to Supabase `onAuthStateChange`; signed-out users see `StartScreen`. Signed-in users trigger a preference read and see onboarding if no row exists, otherwise the `HomeScreen` shell. A load error offers a retry button. |
| `lib/services/preferences_service.dart` | Supabase adapter for the `member_preferences` table. `load()` selects the current user's row by `user_id` and returns a `MemberPreferences?`; `save()` upserts the data with `user_id` as the conflict key. An optional client can be injected, allowing widget tests to use a fake service without initializing Supabase. Throws `NotSignedInException` if there is no current user. |
| `lib/features/trips/data/trip_repository.dart` | Contains `TripModel`, `TripMemberModel`, and `ItineraryItemModel`, plus a singleton `TripRepository`. It starts with two sample trips, keeps local trip and manual-itinerary lists in `ValueNotifier`s, and attempts inserts into Supabase's `trips`, `trip_members`, and `itinerary_items`. It does **not** load trips from the database. Insert errors are logged and local state is still updated, so the UI can appear successful without durable backend storage. |

#### Route interaction and potential overlap

There are two `AppRoutes` classes (legacy `lib/app_routes.dart` and the newer
`lib/core/routes/app_routes.dart`). `main.dart` imports both with an alias for
the newer set, so Dart name ambiguity is avoided. However, the route table
contains a behavior overlap: the core route map contributes `/onboarding`, and
`main.dart` then assigns the legacy `/onboarding` builder to that same map key.
Consequently, a named navigation to `/onboarding` opens the persistence-backed
legacy questionnaire, not `OnboardingFlowScreen`.

The root screen is also not the feature `WelcomeScreen`: `MaterialApp.home` is
`AuthGate`, which presents legacy `StartScreen` when signed out. The root route
is redirected to the gate. The feature-auth routes are present by name but are
not the default sign-in path.

### 3.2 Active legacy authentication and onboarding (`lib/screens/`)

| File | Behavior |
|---|---|
| `lib/screens/auth/start_screen.dart` | First screen for a signed-out user. Uses `LogoBadge` and the reusable legacy `AppButton`; pushes `SignUpScreen` or `LoginScreen` directly with `MaterialPageRoute`. |
| `lib/screens/auth/login_screen.dart` | Supabase email/password sign-in with form validation. Subscribes to auth state so a successful sign-in returns to the first route; also navigates home after a response with a user. Supports Google OAuth using an external browser and a custom redirect URI. Exceptions are shown in snackbars. |
| `lib/screens/auth/sign_up_screen.dart` | Validates profile and credential fields, calls Supabase RPC `username_available`, then Supabase `signUp` with name/username metadata. Handles duplicate usernames, existing email identities, email-confirmation-required state, and Google OAuth. Auth stream subscription returns to the root once signed in. |
| `lib/screens/auth/validators.dart` | Shared required-field, basic email-pattern, and minimum-eight-character password validators used by legacy login/register/recovery screens. |
| `lib/screens/auth/forgot_password_screen.dart` | Validates email and calls `resetPasswordForEmail`; on success, opens the verification screen with that email. |
| `lib/screens/auth/verification_screen.dart` | Collects a six-digit recovery OTP, calls `verifyOTP(type: recovery)`, and opens the new-password screen. Resending calls `resetPasswordForEmail`; a 60-second timer gates resend attempts. |
| `lib/screens/auth/new_password_screen.dart` | Validates matching new password values, updates the Supabase user's password, signs out, and opens the success screen. |
| `lib/screens/auth/password_updated_screen.dart` | Success confirmation. Its back/button actions clear the stack to the legacy login screen. |
| `lib/screens/onboarding/onboarding_flow.dart` | **The onboarding implementation wired by the main `/onboarding` route and auth gate.** Maintains answers for seven steps, validates required activity/pace/day choices, can load existing preferences in `editing` mode, maps “Others” text into values, and calls `PreferencesService.save`. After a normal finish it clears the stack to `/` so `AuthGate` reloads the account state; editing mode returns `true` to the prior screen. |
| `lib/screens/onboarding/onboarding_steps.dart` | Defines the choices and step widgets used by the legacy questionnaire (choice grids, budget, pace, days, notes). `onboarding_flow.dart` supplies state and callbacks; this file supplies presentation. |

### 3.3 Newer feature screens

Most feature screens compose reusable components and use local state/sample
values. They are reachable through the core route table, though the root auth
flow described above does not automatically enter every feature version.

| File | Purpose and execution |
|---|---|
| `lib/features/auth/presentation/screens/welcome_screen.dart` | Feature-style welcome UI with create-account and login buttons. It uses responsive layout helpers, app colors, and `AppButton`; route table's `/` entry does not make it the default because `main.dart` replaces root with `AuthGate`. |
| `lib/features/auth/presentation/screens/login_screen.dart` | Design-oriented login form with local controllers and a half-second simulated loading delay. It then navigates to onboarding; it does not call Supabase or validate/sign in. |
| `lib/features/auth/presentation/screens/register_screen.dart` | Design-oriented registration form. Like the feature login screen, submit and Google buttons move to onboarding rather than creating a Supabase user. |
| `lib/features/auth/presentation/screens/forgot_password_screen.dart` | Newer presentation variant for the recovery flow; route is registered separately from the active legacy auth path. |
| `lib/features/auth/presentation/screens/verification_code_screen.dart` | Newer OTP-style verification presentation. The live password-recovery sequence currently uses `screens/auth/verification_screen.dart`. |
| `lib/features/auth/presentation/screens/create_new_password_screen.dart` | Newer password form presentation. The live legacy recovery sequence instead uses `screens/auth/new_password_screen.dart`. |
| `lib/features/auth/presentation/screens/password_updated_screen.dart` | Newer password-success presentation, separate from the legacy screen reached after a real password update. |
| `lib/features/onboarding/presentation/screens/onboarding_flow_screen.dart` | Alternative seven-step visual questionnaire built with newer components. It keeps answers in screen state and does not use `MemberPreferences` or `PreferencesService`; main's `/onboarding` override means the persisted legacy flow is the one normally selected by that route. |
| `lib/features/shell/presentation/screens/main_shell_screen.dart` | Five-tab app shell. Uses `IndexedStack` so each tab remains mounted while switching. Updates selected index with `setState`; tab callbacks can move home shortcuts to Trips, Groups, or Profile. |
| `lib/features/shell/presentation/screens/home_tab.dart` | Home dashboard, greeting, hero banner, sample group shortcuts, and trip cards. Reads the current Supabase user for a displayed name but much of the dashboard content is static. Buttons navigate to trip/group detail routes. |
| `lib/features/shell/presentation/screens/trips_tab.dart` | Search/filter bar and a static list of group/trip cards. Search controller is disposed correctly; the filter currently shows a snackbar, and the sample list is not loaded from a repository. |
| `lib/features/shell/presentation/screens/create_tab.dart` | Hosts `PlanTripScreen` as the Create tab; when the planner calls `onCompleted`, it switches the shell to Trips. |
| `lib/features/shell/presentation/screens/groups_tab.dart` | Static group panel for “Bantayan Squad”, availability, and sample members. Invite actions open the create-group route; member callbacks are currently empty. |
| `lib/features/shell/presentation/screens/profile_tab.dart` | Reads Supabase email/metadata for profile labels, shows static preference summary rows, links to onboarding, and signs out. The preference summary is not actually loaded from `PreferencesService`. Its update action currently navigates to `/onboarding` without the legacy flow's `editing: true` flag. |
| `lib/features/shell/presentation/widgets/hero_banner_trio.dart` | Decorative illustration widget used by the home hero banner. |
| `lib/features/trips/presentation/screens/plan_trip_screen.dart` | Stateful multi-stage planner. Collects trip details, selected sample members, planning mode, and itinerary entries. Its “AI” stage is a timed UI transition, not a call to an AI service. Manual itinerary submission calls `TripRepository.saveManualItineraryItem`; finishing calls `saveTrip`, which attempts database writes and updates local notifier data. |
| `lib/features/trips/presentation/screens/trip_overview_screen.dart` | Detail/overview design for one trip, with default sample parameters and a remote Unsplash image (with a visual fallback). Share/more controls are currently empty callbacks. |
| `lib/features/trips/presentation/screens/member_responses_screen.dart` | Sample confirmed/pending member list. “Nudge” actions mutate an in-memory flag and display snackbars; no notifications are sent. |
| `lib/features/groups/presentation/screens/create_group_flow_screen.dart` | Four-stage-looking create/invite/review/confirmation interface with example group name, description, and members. It validates the group name and changes local screen state; there is no group database operation. |
| `lib/features/groups/presentation/screens/group_detail_screen.dart` | Group page with overview/trips/availability/members tabs. Group name is passed as a route argument. Trip and availability content uses reusable panels; trip list can observe `TripRepository.tripsNotifier` via `ValueListenableBuilder`. |
| `lib/features/groups/presentation/screens/group_overview_screen.dart` | Separate static overview-style group page with sample member/trip data. Registered as `/group-overview`; distinct from the tabbed `GroupDetailScreen`. |
| `lib/features/groups/presentation/widgets/shield_check_icon.dart` | Small shield/check decorative icon used in the group flow. |
| `lib/features/chat/presentation/screens/group_chat_screen.dart` | Sample messages held in a local list. Sending trims text, appends a local “You” message, clears the composer, and rebuilds. No chat API, realtime stream, or persistent message store is implemented. |
| `lib/features/notifications/presentation/screens/invitations_screen.dart` | Sample invitation list. Accept/decline removes an item from local state and displays a snackbar; no server-side invitation action occurs. |
| `lib/features/expenses/presentation/screens/expense_updates_screen.dart` | Sample expense/balance details. “Settle Up” changes local status and displays a GCash confirmation message; the code does not perform a payment. |

### 3.4 Reusable visual components

The `components` directory follows the atomic-design idea: **atoms** are small
controls, **molecules** combine controls into a reusable row/card, and
**organisms** are larger screen sections. These widgets receive data and
callbacks from their parent; they do not own backend repositories.

| File | Reusable responsibility |
|---|---|
| `components/atoms/app_avatar.dart` | User avatar/initial circles and groups of overlapping member avatars/tokens. |
| `components/atoms/app_badge.dart` | Status/role/tier badges and RSVP state tiles. |
| `components/atoms/app_button.dart` | Main branded button variants, disabled/loading state, press animation, optional leading/trailing icons. |
| `components/atoms/app_checkbox.dart` | Custom checkbox sizes and selected/unselected visuals; reports changes through callback. |
| `components/atoms/app_icon.dart` | Icon wrapper; handles Iconsax glyphs and uses custom path painting for supported solid glyphs. |
| `components/atoms/app_icon_button.dart` | Circular/compact icon action button with disabled and loading states. |
| `components/atoms/app_input_field.dart` | Shared styled text entry supporting password visibility, validation, errors, helper text, and loading/read-only states. |
| `components/atoms/app_otp_field.dart` | Multi-cell OTP input; strips non-digits and reports changed/completed code. |
| `components/atoms/app_pressable.dart` | Reusable animated press-scale interaction wrapper. |
| `components/atoms/app_switch.dart` | Styled boolean toggle whose parent owns the value. |
| `components/atoms/app_text.dart` | Text wrapper for app text variants, color, weight, truncation, and alignment. |
| `components/atoms/iconsax_solid_paths.dart` | Encoded vector path data and path construction used by `AppIcon` for specific solid icon glyphs. |
| `components/molecules/app_availability_pill.dart` | Selectable weekday pill. |
| `components/molecules/app_availability_row.dart` | A weekday row displaying free-member counts. |
| `components/molecules/app_budget_slider.dart` | Discrete budget selection and formatted budget labels for onboarding/planning. |
| `components/molecules/app_chat_message.dart` | Chat bubble presentation with alignment/style based on whether the sender is the current user. |
| `components/molecules/app_dropdown_field.dart` | Labeled dropdown field with options and selection callback. |
| `components/molecules/app_labeled_form_field.dart` | Label-plus-input form composition. |
| `components/molecules/app_member_action_row.dart` | Member label and an optional row action. |
| `components/molecules/app_message_composer.dart` | Message text input and send affordance; caller supplies controller and send callback. |
| `components/molecules/app_navigation_item.dart` | One labeled item in the bottom navigation. |
| `components/molecules/app_option_card.dart` | Selectable option card supporting icon/custom icon and selected color. |
| `components/molecules/app_pace_card.dart` | Travel-pace selection card with title, description, icon, and selected state. |
| `components/molecules/app_preference_choice.dart` | Compact selectable preference option. |
| `components/molecules/app_search_bar.dart` | Search field with text callbacks and clear state. |
| `components/molecules/app_search_filter_bar.dart` | Search field plus optional filter action. |
| `components/molecules/app_segmented_tabs.dart` | Generic selectable segmented tabs; labels come from a supplied function. |
| `components/molecules/app_trip_metadata.dart` | Location, dates, and optional group details displayed in one component. |
| `components/organisms/app_bottom_navigation.dart` | Five app tabs; emits selected tab index. Used by the main shell and group detail view. |
| `components/organisms/app_main_top_bar.dart` | Main-shell app bar for profile, notifications, and settings. The settings sheet includes sign-out behavior. |
| `components/organisms/app_top_bar.dart` | General title/subtitle/back-button app bar for feature pages. |
| `components/organisms/availability_panel.dart` | Availability summary composed from weekday rows and member names/counts. |
| `components/organisms/group_header_organism.dart` | Group identity, member summary, and plan-trip action header. |
| `components/organisms/member_panel.dart` | Member row/list panel with optional search, action, loading, and empty states. |
| `components/organisms/overview_summary_panel.dart` | Summary metric cards for group/trip overview values. |
| `components/organisms/trip_summary_card.dart` | Tappable trip card with remote image/fallback, trip metadata, loading, and error states. |

### 3.5 Theme, design constants, and responsive helpers

| File | Purpose |
|---|---|
| `lib/core/constants/app_colors.dart` | Shared brand, semantic, neutral, and surface colors. |
| `lib/core/constants/app_radii.dart` | Standard rounded-corner radii, including pill and card shapes. |
| `lib/core/constants/app_spacing.dart` | Spacing values, screen/card padding, and minimum tap-target size. |
| `lib/core/constants/app_typography.dart` | Urbanist heading/button styles and Open Sans body styles via `google_fonts`. |
| `lib/core/theme/app_theme.dart` | `ThemeData` used by `MaterialApp`; sets color scheme, app bars, text styles, cards, input borders, checkbox styles, and page transitions. |
| `lib/core/theme/smooth_page_route.dart` | Generic slide-and-fade `PageRouteBuilder`. No usage was found in the app's current route wiring; named routes use `MaterialPageRoute`. |
| `lib/core/utils/app_responsive.dart` | Breakpoint helpers, `AppResponsiveWrapper` for narrow phones/tablets, and `AppScrollableFillBody`. The wrapper is not installed as `MaterialApp.builder`; `AppScrollableFillBody` is used by feature welcome UI. |
| `lib/theme/app_theme.dart` | Older, separate theme palette and `buildAppTheme()` helper. It serves the legacy onboarding/auth widgets and is not the global `MaterialApp` theme (which uses `core/theme/app_theme.dart`). |
| `lib/widgets/auth_widgets.dart` | Shared legacy auth layout, logo badge, headers, button, fields, OTP input, and footer/divider patterns. The legacy `screens/auth` screens compose these widgets. |
| `lib/widgets/onboarding_widgets.dart` | Legacy onboarding UI building blocks: progress pills, question header, choice grid/tiles, and multiline notes field. Used by `screens/onboarding/onboarding_steps.dart`. |

### Tests and repository-level support files

| File | Purpose and observed behavior |
|---|---|
| `test/onboarding_test.dart` | Exercises all seven onboarding steps and checks saved values through an injected fake `PreferencesService`; also checks that edit mode restores a custom answer. The full-flow test currently expects a `HOME` page but the flow navigates to `/`, while the test harness registers `/home`. |
| `test/widget_test.dart` | Tests the initial auth screen and a forgot-password-to-verification path using `AnoTaraApp`. It currently pumps the app without initializing Supabase, so `AuthGate` throws before the expected UI can appear. |
| `README.md` | Still the default Flutter starter text (“A new Flutter project”), with links to Flutter learning resources; it does not explain Ano Tara's features. |
| `.gitignore` | Git ignore rules for Flutter build/package output, Android build artifacts, IDE metadata, and common temporary files. |
| `.metadata` | Flutter-generated project metadata used by Flutter tooling; it does not implement a runtime feature. |
| `pubspec.lock` | Generated package resolution lockfile, recording exact resolved versions and package sources. |

## 4. Application workflows

### Startup and signed-in routing

```text
Flutter platform launcher
  → lib/main.dart: main()
  → WidgetsFlutterBinding.ensureInitialized()
  → Supabase.initialize(...)
  → runApp(AnoTaraApp)
  → MaterialApp(home: AuthGate)
  → AuthGate listens to Supabase auth state
      ├─ no session → screens/auth/start_screen.dart
      └─ session exists → OnboardingCheck
           → PreferencesService.load()
               ├─ no member_preferences row → screens/onboarding/onboarding_flow.dart
               ├─ row exists → HomeScreen → MainShellScreen
               └─ error → retry button
```

`StreamBuilder` rebuilds the gate when Supabase auth emits an event. The
`OnboardingCheck` future loads once per signed-in user because the gate keys it
with the user ID. The home shell is also reachable at the explicit `/home`
route.

### Account creation and login

```text
StartScreen → SignUpScreen or LoginScreen (legacy direct MaterialPageRoute)

Sign up:
form validators → username_available RPC → Supabase auth.signUp
  → account metadata (first name, last name, username)
  → confirmation notice OR signed-in auth event
  → AuthGate sees session → preference check → onboarding/home

Login:
form validators → Supabase signInWithPassword
  → success clears the pushed auth screens
  → AuthGate sees the session → preference check → onboarding/home
```

Google sign-in/sign-up launches an external browser OAuth flow and relies on a
custom URI callback configured in platform manifests. It is not the same as the
feature-auth presentation screens, whose buttons simulate progress only.

### Password recovery

```text
Login → ForgotPasswordScreen
  → validate email → resetPasswordForEmail
  → VerificationScreen(email)
  → enter 6-digit code → verifyOTP(type: recovery)
  → NewPasswordScreen → updateUser(password) → signOut
  → PasswordUpdatedScreen → LoginScreen
```

Auth exceptions are converted to snackbars. The recovery screen also starts a
60-second resend cooldown. The UI does not show the remaining seconds in the
inspected implementation; resend simply does nothing while the timer is active.

### Onboarding questionnaire

```text
OnboardingFlow
  → 1 Activities (at least one required)
  → 2 Dietary preferences
  → 3 Allergies
  → 4 Budget
  → 5 Travel pace (required)
  → 6 Usual available days (at least one required)
  → 7 Notes
  → MemberPreferences
  → PreferencesService.save()
  → upsert member_preferences on user_id
  → return to AuthGate or pop with true in editing mode
```

Step state stays in the screen as sets, an integer budget, an enum pace, and
text controllers. `MemberPreferences.toMap()` supplies the Supabase column
names. For custom “Others” answers, the selected option is a UI marker and the
typed text is stored in the relevant list.

### Trip creation and itinerary

```text
Home Plan a Trip / Create tab / group header
  → PlanTripScreen
  → trip details
  → member selection
  → AI or manual mode selection
  → sample AI-loading timer or manual itinerary screens
  → TripRepository.saveTrip(...)
       → try insert trips; collect returned trip id
       → try insert trip_members
       → try insert itinerary_items
       → on backend error, log and continue locally
       → prepend TripModel to tripsNotifier
  → GroupDetailScreen listens to tripsNotifier and rebuilds trip content
```

The “AI” path is a timed transition to a populated sample itinerary. Search
recommendations and member lists are local arrays. A manually added item is
prepended to `manualItineraryItemsNotifier` before its database insert. A
successful local UI update therefore does not prove that the backend write
succeeded.

### Other user actions

* Main tab selection updates `_currentIndex`; `IndexedStack` preserves the tab
  widgets instead of disposing them on every change.
* Group cards, app-bar notification actions, and trip cards navigate via named
  routes and optional route arguments (usually a group name).
* Chat, accept/decline, expense settle-up, member nudges, and group creation
  mutate local lists/flags or show snackbars. The code does not send chat
  messages, payment requests, invitation responses, group creation, or
  notifications to Supabase.

## 5. Data and backend map

| Data | Read/write path | What the repository confirms |
|---|---|---|
| Supabase auth session | `main.dart` initializes client; `AuthGate`, login/register/recovery screens, profile and app bar use `supabase.auth`. | Email/password, OAuth, reset OTP, password update, current user, sign-out are present. |
| Username availability | `screens/auth/sign_up_screen.dart` calls RPC `username_available` with `p_username`. | Server-side function/schema is not included in this repository; its implementation and permissions cannot be verified here. |
| Member preferences | `PreferencesService` reads/writes `member_preferences`; model maps preference columns. | Assumes a `user_id` column and an upsert conflict key on `user_id`. Schema and Row Level Security policies are not checked in source. |
| Trip records | `TripRepository.saveTrip` inserts `trips`, then `trip_members`, then `itinerary_items`. | No trip read/query from Supabase appears in this repository. Existing trip list begins with hard-coded seeds. |
| Standalone itinerary item | `TripRepository.saveManualItineraryItem` inserts to `itinerary_items`. | The local notifier updates before the insert and remains updated if insert fails. |
| Groups, messages, invitations, expenses | Sample widget state. | No database/API persistence is implemented for these screens in the inspected source. |
| Trip image | `Image.network` in trip card/overview. | Uses a remote Unsplash image URL with visual error fallback; not a repository asset. |

Supabase URL and publishable client configuration are currently specified in
`lib/main.dart`. The actual configuration values are intentionally omitted from
this guide. A publishable client key is expected to be present in client apps;
database authorization must therefore be enforced by Supabase policies and
server-side function permissions. No schema/migrations or policy files were
found in the repository.

## 6. Packages and assets

### Direct dependencies (`pubspec.yaml`)

| Dependency | Type | Use in source |
|---|---|---|
| `flutter` | SDK dependency | Flutter widgets, Material UI, layout, navigation, and platform app. |
| `cupertino_icons` | Flutter package | iOS-style icon package; no direct `CupertinoIcons` use was found in `lib/`. |
| `supabase_flutter` | Flutter/Dart package | `Supabase.initialize`, client auth, OAuth, RPC, and PostgREST table operations. |
| `iconsax` | Dart/Flutter package | Iconsax glyphs used throughout components and screens. |
| `google_fonts` | Flutter package | Urbanist and Open Sans typography. The project also stores TTF files in `assets/fonts`, but `pubspec.yaml` does not declare those files as assets/fonts. |

### Development dependencies

| Dependency | Type | Use |
|---|---|---|
| `flutter_test` | Flutter SDK dev dependency | Widget tests under `test/`. |
| `flutter_lints` | Dart dev dependency | Recommended analyzer rules included by `analysis_options.yaml`. |

`pubspec.lock` records resolved direct and transitive package versions for
repeatable package resolution. It is generated by Pub; it is not a place to add
application dependencies manually.

### Assets

`assets/fonts/` contains `Urbanist-SemiBold.ttf`, `Urbanist-Medium.ttf`,
`Urbanist-ExtraBold.ttf`, `Urbanist-Bold.ttf`, `OpenSans-SemiBold.ttf`,
`OpenSans-Regular.ttf`, and `OpenSans-Bold.ttf`. The app's styles call
`GoogleFonts.*`; the bundled TTFs are not explicitly registered in
`pubspec.yaml` in this snapshot. There are no declared image assets in the
manifest. Material icons are enabled with `uses-material-design: true`.

## 7. Platform and project configuration

| Path | Role |
|---|---|
| `pubspec.yaml` | Package name/version, Dart SDK constraint, dependencies, dev dependencies, Material icon and asset configuration. |
| `analysis_options.yaml` | Excludes platform/build folders from Dart analysis and includes `flutter_lints`. |
| `.metadata` | Flutter project metadata used by Flutter tooling. |
| `.gitignore` | Excludes generated outputs, local files, and build artifacts. |
| `android/settings.gradle.kts` | Locates Flutter SDK from Android `local.properties`, loads Flutter Gradle integration and Android/Kotlin Gradle plugins. |
| `android/build.gradle.kts` | Shared Maven repositories, build output location, and clean task. |
| `android/app/build.gradle.kts` | App namespace/ID, Android SDK/NDK and Java/Kotlin 17 settings, app version values, Flutter Gradle source. Release currently uses debug signing, so it is not a production signing setup. |
| `android/app/src/main/AndroidManifest.xml` | Android app label/icon, main Activity, launcher intent and custom Supabase callback intent filter. The declared callback host is `signup-callback`; the login flow uses `login-callback`, so this needs platform/OAuth configuration verification. |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Minimal `FlutterActivity` host. |
| `android/app/src/main/res/` | Android launch background, styles, and mipmap launcher icons. |
| `ios/Runner/Info.plist` | iOS display/app metadata, URL scheme, storyboard names, and supported orientations. It registers the `io.supabase.anotara` scheme. |
| `ios/Runner/AppDelegate.swift`, `SceneDelegate.swift` | iOS Flutter app/scene lifecycle integration and plugin registration. |
| `ios/Runner/Base.lproj/` and `Assets.xcassets/` | Native launch/main storyboards and launch image resources. |
| `ios/Runner.xcodeproj/`, `ios/Runner.xcworkspace/` | Xcode project/workspace and scheme settings. |
| `web/index.html` | Browser entry document, title/metadata, manifest reference, and Flutter bootstrap script. It retains template text such as “A new Flutter project.” |
| `linux/runner/` | GTK desktop entry and application/window implementation. `linux/flutter/` plugin registration is generated. |
| `macos/Runner/` | macOS app delegate/window and native app configuration. `macos/Flutter/GeneratedPluginRegistrant.swift` is generated. |
| `windows/runner/` | Win32 entry point, Flutter window and window utilities/resources. `windows/flutter/` plugin registration is generated. |

The standard platform folders are Flutter launch/build hosts. The user-facing
business logic lives in `lib/`; native source does not implement separate trip
or auth features.

## 8. Dart and Flutter concepts used

| Concept | Meaning here |
|---|---|
| `StatelessWidget` / `StatefulWidget` | Stateless widgets render from inputs; stateful screens retain interactive state. Examples include `WelcomeScreen`, `LoginScreen`, and tab screens. |
| `build(BuildContext)` | Describes the widget tree Flutter should render. It may run repeatedly after state changes. |
| `BuildContext` | A handle to a widget's location, used for navigation, theme, snackbar, and layout lookup. |
| `setState()` | Marks a stateful screen for rebuild after values change (selected tab, loading state, answers, etc.). |
| `async` / `await` / `Future` | Used for Supabase operations and asynchronous form submissions. A `Future` represents one eventual result. |
| `Stream` / `StreamBuilder` | Supabase auth events can happen over time; `AuthGate` rebuilds when a new auth state arrives. |
| `FutureBuilder` | `OnboardingCheck` renders loading/error/data states while a preference lookup completes. |
| `ValueNotifier` / `ValueListenableBuilder` | Lightweight observable trip state. Repository updates notify `GroupDetailScreen` listeners to rebuild. |
| Controllers | `TextEditingController` reads and manages text input; screens dispose their controllers when removed. |
| Navigator / named routes | Pushes screens onto a route stack, passes route arguments, or clears stack after sign-in/sign-out/onboarding. |
| Classes, constructors, encapsulation | Models bundle data; widgets expose constructor parameters and keep screen-only state private with `_` names. |
| Enums and generics | `TravelPace`, `PlanTripStep`, and `GroupDetailTab` represent finite choices. `AppSegmentedTabs<T>` works with typed tab values. |
| Collections | Lists hold ordered messages/trips; sets hold unique selected preferences; maps represent Supabase rows and sample UI records. |
| Null safety | Optional values use `?`; defaults and `??` handle absent metadata/columns; `!` appears where code assumes a form key or value is available. |
| Form validation | `Form`, `GlobalKey<FormState>`, and validator callbacks validate auth fields before submitting. |
| Composition and callbacks | Parent screens assemble reusable child widgets and pass `VoidCallback`/`ValueChanged` handlers down to them. |
| Exceptions | Auth screens catch Supabase `AuthException` and generic failures to display messages. Preference screens show retry/error messages. Trip writes catch and log failures while preserving local state. |

No separate provider/bloc state container, local SQL database, or custom HTTP
client was found.

## 9. Dependency and relationship map

| Source | Depends on / calls | Used by / effect |
|---|---|---|
| `main.dart` | Both route catalogs, `AppTheme`, `AuthGate`, `MainShellScreen`, `OnboardingFlow`, Supabase SDK | Application bootstrap, global theme, root auth gate and routes |
| `services/auth_service.dart` | `main.dart` client, `PreferencesService`, preference model, legacy `StartScreen`/`OnboardingFlow`, `HomeScreen` | `main.dart`'s `MaterialApp.home` |
| `screens/auth/login_screen.dart` | Supabase client, validators, auth widgets, legacy route constants | `StartScreen`; opens recovery/register and returns to root on login |
| `screens/auth/sign_up_screen.dart` | Supabase client/RPC, validators, auth widgets | `StartScreen`; sign-up and OAuth |
| `screens/auth/forgot_password_screen.dart` | Supabase client, validators, `VerificationScreen` | Login screen |
| `screens/auth/verification_screen.dart` | Supabase OTP, `NewPasswordScreen`, OTP/auth widgets | Forgot-password flow |
| `screens/auth/new_password_screen.dart` | Supabase auth, validators, `PasswordUpdatedScreen` | Recovery verification flow |
| `screens/onboarding/onboarding_flow.dart` | `MemberPreferences`, `PreferencesService`, onboarding widgets/steps | Auth gate, named `/onboarding`, profile action |
| `services/preferences_service.dart` | Supabase PostgREST client and model mapper | Auth gate and onboarding flow |
| `features/shell/.../main_shell_screen.dart` | Five tab screens and bottom navigation | `HomeScreen` and `/main` route |
| `features/shell/.../home_tab.dart` | Supabase current-user metadata, app top bar/buttons/trip cards, core route constants | Main shell home tab |
| `features/shell/.../profile_tab.dart` | Supabase current user/sign out, UI components, route constants | Main shell profile tab |
| `features/trips/.../plan_trip_screen.dart` | UI atoms, responsive helpers, `TripRepository` models/repository | Create tab, `/plan-trip`, group-header action |
| `features/trips/data/trip_repository.dart` | Supabase client, Flutter `ValueNotifier` | Planner writes; `GroupDetailScreen` reads local notifier |
| `features/groups/.../group_detail_screen.dart` | Group/trip organisms, route constants, `TripRepository`, shell | `/group-detail`; displays repository's local trip notifier |
| `features/chat/.../group_chat_screen.dart` | `AppChatMessage`, `AppMessageComposer` | `/group-chat` |
| `features/notifications/.../invitations_screen.dart` | App colors/type/button; local invitation list | Home/trips/profile app-bar notification routes |
| `features/expenses/.../expense_updates_screen.dart` | App colors/type/button; local settled flag | `/expense-updates` |
| `components/organisms/app_bottom_navigation.dart` | Navigation item molecule, pressable atom | Main shell and standalone group detail |
| `components/organisms/trip_summary_card.dart` | Trip metadata, icon, pressable atoms | Home and group/trip overview content |
| `components/organisms/availability_panel.dart` | Availability row/pill molecules | Groups and group detail |
| `components/atoms/app_icon.dart` | Iconsax and custom solid icon paths | Shared screens/components needing Iconsax glyphs |
| `core/theme/app_theme.dart` | Colors, radii, Google Fonts | `main.dart` global Material theme |

## 10. Findings and recommendations

### Confirmed observations

1. **Parallel auth/onboarding implementations exist.** The top-level legacy
   screens perform backend operations; similarly named feature auth screens
   mostly simulate navigation. Main starts in the legacy implementation.
2. **The `/onboarding` route is overwritten in `main.dart`.** The final map
   entry is the legacy `OnboardingFlow`, not the registered feature
   `OnboardingFlowScreen`.
3. **Profile preference editing does not set edit mode.** The profile tab
   navigates to `/onboarding`; that route builds `OnboardingFlow()` with default
   `editing: false`. The separate `/preferences/edit` constant is declared but
   is not registered/used as that profile action.
4. **Password login may bypass the preference gate.** The legacy login screen
   explicitly replaces the route stack with `/home` after a successful password
   response. `/home` builds `MainShellScreen` directly, while the auth gate's
   intended first-login path checks for saved preferences. Which route wins
   can depend on auth-stream and request timing; this should be consolidated
   around one post-auth routing decision.
5. **Most group/chat/invitation/expense screens are prototypes.** Their actions
   update local widget state and show UI feedback; no corresponding backend
   writes are present.
6. **Trip persistence is write-only in the inspected app source.** Local seed
   trips and `ValueNotifier` state provide UI data; no Supabase trip retrieval
   was found. The repository catches database failures and still returns a
   locally created trip.
7. **OAuth redirect configuration needs a consistency check.** Android's
   manifest declares the custom scheme with host `signup-callback`. The login
   screen requests `login-callback`, while signup OAuth requests
   `signup-callback`. iOS registers the scheme without constraining a host.
   The deployed Supabase redirect allowlist and Android intent filters must
   match each exact URI.
8. **Font assets are present but not declared.** The manifest does not declare
   `assets/fonts`; code uses GoogleFonts APIs instead.
9. **Project tests currently fail.** `flutter test` produced 1 passing and 3
   failing tests. `widget_test.dart` pumps `AnoTaraApp` without running the
   `main()` initializer, so `AuthGate` throws “You must initialize the supabase
   instance”. The full onboarding test expects `HOME` after finish, but its
   harness defines `/home` and the flow navigates to `/`; those routes do not
   line up in that test setup.
10. **Some errors are intentionally hidden behind generic UI text.** Auth
   failures generally show a snackbar, but generic exceptions become broad
   “Something went wrong” messages. Trip write exceptions are only printed and
   are not surfaced to the user.
11. The onboarding flow calls `debugPrint` with the full preference map before
    saving. It does not expose a credential, but it does put user-entered
    preference notes into logs and should be removed or redacted for production.
12. `MemberPreferences` documentation describes the row as keyed by
    `member_id`, but `PreferencesService` actually queries/upserts on `user_id`.
    Database schema and source comments should agree.
13. Android release configuration uses debug signing and the web document
    retains Flutter template title/description. These are deployment-readiness
    items, not runtime features.

### Suggested next improvements

* Choose one canonical auth and onboarding implementation and remove route
  ambiguity only after deciding which UI is intended to ship.
* Inject an auth client/service into screens (as onboarding already allows for
  preferences) so widget tests can run without a real Supabase initialization.
* Align tests with the actual route contract and test auth success/error using
  fakes rather than network access.
* Add trip/group read operations, backend schemas/policies/migrations, and
  explicit user-visible save failures before treating those screens as
  persistent product features.
* Verify OAuth callback URLs in Supabase and all platform manifests; configure
  production signing and externalize environment-specific configuration.
* Remove or redact the onboarding-answer debug log. Confirm Row Level Security
  and `username_available` RPC permissions in the Supabase project (those
  server-side settings are outside this repository).
* Either register bundled font files in `pubspec.yaml` and use them locally, or
  remove the unused TTF files and document the runtime Google Fonts behavior.

## 11. Analysis checklist

| Scope | Status |
|---|---|
| All 88 Dart files under `lib/` listed in the tree and assigned a responsibility | Analyzed |
| `test/onboarding_test.dart` and `test/widget_test.dart` | Analyzed; suite executed and failures recorded |
| `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.metadata`, `.gitignore`, `README.md` | Reviewed |
| Assets under `assets/fonts/` | Listed and checked against manifest registration |
| Android, iOS, web, Linux, macOS, and Windows source/configuration entry points | Reviewed at app-configuration and launcher level |
| Generated build output, package caches, and ephemeral plugin files | Excluded from feature analysis; these are tool outputs, not maintained app logic |
| `.widget_preview/` | Identified as a separate local preview/tooling folder, not part of `pubspec.yaml` app target |

No Dart application file in the project source tree was silently skipped.
