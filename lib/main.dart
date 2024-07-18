import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadbirio/utils/app_theme_mode.dart';
import 'package:tadbirio/views/screens/splash_screens/splash_screen.dart';
import 'bloc/auth/auth_cubit.dart';
import 'bloc/qatnashgan/event_bloc.dart';
import 'bloc/qatnashgan/event_event.dart';
import 'firebase_options.dart';
import 'service/firebase_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit()..authStateChanges(),
        ),
        BlocProvider(
          create: (context) =>
              EventBloc(firebaseService: FirebaseService())..add(LoadEvents()),
        ),
      ],
      child: AdaptiveTheme(
        light: AppThemeMode.light,
        dark: AppThemeMode.night,
        initial: AdaptiveThemeMode.light,
        builder: (light, dark) {
          return MaterialApp(
            darkTheme: dark,
            theme: light,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
