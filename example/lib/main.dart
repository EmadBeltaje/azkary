import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

import 'app/azkary_demo_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var packageReady = false;
  try {
    packageReady = await Azkary.initialize();
  } on AzkaryException catch (e) {
    debugPrint(e.developerMessage);
  } catch (e, st) {
    debugPrint('$e\n$st');
  }
  runApp(AzkaryDemoApp(packageReady: packageReady));
}
