import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/app/router.dart';
import 'package:moby_demo/core/config/children_content.dart';
import 'package:moby_demo/core/theme/app_theme.dart';
import 'package:moby_demo/data/server/family_api.dart';
import '../support/space_fixture.dart';

void main() {
  test('Russian child age copy handles teens and singular years', () {
    expect(ChildrenContent.childAge(10), '10 лет');
    expect(ChildrenContent.childAge(11), '11 лет');
    expect(ChildrenContent.childAge(14), '14 лет');
    expect(ChildrenContent.childAge(21), '21 год');
    expect(ChildrenContent.childAge(22), '22 года');
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets(
      'rebrand hub wallet, age and money request at scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = SpacePreviewApi();
        final space = api.data['familySpace'] as JsonMap;
        (space['requests'] as List).add({
          'id': 'money-request',
          'childId': spaceJuniorId,
          'title': 'На продукты',
          'kind': 'money',
          'amountMinor': 2000,
          'status': 'pending',
        });
        final session = SpacePreviewSession(api);
        final container = ProviderContainer(
          overrides: [familySessionProvider.overrideWithValue(session)],
        );
        final router = container.read(appRouterProvider)..go('/family');
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: buildMobyTheme(),
              locale: const Locale('ru'),
              supportedLocales: const [Locale('ru')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              routerConfig: router,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                ),
                child: child!,
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 150));
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final wallet = find.byKey(const ValueKey('family-wallet'));
        final child = find.byKey(const ValueKey('family-child-$spaceJuniorId'));
        expect(wallet.hitTestable(), findsOneWidget);
        expect(child.hitTestable(), findsOneWidget);
        expect(
          tester.getTopLeft(wallet).dy,
          lessThan(tester.getTopLeft(child).dy),
        );
        expect(find.textContaining('10 лет'), findsOneWidget);
        expect(find.textContaining('16 лет'), findsOneWidget);
        expect(find.text('В резерве 120,00 BYN'), findsOneWidget);
        expect(find.text('Михаил просит 20,00 BYN'), findsOneWidget);
        for (
          var i = 0;
          i < 6 &&
              find
                  .text('Михаил просит 20,00 BYN')
                  .hitTestable()
                  .evaluate()
                  .isEmpty;
          i++
        ) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -200),
          );
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Михаил просит 20,00 BYN'));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, '/family/child/$spaceJuniorId/money');
        expect(api.commands, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        session.dispose();
      },
      skip: !familyApiEnabled,
    );
  }
}
