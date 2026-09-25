import 'package:flutter/material.dart';

import '../../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int filter = 0;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final all = store.reports;
    final open = all.where((r) => r.status.isOpen).toList();
    final resolved = all.where((r) => !r.status.isOpen).toList();
    final visible = [all, open, resolved][filter];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            BrandHeader(
              showActions: true,
              onBell: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              onProfile: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.chevron_left),
                const Text('My Reports', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
              child: Row(
                children: [
                  _chip('All (${all.length})', 0),
                  _chip('Open (${open.length})', 1),
                  _chip('Resolved (${resolved.length})', 2),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: store.refreshStatuses, child: const Text('Refresh PMC Status')),
            ),
            if (visible.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No reports yet. Reports you send from anywhere in Pune appear here.', style: TextStyle(color: AppColors.muted)),
              ),
            for (final report in visible) ...[
              ReportRow(report: report, onTap: () => openReport(context, report)),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int index) {
    final selected = filter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => filter = index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.teal : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
