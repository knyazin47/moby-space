import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_copy.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class MobyApp extends ConsumerWidget {
  const MobyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: AppCopy.appName,
    debugShowCheckedModeBanner: false,
    theme: buildMobyTheme(),
    themeMode: ThemeMode.light,
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    routerConfig: ref.watch(appRouterProvider),
  );
}
