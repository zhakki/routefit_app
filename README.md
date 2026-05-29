# RouteFit App

RouteFit is a cross-platform fitness and route tracking application built with Flutter.

The app allows users to register, log in, track routes with GPS, save completed routes, view route history, edit profile data, and see personal activity statistics. The project uses Firebase Authentication for user accounts and Cloud Firestore for storing user profiles, settings, routes, route points, and daily summaries.

---

## Project Description

RouteFit is designed for users who want to track their walking or running activity.  
The user can start a route, track distance and time, save the completed route, and later view route history and statistics.

The application combines:

- user authentication
- GPS route tracking
- Google Maps
- route history
- personal profile data
- weekly statistics
- Firebase Firestore database

---

## Main Features

### Authentication

- User registration with email and password
- User login and logout
- Firebase Authentication integration
- Automatic Firestore profile creation after registration

### User Profile

- View user profile data
- Edit name, age, weight, height and gender
- Store profile data in Firestore
- Save user settings:
  - distance unit
  - location permission preference
  - route saving preference
  - daily step goal

### Route Tracking

- Track route using GPS
- Display route on Google Maps
- Start and stop route tracking
- Calculate route distance
- Calculate route duration
- Calculate average speed
- Save completed route to Firestore
- Save route GPS points as a subcollection

### Route History

- View saved routes for the current user
- Show distance, duration, steps and calories
- Open route detail screen
- Edit route title
- Save updated route title to Firestore

### Result Screen

- Show completed route summary
- Display distance, duration, steps, calories and average speed
- Inform user that the route was saved to history

### Statistics

- Weekly activity overview
- Average daily steps
- Total weekly steps
- Total distance
- Total calories
- Completed daily goals
- Recent saved routes
- Statistics are calculated from the current user's saved routes

---

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Google Maps Flutter
- Location package
- Pedometer package
- Provider
- Wakelock Plus

---

## Firebase Data Structure

Firebase Authentication is used for user accounts.  
Cloud Firestore is used for application data.

```text
users
 └── {uid}
      ├── uid
      ├── email
      ├── fullName
      ├── age
      ├── weightKg
      ├── heightCm
      ├── gender
      ├── createdAt
      ├── updatedAt
      │
      ├── settings
      │    └── main
      │         ├── distanceUnit
      │         ├── saveRoutes
      │         ├── allowLocation
      │         ├── dailyStepGoal
      │         └── updatedAt
      │
      ├── routes
      │    └── {routeId}
      │         ├── routeId
      │         ├── userId
      │         ├── title
      │         ├── startTime
      │         ├── endTime
      │         ├── distanceKm
      │         ├── durationSeconds
      │         ├── steps
      │         ├── calories
      │         ├── averageSpeed
      │         ├── activityType
      │         ├── createdAt
      │         │
      │         └── points
      │              └── {pointId}
      │                   ├── pointId
      │                   ├── routeId
      │                   ├── latitude
      │                   ├── longitude
      │                   ├── accuracy
      │                   ├── altitude
      │                   └── timestamp
      │
      └── daily_summaries
           └── {yyyy-MM-dd}
                ├── summaryId
                ├── userId
                ├── date
                ├── totalSteps
                ├── stepGoal
                ├── progressPercent
                ├── calories
                ├── distanceKm
                ├── durationSeconds
                ├── createdAt
                └── updatedAt
```

---

## Project Structure

```text
lib/
 ├── models/
 │    ├── daily_step_summary.dart
 │    ├── route_model.dart
 │    ├── route_point.dart
 │    ├── user_profile.dart
 │    └── user_settings.dart
 │
 ├── providers/
 │    └── tracking_provider.dart
 │
 ├── screens/
 │    ├── app_shell.dart
 │    ├── auth_scaffold.dart
 │    ├── home_screen.dart
 │    ├── login_screen.dart
 │    ├── register_screen.dart
 │    ├── map_screen.dart
 │    ├── history_screen.dart
 │    ├── route_detail_screen.dart
 │    ├── result_screen.dart
 │    ├── profile_screen.dart
 │    ├── settings_screen.dart
 │    └── statistics_screen.dart
 │
 ├── services/
 │    ├── auth_service.dart
 │    ├── auth_user_flow_service.dart
 │    ├── route_service.dart
 │    ├── statistics_service.dart
 │    ├── step_service.dart
 │    └── user_service.dart
 │
 ├── theme/
 │
 ├── utils/
 │    ├── calorie_calculator.dart
 │    ├── distance_formatter.dart
 │    └── permission_helper.dart
 │
 ├── widgets/
 │    ├── auth_gate.dart
 │    ├── app_widgets.dart
 │    └── route_data.dart
 │
 ├── firebase_options.dart
 └── main.dart
```

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/zhakki/routefit_app.git
cd routefit_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

