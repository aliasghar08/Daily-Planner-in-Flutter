import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:daily_planner/screens/changePass.dart';
import 'package:daily_planner/screens/forgotPass.dart';
import 'package:daily_planner/screens/home.dart';
import 'package:daily_planner/screens/login.dart';
import 'package:daily_planner/utils/notification.dart';
import 'package:daily_planner/utils/thememode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  await NotificationService.requestPermissionIfNeeded();
  await ThemePreferences.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: "Daily Planner",
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: const AuthWrapper(), 
          routes: {
            "/home": (context) => const MyHome(),
            "/login": (context) => const LoginPage(),
            "/changepassword": (context) => const ChangePasswordPage(),
            "/forgotpass": (context) => const ForgotPasswordScreen(),
          },
        );
      },
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const MyHome(); // ✅ Already signed in
        } else {
          return const LoginPage(); // 🔐 Not signed in
        }
      },
    );
  }
}
