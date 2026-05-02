import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'data/providers/auth_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const BaakHRApp(),
    ),
  );
}

class BaakHRApp extends StatelessWidget {
  const BaakHRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baak HR Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      
      home: FutureBuilder<bool>(
        future: context.read<AuthProvider>().checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.data == true) {
            return const DashboardScreen(); 
          }

          return const LoginScreen();
        },
      ),
    );
  }
}