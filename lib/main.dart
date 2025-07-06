import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'features/onboard/presentation/provider/login_provider.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupLocator(); // Register all DI singletons before runApp

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
   // print('Firebase initialized successfully');
  } catch (e) {
   // print('Firebase initialization error: $e');

  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,

      child: MaterialApp.router(
        routerConfig: appRouter,
        title: 'Break Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'MyriadPro',
        ),
      ),
    );
  }
}
