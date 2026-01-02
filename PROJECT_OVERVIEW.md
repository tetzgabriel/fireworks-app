# Project Overview: Vai ter fogos hoje?

## Description
"Vai ter fogos hoje?" is a Flutter application that displays a calendar highlighting dates with a high probability of fireworks in Brazil. It provides a beautiful, month-by-month view and details specific events like New Year's Eve, Carnival, and June Festivals.

## Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **Key Packages:**
    - `table_calendar`: For the calendar UI.
    - `intl`: For date formatting and locale support (pt_BR).
    - `http`: For fetching holiday data from the API.

## Key Features
- Month-by-month calendar view.
- Event markers for days with fireworks (based on holidays).
- Detailed list of events for selected days.
- Dark, festive theme ("beautiful" design).
- Localized for Brazil (pt_BR).
- Real-time data fetching from `BrasilAPI`.

## File Structure
- `lib/main.dart`: Main entry point and UI implementation.
- `lib/fireworks_events.dart`: Data model for events.
- `lib/services/holiday_service.dart`: Service to fetch holidays from the API.
