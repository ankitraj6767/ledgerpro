import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class LedgerProApp extends StatelessWidget {
  const LedgerProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LedgerPro Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
