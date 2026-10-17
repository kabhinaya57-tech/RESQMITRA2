# RESQ-MITRA — emergency response Flutter development build

Branded emergency-response application with General SOS, Women SOS, Child SOS, Blood Needed (A+, A-, B+, B-, AB+, AB-, O+, O-), a confirmation flow, DO NOT CALL preference, location capture, responder queue UI, and Firebase-backed incident operations.

**Safety notice:** This is a development candidate, not a certified emergency dispatch service. Push notifications, SMS, automated calling, live map tiles, and a durable offline queue are not implemented. In an immediate emergency, contact the appropriate official emergency service. Do not assume a request reached a responder unless the app explicitly confirms the relevant delivery state.

## Run

Install Flutter stable and Android Studio, then:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

If Android platform files are missing, run `flutter create . --platforms=android` from the project root, then rerun the commands.

## Firebase

Follow `docs/FIREBASE_SETUP.md`. Firebase Email/Password authentication is used when Firebase is configured. Without Firebase, the app allows local exploration only and clearly reports that SOS is not delivered.

Cloud Functions are under `functions/`. The trusted backend implements idempotent incident creation, separate private incident details, atomic responder claiming, and authorized status updates. Deploy only after configuring your own Firebase project and testing with emulators.

## Source structure

- `lib/main.dart` — existing app UI and navigation
- `lib/models/` — typed user, responder, and emergency models
- `lib/services/` — authentication and server-authoritative responder/SOS services
- `functions/src/index.ts` — callable backend functions
- `firestore.rules` — restrictive client access rules
- `docs/` — setup and release acceptance criteria

## Known limitations

The app is not production-ready solely because it compiles. Review `docs/PRODUCTION_ACCEPTANCE_CHECKLIST.md`. This archive intentionally does not include `.git` history or any project secrets.
