import 'package:flutter/foundation.dart';

import 'models.dart';

class AppStore extends ChangeNotifier {
  bool seenWelcome = false;
  bool signedIn = false;
  String mobile = '';
  String name = 'Anup';
  int tab = 0;
  bool codeSent = false;
  String otp = '';
  final ReportDraft draft = ReportDraft();
  String? lastReference;

  final List<DogReport> reports = [
    DogReport(
      id: 'r1',
      title: 'Aggressive dog near NIBM Road',
      location: 'NIBM Road, Pune',
      area: 'NIBM Road, Kondhwa',
      timeLabel: '2 hours ago',
      status: ReportStatus.inProgress,
      asset: 'assets/images/dog_aggressive.png',
      issue: IssueType.aggressive,
      dogCount: 3,
      note:
          'Group of three dogs behaving aggressively near the apartment gate. They bark and chase people.',
      reference: 'PC45182',
      latitude: 18.4698,
      longitude: 73.9045,
      updates: const [
        TimelineEvent(
          title: 'Report sent',
          time: '12 Mar 2024, 10:15 AM',
          body: 'Your report has been submitted successfully.',
          done: true,
        ),
        TimelineEvent(
          title: 'Assigned',
          time: '12 Mar 2024, 11:20 AM',
          body: 'Our team has been assigned to look into this.',
          done: true,
        ),
        TimelineEvent(
          title: 'In progress',
          time: '12 Mar 2024, 2:30 PM',
          body: 'Our team is on the way and working on this report.',
          done: true,
          current: true,
        ),
        TimelineEvent(
          title: 'Resolved',
          time: 'Pending',
          body: 'This report will be marked as resolved once the issue is addressed.',
          done: false,
        ),
      ],
    ),
    DogReport(
      id: 'r2',
      title: 'Injured dog near Salunke Vihar',
      location: 'Salunke Vihar, Pune',
      area: 'Salunke Vihar, Pune',
      timeLabel: '1 day ago',
      status: ReportStatus.submitted,
      asset: 'assets/images/dog_injured.png',
      issue: IssueType.injured,
      dogCount: 1,
      note: 'Dog is lying near the lane and is not able to walk.',
      reference: 'PC44891',
      latitude: 18.4845,
      longitude: 73.9012,
      updates: const [
        TimelineEvent(
          title: 'Report sent',
          time: '23 Mar 2024, 9:05 AM',
          body: 'Your report has been submitted successfully.',
          done: true,
          current: true,
        ),
        TimelineEvent(
          title: 'Assigned',
          time: 'Pending',
          body: 'A team will be assigned to look into this.',
          done: false,
        ),
        TimelineEvent(
          title: 'In progress',
          time: 'Pending',
          body: 'Work starts after the report is assigned.',
          done: false,
        ),
        TimelineEvent(
          title: 'Resolved',
          time: 'Pending',
          body: 'This report will be marked as resolved once the issue is addressed.',
          done: false,
        ),
      ],
    ),
    DogReport(
      id: 'r3',
      title: 'Pack of dogs near school',
      location: 'Vibgyor High School, NIBM',
      area: 'NIBM, Pune',
      timeLabel: '2 days ago',
      status: ReportStatus.resolved,
      asset: 'assets/images/dog_pack.png',
      issue: IssueType.pack,
      dogCount: 4,
      note: 'A pack gathers outside the school gate in the morning.',
      reference: 'PC44102',
      latitude: 18.4760,
      longitude: 73.9080,
      updates: const [
        TimelineEvent(
          title: 'Report sent',
          time: '22 Mar 2024, 8:10 AM',
          body: 'Your report has been submitted successfully.',
          done: true,
        ),
        TimelineEvent(
          title: 'Assigned',
          time: '22 Mar 2024, 9:40 AM',
          body: 'Our team has been assigned to look into this.',
          done: true,
        ),
        TimelineEvent(
          title: 'In progress',
          time: '22 Mar 2024, 1:15 PM',
          body: 'Our team is working on this report.',
          done: true,
        ),
        TimelineEvent(
          title: 'Resolved',
          time: '23 Mar 2024, 11:00 AM',
          body: 'The issue has been addressed.',
          done: true,
          current: true,
        ),
      ],
    ),
    DogReport(
      id: 'r4',
      title: 'Sick dog near Mohammadwadi',
      location: 'Mohammadwadi, Pune',
      area: 'Mohammadwadi, Pune',
      timeLabel: '4 days ago',
      status: ReportStatus.assigned,
      asset: 'assets/images/dog_sick.png',
      issue: IssueType.sick,
      dogCount: 1,
      note: 'Dog has been lying in the same spot since morning.',
      reference: 'PC43920',
      latitude: 18.4635,
      longitude: 73.9180,
      updates: const [
        TimelineEvent(
          title: 'Report sent',
          time: '20 Mar 2024, 4:20 PM',
          body: 'Your report has been submitted successfully.',
          done: true,
        ),
        TimelineEvent(
          title: 'Assigned',
          time: '20 Mar 2024, 6:05 PM',
          body: 'Our team has been assigned to look into this.',
          done: true,
          current: true,
        ),
        TimelineEvent(
          title: 'In progress',
          time: 'Pending',
          body: 'Our team will update you when work begins.',
          done: false,
        ),
        TimelineEvent(
          title: 'Resolved',
          time: 'Pending',
          body: 'This report will be marked as resolved once the issue is addressed.',
          done: false,
        ),
      ],
    ),
    DogReport(
      id: 'r5',
      title: 'Unsterilised dog near Kondhwa',
      location: 'Kondhwa, Pune',
      area: 'Kondhwa, Pune',
      timeLabel: '1 week ago',
      status: ReportStatus.resolved,
      asset: 'assets/images/dog_unsterilised.png',
      issue: IssueType.unsterilised,
      dogCount: 1,
      note: 'Dog is often seen near the society gate.',
      reference: 'PC43110',
      latitude: 18.4600,
      longitude: 73.8890,
      updates: const [
        TimelineEvent(
          title: 'Report sent',
          time: '17 Mar 2024, 10:00 AM',
          body: 'Your report has been submitted successfully.',
          done: true,
        ),
        TimelineEvent(
          title: 'Assigned',
          time: '17 Mar 2024, 12:30 PM',
          body: 'Our team has been assigned to look into this.',
          done: true,
        ),
        TimelineEvent(
          title: 'In progress',
          time: '18 Mar 2024, 9:00 AM',
          body: 'Our team is working on this report.',
          done: true,
        ),
        TimelineEvent(
          title: 'Resolved',
          time: '19 Mar 2024, 3:45 PM',
          body: 'The issue has been addressed.',
          done: true,
          current: true,
        ),
      ],
    ),
  ];

