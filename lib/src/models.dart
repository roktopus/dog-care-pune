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
  ReportStatus status;
  final String asset;
  final IssueType issue;
  final int dogCount;
  final String note;
  final String reference;
  final double latitude;
  final double longitude;
  List<TimelineEvent> updates;
  String? filePath;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'location': location,
        'area': area,
        'timeLabel': timeLabel,
        'status': status.name,
        'asset': asset,
        'issue': issue.name,
        'dogCount': dogCount,
        'note': note,
        'reference': reference,
        'latitude': latitude,
        'longitude': longitude,
        'filePath': filePath,
        'updates': [
          for (final event in updates)
            {
              'title': event.title,
              'time': event.time,
              'body': event.body,
              'done': event.done,
              'current': event.current,
            },
        ],
      };

  factory DogReport.fromJson(Map<String, Object?> json) {
    final updates = (json['updates'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (event) => TimelineEvent(
            title: event['title']?.toString() ?? '',
            time: event['time']?.toString() ?? '',
            body: event['body']?.toString() ?? '',
            done: event['done'] == true,
            current: event['current'] == true,
          ),
        )
        .toList();
    return DogReport(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      timeLabel: json['timeLabel']?.toString() ?? '',
      status: ReportStatus.values.byName(json['status']?.toString() ?? 'submitted'),
      asset: json['asset']?.toString() ?? 'assets/images/dog_street.png',
      issue: IssueType.values.byName(json['issue']?.toString() ?? 'aggressive'),
      dogCount: json['dogCount'] as int? ?? 1,
      note: json['note']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? puneCenterLat,
      longitude: (json['longitude'] as num?)?.toDouble() ?? puneCenterLng,
      updates: updates,
      filePath: json['filePath']?.toString(),
    );
  }
}

const puneCenterLat = 18.5204;
const puneCenterLng = 73.8567;

class ReportDraft {
  String? filePath;
  String asset = 'assets/images/dog_street.png';
  IssueType issue = IssueType.aggressive;
  int dogCount = 1;
  String note = '';
  String location = '';
  String area = '';
  double latitude = 0;
  double longitude = 0;
  bool locationChosen = false;
  String? wardId;
  String wardName = '';
  String? prabhagId;
  String prabhagName = '';
}
