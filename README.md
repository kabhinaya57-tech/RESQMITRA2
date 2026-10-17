# SOS Responder — Flutter + Supabase starter

A starter Flutter repository for a community SOS and volunteer-response app. It uses Supabase Auth, PostgreSQL, Row Level Security (RLS), and Realtime for the incident feed.

## Included in this MVP

- Victim and responder role selection (demo UI; roles are not verified)
- Anonymous Supabase Auth sign-in for the prototype
- Create an SOS incident with current GPS coordinates
- Realtime feed of open incidents
- Atomic incident acceptance and constrained status transitions through Postgres RPCs
- Incident status updates and Google Maps location display
- Open device dialler for India's emergency number 112
- SQL schema, indexes, and starter RLS policies

## Not included

Push notifications, siren/background alerting, responder identity verification, true two-way live location sharing, audio/video streaming, automated 112 dispatch, and a production abuse/moderation workflow are not implemented. The high-risk flag is only a database label and does not start recording.

## Requirements

- Flutter stable and Dart SDK compatible with `pubspec.yaml`
- A Supabase project
- Google Maps API key for the platforms you build

## Setup

1. Check Flutter is installed:

   ```bash
   flutter doctor
   ```

2. In Supabase Dashboard, open **Authentication → Sign In / Providers** and enable **Anonymous Sign-Ins** for this prototype. Anonymous accounts are not verified identities; use verified accounts and explicit responder approval before production.

3. Open the Supabase **SQL Editor** and run `supabase/schema.sql`. If the final `alter publication` statement reports that the table is already included, confirm `incidents` appears under Database → Publications → `supabase_realtime`; do not add it twice. Review the RLS policies before real deployment.

4. Copy the Project URL and publishable/anon key from **Project Settings → API**. These are client-side values; **never place a service-role key in a Flutter app**. Run the app with compile-time defines:

   ```bash
   flutter pub get
   flutter run \
     --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY
   ```

   For release builds, supply the same defines through your build pipeline. Do not commit real project values to a public repository if your policy treats them as configuration secrets. `.env.example` is documentation only; Flutter does not automatically load it.

5. Add a restricted Google Maps API key:
   - Android: add the `com.google.android.geo.API_KEY` metadata in `android/app/src/main/AndroidManifest.xml` inside `<application>`.
   - iOS: follow the `google_maps_flutter` platform setup instructions.

   Restrict the key by app/package and API in Google Cloud Console.

6. Run checks and launch:

   ```bash
   flutter analyze
   flutter test
   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
   ```

## Data model

`public.incidents` contains `id`, `created_by`, `status`, `risk`, `category`, `latitude`, `longitude`, `accepted_by`, `accepted_at`, `created_at`, and `updated_at`. The allowed statuses are `open`, `accepted`, `en_route`, `arrived`, `completed`, and `cancelled`.

## Security and production checklist

- Review RLS against your actual victim/responder roles. This demo's anonymous accounts do not prove a person's identity or responder credentials.
- Review status transitions and RPC ownership carefully before production; the included database functions are starter controls, not a complete dispatch authorization system.
- Add push notifications through a trusted server/edge function; a database insert alone does not alert devices reliably.
- Add consent-based messaging only after a privacy and safety review. Avoid covert recording and give users clear control over audio/video sharing.
- Define incident retention, audit logging, abuse reporting, account deletion, and access revocation.
- Establish an authorized emergency-service integration before claiming dispatch or media sharing with 112. Do not rely on this app as a replacement for emergency services. In immediate danger in India, call 112.
- Test poor connectivity, denied GPS permission, app termination, concurrent acceptance, false alarms, and account abuse on real devices.

## Create platform folders if needed

If `android/` and `ios/` folders are absent, run `flutter create .` in the repository root, then configure permissions and platform-specific Maps keys.

## License

Choose a license before publishing publicly.