  int get openCount => reports.where((r) => r.status.isOpen).length;
  int get resolvedCount => reports.where((r) => !r.status.isOpen).length;

  List<DogReport> get recent => reports.take(3).toList();

  void continueFromWelcome() {
    seenWelcome = true;
    signedIn = true;
    notifyListeners();
  }

  void sendCode() {
    codeSent = true;
    notifyListeners();
  }

  void setOtp(String value) {
    otp = value;
    if (value.length == 6) {
      signedIn = true;
    }
    notifyListeners();
  }

  void signOut() {
    signedIn = false;
    codeSent = false;
    otp = '';
    tab = 0;
    notifyListeners();
  }

  void setTab(int value) {
    tab = value;
    notifyListeners();
  }

  void touch() => notifyListeners();

  void resetDraft() {
    draft
      ..filePath = null
      ..asset = 'assets/images/dog_street.png'
      ..issue = IssueType.aggressive
      ..dogCount = 3
      ..note = 'Dogs chasing people near the gate.'
      ..location = 'NIBM Road, Kondhwa'
      ..area = 'Pune, Maharashtra'
      ..latitude = 18.4698
      ..longitude = 73.9045;
    notifyListeners();
  }

  DogReport submitDraft() {
    final n = 45182 + reports.length;
    final ref = 'PC$n';
    final report = DogReport(
      id: 'local-$n',
      title: '${draft.issue.label} near ${draft.location.split(',').first}',
      location: draft.location.contains('Pune')
          ? draft.location
          : '${draft.location.split(',').first}, Pune',
      area: draft.location,
      timeLabel: 'Just now',
      status: ReportStatus.submitted,
      asset: draft.asset,
      issue: draft.issue,
      dogCount: draft.dogCount,
      note: draft.note,
      reference: ref,
      latitude: draft.latitude,
      longitude: draft.longitude,
      filePath: draft.filePath,
      updates: const [
        TimelineEvent(
          title: 'Report sent',
          time: 'Just now',
          body: 'Your report has been submitted successfully.',
          done: true,
          current: true,
        ),
        TimelineEvent(
          title: 'Assigned',
          time: 'Pending',
          body: 'A team will be assigned to look into this.',
          done: false,
        ),
        TimelineEvent(
          title: 'In progress',
          time: 'Pending',
          body: 'Work starts after the report is assigned.',
          done: false,
        ),
        TimelineEvent(
          title: 'Resolved',
          time: 'Pending',
          body: 'This report will be marked as resolved once the issue is addressed.',
          done: false,
        ),
      ],
    );
    reports.insert(0, report);
    lastReference = ref;
    notifyListeners();
    return report;
  }
}
