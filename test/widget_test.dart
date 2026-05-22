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
import 'package:studyflow_app/services/mock_data_service.dart';

const _minimalSeed = '''
{
  "subjects": ["Math", "English"],
  "learningTips": ["Study hard every day."],
  "eventSeeds": [],
  "templates": {
    "Math": [{ "title": "Review", "details": "Go through notes." }],
    "English": [{ "title": "Read", "details": "Read a chapter." }]
  }
}
''';

void main() {
  setUp(() {
    MockDataService.reset();
    MockDataService.loadFromJsonString(_minimalSeed);
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
          ChangeNotifierProvider<StudyFlowController>.value(value: studyFlow),
          ChangeNotifierProvider<FavouritesProvider>.value(value: favourites),
          ChangeNotifierProvider(create: (_) => PremiumController()),
        ],
        child: StudyFlowRoot(router: router),
      ),
    );

    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('StudyFlow home screen shows main dashboard content', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await pumpApp(tester);

    expect(find.text('StudyFlow'), findsOneWidget);
    expect(find.text('Learning Tip'), findsOneWidget);
    expect(find.text('Recommended for today'), findsOneWidget);
    expect(find.text('Create a study plan to get started'), findsOneWidget);
  });

  testWidgets('Tips library shows header and loads first tips', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();

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
          ChangeNotifierProvider<StudyFlowController>.value(value: studyFlow),
          ChangeNotifierProvider<FavouritesProvider>.value(value: favourites),
          ChangeNotifierProvider(create: (_) => PremiumController()),
        ],
        child: StudyFlowRoot(router: router),
      ),
    );

    router.go('/tips');
    await tester.pumpAndSettle();

    expect(find.text('Tips library'), findsOneWidget);
    expect(find.text('Study tip'), findsWidgets);
  });

  testWidgets('Help screen shows FAQ and feedback form', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();

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
          ChangeNotifierProvider<StudyFlowController>.value(value: studyFlow),
          ChangeNotifierProvider<FavouritesProvider>.value(value: favourites),
          ChangeNotifierProvider(create: (_) => PremiumController()),
        ],
        child: StudyFlowRoot(router: router),
      ),
    );

    router.go('/help');
    await tester.pumpAndSettle();

    expect(find.text('Help & Feedback'), findsOneWidget);
    expect(find.textContaining('Suggested focus'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.text('Send feedback'), findsOneWidget);
  });

  testWidgets('Settings screen shows theme options', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final router = await pumpApp(tester);

    router.go('/settings');
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Light mode'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('About screen shows author and contact details', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final router = await pumpApp(tester);

    router.go('/about');
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Phan Ngoc Phuoc Loc'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
  });

  testWidgets('Planner screen shows create button and stats', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final router = await pumpApp(tester);

    router.go('/planner');
    await tester.pumpAndSettle();

    expect(find.text('Study Planner'), findsOneWidget);
    expect(find.text('New plan'), findsOneWidget);
    expect(find.text('Planner stats'), findsOneWidget);
  });
}
