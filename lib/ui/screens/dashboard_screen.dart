import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baak HR - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_customize, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Bienvenue sur l\'interface Agent',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Session active et sécurisée'),
          ],
        ),
      ),
    );
  }
}