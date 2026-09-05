import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

/// DTO representing a remote Google Drive backup entry in appDataFolder.
class DriveBackupInfo {
  final String id;
  final String name;
  final DateTime? modifiedTime;
  final int? sizeBytes;

  const DriveBackupInfo({
    required this.id,
    required this.name,
    this.modifiedTime,
    this.sizeBytes,
  });
}

/// Custom HTTP client injecting Google OAuth authentication headers for Google APIs.
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

/// Service interfacing with Google Drive API v3 within private appDataFolder.
class GoogleDriveService {
  final GoogleSignIn _googleSignIn;

  GoogleDriveService({GoogleSignIn? googleSignIn})
      : _googleSignIn =
            googleSignIn ??
            GoogleSignIn(
              scopes: [drive.DriveApi.driveAppdataScope],
            );

  /// Current signed in account if authenticated.
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Signs in to Google with Drive appDataFolder scope.
  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  /// Signs in silently if previous session exists.
  Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  /// Signs out from Google session.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Creates a DriveApi client with active credentials.
  Future<drive.DriveApi> _getDriveApi() async {
    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw StateError('User is not signed in to Google Drive');
    }
    final authHeaders = await account.authHeaders;
    final client = GoogleAuthClient(authHeaders);
    return drive.DriveApi(client);
  }

  /// Uploads a JSON backup snapshot string to Google Drive's private appDataFolder.
  Future<drive.File> uploadBackup({
    required String backupJson,
    required String filename,
  }) async {
    final driveApi = await _getDriveApi();

    final drive.File driveFile = drive.File()
      ..name = filename
      ..parents = ['appDataFolder']
      ..mimeType = 'application/json';

    final media = drive.Media(
      Stream.value(utf8.encode(backupJson)),
      backupJson.length,
    );

    return await driveApi.files.create(driveFile, uploadMedia: media);
  }

  /// Lists all backup files stored in appDataFolder ordered by most recent first.
  Future<List<DriveBackupInfo>> listBackups() async {
    final driveApi = await _getDriveApi();

    final fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      orderBy: 'modifiedTime desc',
      $fields: 'files(id, name, modifiedTime, size)',
    );

    final files = fileList.files ?? [];
    return files
        .map(
          (f) => DriveBackupInfo(
            id: f.id ?? '',
            name: f.name ?? 'Untitled Backup',
            modifiedTime: f.modifiedTime,
            sizeBytes: f.size != null ? int.tryParse(f.size!) : null,
          ),
        )
        .toList();
  }

  /// Downloads backup JSON contents for a given file [fileId].
  Future<String> downloadBackup(String fileId) async {
    final driveApi = await _getDriveApi();

    final drive.Media media =
        await driveApi.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    final bytes = await media.stream.fold<List<int>>(
      <int>[],
      (previous, element) => previous..addAll(element),
    );

    return utf8.decode(bytes);
  }

  /// Deletes a backup file by [fileId] from appDataFolder.
  Future<void> deleteBackup(String fileId) async {
    final driveApi = await _getDriveApi();
    await driveApi.files.delete(fileId);
  }
}
