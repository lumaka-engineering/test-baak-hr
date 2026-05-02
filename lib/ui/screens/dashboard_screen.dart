import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<AuthProvider>().fetchProfile()
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final agent = authProvider.agentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baak HR - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              
              // Redirection propre et suppression de l'historique de navigation
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_customize, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            
            Text(
              agent != null 
                  ? 'Bienvenue, ${agent['prenom']} ${agent['nom']}' 
                  : 'Chargement du profil...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              agent != null 
                  ? 'Rôle : ${agent['role']}' 
                  : 'Session active et sécurisée',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}