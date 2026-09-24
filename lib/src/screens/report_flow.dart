import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'report_detail_screen.dart';

void openReportFlow(BuildContext context) {
  AppScope.of(context).resetDraft();
  Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotoStep()));
}

class PhotoStep extends StatelessWidget {
  const PhotoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final draft = store.draft;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                  const LogoMark(size: 36),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dog Help Pune', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text('Report dog issues and track updates', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Report a Dog Issue', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const Text('Step 1 of 3', style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 10),
              const _Stepper(step: 1, labels: ['Photo', 'Details', 'Review']),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      draft.filePath != null
                          ? Image.file(File(draft.filePath!), fit: BoxFit.cover)
                          : Image.asset(draft.asset, fit: BoxFit.cover),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () {
                              draft.filePath = null;
                              store.touch();
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PhotoAction(
                      filled: true,
                      icon: Icons.photo_camera_outlined,
                      label: 'Take Photo',
                      onTap: () => _pick(context, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PhotoAction(
                      filled: false,
                      icon: Icons.image_outlined,
                      label: 'Choose from Gallery',
                      onTap: () => _pick(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FB), borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.muted, size: 18),
                    SizedBox(width: 8),
                    Text('Try to keep the dog clearly visible.'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Next',
                trailing: Icons.chevron_right,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailsStep())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final store = AppScope.of(context);
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (file != null) {
        store.draft.filePath = file.path;
        store.touch();
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Using the sample photo. Camera or gallery is unavailable here.')),
        );
      }
    }
  }
}

class DetailsStep extends StatefulWidget {
  const DetailsStep({super.key});

