import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'premium/premium_controller.dart';
import 'premium/premium_scope.dart';
import 'providers/app_settings_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/study_flow_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = AppSettingsProvider();
  await settings.load();

  final studyFlow = StudyFlowController();
  await studyFlow.initialize();

  final favourites = FavouritesProvider();
  await favourites.load();

  final router = createAppRouter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettingsProvider>.value(value: settings),
        ChangeNotifierProvider<StudyFlowController>.value(value: studyFlow),
        ChangeNotifierProvider<FavouritesProvider>.value(value: favourites),
        ChangeNotifierProvider(create: (_) => PremiumController()),
      ],
      child: StudyFlowRoot(router: router),
    ),
  );
}

class StudyFlowRoot extends StatelessWidget {
  final GoRouter router;

  const StudyFlowRoot({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return PremiumScope(
      controller: Provider.of<PremiumController>(context, listen: false),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'StudyFlow',
        themeMode: settings.themeMode,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        routerConfig: router,
      ),
    );
  }
}
