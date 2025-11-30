import 'package:device_preview/device_preview.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:phone_app/Statemangement/AuthProvider.dart';
import 'package:phone_app/firebase_options.dart';
import 'package:phone_app/screens/Users_list.dart';
import 'package:phone_app/screens/home.dart';
import 'package:phone_app/screens/login.dart';
import "package:provider/provider.dart";
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviderS()),
      ],
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Firebase Google Auth',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFDF7F0), // Soft off-white - GREAT!
        primaryColor: Color(0xFFFF9800), // Richer orange - GREAT!
        colorScheme: ColorScheme.light(
          primary: Color(0xFFFF9800), // Orange
          secondary: Color(0xFFFFB74D), // Light orange
          background: Color(0xFFFDF7F0), // Subtle warm white
          onPrimary: Colors.white,
          onBackground: Color(0xFF333333), // Dark gray for text
        ),
        appBarTheme: AppBarTheme(
          backgroundColor:
              Color(0xFFFF9800), // Nice warm orange - **THIS IS THE AREA**
          elevation: 4,
          shadowColor: Colors.orange.shade100,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          centerTitle: true,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // GREAT!
          selectedItemColor: Color(0xFFFF9800), // GREAT!
          unselectedItemColor: Colors.grey.shade500, // GREAT!
          selectedIconTheme: IconThemeData(size: 28),
          unselectedIconTheme: IconThemeData(size: 24),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
        ),
      ),
      darkTheme: ThemeData.dark(),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.data == true) {
            return MyHomePage(); // 👈 user is logged in
          } else {
            return LoginScreen(); // 👈 user needs to login
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
