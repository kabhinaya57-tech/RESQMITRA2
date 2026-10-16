# RESQ MITRA — Flutter starter source

This starter implements the first requested app flow:

1. Animated splash screen with app name, rotating HELP / PROTECT / SUPPORT / TOGETHER tagline, and loading indicator.
2. Create-account / login UI with phone, email, and password fields. A local preference remembers the demo login so the auth page is skipped on the next launch.
3. Role selection: HELP SEEKER or VOLUNTEER AS RESCUE RESPONDER, followed by GET STARTED.
4. Home screen with a pulsing red SOS button and permanent HOME / MAP / HISTORY / BADGES / PROFILE navigation.
5. SOS chooser for GENERAL SOS (blue), WOMEN SOS (pink), and CHILD SOS (yellow).
6. SQLite local SOS history, JSON app configuration, and geolocator coordinate lookup.

## Run it

1. Install Flutter SDK and Android Studio, then ensure `flutter doctor` passes.
2. If using this as a fresh project, from this folder run `flutter create .` to generate platform folders (or copy `lib/`, `assets/`, and `pubspec.yaml` into your existing Flutter project).
3. Add the two location permissions shown in `android_setup/AndroidManifest_permissions.xml` inside `android/app/src/main/AndroidManifest.xml`, directly under the `<manifest>` element.
4. Run:

   ```bash
   flutter pub get
   flutter run
   ```

## Important before production

- The uploaded media was a video, and its first frame did not show a usable standalone logo asset. The splash currently uses a built-in safety icon as a placeholder. Replace it with your logo asset when you provide a PNG/SVG image.
- Authentication is a UI/demo flow only. It does not verify credentials and stores a local logged-in flag. Connect Firebase Authentication or a trusted backend before real use.
- SOS events are stored on the device and coordinates are read when permission is granted. This starter does **not** dispatch SOS alerts, SMS, calls, or notifications to responders/emergency services. Add and test a real emergency backend before relying on it.
- The map page currently displays coordinates rather than an interactive map. The BADGES page is a placeholder for the next development phase.
- Test location permission behavior on a real Android device. Never use this starter as the sole emergency response system.

## Files

- `lib/main.dart` — Flutter screens, navigation, SOS flow, location lookup and SQLite history.
- `assets/data/app_data.json` — app text, roles, SOS types and dashboard labels.
- `android_setup/AndroidManifest_permissions.xml` — Android location permission snippet.
