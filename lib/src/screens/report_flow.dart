import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../main.dart';
import '../models.dart';
import '../persistence.dart';
import '../photo_check.dart';
import '../pmc/pmc_api.dart';
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FitScroll(
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
              SizedBox(
                height: 280,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      draft.filePath != null
                          ? Image.file(File(draft.filePath!), fit: BoxFit.cover)
                          : const EmptyPhoto(iconSize: 56),
                      if (draft.filePath != null)
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
                onPressed: () {
                  if (store.draft.filePath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a photo before continuing.')));
                    return;
                  }
                  () async {
                    store.checkingPhoto = true;
                    store.touch();
                    final verdict = await PhotoCheck.inspect(store.draft.filePath!);
                    store.photoVerdict = verdict;
                    store.checkingPhoto = false;
                    store.touch();
                    if (!context.mounted) return;
                    if (!verdict.accepted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(verdict.detail)));
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailsStep()));
                  }();
                },
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
      if (file == null) return;
      // Keep a durable copy — image_picker cache paths are replaced on the next pick.
      final saved = await persistReportPhoto(file.path);
      store.draft.filePath = saved;
      store.photoVerdict = PhotoVerdict.pending;
      store.touch();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera or gallery is unavailable on this device.')),
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
  late final TextEditingController note = TextEditingController();
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final store = AppScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!store.draft.locationChosen) {
        await store.captureLocation();
      } else if (store.wards.isEmpty) {
        await store.loadAreas();
      }
    });
  }

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
                                ? Image.file(
                                    File(draft.filePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const EmptyPhoto(iconSize: 28),
                                  )
                                : const EmptyPhoto(iconSize: 28),
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
                        const Text('What Is the Issue?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('How Many Dogs?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              Text('Select the total number of dogs at this location', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          key: const Key('dog_count_minus'),
                          onPressed: draft.dogCount <= 1
                              ? null
                              : () {
                                  draft.dogCount--;
                                  store.touch();
                                },
                          icon: const Icon(Icons.remove),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${draft.dogCount}',
                            key: const Key('dog_count_value'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton.filled(
                          key: const Key('dog_count_plus'),
                          style: IconButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white),
                          onPressed: () {
                            draft.dogCount++;
                            store.touch();
                          },
                          icon: const Icon(Icons.add),
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
                            const Expanded(
                              child: Text('Location', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            ),
                            IconButton(
                              tooltip: 'My location',
                              onPressed: () => store.captureLocation(),
                              icon: const Icon(Icons.my_location, color: AppColors.teal),
                            ),
                            IconButton(
                              tooltip: 'Change on map',
                              onPressed: () => _changeLocation(context),
                              icon: const Icon(Icons.edit_location_alt_outlined, color: AppColors.teal),
                            ),
                          ],
                        ),
                        Text(
                          draft.locationChosen ? 'Anywhere in Pune' : 'Use your location or tap the map',
                          style: const TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.teal, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(draft.location.isEmpty ? 'Location not set' : draft.location, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(draft.area.isEmpty ? 'Pune' : draft.area, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 140,
                          child: MapArtwork(
                            zoom: 15,
                            interactive: false,
                            pin: draft.locationChosen ? LatLng(draft.latitude, draft.longitude) : null,
                            you: store.here == null ? null : LatLng(store.here!.latitude, store.here!.longitude),
                            onTap: (point) {
                              store.placeAt(point.latitude, point.longitude, label: 'Pinned on map');
                            },
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
                        const Text('PMC Area', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(store.areaNote ?? 'Filled from your location when a PMC ward matches. You can change it.', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        const SizedBox(height: 8),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ward',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: store.wards.any((ward) => ward.id == draft.wardId) ? draft.wardId : null,
                              isExpanded: true,
                              hint: Text(store.wards.isEmpty ? 'Loading wards…' : 'Choose ward'),
                              items: [
                                for (final ward in store.wards)
                                  DropdownMenuItem(value: ward.id, child: Text(ward.name, overflow: TextOverflow.ellipsis)),
                              ],
                              onChanged: (id) => store.selectWard(id),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Prabhag',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: store.prabhags.any((item) => item.id == draft.prabhagId) ? draft.prabhagId : null,
                              isExpanded: true,
                              hint: Text(
                                store.prabhags.isEmpty
                                    ? (draft.wardId == null ? 'Choose a ward first' : 'Loading prabhags…')
                                    : 'Choose prabhag',
                              ),
                              items: [
                                for (final item in store.prabhags)
                                  DropdownMenuItem(value: item.id, child: Text(item.name, overflow: TextOverflow.ellipsis)),
                              ],
                              onChanged: store.prabhags.isEmpty ? null : (id) => store.selectPrabhag(id),
                            ),
                          ),
                        ),
                        if (draft.wardName.isNotEmpty || draft.prabhagName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              [if (draft.wardName.isNotEmpty) draft.wardName, if (draft.prabhagName.isNotEmpty) draft.prabhagName].join(' · '),
                              style: const TextStyle(fontWeight: FontWeight.w700),
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
                        const Text('Short Note (Optional)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
                  final problem = store.draftError();
                  if (problem != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(problem)));
                    return;
                  }
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
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => _LocationPicker(initial: LatLng(store.draft.latitude, store.draft.longitude)),
      ),
    );
    if (result == true) return; // already applied via current-location capture
    if (result is! LatLng) return;
    await store.placeAt(result.latitude, result.longitude, label: 'Pinned on map');
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
  var _locating = false;

  Future<void> _useCurrent(BuildContext context) async {
    final store = AppScope.of(context);
    setState(() => _locating = true);
    try {
      await store.captureLocation();
      if (!mounted) return;
      if (store.here == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(store.areaNote ?? 'Could not read your location.')),
        );
        return;
      }
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Location')),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: OutlinedButton.icon(
              onPressed: _locating ? null : () => _useCurrent(context),
              icon: _locating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, color: AppColors.teal),
              label: Text(_locating ? 'Finding you…' : 'Use my current location', style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      asset: '',
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
                        const Text('Before You Send', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const Text('Please confirm the following before submitting your report.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                        const SizedBox(height: 8),
                        _check('Photo check', store.photoVerdict.detail, ok: store.photoVerdict.accepted),
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
                    onPressed: store.busy
                        ? null
                        : () async {
                            try {
                              final report = await store.submitDraft();
                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => SentScreen(report: report)),
                              );
                            } on PmcException catch (error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
                            } catch (error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not send the report. ${error.toString()}')),
                              );
                            }
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

  Widget _check(String title, String body, {bool ok = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.check_circle : Icons.error, color: ok ? AppColors.green : const Color(0xFFE24B4B), size: 20),
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
              const Text('Report Sent', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
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
