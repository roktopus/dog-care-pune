import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';
import 'sign_in_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FitScroll(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            children: [
              const LogoMark(size: 40),
              const Text('Dog Help Pune', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const Text('Report dog issues and track updates', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/images/hero_dog.png', height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 22, height: 1.1, fontWeight: FontWeight.w800, color: AppColors.navy),
                  children: [
                    TextSpan(text: 'Help keep dogs and people '),
                    TextSpan(text: 'safe', style: TextStyle(color: AppColors.teal)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const _StepCard(color: AppColors.tealSoft, icon: Icons.photo_camera_outlined, iconColor: AppColors.teal, title: 'Take a photo', body: 'Capture the dog and the issue.'),
              const SizedBox(height: 6),
              const _StepCard(color: Color(0xFFFFF1E8), icon: Icons.location_on_outlined, iconColor: Color(0xFFF08A3A), title: 'Add location', body: 'Use your location anywhere in Pune.'),
              const SizedBox(height: 6),
              const _StepCard(color: AppColors.greenBg, icon: Icons.check_circle_outline, iconColor: AppColors.green, title: 'Track updates', body: 'Follow the report until it is resolved.'),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'I already have an account',
                trailing: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
              ),
              TextButton(
                onPressed: () => openPmcRegistration(context),
                child: const Text(
                  'I don’t have a PMC CARE account',
                  style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
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
