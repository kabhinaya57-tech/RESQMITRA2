# ResQMitra Flutter App

This corrected starter contains the splash screen, role selection, and validated signup form.

## Run
```bash
flutter pub get
flutter analyze
flutter run
```

Note: account creation currently validates the form and shows a message. It does not create a real account until an authentication provider (for example Supabase or Firebase) is connected. Create an `assets/` directory before running if you keep the `assets/` declaration in `pubspec.yaml`.
