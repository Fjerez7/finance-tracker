import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// Service managing unified Google authentication with Drive and Gmail scopes.
abstract class GmailAuthService {
  /// Stream of Google authentication state changes.
  Stream<GoogleSignInAccount?> get authStateChanges;

  /// Current signed in account if authenticated.
  GoogleSignInAccount? get currentUser;

  /// Interactive sign in requesting Gmail and Drive scopes.
  Future<GoogleSignInAccount?> signIn();

  /// Silent sign in if existing valid session exists.
  Future<GoogleSignInAccount?> signInSilently();

  /// Obtains valid OAuth2 authentication headers (including Bearer token).
  Future<Map<String, String>> getAuthHeaders();

  /// Signs out from Google session.
  Future<void> signOut();

  /// Checks if the user is signed in and has authorized scopes.
  Future<bool> isAuthorized();
}

/// Implementation of [GmailAuthService] utilizing [GoogleSignIn].
class GmailAuthServiceImpl implements GmailAuthService {
  final GoogleSignIn _googleSignIn;

  static const List<String> defaultScopes = [
    drive.DriveApi.driveAppdataScope,
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.modify',
    'https://www.googleapis.com/auth/gmail.labels',
  ];

  GmailAuthServiceImpl({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: defaultScopes,
            );

  @override
  Stream<GoogleSignInAccount?> get authStateChanges =>
      _googleSignIn.onCurrentUserChanged;

  @override
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  @override
  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  @override
  Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  @override
  Future<Map<String, String>> getAuthHeaders() async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (account == null) {
      throw StateError('Google user is not authenticated.');
    }
    return await account.authHeaders;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Future<bool> isAuthorized() async {
    return _googleSignIn.currentUser != null;
  }
}
