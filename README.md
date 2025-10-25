# Workout Planner App

A modern Flutter application for planning and tracking workouts with Firebase authentication, Firestore persistence, and a cue‑based workout builder.  
Built with Provider state management and a clean, scalable architecture.

## Features
- Secure authentication (email/password)
- Firestore persistence for user workouts
- Cue‑based workout builder with visual graphs
- Rename, delete, and undo actions
- Responsive Material Design UI

## Project Structure
- `lib/models` — Data models (`Workout`, `Cue`)
- `lib/providers` — State management with Provider
- `lib/screens` — UI screens (Login, Workouts, Create Workout)
- `lib/widgets` — Reusable UI components

## Getting Started
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/workout_app.git
   cd workout_app
2. Install dependencies

bash-
flutter pub get
3. Configure Firebase

Add google-services.json to android/app/

Add GoogleService-Info.plist to ios/Runner/

4. Run the app

bash
flutter run

**Tech Stack**

Flutter 3.x
Firebase Authentication
Cloud Firestore
Provider (state management)
