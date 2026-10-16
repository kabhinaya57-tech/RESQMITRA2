# ResQMitra Splash Screen

This package contains the Flutter splash-screen widget for ResQMitra.

## Files
- `lib/splash_screen.dart` — animated splash screen.
- `assets/images/README.txt` — where to put your original logo.

## 1. Add your original logo
Copy your provided logo image into:

`assets/images/resqmitra_logo.png`

Use a PNG image if possible. Do not use a different logo if you want to preserve your original branding.

## 2. Register assets in pubspec.yaml
Inside the existing `flutter:` section, add the assets entry below. If an `assets:` section already exists, add the folder line to that section rather than creating a duplicate.

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

Keep the indentation exactly as shown.

## 3. Connect the splash screen
Import the widget in your app's entry file (usually `lib/main.dart`):

```dart
import 'splash_screen.dart';
```

Then use it as the app's starting screen, adapting the names to the login and home widgets already in your project:

```dart
home: SplashScreen(
  checkAuthentication: () async {
    // TODO: Replace with your real authentication/session check.
    return false;
  },
  destinationBuilder: (isLoggedIn) {
    // Replace LoginScreen and HomeScreen with your existing widget names.
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  },
),
```

`return false` is a placeholder and always routes to login. It does not check a real user session. Connect Firebase Auth or your current authentication system before relying on automatic login skipping.

## 4. Test
From the root folder of your Flutter project, run:

```bash
flutter pub get
flutter analyze
flutter run
```

## 5. Copy into your existing project
Copy `lib/splash_screen.dart` into your project's `lib/` folder. Copy the logo into `assets/images/`. Review the `pubspec.yaml` change and the `main.dart` integration before running.

## 6. Upload to GitHub
Run these commands from your Flutter project root:

```bash
git status
git add lib/splash_screen.dart pubspec.yaml assets/images/resqmitra_logo.png
git commit -m "Add animated ResQMitra splash screen"
git push origin main
```

Only add `assets/images/resqmitra_logo.png` after you have placed the logo there. If GitHub returns a 403 permission error, the repository owner must grant your GitHub account write access or you must authenticate with an account that already has it. Do not upload passwords, API secrets, or private keys.
