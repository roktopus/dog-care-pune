import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const BrandHeader(),
            const SizedBox(height: 12),
            const Text('Help', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/hero_dog.png', height: 160, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            const SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What this app does', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  SizedBox(height: 6),
                  Text(
                    'Photograph a stray-dog issue, add the location, and follow updates on your report.',
                    style: TextStyle(color: AppColors.muted, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const _HelpRow(icon: Icons.photo_camera_outlined, title: 'Take a clear photo', body: 'Keep the dog and the surroundings visible.'),
            const _HelpRow(icon: Icons.location_on_outlined, title: 'Confirm the location', body: 'NIBM Road, Kondhwa is used when the device location is available.'),
            const _HelpRow(icon: Icons.timeline, title: 'Track the report', body: 'Submitted, assigned, in progress, and resolved updates stay on this phone.'),
            const SizedBox(height: 10),
            SoftCard(
              color: AppColors.mint,
              child: const Text(
                'Dog Help Pune is an independent civic app. It is not an official Pune Municipal Corporation application.',
                style: TextStyle(height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        child: Row(
          children: [
            CircleAvatar(backgroundColor: AppColors.tealSoft, child: Icon(icon, color: AppColors.teal)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(body, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
