enum ReportStatus { submitted, assigned, inProgress, resolved }

enum IssueType { aggressive, injured, bite, sick, unsterilised, pack }

extension IssueTypeX on IssueType {
  String get label {
    switch (this) {
      case IssueType.aggressive:
        return 'Aggressive dog';
      case IssueType.injured:
        return 'Injured dog';
      case IssueType.bite:
        return 'Dog bite';
      case IssueType.sick:
        return 'Sick dog';
      case IssueType.unsterilised:
        return 'Unsterilised dog';
      case IssueType.pack:
        return 'Pack of dogs';
    }
  }
}

extension ReportStatusX on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.assigned:
        return 'Assigned';
      case ReportStatus.inProgress:
        return 'In progress';
      case ReportStatus.resolved:
        return 'Resolved';
    }
  }

  bool get isOpen => this != ReportStatus.resolved;
}

class TimelineEvent {
  const TimelineEvent({
    required this.title,
    required this.time,
    required this.body,
    required this.done,
    this.current = false,
  });

  final String title;
  final String time;
  final String body;
  final bool done;
  final bool current;
}

class DogReport {
  DogReport({
    required this.id,
    required this.title,
    required this.location,
    required this.area,
    required this.timeLabel,
    required this.status,
    required this.asset,
    required this.issue,
    required this.dogCount,
    required this.note,
    required this.reference,
    required this.latitude,
    required this.longitude,
    required this.updates,
    this.filePath,
  });

  final String id;
  final String title;
  final String location;
  final String area;
  final String timeLabel;
  final ReportStatus status;
  final String asset;
  final IssueType issue;
  final int dogCount;
  final String note;
  final String reference;
  final double latitude;
  final double longitude;
  final List<TimelineEvent> updates;
  String? filePath;
}

class ReportDraft {
  String? filePath;
  String asset = 'assets/images/dog_street.png';
  IssueType issue = IssueType.aggressive;
  int dogCount = 3;
  String note = 'Dogs chasing people near the gate.';
  String location = 'NIBM Road, Kondhwa';
  String area = 'Pune, Maharashtra';
  double latitude = 18.4698;
  double longitude = 73.9045;
}
