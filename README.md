# PlantApp 🌱

PlantApp is a Flutter mobile application for managing plant care.  
The app helps users store their plants, track watering needs, view weather-based care advice, customize their local profile, switch app themes, and receive local care notifications.

## Features

### User Account / Profile

- Local registration
- Local login
- Logout
- Editable profile
- Display name customization
- Email customization
- Bio customization
- Avatar emoji customization
- Profile data saved locally in SQLite
 User credentials are stored locally using a password hash.

### Plant Management

The app includes full CRUD functionality for plants:

- Add new plants
- View saved plants
- Edit existing plants
- Delete plants
- Search plants
- Mark plants as favorites
- Store watering interval
- Store plant care notes
- Track last watered date
- Calculate next watering date

All plant data is saved locally using SQLite.

### Care Today

The Care Today screen shows plants that need watering based on their watering interval.

Users can:

- View plants that need care today
- Mark a plant as watered
- Update the last watered date
- Receive a local notification after marking a plant as watered

### Weather Advice

The Weather Advice screen uses the phone's current location to fetch dynamic weather data.

It shows:

- Temperature
- Humidity
- Rain/precipitation information
- Weather condition
- Plant care advice based on weather conditions

The app uses the Open-Meteo API for weather data.

### Theme Customization

The app supports:

- System theme
- Light mode
- Dark mode

The selected theme is saved locally in SQLite and remains active after restarting the app.

### Navigation

The app includes intuitive navigation:

- Landing page / splash screen
- Register/Login flow
- Bottom navigation bar
- Responsive navigation rail on wider screens
- Navigation between:
  - Plants
  - Care Today
  - Weather
  - Profile
  - Settings


### Notifications

The app uses local notifications.

Examples:
- Test notification from Settings
- Plant watered notification from Care Today

Notifications are local to the device.
### Responsive Design

The UI adapts to different screen sizes using responsive layout components.

On mobile devices, the app uses bottom navigation.  
On wider screens, the app can use a navigation rail layout.

## Technologies Used

- Flutter
- Dart
- SQLite
- sqflite
- Provider
- GoRouter
- Geolocator
- HTTP
- Flutter Local Notifications
- Open-Meteo API

## Project Structure

lib/
  core/
    controllers/
      app_controller.dart
    theme/
      app_colors.dart
      app_radius.dart
      app_spacing.dart
      app_text_styles.dart
      app_theme.dart

  data/
    database/
      app_database.dart
    models/
      plant.dart
      user_profile.dart
    repositories/
      plant_repository.dart
      profile_repository.dart

  features/
    auth/
      auth_screen.dart
    care/
      care_today_screen.dart
    landing/
      landing_page.dart
    plants/
      plant_list_screen.dart
    profile/
      profile_screen.dart
    settings/
      settings_screen.dart
    weather/
      weather_advice_screen.dart

  navigation/
    app_router.dart
    app_shell.dart

  services/
    location_service.dart
    notification_service.dart
    weather_service.dart

  shared/
    widgets/
      empty_state.dart
      responsive_page.dart

  main.dart

  ## Running the App

  Make sure you have the following tools installed: 
  - Flutter SDK
  - Dart SDK
  - Android Studio
  - Android SDK
  - VSC
  - Git

  Open the project in VSC and run the following code in the terminal: 
  
  - flutter clean
  - flutter pub get
  - flutter run

