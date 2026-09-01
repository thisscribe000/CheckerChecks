import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'providers/app_provider.dart';
import 'theme/stitch_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    // Attempt anonymous sign-in to get a unique UID for this device
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint("Failed to sign in anonymously: $e");
  }

  runApp(const CheckerChecksApp());
}

class CheckerChecksApp extends StatelessWidget {
  const CheckerChecksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'CheckerChecks',
            debugShowCheckedModeBanner: false,
            theme: StitchTheme.themeData,
            home: provider.onboardingCompleted
                ? const MainNavigationShell()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
