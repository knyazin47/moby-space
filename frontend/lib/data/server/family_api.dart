import 'package:grpc/grpc.dart' as grpc;

import 'family_api_contract.dart';
import 'family_grpc_transport.dart';

export 'family_api_contract.dart';

/// Stable application facade backed exclusively by native gRPC/HTTP2.
/// The canonical URI also identifies existing secure session/outbox storage.
class FamilyApi {
  FamilyApi(
    this.baseUri, {
    grpc.ClientChannel? channel,
    Duration requestTimeout = const Duration(seconds: 20),
    Duration streamIdleTimeout = const Duration(seconds: 35),
  }) {
    if (baseUri.scheme != 'https' &&
        !(baseUri.scheme == 'http' &&
            (baseUri.host == 'localhost' ||
                baseUri.host == '127.0.0.1' ||
                baseUri.host == '10.0.2.2'))) {
      throw ArgumentError('Family API requires HTTPS');
    }
    if (baseUri.userInfo.isNotEmpty ||
        baseUri.hasQuery ||
        baseUri.hasFragment) {
      throw ArgumentError('Family API URL must not contain credentials');
    }
    _transport = FamilyGrpcTransport(
      baseUri,
      channel: channel,
      requestTimeout: requestTimeout,
      streamIdleTimeout: streamIdleTimeout,
    );
  }

  final Uri baseUri;
  late final FamilyGrpcTransport _transport;
  String? token;

  Future<JsonMap> request(String method, String path, [JsonMap? body]) {
    // Capture identity before connection establishment or any asynchronous work.
    final authorization = token;
    return _transport.request(method, path, body, authorization);
  }

  Stream<JsonMap> events() => _transport.events(token);
  void cancelEvents() => _transport.cancelEvents();
  void close() => _transport.close();
}
