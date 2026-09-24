import 'package:flutter/material.dart';

import '../../main.dart';
import '../theme.dart';
import '../widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.tealSoft,
                  child: Icon(Icons.person, color: AppColors.teal),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('+91 ${store.mobile}', style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlineButton(
            label: 'Sign out',
            onPressed: () {
              store.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
