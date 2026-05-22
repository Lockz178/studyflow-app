import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyflow_app/main.dart';
import 'package:studyflow_app/premium/premium_controller.dart';
import 'package:studyflow_app/providers/app_settings_provider.dart';
import 'package:studyflow_app/providers/favourites_provider.dart';
import 'package:studyflow_app/providers/study_flow_controller.dart';
import 'package:studyflow_app/router/app_router.dart';
import 'package:studyflow_app/screens/settings_screen.dart';
import 'package:studyflow_app/services/mock_data_service.dart';

// 6 tips so pagination loads page 1 (2 tips), then page 2 (2 more), etc.
const _seed = '''
{
  "subjects": ["Math", "English"],
  "learningTips": [
    "Tip one.", "Tip two.", "Tip three.", "Tip four.", "Tip five.", "Tip six."
  ],
  "eventSeeds": [],
  "templates": {
    "Math":    [{ "title": "Review", "details": "Go through notes." }],
    "English": [{ "title": "Read",   "details": "Read a chapter."  }]
  }
}
''';

void main() {
  setUp(() {
    MockDataService.reset();
    MockDataService.loadFromJsonString(_seed);
  });

  Future<GoRouter> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettingsProvider();
    await settings.load();
    final studyFlow = StudyFlowController();
    await studyFlow.initialize();
    final favourites = FavouritesProvider();
    await favourites.load();
    final router = createAppRouter();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettingsProvider>.value(value: settings),
          ChangeNotifierProvider<StudyFlowController>.value(
            value: studyFlow,
          ),
          ChangeNotifierProvider<FavouritesProvider>.value(value: favourites),
          ChangeNotifierProvider(create: (_) => PremiumController()),
        ],
        child: StudyFlowRoot(router: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  // ── Planner: form validation ────────────────────────────────────────────

  testWidgets(
    'Create plan form shows validation error for empty topic',
    (tester) async {
      final router = await pumpApp(tester);
      router.go('/planner');
      await tester.pumpAndSettle();

      await tester.tap(find.text('New plan'));
      await tester.pumpAndSettle();

      expect(find.text('Create Study Plan'), findsOneWidget);

      await tester.ensureVisible(find.text('Create study plan'));
      await tester.tap(find.text('Create study plan'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a topic or assignment name.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Create plan form shows error when topic is shorter than 3 characters',
    (tester) async {
      final router = await pumpApp(tester);
      router.go('/planner');
      await tester.pumpAndSettle();

      await tester.tap(find.text('New plan'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'AB');
      await tester.ensureVisible(find.text('Create study plan'));
      await tester.tap(find.text('Create study plan'));
      await tester.pumpAndSettle();

      expect(
        find.text('Topic must be at least 3 characters.'),
        findsOneWidget,
      );
    },
  );

  // ── Planner: successful plan creation ──────────────────────────────────

  testWidgets(
    'Valid study plan creation adds the plan to the planner list',
    (tester) async {
      final router = await pumpApp(tester);
      router.go('/planner');
      await tester.pumpAndSettle();

      await tester.tap(find.text('New plan'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'My Calculus Study',
      );
      await tester.ensureVisible(find.text('Create study plan'));
      await tester.tap(find.text('Create study plan'));
      await tester.pumpAndSettle();

      // Plan topic visible in the planner list and/or snackbar confirmation.
      expect(find.textContaining('My Calculus Study'), findsWidgets);
    },
  );

  // ── Settings: theme switch ──────────────────────────────────────────────

  testWidgets(
    'Tapping Dark mode in Settings updates AppSettingsProvider to dark',
    (tester) async {
      final router = await pumpApp(tester);
      router.go('/settings');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();

      final settings = tester
          .element(find.byType(SettingsScreen))
          .read<AppSettingsProvider>();
      expect(settings.themeMode, ThemeMode.dark);
    },
  );

  // ── Tips library: infinite scroll / pagination (bonus +5) ──────────────

  testWidgets(
    'Tips library paginates: page 1 loads on open, page 2 loads on scroll',
    (tester) async {
      // A small viewport makes the list scrollable so the scroll listener
      // fires and _maybeLoadMore triggers the next page load.
      tester.view.physicalSize = const Size(400, 300);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = await pumpApp(tester);
      router.go('/tips');
      await tester.pumpAndSettle();

      // Wait for the 280 ms artificial page-load delay in TipsLibraryScreen.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Page 1: first two tips present; page 2 not yet loaded.
      expect(find.text('Tip one.'), findsOneWidget);
      expect(find.text('Tip two.'), findsOneWidget);
      expect(find.text('Tip three.'), findsNothing);

      // Scroll to bottom — scroll listener fires, page 2 loads.
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Page 2 loaded: 'Tip three.' is now present (was absent before scroll).
      expect(find.text('Tip three.'), findsOneWidget);
    },
  );
}
