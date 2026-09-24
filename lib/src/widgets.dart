import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'models.dart';
import 'theme.dart';

const kondhwaCenter = LatLng(18.469, 73.896);
const youAreHere = LatLng(18.4672, 73.8950);

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.showActions = false,
    this.onBell,
    this.onProfile,
  });

  final bool showActions;
  final VoidCallback? onBell;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const LogoMark(size: 46),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dog Help Pune',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Report dog issues and track updates',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (showActions) ...[
          _RoundIcon(icon: Icons.notifications_none_rounded, onTap: onBell, dot: true),
          const SizedBox(width: 8),
          _RoundIcon(icon: Icons.person_outline_rounded, onTap: onProfile),
        ],
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, this.onTap, this.dot = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.ink, size: 22),
            if (dot)
              const Positioned(
                right: 9,
                top: 9,
                child: CircleAvatar(radius: 4, backgroundColor: Color(0xFFE24B4B)),
              ),
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    late Color fg;
    late Color bg;
    switch (status) {
      case ReportStatus.inProgress:
        fg = AppColors.orange;
        bg = AppColors.orangeBg;
      case ReportStatus.submitted:
        fg = AppColors.coral;
        bg = AppColors.coralBg;
      case ReportStatus.resolved:
        fg = AppColors.green;
        bg = AppColors.greenBg;
      case ReportStatus.assigned:
        fg = AppColors.blue;
        bg = AppColors.blueBg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Icon(trailing, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: Color(0xFFD5DDD8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding, this.color, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x140F2A24), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class ReportThumb extends StatelessWidget {
  const ReportThumb({super.key, required this.report, this.size = 64, this.radius = 14});

  final DogReport report;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final image = report.filePath != null
        ? Image.file(File(report.filePath!), fit: BoxFit.cover)
        : Image.asset(report.asset, fit: BoxFit.cover);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: image),
    );
  }
}

class ReportRow extends StatelessWidget {
  const ReportRow({super.key, required this.report, required this.onTap});

  final DogReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ReportThumb(report: report),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.2),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        report.location,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(report.timeLabel, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusPill(status: report.status),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ],
      ),
    );
  }
}

class MapArtwork extends StatelessWidget {
  const MapArtwork({
    super.key,
    this.markers = const [],
    this.showYou = false,
    this.onMarker,
    this.selectedId,
    this.pin,
    this.onTap,
    this.zoom = 13,
  });

  final List<DogReport> markers;
  final bool showYou;
  final ValueChanged<DogReport>? onMarker;
  final String? selectedId;
  final LatLng? pin;
  final ValueChanged<LatLng>? onTap;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: pin ?? (markers.isEmpty ? kondhwaCenter : LatLng(markers.first.latitude, markers.first.longitude)),
          initialZoom: zoom,
          onTap: onTap == null ? null : (_, point) => onTap!(point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'in.pune.doghelp.dogHelpPune',
          ),
          MarkerLayer(
            markers: [
              if (showYou)
                Marker(
                  point: youAreHere,
                  width: 22,
                  height: 22,
                  child: const _YouPin(),
                ),
              if (pin != null)
                Marker(
                  point: pin!,
                  width: 36,
                  height: 42,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on, color: AppColors.teal, size: 36),
                ),
              for (final report in markers)
                Marker(
                  point: LatLng(report.latitude, report.longitude),
                  width: 36,
                  height: 46,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () => onMarker?.call(report),
                    child: _Pin(report: report, selected: report.id == selectedId),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YouPin extends StatelessWidget {
  const _YouPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Color(0x552F80ED), blurRadius: 12)],
          ),
        ),
      ],
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.report, required this.selected});

  final DogReport report;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (report.issue) {
      case IssueType.aggressive:
      case IssueType.bite:
        color = const Color(0xFFE24B4B);
        icon = Icons.priority_high_rounded;
      case IssueType.injured:
        color = AppColors.orange;
        icon = Icons.healing_rounded;
      case IssueType.pack:
        color = AppColors.blue;
        icon = Icons.groups_rounded;
      case IssueType.sick:
        color = const Color(0xFF5B8DEF);
        icon = Icons.medical_services_outlined;
      case IssueType.unsterilised:
        color = AppColors.green;
        icon = Icons.pets_rounded;
    }
    if (report.status == ReportStatus.resolved) color = AppColors.green;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: selected ? 3 : 2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: selected ? 0.45 : 0.25), blurRadius: selected ? 16 : 6),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        Container(width: 2, height: 8, color: color),
      ],
    );
  }
}

void copyText(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Reference number copied')),
  );
}
