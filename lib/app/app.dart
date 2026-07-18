import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'constants/app_constants.dart';
import 'theme/infra_theme.dart';

class LedgerProApp extends StatelessWidget {
  const LedgerProApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: InfraTheme.light(),
      themeMode: ThemeMode.light,
      // Required by the Fleather rich-text editor for its toolbar/menu strings.
      // Material/Widgets/Cupertino defaults are still provided automatically.
      localizationsDelegates: const [
        FleatherLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
