import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../main.dart';
import '../theme.dart';
import '../widgets.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'report_flow.dart';
import 'report_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: FitScroll(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
          children: [
            BrandHeader(
              showActions: true,
              onBell: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              onProfile: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset('assets/images/hero_dog.png', fit: BoxFit.cover, alignment: const Alignment(0.2, -0.2)),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xF2FFFFFF), Color(0x66FFFFFF)],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${store.name.isEmpty ? 'There' : store.name} 👋',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Together For a Safer, Kinder Pune 💚',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => openReportFlow(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF14967F), Color(0xFF0E7C6B)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_camera_outlined, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Report a Dog Issue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                          Text('Photo, location and details in a few steps', style: TextStyle(color: Color(0xFFE7FFF8), fontSize: 13)),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Color(0x33000000),
                      child: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(count: '${store.openCount}', label: 'Open Reports', icon: Icons.assignment_outlined, tint: AppColors.orange, onTap: () => store.setTab(1))),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(count: '${store.resolvedCount}', label: 'Resolved', icon: Icons.check_circle_outline, tint: AppColors.green, onTap: () => store.setTab(1))),
              ],
            ),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Recent Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => store.setTab(1),
                        child: const Text('See All', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  if (store.recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                      child: Text('No reports yet. A report appears here after PMC CARE accepts it.', style: TextStyle(color: AppColors.muted)),
                    ),
                  for (final report in store.recent) ...[
                    InkWell(
                      onTap: () => openReport(context, report),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ReportThumb(report: report, size: 56),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(report.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(report.location, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                  Text(report.timeLabel, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                            StatusPill(status: report.status),
                            const Icon(Icons.chevron_right, color: AppColors.muted),
                          ],
                        ),
                      ),
                    ),
                    if (report != store.recent.last) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            SoftCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.map_outlined, color: AppColors.teal),
                            SizedBox(width: 6),
                            Text('My Map', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Pins for reports you sent.\nNothing from other people.', style: TextStyle(color: AppColors.muted, height: 1.3)),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: () => store.setTab(2),
                          icon: const Text('View Map'),
                          label: const Icon(Icons.chevron_right, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    height: 96,
                    child: MapArtwork(
                      zoom: 12,
                      you: store.here == null ? null : LatLng(store.here!.latitude, store.here!.longitude),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String count;
  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(backgroundColor: tint.withValues(alpha: 0.12), child: Icon(icon, color: tint)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                Text(count, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
