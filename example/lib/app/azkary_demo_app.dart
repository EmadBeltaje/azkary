import 'package:flutter/material.dart';

import '../screens/categories_page.dart';
import '../screens/init_failed_page.dart';
import 'theme.dart';

class AzkaryDemoApp extends StatelessWidget {
  const AzkaryDemoApp({super.key, required this.packageReady});

  final bool packageReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azkary Demo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: packageReady ? const CategoriesPage() : const InitFailedPage(),
    );
  }
}