The project uses Firebase Authentication and Cloud Firestore.

Required Firebase files:

```text
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

If Firebase must be configured again, run:

```bash
flutterfire configure
```

### 4. Configure Google Maps API Key

Create a `.env` file in the project root:

```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

The `.env` file should not be committed to GitHub.

Add this to `.gitignore`:

```gitignore
.env
.env.*
!.env.example
```

### 5. Run the app

```bash
flutter run
```

For Android emulator:

```bash
flutter run -d emulator-5554
```

---

## Firestore Security Rules

The app uses user-based Firestore access.  
Each authenticated user can access only their own profile, settings, routes, route points and daily summaries.

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, create, update, delete: if isOwner(userId);

      match /settings/{settingId} {
        allow read, create, update, delete: if isOwner(userId);
      }

      match /routes/{routeId} {
        allow read, create, update, delete: if isOwner(userId);

        match /points/{pointId} {
          allow read, create, update, delete: if isOwner(userId);
        }
      }

      match /daily_summaries/{summaryId} {
        allow read, create, update, delete: if isOwner(userId);
      }
    }
  }
}
```

---

## Main Screens

### Login Screen

The login screen allows users to sign in with email and password using Firebase Authentication.

### Register Screen

The registration screen creates a new Firebase Authentication user and automatically creates a Firestore user profile with default settings.

### Home Screen

The home screen displays current activity overview, daily step goal progress, weekly progress and last saved route.

### Map Screen

The map screen tracks the user's route using GPS and Google Maps.  
When the user stops tracking, the route is saved to Firestore.

### Result Screen

The result screen shows a summary of the completed route after it has been saved.

### History Screen

The history screen displays saved routes from Firestore for the current user.

### Route Detail Screen

The route detail screen shows route information and allows the user to edit the route title.

### Profile Screen

The profile screen displays and edits user data from Firestore.

### Statistics Screen

The statistics screen calculates and displays weekly activity statistics based on saved routes.

---

## Current Limitations

- Step counting may not work on Android emulator because the emulator usually does not support a real step counter sensor.
- On emulator, saved routes may have `0` steps.
- GPS route distance is best tested on a real physical device.
- Google and Apple sign-in buttons are currently UI placeholders.
- Pause/resume logic can be improved in the future.
- Route map preview on the detail screen can be improved later.

---

## Future Improvements

- Add real Google Sign-In
- Add Apple Sign-In
- Add route deletion
- Add route map preview on route detail screen
- Improve pause and resume tracking
- Improve background GPS tracking
- Add push notifications
- Add avatar upload with Firebase Storage
- Add more detailed achievements
- Add monthly and yearly statistics
- Improve route filtering in history

---

## Testing

During development, the following commands were used:

```bash
flutter pub get
flutter analyze
flutter run
```

Tested functionality:

- user registration
- user login
- user logout
- profile creation
- profile editing
- settings update
- route tracking
- route saving
- route history loading
- route title editing
- result screen
- statistics loading from Firebase

---

## Team Work

This project was developed as a team project for a mobile application development course.

Main responsibility areas:

- UI screens and visual design
- Google Maps and GPS route tracking
- Firebase Authentication
- Firestore database structure
- Profile and settings logic
- Route saving
- Route history
- Statistics calculation

---

## Short Description in Estonian

RouteFit on Flutteriga loodud mobiilirakendus, mis võimaldab kasutajal registreeruda, sisse logida, jälgida GPS-i abil oma liikumismarsruuti, salvestada marsruute Firebase Firestore andmebaasi ning vaadata isiklikku ajalugu ja statistikat.

Rakendus kasutab Firebase Authenticationit kasutajate haldamiseks ning Cloud Firestore'i profiili, seadete, marsruutide, marsruudipunktide ja päevakokkuvõtete salvestamiseks.

---

## Authors
- zhakki
- maapin
- geisterin

RouteFit App team project.
