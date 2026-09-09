import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({SupabaseClient? client}) : _injectedClient = client;

  final SupabaseClient? _injectedClient;

  SupabaseClient get _client => _injectedClient ?? Supabase.instance.client;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String accountType,
  }) async {
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'nome': name.trim(), 'tipo_conta': accountType},
    );
  }

  Future<AuthResponse> signInWithGoogle({required String accountType}) async {
    const scopes = <String>['email', 'profile'];

    final googleSignIn = GoogleSignIn.instance;

    final googleUser = await googleSignIn.authenticate(scopeHint: scopes);

    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);

    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('O Google não retornou um ID Token.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    final user = response.user;

    if (user == null) {
      throw const AuthException('Não foi possível obter o usuário do Google.');
    }

    final profile = await _client
        .from('profiles')
        .select('id, tipo_conta')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      final metadata = user.userMetadata ?? const <String, dynamic>{};

      final nome =
          metadata['full_name'] ??
          metadata['name'] ??
          user.email?.split('@').first ??
          'Usuário';

      await _client.from('profiles').insert({
        'id': user.id,
        'nome': nome.toString().trim(),
        'tipo_conta': accountType,
      });
    }

    return response;
  }

  Future<Map<String, dynamic>> signInExistingWithGoogle() async {
    const scopes = <String>['email', 'profile'];

    final googleSignIn = GoogleSignIn.instance;

    final googleUser = await googleSignIn.authenticate(scopeHint: scopes);

    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);

    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('O Google não retornou um ID Token.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    final user = response.user;

    if (user == null) {
      throw const AuthException('Não foi possível obter o usuário do Google.');
    }

    final profile = await _client
        .from('profiles')
        .select('id, nome, tipo_conta')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      await _client.auth.signOut();

      throw const AuthException(
        'Nenhum perfil BarberBlack encontrado para esta conta Google.',
      );
    }

    return profile;
  }
}
