import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/firebase_options.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/providers/locale_provider.dart';
import 'package:dashboard/core/providers/users_provider.dart';
import 'package:dashboard/core/providers/groups_provider.dart';
import 'package:dashboard/core/providers/ai_provider.dart';
import 'package:dashboard/core/providers/settings_provider.dart';
import 'package:dashboard/core/router/app_router.dart';

/// LocaleProviderScope — InheritedWidget so any descendant can access
/// the locale provider without a DI package.
///

class LocaleProviderScope extends InheritedNotifier<LocaleProvider> {
  const LocaleProviderScope({
    super.key,
    required LocaleProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static LocaleProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleProviderScope>()!
        .notifier!;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StuStepApp());
}

class StuStepApp extends StatefulWidget {
  const StuStepApp({super.key});

  @override
  State<StuStepApp> createState() => _StuStepAppState();
}

class _StuStepAppState extends State<StuStepApp> {
  final _localeProvider = LocaleProvider();

  @override
  void dispose() {
    _localeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localeProvider,
      builder: (context, _) {
        final isArabic = _localeProvider.isArabic;

        return LocaleProviderScope(
          provider: _localeProvider,
          child: MaterialApp.router(
            title: 'StuStep Dashboard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(isArabic: isArabic),

            // ─── Locale ──────────────────────────────────────────────
            locale: _localeProvider.locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ─── Router ──────────────────────────────────────────────
            routerConfig: appRouter,

            // ─── Builder: inject providers INSIDE the navigator ──────
            // This ensures all GoRouter pages can find the providers,
            // because builder runs inside the Navigator's widget tree.
            builder: (context, child) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (_) => UsersProvider()),
                  ChangeNotifierProvider(create: (_) => GroupsProvider()),
                  ChangeNotifierProvider(create: (_) => AIProvider()),
                  ChangeNotifierProvider(create: (_) => SettingsProvider()),
                ],
                child: child!,
              );
            },
          ),
        );
      },
    );
  }
}