  @override
  State<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<DetailsStep> {
  late final TextEditingController note = TextEditingController(
    text: 'Dogs chasing people near the gate.',
  );

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final draft = store.draft;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                  const Expanded(
                    child: Column(
                      children: [
                        Text('Add Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('Step 2 of 3', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Text('1', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800)),
                  const Text(' — 2 — 3', style: TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SoftCard(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 72,
                            height: 72,
                            child: draft.filePath != null
                                ? Image.file(File(draft.filePath!), fit: BoxFit.cover)
                                : Image.asset('assets/images/dog_aggressive.png', fit: BoxFit.cover),
                          ),
                        ),
                        const Spacer(),
                        const CircleAvatar(backgroundColor: AppColors.tealSoft, child: Icon(Icons.photo_camera_outlined, color: AppColors.teal)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('What is the issue?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final type in IssueType.values)
                              _IssueChip(
                                type: type,
                                selected: draft.issue == type,
                                onTap: () {
                                  draft.issue = type;
                                  store.touch();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Location', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _changeLocation(context),
                              child: const Text('Change', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const Text('Detected from your device', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.teal, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(draft.location, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(draft.area, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: MapArtwork(
                            showYou: true,
                            zoom: 15,
                            pin: LatLng(draft.latitude, draft.longitude),
                            onTap: (point) {
                              draft.latitude = point.latitude;
                              draft.longitude = point.longitude;
                              draft.location = 'Pinned on map';
                              draft.area = '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
                              store.touch();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('How many dogs?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              Text('Select the total number of dogs at this location', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                        _RoundStep(
                          icon: Icons.remove,
                          onTap: () {
                            if (draft.dogCount > 1) {
                              draft.dogCount--;
                              store.touch();
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('${draft.dogCount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        ),
                        _RoundStep(
                          icon: Icons.add,
                          filled: true,
                          onTap: () {
                            draft.dogCount++;
                            store.touch();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Short note (optional)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        TextField(
                          controller: note,
                          maxLength: 200,
                          maxLines: 3,
                          onChanged: (v) => draft.note = v,
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: PrimaryButton(
                label: 'Next',
                trailing: Icons.chevron_right,
                onPressed: () {
                  draft.note = note.text;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewStep()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLocation(BuildContext context) async {
    final store = AppScope.of(context);
    final picked = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => _LocationPicker(initial: LatLng(store.draft.latitude, store.draft.longitude)),
      ),
    );
    if (picked == null) return;
    store.draft
      ..latitude = picked.latitude
      ..longitude = picked.longitude
      ..location = 'Pinned on map'
      ..area = '${picked.latitude.toStringAsFixed(5)}, ${picked.longitude.toStringAsFixed(5)}';
    store.touch();
  }
}

class _LocationPicker extends StatefulWidget {
  const _LocationPicker({required this.initial});

  final LatLng initial;

  @override
  State<_LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<_LocationPicker> {
  late LatLng point = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose location')),
      body: Column(
        children: [
          Expanded(
            child: MapArtwork(
              zoom: 15,
              pin: point,
              onTap: (next) => setState(() => point = next),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: 'Use this location',
              onPressed: () => Navigator.pop(context, point),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final draft = store.draft;
    final preview = DogReport(
      id: 'draft',
      title: '',
      location: draft.location,
      area: draft.area,
      timeLabel: '',
      status: ReportStatus.submitted,
      asset: draft.filePath == null ? 'assets/images/dog_aggressive.png' : draft.asset,
      issue: draft.issue,
      dogCount: draft.dogCount,
      note: draft.note,
      reference: '',
      latitude: draft.latitude,
      longitude: draft.longitude,
      updates: const [],
      filePath: draft.filePath,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
              child: Row(
                children: [
                  const LogoMark(size: 36),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dog Help Pune', style: TextStyle(fontWeight: FontWeight.w800)),
                        Text('Report dog issues and track updates', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_none_rounded),
                  const SizedBox(width: 8),
                  const Icon(Icons.person_outline),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Review', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                          Text('Step 3 of 3', style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                  const _Stepper(step: 3, labels: ['Details', 'Location', 'Review']),
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Report Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.teal),
                              label: const Text('Edit', style: TextStyle(color: AppColors.teal)),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReportThumb(report: preview, size: 92, radius: 16),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Issue Type', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                                  Text(draft.issue.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  const Text('Location', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                                  Text(draft.location, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  const Text('Number of Dogs', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                                  Text('${draft.dogCount}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  const Text('Additional Details', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                                  Text(draft.note, style: const TextStyle(height: 1.3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Before you send', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const Text('Please confirm the following before submitting your report.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                        const SizedBox(height: 8),
                        _check('Photo is clear', 'The photo clearly shows the dog/dogs and surroundings.'),
                        _check('Location looks correct', '${draft.location} is selected.'),
                        _check('Details are ready', 'Issue type, number of dogs and description are added.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Send Report',
                    icon: Icons.send_rounded,
                    onPressed: () {
                      final report = store.submitDraft();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SentScreen(report: report)),
                      );
                    },
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: AppColors.teal),
                    label: const Text('Back', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _check(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(body, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SentScreen extends StatelessWidget {
  const SentScreen({super.key, required this.report});

  final DogReport report;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BrandHeader(showActions: true),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: Image.asset('assets/images/hero_dog.png', width: 220, height: 180, fit: BoxFit.cover),
                  ),
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFF2EAE6A),
                    child: Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Report sent', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const Text('Your request has been shared successfully.', style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 14),
              SoftCard(
                color: AppColors.mint,
                child: Row(
                  children: [
                    const Icon(Icons.assignment_outlined, color: AppColors.teal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Reference Number', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                          Text(report.reference, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => copyText(context, report.reference), icon: const Icon(Icons.copy_rounded)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const StatusPill(status: ReportStatus.submitted),
              const SizedBox(height: 6),
              const Text('You can follow updates anytime.', style: TextStyle(color: AppColors.muted)),
              const Spacer(),
              PrimaryButton(
                label: 'Track This Report',
                trailing: Icons.chevron_right,
                onPressed: () => openReport(context, report),
              ),
              const SizedBox(height: 8),
              OutlineButton(
                label: 'Report Another Issue',
                onPressed: () {
                  store.resetDraft();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PhotoStep()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step, required this.labels});

  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: i + 1 <= step ? AppColors.teal : const Color(0xFFE6EEEA),
                child: Text('${i + 1}', style: TextStyle(color: i + 1 <= step ? Colors.white : AppColors.muted, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              const SizedBox(height: 4),
              Text(labels[i], style: TextStyle(fontSize: 12, color: i + 1 == step ? AppColors.teal : AppColors.muted, fontWeight: FontWeight.w700)),
            ],
          ),
          if (i != labels.length - 1)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 2,
                color: i + 1 < step ? AppColors.teal : const Color(0xFFE6EEEA),
              ),
            ),
        ],
      ],
    );
  }
}

class _PhotoAction extends StatelessWidget {
  const _PhotoAction({required this.filled, required this.icon, required this.label, required this.onTap});

  final bool filled;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: filled ? AppColors.teal : AppColors.mint,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: filled ? Colors.white : AppColors.tealSoft,
              child: Icon(icon, color: AppColors.teal),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: filled ? Colors.white : AppColors.navy)),
          ],
        ),
      ),
    );
  }
}

class _IssueChip extends StatelessWidget {
  const _IssueChip({required this.type, required this.selected, required this.onTap});

  final IssueType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.teal : AppColors.line, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(_icon(type), color: _color(type), size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(type.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
            if (selected) const Icon(Icons.check_circle, color: AppColors.teal, size: 18),
          ],
        ),
      ),
    );
  }

  IconData _icon(IssueType type) {
    switch (type) {
      case IssueType.aggressive:
        return Icons.pets;
      case IssueType.injured:
        return Icons.healing;
      case IssueType.bite:
        return Icons.warning_amber_rounded;
      case IssueType.sick:
        return Icons.medical_services_outlined;
      case IssueType.unsterilised:
        return Icons.pets_outlined;
      case IssueType.pack:
        return Icons.groups_outlined;
    }
  }

  Color _color(IssueType type) {
    switch (type) {
      case IssueType.aggressive:
        return AppColors.orange;
      case IssueType.injured:
        return AppColors.coral;
      case IssueType.bite:
        return const Color(0xFFE15B4C);
      case IssueType.sick:
        return AppColors.blue;
      case IssueType.unsterilised:
        return const Color(0xFF8B6AD8);
      case IssueType.pack:
        return AppColors.green;
    }
  }
}

class _RoundStep extends StatelessWidget {
  const _RoundStep({required this.icon, required this.onTap, this.filled = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        backgroundColor: filled ? AppColors.teal : const Color(0xFFE8EEF0),
        child: Icon(icon, color: filled ? Colors.white : AppColors.navy, size: 18),
      ),
    );
  }
}
