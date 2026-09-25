import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

void openReport(BuildContext context, DogReport report) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report)));
}

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.report});

  final DogReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
                  const Expanded(
                    child: Text('Report Details', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  _mini(Icons.notifications_none_rounded, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  }, dot: true),
                  const SizedBox(width: 8),
                  _mini(Icons.person_outline_rounded, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  SoftCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReportThumb(report: report, size: 84, radius: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(report.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              Text('Ref. No. ${report.reference}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                              const SizedBox(height: 6),
                              StatusPill(status: report.status),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.muted),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(report.location, style: const TextStyle(color: AppColors.muted))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Updates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        for (var i = 0; i < report.updates.length; i++)
                          _UpdateTile(event: report.updates[i], last: i == report.updates.length - 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Back to Reports',
                    icon: Icons.chevron_left,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(IconData icon, VoidCallback onTap, {bool dot = false}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.line)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20),
            if (dot)
              const Positioned(right: 8, top: 8, child: CircleAvatar(radius: 3.5, backgroundColor: Color(0xFFE24B4B))),
          ],
        ),
      ),
    );
  }
}

class _UpdateTile extends StatelessWidget {
  const _UpdateTile({required this.event, required this.last});

  final TimelineEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final active = event.done || event.current;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: active ? AppColors.teal : const Color(0xFFD5DDD8), width: 2),
                  ),
                  child: Icon(
                    event.current && event.title == 'In progress' ? Icons.more_horiz : (event.done ? Icons.check : null),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: event.done ? AppColors.teal : const Color(0xFFD5DDD8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: event.current ? AppColors.tealSoft : const Color(0xFFF7F8F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: TextStyle(fontWeight: FontWeight.w800, color: active ? AppColors.navy : AppColors.muted)),
                  Text(event.time, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(event.body, style: TextStyle(color: active ? AppColors.ink : AppColors.muted, height: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
