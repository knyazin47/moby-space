// Real Go + native Dart smoke. Uses only a disposable database/process.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:grpc/grpc.dart' as grpc;
import 'package:moby_demo/data/server/family_api.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

Future<void> main() async {
  final binary = Platform.environment['MOBY_SMOKE_BINARY'];
  if (binary == null) throw StateError('MOBY_SMOKE_BINARY is required');
  final xrayBinary = Platform.environment['MOBY_SMOKE_XRAY'];
  final directory = await Directory.systemTemp.createTemp('moby-grpc-smoke-');
  final sockets = [
    await ServerSocket.bind('127.0.0.1', 0),
    await ServerSocket.bind('127.0.0.1', 0),
    if (xrayBinary != null) await ServerSocket.bind('127.0.0.1', 0),
  ];
  final ports = sockets.map((s) => s.port).toList();
  for (final socket in sockets) {
    await socket.close();
  }
  late FamilyApi api, childApi, teenApi;
  var clientsReady = false;
  Process? server;
  Process? proxy;
  final subscriptions = <StreamSubscription<JsonMap>>[];
  const bootstrap = 'disposable-cross-language-fixture-only-32-chars';
  final http = HttpClient();

  Future<void> tlsHealth(
    List<int> certificate,
    String host,
    List<String> protocols,
  ) async {
    final context = SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(certificate);
    final tcp = await Socket.connect('127.0.0.1', ports[2]);
    SecureSocket? secure;
    try {
      secure = await SecureSocket.secure(
        tcp,
        host: host,
        context: context,
        supportedProtocols: protocols,
      );
      check(
        secure.selectedProtocol == 'http/1.1',
        'HTTP1 ALPN preference changed',
      );
      secure.write(
        'GET /healthz HTTP/1.1\r\nHost: $host\r\nConnection: close\r\n\r\n',
      );
      await secure.flush();
      final response = await utf8.decoder
          .bind(secure)
          .join()
          .timeout(const Duration(seconds: 5));
      check(response.startsWith('HTTP/1.1 200'), 'TLS HTTP1 health rejected');
      check(response.contains('"synthetic":true'), 'Unexpected fixture health');
    } finally {
      secure?.destroy();
      tcp.destroy();
    }
  }

  Future<FamilyApi Function()> startProxy() async {
    final certificate = '${directory.path}/test-certificate.pem';
    final key = '${directory.path}/test-key.pem';
    final generated = await Process.run('openssl', [
      'req',
      '-x509',
      '-newkey',
      'ec',
      '-pkeyopt',
      'ec_paramgen_curve:prime256v1',
      '-sha256',
      '-nodes',
      '-days',
      '1',
      '-subj',
      '/CN=api.moby.test',
      '-addext',
      'subjectAltName=DNS:api.moby.test,DNS:neighbor.invalid',
      '-keyout',
      key,
      '-out',
      certificate,
    ]);
    check(generated.exitCode == 0, 'Disposable certificate generation failed');
    final config = File('${directory.path}/test-xray.json');
    await config.writeAsString(
      jsonEncode({
        'log': {'loglevel': 'none'},
        'inbounds': [
          {
            'listen': '127.0.0.1',
            'port': ports[2],
            'protocol': 'trojan',
            'settings': {
              'clients': [
                {'password': 'disposable-xray-fixture-only'},
              ],
              'fallbacks': [
                {
                  'name': 'api.moby.test',
                  'alpn': 'h2',
                  'dest': '127.0.0.1:${ports[1]}',
                  'xver': 0,
                },
                {
                  'name': 'api.moby.test',
                  'dest': '127.0.0.1:${ports[0]}',
                  'xver': 0,
                },
                {
                  'name': 'neighbor.invalid',
                  'dest': '127.0.0.1:${ports[0]}',
                  'xver': 0,
                },
                {'dest': '127.0.0.1:${ports[0]}', 'xver': 0},
              ],
            },
            'streamSettings': {
              'network': 'tcp',
              'security': 'tls',
              'tlsSettings': {
                'alpn': ['http/1.1', 'h2'],
                'certificates': [
                  {'certificateFile': certificate, 'keyFile': key},
                ],
              },
            },
          },
        ],
        'outbounds': [
          {'protocol': 'freedom'},
        ],
      }),
    );
    proxy = await Process.start(xrayBinary!, ['run', '-c', config.path]);
    proxy!.stdout.drain<void>();
    proxy!.stderr.drain<void>();
    final trustedCertificate = await File(certificate).readAsBytes();
    var ready = false;
    for (var attempt = 0; attempt < 100; attempt++) {
      try {
        await tlsHealth(trustedCertificate, 'api.moby.test', ['http/1.1']);
        ready = true;
        break;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }
    check(ready, 'Disposable Xray TLS proxy did not start');
    await tlsHealth(trustedCertificate, 'api.moby.test', [
      'h2',
      'http/1.1',
    ]);
    await tlsHealth(trustedCertificate, 'neighbor.invalid', ['h2', 'http/1.1']);
    return () => FamilyApi(
      Uri.parse('https://api.moby.test:${ports[2]}'),
      channel: grpc.ClientChannel(
        '127.0.0.1',
        port: ports[2],
        options: grpc.ChannelOptions(
          credentials: grpc.ChannelCredentials.secure(
            certificates: trustedCertificate,
            authority: 'api.moby.test',
          ),
        ),
      ),
    );
  }

  Future<void> start() async {
    server = await Process.start(
      binary,
      [],
      environment: {
        'MOBY_ADDR': '127.0.0.1:${ports[0]}',
        'MOBY_GRPC_ADDR': '127.0.0.1:${ports[1]}',
        'MOBY_DATABASE': '${directory.path}/family.sqlite',
        'MOBY_BOOTSTRAP_SECRET': bootstrap,
        'MOBY_BUSINESS_DATE': '2026-10-21',
      },
    );
    // Never echo backend responses, tokens, QR material or credentials.
    server!.stdout.drain<void>();
    server!.stderr.drain<void>();
    for (var i = 0; i < 100; i++) {
      try {
        final request = await http.getUrl(
          Uri.parse('http://127.0.0.1:${ports[0]}/healthz'),
        );
        final response = await request.close();
        await response.drain<void>();
        if (response.statusCode == 200) return;
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    throw StateError('Disposable Go backend did not start');
  }

  Future<void> stop() async {
    server?.kill(ProcessSignal.sigterm);
    await server?.exitCode.timeout(const Duration(seconds: 10));
    server = null;
  }

  Future<JsonMap> rest(String path, JsonMap body, {String? token}) async {
    final request = await http.postUrl(
      Uri.parse('http://127.0.0.1:${ports[0]}$path'),
    );
    request.headers.set('Authorization', 'Bearer ${token ?? api.token}');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    final decoded =
        jsonDecode(await utf8.decoder.bind(response).join()) as JsonMap;
    check(response.statusCode < 300, 'REST compatibility request rejected');
    return decoded;
  }

  Future<String> makeChild(String name, String dob, FamilyApi device) async {
    final child = await api.request('POST', '/v1/children', {
      'displayName': name,
      'legalName': 'Вымышленный $name',
      'dateOfBirth': dob,
      'idempotencyKey': 'smoke-child-$name',
    });
    final id = child['id'] as String;
    await api.request('POST', '/v1/children/$id/verification', {
      'outcome': 'verified',
    });
    await api.request('POST', '/v1/children/$id/product', {
      'agreementVersion': 'synthetic-v1',
      'signerConsent': true,
    });
    final pair = await device.request('POST', '/v1/pairings', {
      'deviceName': 'fixture',
    });
    await api.request('POST', '/v1/pairings/consume', {
      'code': pair['code'],
      'childId': id,
    });
    final result = await device.request(
      'POST',
      '/v1/pairings/${pair['id']}/poll',
      {'requestSecret': pair['requestSecret']},
    );
    device.token = (result['session'] as JsonMap)['token'] as String;
    return id;
  }

  try {
    await start();
    final makeApi = xrayBinary == null
        ? () => FamilyApi(Uri.parse('http://127.0.0.1:${ports[1]}'))
        : await startProxy();
    api = makeApi();
    childApi = makeApi();
    teenApi = makeApi();
    clientsReady = true;
    final grant = await api.request('POST', '/v1/auth/adult', {
      'bootstrapSecret': bootstrap,
      'deviceName': 'fixture adult',
    });
    api.token = grant['token'] as String;
    final child = await makeChild('Марк', '2016-01-02', childApi);
    final teen = await makeChild('Анна', '2010-01-02', teenApi);
    final childSnapshot = await childApi.request('GET', '/v1/snapshot');
    check((childSnapshot['children'] as List).length == 1, 'Sibling leaked');
    check(
      !(childSnapshot['familySpace'] as JsonMap).containsKey('adultWallet'),
      'Adult wallet leaked',
    );
    check(
      ((childSnapshot['children'] as List).first as JsonMap)['id'] == child,
      'Wrong child scope',
    );
    try {
      await childApi.request('GET', '/v1/children/$teen');
      throw StateError('Foreign child request succeeded');
    } on FamilyApiException catch (error) {
      check(error.status == 403, 'Scope error lost semantics');
    }
    final seen = <int, Completer<void>>{
      0: Completer(),
      1: Completer(),
      2: Completer(),
    };
    final fresh = <int, Completer<void>>{
      0: Completer(),
      1: Completer(),
      2: Completer(),
    };
    int? baseline;
    for (final entry in [api, childApi, teenApi].asMap().entries) {
      subscriptions.add(
        entry.value.events().listen(
          (snapshot) {
            final revision = snapshot['revision'] as int;
            if (!seen[entry.key]!.isCompleted) seen[entry.key]!.complete();
            if (baseline != null &&
                revision > baseline &&
                !fresh[entry.key]!.isCompleted) {
              fresh[entry.key]!.complete();
            }
          },
          onError: (Object error) {
            if (!fresh[entry.key]!.isCompleted)
              fresh[entry.key]!.completeError(StateError('Watch failed'));
          },
        ),
      );
    }
    await Future.wait(
      seen.values.map((c) => c.future),
    ).timeout(const Duration(seconds: 5));
    baseline = (await api.request('GET', '/v1/snapshot'))['revision'] as int;
    final command = <String, dynamic>{
      'type': 'wallet.transfer',
      'childId': child,
      'amountMinor': 600,
      'idempotencyKey': 'smoke-cross-language-transfer',
    };
    final ack = await api.request('POST', '/v1/family-space/commands', command);
    check(
      ((ack['children'] as List).firstWhere((c) => c['id'] == child)
              as JsonMap)['balanceMinor'] ==
          600,
      'Transfer balance or typed int64 lost',
    );
    final restAck = await rest('/v1/family-space/commands', command);
    check(
      restAck['revision'] == ack['revision'],
      'Cross-transport replay mutated state',
    );
    await Future.wait(
      fresh.values.map((c) => c.future),
    ).timeout(const Duration(seconds: 5));
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    subscriptions.clear();
    final purchase = <String, dynamic>{
      'amountMinor': 100,
      'currency': 'BYN',
      'channel': 'pos',
      'category': 'food',
      'merchant': 'Fixture',
      'idempotencyKey': 'smoke-rest-first-purchase',
    };
    final first = await rest(
      '/v1/children/$child/operations',
      purchase,
      token: childApi.token,
    );
    final replay = await childApi.request(
      'POST',
      '/v1/children/$child/operations',
      purchase,
    );
    check(
      first['id'] == replay['id'],
      'REST to gRPC replay duplicated purchase',
    );
    await stop();
    await start();
    final afterRestart = await api.request(
      'POST',
      '/v1/family-space/commands',
      command,
    );
    check(
      ((afterRestart['children'] as List).firstWhere((c) => c['id'] == child)
              as JsonMap)['balanceMinor'] ==
          500,
      'Restart lost durable ledger or replay duplicated transfer',
    );
    await api.request('POST', '/v1/auth/logout');
    try {
      await api.request('GET', '/v1/snapshot');
      throw StateError('Revoked token accepted');
    } on FamilyApiException catch (error) {
      check(error.status == 401, 'Revoke error lost semantics');
    }
    stdout.writeln(
      'PASS: ${xrayBinary == null ? 'direct' : 'Xray TLS h2 + HTTP1/neighbor ALPN'} Go/Dart native RPC, three scoped watches, both replay directions, restart and logout',
    );
  } finally {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    if (clientsReady) {
      api.close();
      childApi.close();
      teenApi.close();
    }
    http.close(force: true);
    await stop();
    proxy?.kill(ProcessSignal.sigterm);
    await proxy?.exitCode.timeout(const Duration(seconds: 10));
    await directory.delete(
      recursive: true,
    ); // This tool owns only this disposable directory.
  }
}
