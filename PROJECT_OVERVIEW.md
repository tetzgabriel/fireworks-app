# Project Overview: Vai ter fogos hoje?

## Description
"Vai ter fogos hoje?" is a Flutter application that helps users know if there will be fireworks on the current day or upcoming dates. It features a playful and cozy design, providing a direct answer for "today" and a calendar for planning ahead.

## Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **Key Packages:**
    - `table_calendar`: For the calendar UI.
    - `intl`: For date formatting and locale support (pt_BR).
    - `http`: For fetching holiday data from the API.
    - `add_2_calendar`: For adding events to the device calendar.

## Key Features
- **Home Page (Today):** 
    - Instantly answers "Is there going to be fireworks today?"
    - "Normal" (Calm) vs "Alert" (Celebration) visual states.
    - Animated playful interface.
- **Calendar Page:** 
    - Month-by-month calendar view.
    - Event markers for days with fireworks.
    - Ability to add reminders to the native device calendar.
- **Data Source:** Real-time data fetching from `BrasilAPI` for holidays.
- **Pet Safety Warning:** A prominent warning card appears on dates with fireworks to remind users about pet safety.
- **Cozy & Playful Design:** Dark theme with soothing colors for quiet nights and vibrant animations for celebration days.

## File Structure
- `lib/main.dart`: Main entry point and navigation (`MainScreen`).
- `lib/pages/home_page.dart`: The "Answer" page showing the status for today.
- `lib/pages/calendar_page.dart`: The calendar view for exploring future events.
- `lib/fireworks_events.dart`: Data model for events.
- `lib/services/holiday_service.dart`: Service to fetch holidays from the API.