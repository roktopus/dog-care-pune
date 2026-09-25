import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../main.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'report_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int filter = 0;
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final reports = store.reports.where((r) {
      if (filter == 1) return r.issue == IssueType.aggressive || r.issue == IssueType.bite;
      if (filter == 2) return r.issue == IssueType.injured;
      if (filter == 3) return r.issue == IssueType.pack;
      return true;
    }).toList();
    final selected = reports.where((r) => r.id == selectedId).firstOrNull ?? (reports.isEmpty ? null : reports.first);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: BrandHeader(
                showActions: true,
                onBell: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                onProfile: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('My Reports', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _Filter(label: 'All', icon: Icons.grid_view_rounded, selected: filter == 0, onTap: () => setState(() => filter = 0)),
                  _Filter(label: 'Aggressive', icon: Icons.priority_high_rounded, selected: filter == 1, onTap: () => setState(() => filter = 1)),
                  _Filter(label: 'Injured', icon: Icons.healing_rounded, selected: filter == 2, onTap: () => setState(() => filter = 2)),
                  _Filter(label: 'Packs', icon: Icons.groups_rounded, selected: filter == 3, onTap: () => setState(() => filter = 3)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Stack(
                  children: [
                    MapArtwork(
                      markers: reports,
                      zoom: reports.isEmpty ? 12 : 13.5,
                      you: store.here == null ? null : LatLng(store.here!.latitude, store.here!.longitude),
                      selectedId: selected?.id,
                      onMarker: (r) => setState(() => selectedId = r.id),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _Legend(store: store),
                    ),
                  ],
                ),
              ),
            ),
            if (selected == null)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text('No reports yet. Pins appear here only after you send a report. Other people’s reports are not available.', style: TextStyle(color: AppColors.muted)),
              )
            else
              Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SoftCard(
                child: Row(
                  children: [
                    ReportThumb(report: selected, size: 64),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selected.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(selected.location, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          Text(selected.timeLabel, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusPill(status: selected.status),
                        const SizedBox(height: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => openReport(context, selected),
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.teal : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.ink),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    Widget row(Color c, String label, int n) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            CircleAvatar(radius: 5, backgroundColor: c),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
            const Spacer(),
            Text('$n', style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      );
    }

    final open = store.reports.where((r) => r.status == ReportStatus.submitted).length;
    final progress = store.reports.where((r) => r.status == ReportStatus.inProgress || r.status == ReportStatus.assigned).length;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [
        BoxShadow(color: Color(0x22000000), blurRadius: 10),
      ]),
      child: Column(
        children: [
          row(const Color(0xFFE24B4B), 'Open', open),
          row(AppColors.orange, 'In progress', progress),
          row(AppColors.green, 'Resolved', store.resolvedCount),
        ],
      ),
    );
  }
}

extension IterableFirst<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
