import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> getCurrentProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw const AuthException('Usuário não autenticado.');
    }

    final profile = await _client
        .from('profiles')
        .select('id, nome, tipo_conta')
        .eq('id', user.id)
        .single();

    return profile;
  }
}
