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
- **Pet Safety Warning:** A prominent, serious warning card appears on dates with fireworks, providing advice on how to protect pets from anxiety and panic.
- **Personalizable Calendar Reminders:** Users can add reminders to their native calendar for fireworks events, with customizable titles, descriptions, and times.

## Testing
The project includes a comprehensive suite of unit and widget tests:
- **Unit Tests:** Cover the `FireworksEvent` model and `HolidayService` (using `mockito` to mock HTTP requests).
- **Widget Tests:** Verify the `FireworksCalendarPage` UI states (loading, error, success) and interactions, mocking the underlying service.

## File Structure
- `lib/main.dart`: Main entry point and UI implementation.
- `lib/fireworks_events.dart`: Data model for events.
- `lib/services/holiday_service.dart`: Service to fetch holidays from the API.
