import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionVault {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

/// OS Keychain/Keystore. No tokens in preferences, URLs, debug output or backups.
class SecureSessionVault implements SessionVault {
  const SecureSessionVault({this.namespace = ''});
  final String namespace;
  static const _storage = FlutterSecureStorage();
  String get _key => 'moby.family.session.v1.$namespace';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}
