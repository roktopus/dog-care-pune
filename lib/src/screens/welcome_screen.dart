import 'package:flutter/material.dart';

import '../../main.dart';
import '../theme.dart';
import '../widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          children: [
            const Center(child: LogoMark(size: 54)),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Dog Help Pune',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            const Center(
              child: Text(
                'Report dog issues and track updates',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/hero_dog.png',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
                children: [
                  TextSpan(text: 'Help keep dogs\nand people '),
                  TextSpan(text: 'safe', style: TextStyle(color: AppColors.teal)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Report a dog issue in a few quick steps\nand follow updates on your request.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.35),
            ),
            const SizedBox(height: 16),
            const _StepCard(
              color: AppColors.tealSoft,
              icon: Icons.photo_camera_outlined,
              iconColor: AppColors.teal,
              title: 'Take a photo',
              body: 'Capture the dog and the issue in a few seconds.',
            ),
            const SizedBox(height: 10),
            const _StepCard(
              color: Color(0xFFFFF1E8),
              icon: Icons.location_on_outlined,
              iconColor: Color(0xFFF08A3A),
              title: 'Add location',
              body: 'We automatically detect the location or you can set it on the map.',
            ),
            const SizedBox(height: 10),
            const _StepCard(
              color: AppColors.greenBg,
              icon: Icons.check_circle_outline,
              iconColor: AppColors.green,
              title: 'Track updates',
              body: 'See the status of your report till it’s resolved.',
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Get Started',
              trailing: Icons.arrow_forward_rounded,
              onPressed: () => AppScope.of(context).continueFromWelcome(),
            ),
            TextButton(
              onPressed: () => AppScope.of(context).continueFromWelcome(),
              child: const Text(
                'I already have an account',
                style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(body, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.3)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
