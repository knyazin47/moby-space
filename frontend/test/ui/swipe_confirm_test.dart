import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/core/ui/recorded_cards.dart';

void main() {
  testWidgets('swipe rejects tap, middle start and short drag; submits once', (
    tester,
  ) async {
    var confirmations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: RecordedSwipeConfirm(
                enabled: true,
                label: 'Проведите пальцем',
                semanticLabel: 'Подтвердить',
                onConfirm: () {
                  confirmations++;
                  return true;
                },
              ),
            ),
          ),
        ),
      ),
    );
    final control = find.byType(RecordedSwipeConfirm);
    final rect = tester.getRect(control);
    await tester.tap(control);
    await tester.dragFrom(rect.center, const Offset(240, 0));
    await tester.dragFrom(
      rect.topLeft + const Offset(22, 22),
      const Offset(60, 0),
    );
    await tester.pumpAndSettle();
    expect(confirmations, 0);
    await tester.dragFrom(
      rect.topLeft + const Offset(22, 22),
      const Offset(260, 0),
    );
    await tester.pumpAndSettle();
    expect(confirmations, 1);
    await tester.dragFrom(
      rect.topLeft + const Offset(22, 22),
      const Offset(260, 0),
    );
    await tester.pumpAndSettle();
    expect(confirmations, 1);
  });
  testWidgets('failed local submit resets and can be retried', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: RecordedSwipeConfirm(
                enabled: true,
                label: 'Проведите пальцем',
                semanticLabel: 'Подтвердить',
                onConfirm: () => ++attempts > 1,
              ),
            ),
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.byType(RecordedSwipeConfirm));
    for (var i = 0; i < 2; i++) {
      await tester.dragFrom(
        rect.topLeft + const Offset(22, 22),
        const Offset(260, 0),
      );
      await tester.pumpAndSettle();
    }
    expect(attempts, 2);
  });
}
