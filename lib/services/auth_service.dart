import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Future<void> ensureSignedIn() async {
    if (_client.auth.currentUser == null) {
      await _client.auth.signInAnonymously();
    }
  }
}
