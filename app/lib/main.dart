import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/app_services.dart';
import 'core/sync/sync_triggers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.open();
  await registerBackgroundSync();
  runApp(
    ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const HomeSyncApp(),
    ),
  );
}
