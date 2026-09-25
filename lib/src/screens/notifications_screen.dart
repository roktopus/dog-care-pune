import 'package:flutter/material.dart';

import '../../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'report_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(title: const Text('Updates', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (store.reports.isEmpty) const Text('No updates yet.', style: TextStyle(color: AppColors.muted)),
          for (final report in store.reports.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                onTap: () => openReport(context, report),
                child: Row(
                  children: [
                    ReportThumb(report: report, size: 52),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text('${report.status.label} · ${report.timeLabel}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
