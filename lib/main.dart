import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:tadbir_go/src/core/router/app_router.dart';

import 'package:tadbir_go/src/features/auth/data/auth_repository.dart';
import 'package:tadbir_go/src/features/event_detail/data/event_detail_repository.dart';
import 'package:tadbir_go/src/features/home/data/event_repository.dart';

import 'src/core/network/api_client.dart';
import 'src/core/network/offline_status.dart';
import 'src/features/tickets/data/tickets_repository.dart';
import 'src/core/localization/app_text.dart';
import 'src/features/profile/data/profile_repository.dart';
import 'src/features/settings/data/settings_repository.dart';
import 'src/features/settings/presentation/cubit/settings_cubit.dart';
import 'src/core/consts/app_themes.dart';
import 'src/features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('event_cache');
  await AppText.load();
  await OfflineStatus.initialize();

  const url = String.fromEnvironment(
    'STRAPI_URL',
    defaultValue: 'http://192.168.1.80:1337',
  );

  // Tokenlarni xavfsiz saqlash
  const storage = FlutterSecureStorage();

  // HTTP so'rovlar uchun Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: url,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final apiClient = ApiClient(baseUrl: url, dio: dio, storage: storage);

  final repository = AuthRepository(api: apiClient, storage: storage, dio: dio);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: repository),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepository(apiClient),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (_) => SettingsRepository(Hive.box('settings')),
        ),
        RepositoryProvider<TicketsRepository>(
          create: (_) => TicketsRepository(apiClient),
        ),
        RepositoryProvider<EventRepository>(
          create: (_) => EventRepository(apiClient),
        ),
        RepositoryProvider<EventDetailRepository>(
          create: (_) => EventDetailRepository(apiClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(repository)),
          BlocProvider<SettingsCubit>(
            create: (context) =>
                SettingsCubit(context.read<SettingsRepository>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      OfflineStatus.refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) => MaterialApp(
        title: 'Tadbir Go',
        locale: Locale(settings.language),
        supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        themeMode: settings.themeMode,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
