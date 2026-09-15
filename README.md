# bci-mobile-app

Flutter mobile app for the BCI School Management System.

**Primary users:** guardians/parents (applications, ward profiles, fees,
receipts, wallet/pocket-money, attendance view, stationery store,
announcements, chat with school) and staff (duty roster, timetable,
attendance marking for teachers, salary/payslip view, staff messaging).

Talks to `bci-backend-api` over REST; push notifications via Firebase
Cloud Messaging.

## Stack
Flutter (Dart), Riverpod for state, go_router for navigation.

## Getting started
```bash
flutter pub get
flutter run
```

## Feature layout (`lib/features/`)
`auth`, `applications`, `student_profile`, `attendance`, `fees_payment`,
`wallet`, `stationery_store`, `staff_dashboard`, `timetable`, `messaging`,
`announcements`, `payroll_view` — build in the order set out in
the `bci-docs` repo section 9 (Phase 1 → Phase 6), not all at once.

Prioritize Android first (majority of guardians' devices in this context),
add iOS once core flows are stable.
