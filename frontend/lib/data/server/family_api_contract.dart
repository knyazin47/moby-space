/// Errors expose a stable domain code and semantic status, never server text.
class FamilyApiException implements Exception {
  const FamilyApiException(this.status, this.code);
  final int status;
  final String code;
  @override
  String toString() => 'FamilyApiException($status, $code)';
}

typedef JsonMap = Map<String, dynamic>;
