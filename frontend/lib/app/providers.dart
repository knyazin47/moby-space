import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../data/bank_data.dart';

final bankRepositoryProvider = Provider<DemoBankRepository>((ref) {
  final repository = DemoBankRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final bankSnapshotProvider = StreamProvider<BankSnapshot>((ref) async* {
  final repository = ref.watch(bankRepositoryProvider);
  yield repository.snapshot;
  yield* repository.snapshots;
});

BankSnapshot watchBankSnapshot(WidgetRef ref) =>
    ref.watch(bankSnapshotProvider).asData?.value ??
    ref.watch(bankRepositoryProvider).snapshot;

final demoSessionProvider = NotifierProvider<DemoSession, int>(DemoSession.new);

class DemoSession extends Notifier<int> {
  @override
  int build() => 0;
  void restart() => state++;
}

final demoPageStorageProvider = Provider<PageStorageBucket>((ref) {
  ref.watch(demoSessionProvider);
  return PageStorageBucket();
});
