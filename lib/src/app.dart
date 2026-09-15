import 'package:flutter/material.dart';

import 'features/admissions/admissions_page.dart';

class BciApp extends StatelessWidget {
  const BciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BCI School Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF15365C)),
        useMaterial3: true,
      ),
      home: const AdmissionsPage(),
    );
  }
}
