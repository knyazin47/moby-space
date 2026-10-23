import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_copy.dart';
import '../core/theme/app_theme.dart';
import '../core/ui/source_assets.dart';
import '../core/ui/replay_loading.dart';
import '../core/config/demo_motion.dart';
import '../features/cards/cards_page.dart';
import '../features/branches/source_branches_page.dart';
import '../features/payments/source_payment_pages.dart';
import '../features/payments/source_credit_repayment_page.dart';
import '../features/payments/source_arbitrary_payment_page.dart';
import '../features/exchange/source_exchange_page.dart';
import '../features/family/add_child_wizard_page.dart';
import '../features/family/child_home_page.dart';
import '../features/family/child_manage_page.dart';
import '../features/family/child_pair_page.dart';
import '../features/family/child_success_page.dart';
import '../features/family/family_package_page.dart';
import '../features/family/scan_child_page.dart';
import '../features/catalog/source_catalog_pages.dart';
import '../features/chat/chat_page.dart';
import '../features/common/common_pages.dart';
import '../features/reference/observed_web_page.dart';
import '../features/history/history_page.dart';
import '../features/home/home_page.dart';
import '../features/recorded/card_application_page.dart';
import '../features/recorded/recorded_pages.dart';
import '../features/recorded/recorded_forms.dart';
import '../core/config/recorded_forms_content.dart';
import '../features/more/more_page.dart';
import '../features/products/products_page.dart';
import '../features/products/source_offer_page.dart';
import '../features/transfer/transfer_page.dart';
import 'providers.dart';
import 'family_session.dart';
import '../features/onboarding/entry_pages.dart';
import '../features/onboarding/server_child_home_page.dart';
import '../features/family/server_family_pages.dart';
import '../features/family/children_tab_page.dart';
import '../features/space/space_pages.dart';
import '../core/config/children_content.dart';
import '../core/theme/mt_brand_theme.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final familySession = ref.watch(familySessionProvider);
  final router = GoRouter(
    initialLocation: familyApiEnabled ? '/welcome' : '/home',
    refreshListenable: familySession,
    redirect: (context, state) =>
        familyRouteRedirect(familySession, state.uri.path),
    routes: [
      if (familyApiEnabled) ...[
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const FamilyWelcomePage(),
        ),
        GoRoute(
          path: '/adult/phone',
          builder: (context, state) => const AdultPhonePage(),
        ),
        GoRoute(
          path: '/adult/code',
          builder: (context, state) => AdultCodePage(
            phoneSuffix: state.extra is String ? state.extra as String : null,
          ),
        ),
      ],
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              replicaRoute(
                path: '/home',
                builder: (context, state) =>
                    const _DemoSessionRoot(child: HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              replicaRoute(
                path: '/products',
                builder: (context, state) => const _DemoSessionRoot(
                  child: ReplayBodyLoading(
                    background: MobyColors.productsBackground,
                    child: ProductsPage(),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              replicaRoute(
                path: '/more',
                builder: (context, state) =>
                    const _DemoSessionRoot(child: MorePage()),
              ),
            ],
          ),
          if (familyApiEnabled)
            StatefulShellBranch(
              routes: [
                replicaRoute(
                  path: '/family',
                  builder: (context, state) => const ChildrenTabPage(),
                  routes: [
                    replicaRoute(
                      path: 'intro',
                      builder: (context, state) =>
                          const ChildrenTabPage(reviewIntro: true),
                    ),
                    replicaRoute(
                      path: 'inbox',
                      builder: (context, state) => const SpaceInboxPage(),
                    ),
                    replicaRoute(
                      path: 'space',
                      builder: (context, state) => const SpaceAdultPage(),
                    ),
                    replicaRoute(
                      path: 'apply',
                      builder: (context, state) => const ServerAddChildPage(),
                    ),
                    replicaRoute(
                      path: 'success',
                      builder: (context, state) => const ChildrenTabPage(),
                    ),
                    replicaRoute(
                      path: 'child/:id/access',
                      builder: (context, state) => ServerPairChildPage(
                        childId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                    replicaRoute(
                      path: 'child/:id/setup',
                      builder: (context, state) => ServerChildManagePage(
                        childId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                    replicaRoute(
                      path: 'child/:id',
                      builder: (context, state) => SpaceAdultChildPage(
                        childId: state.pathParameters['id'] ?? '',
                        initialSection:
                            state.uri.queryParameters['section'] ?? 'overview',
                      ),
                      routes: [
                        replicaRoute(
                          path: ':section',
                          builder: (context, state) => SpaceAdultChildPage(
                            childId: state.pathParameters['id'] ?? '',
                            initialSection:
                                state.pathParameters['section'] ?? 'overview',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
      replicaRoute(
        path: '/chat',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) =>
              ChatPage(key: ValueKey(ref.watch(demoSessionProvider))),
        ),
      ),
      replicaRoute(
        path: '/products/halva',
        builder: (context, state) => const SourceHalvaOffersPage(),
      ),
      replicaRoute(
        path: '/offers/:id',
        builder: (context, state) =>
            SourceOfferPage(id: state.pathParameters['id']!),
      ),
      replicaRoute(
        path: '/apply-card',
        builder: (context, state) => const CardApplicationPage(),
      ),
      replicaRoute(
        path: '/cards',
        builder: (context, state) => const CardsPage(),
      ),
      replicaRoute(
        path: '/card/:id',
        builder: (context, state) =>
            CardDetailsPage(cardId: state.pathParameters['id']!),
      ),
      replicaRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      replicaRoute(
        path: '/operation/:id',
        builder: (context, state) =>
            OperationDetailsPage(operationId: state.pathParameters['id']!),
      ),
      replicaRoute(
        path: '/transfer',
        builder: (context, state) => TransferPage(
          accountId: state.uri.queryParameters['account'],
          recipient: state.uri.queryParameters['recipient'],
        ),
      ),
      replicaRoute(
        path: '/refill',
        builder: (context, state) => TransferPage(
          refill: true,
          accountId: state.uri.queryParameters['account'],
        ),
      ),
      replicaRoute(
        path: '/profile',
        builder: (context, state) => const RecordedProfilePage(),
      ),
      replicaRoute(
        path: '/demo',
        builder: (context, state) => const DemoControlsPage(),
      ),
      replicaRoute(
        path: '/reference/web',
        builder: (context, state) => const ObservedWebPage(),
      ),
      replicaRoute(
        path: '/safety',
        builder: (context, state) => const SourceSafetyPage(),
      ),
      replicaRoute(
        path: '/settings',
        builder: (context, state) => const RecordedSettingsPage(),
      ),
      replicaRoute(
        path: '/settings/transfers',
        builder: (context, state) => const RecordedTransferSettingsPage(),
      ),
      replicaRoute(
        path: '/settings/transfer/:method',
        builder: (context, state) =>
            RecordedTransferMethodPage(method: state.pathParameters['method']!),
      ),
      replicaRoute(
        path: '/documents',
        builder: (context, state) => const RecordedDocumentsPage(),
      ),
      replicaRoute(
        path: '/notifications',
        builder: (context, state) => const RecordedNotificationsPage(),
      ),
      replicaRoute(
        path: '/currency',
        builder: (context, state) => const RecordedCurrencyPage(),
      ),
      replicaRoute(
        path: '/about',
        builder: (context, state) => const RecordedAboutPage(),
      ),
      replicaRoute(
        path: '/forms/salary',
        builder: (context, state) => RecordedSalaryFormPage(
          onContinue: () => context.push('/forms/salary/cards'),
          onScanQr: () => context.push('/payments/qr'),
        ),
      ),
      replicaRoute(
        path: '/forms/credit',
        builder: (context, state) => RecordedCreditFormPage(
          onContinue: () => context.push('/forms/credit/next'),
        ),
      ),
      replicaRoute(
        path: '/forms/salary/cards',
        builder: (context, state) => const SourceSalaryCardSelectionPage(),
      ),
      replicaRoute(
        path: '/forms/credit/next',
        builder: (context, state) => const SourceCatalogUnavailablePage(
          title: RecordedFormsContent.creditTitle,
        ),
      ),
      replicaRoute(
        path: '/deposits/open',
        builder: (context, state) => const SourceDepositCalculatorPage(),
      ),
      replicaRoute(
        path: '/loyalty',
        builder: (context, state) => SourceLoyaltyPage(
          onConnect: () => context.push('/loyalty/package'),
        ),
      ),
      replicaRoute(
        path: '/loyalty/package',
        builder: (context, state) => const SourceLoyaltyErrorPage(),
      ),
      replicaRoute(
        path: '/currency/exchange',
        builder: (context, state) => const SourceExchangePage(),
      ),
      replicaRoute(
        path: '/branches',
        builder: (context, state) => const SourceBranchesPage(),
      ),
      replicaRoute(
        path: '/payments/codes',
        builder: (context, state) => const SourcePaymentCodebookPage(),
      ),
      replicaRoute(
        path: '/payments/arbitrary',
        builder: (context, state) => const SourceArbitraryPaymentPage(),
      ),
      replicaRoute(
        path: '/transfer/choose',
        builder: (context, state) => const RecordedTransferChooserPage(),
      ),
      replicaRoute(
        path: '/transfer/local',
        builder: (context, state) => const TransferPage(),
      ),
      replicaRoute(
        path: '/transfer/phone',
        builder: (context, state) => const RecordedPhoneContactsPage(),
      ),
      replicaRoute(
        path: '/payments/erip',
        builder: (context, state) => const RecordedEripPickerPage(),
      ),
      replicaRoute(
        path: '/payments/mobile',
        builder: (context, state) => const SourceMobilePaymentPage(),
      ),
      replicaRoute(
        path: '/payments/credit',
        builder: (context, state) => const SourceCreditRepaymentPage(),
      ),
      replicaRoute(
        path: '/payments/templates',
        builder: (context, state) => const SourcePaymentEmptyPage(),
      ),
      replicaRoute(
        path: '/payments/qr',
        builder: (context, state) => const SourceQrPaymentPage(),
      ),
      replicaRoute(
        path: '/child/pair',
        builder: (context, state) => familyApiEnabled
            ? const ServerChildPairPage()
            : const ChildPairPage(),
      ),
      replicaRoute(
        path: '/child/home',
        builder: (context, state) => familyApiEnabled
            ? const ServerChildHomePage()
            : const ChildHomePage(),
      ),
      if (!familyApiEnabled)
        replicaRoute(
          path: '/family',
          builder: (context, state) => const FamilyPackagePage(),
        ),
      if (!familyApiEnabled) ...[
        replicaRoute(
          path: '/family/apply',
          builder: (context, state) => const AddChildWizardPage(),
        ),
        replicaRoute(
          path: '/family/child/:id/access',
          builder: (context, state) =>
              ChildAccessPage(childId: state.pathParameters['id'] ?? ''),
        ),
        replicaRoute(
          path: '/family/success',
          builder: (context, state) =>
              ChildSuccessPage(childId: state.uri.queryParameters['id'] ?? ''),
        ),
        replicaRoute(
          path: '/family/child/:id',
          builder: (context, state) =>
              ChildManagePage(childId: state.pathParameters['id'] ?? ''),
        ),
      ],
      for (final entry in DemoContent.infoPages.entries.where(
        (entry) => !{
          '/settings',
          '/documents',
          '/notifications',
          '/currency',
          '/about',
          '/products/halva',
          '/branches',
          '/loyalty',
          '/currency/exchange',
        }.contains(entry.key),
      ))
        replicaRoute(
          path: entry.key,
          builder: (context, state) => InfoPage(content: entry.value),
        ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop:
        shell.currentIndex == 0 ||
        (shell.currentIndex == 3 && context.canPop()),
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && !(shell.currentIndex == 3 && context.canPop())) {
        shell.goBranch(0);
      }
    },
    child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: shell.currentIndex == 0
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness: shell.currentIndex == 0
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              // Family pages use their own Scaffolds. Reserve the shared
              // footer here so every nested scroll view has a safe viewport.
              // Legacy replica branches retain their recorded overlay layout.
              bottom: shell.currentIndex == 3
                  ? MobyMetrics.navHeight + MediaQuery.paddingOf(context).bottom
                  : 0,
              child: shell,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  height: MobyMetrics.navHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: MobyColors.navBorder),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(MobyMetrics.navRadius),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      for (final entry in <(int, String, String, String)>[
                        (0, AppCopy.home, 'ic_main_inactive', 'main_logo_p'),
                        (
                          1,
                          AppCopy.products,
                          'ic_products_inactive',
                          'ic_products_tab',
                        ),
                        if (familyApiEnabled)
                          (3, ChildrenContent.tabLabel, '', ''),
                        (-1, AppCopy.chat, 'menu_icon_chat', 'menu_icon_chat'),
                        (2, AppCopy.more, 'ic_more', 'ic_more_active'),
                      ])
                        Expanded(
                          child: Semantics(
                            selected: shell.currentIndex == entry.$1,
                            button: true,
                            label: entry.$2,
                            child: InkWell(
                              onTap: () {
                                if (entry.$1 < 0) {
                                  context.push('/chat');
                                } else {
                                  shell.goBranch(
                                    entry.$1,
                                    initialLocation:
                                        shell.currentIndex == entry.$1,
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (entry.$1 == 3)
                                      Icon(
                                        Icons.people_outline_rounded,
                                        size: 24,
                                        color: shell.currentIndex == 3
                                            ? MtBrandColors.blue
                                            : MobyColors.text,
                                      )
                                    else
                                      SourceIcon(
                                        shell.currentIndex == entry.$1
                                            ? entry.$4
                                            : entry.$3,
                                        size: 24,
                                      ),
                                    const SizedBox(height: 3),
                                    Text(
                                      entry.$2,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: shell.currentIndex == entry.$1
                                            ? (entry.$1 == 3
                                                  ? MtBrandColors.blue
                                                  : MobyColors.brand)
                                            : MobyColors.text,
                                        fontWeight:
                                            shell.currentIndex == entry.$1
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DemoSessionRoot extends ConsumerWidget {
  const _DemoSessionRoot({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) => KeyedSubtree(
    key: ValueKey(ref.watch(demoSessionProvider)),
    child: PageStorage(
      bucket: ref.watch(demoPageStorageProvider),
      child: child,
    ),
  );
}

/// Horizontal navigation is observed in the recording. Timing/easing are centralized replay settings, not a measured original contract.
GoRoute replicaRoute({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  routes: routes,
  pageBuilder: (context, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: DemoMotion.routeTransition,
    reverseTransitionDuration: DemoMotion.routeTransition,
    child: builder(context, state),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
  ),
);
