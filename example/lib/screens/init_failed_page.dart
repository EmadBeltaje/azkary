import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

class InitFailedPage extends StatelessWidget {
  const InitFailedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final msg = Azkary.lastError?.developerMessage ??
        'Azkary.initialize() did not complete.';
    return Scaffold(
      appBar: AppBar(title: const Text('Azkary Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SelectableText(msg, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
