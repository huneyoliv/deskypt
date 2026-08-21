import 'package:google_sign_in/google_sign_in.dart';
import 'constants.dart';

class GoogleAuthResult {
  final String idToken;
  final String email;
  final String displayName;
  final String? photoUrl;

  const GoogleAuthResult({
    required this.idToken,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

class GoogleSignInException implements Exception {
  final String message;
  final bool isCancelled;

  const GoogleSignInException(this.message, {this.isCancelled = false});

  @override
  String toString() => message;
}

class GoogleSignInService {
  final GoogleSignIn _googleSignIn;

  GoogleSignInService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: CompanionConstants.googleWebClientId,
              scopes: const ['email', 'profile'],
            );

  Future<GoogleAuthResult> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const GoogleSignInException(
          'Login com Google cancelado pelo usuário.',
          isCancelled: true,
        );
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const GoogleSignInException(
          'Não foi possível obter o token de autenticação do Google.',
        );
      }

      return GoogleAuthResult(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName ?? account.email.split('@').first,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInException {
      rethrow;
    } catch (e) {
      throw GoogleSignInException('Erro ao autenticar com o Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (_) {
      return false;
    }
  }
}
