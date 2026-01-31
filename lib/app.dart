import 'package:flutter/material.dart';
import 'package:silaju/core/theme/app_theme.dart';
import 'package:silaju/core/router/app_router.dart';
import 'package:silaju/core/constants/app_strings.dart';

/// Main application widget
class SilajuApp extends StatelessWidget {
  const SilajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
