import 'dart:convert';
import 'dart:math' as math;

class AreaHit {
  const AreaHit({required this.ward, required this.prabhag, required this.distanceKm});

  final String ward;
  final String prabhag;
  final double distanceKm;
}

class AreaIndex {
  AreaIndex(this._features);

  final List<_Feature> _features;

  static AreaIndex parse(String raw) {
    final json = jsonDecode(raw);
    final features = (json is Map ? json['features'] as List? : null) ?? const [];
    return AreaIndex([
      for (final item in features)
        if (item is Map) _Feature.fromJson(item),
    ]);
  }

  AreaHit? find(double latitude, double longitude) {
    for (final feature in _features) {
      if (feature.contains(latitude, longitude)) {
        return AreaHit(ward: feature.ward, prabhag: feature.prabhag, distanceKm: 0);
      }
    }
    _Feature? nearest;
    var best = double.infinity;
    for (final feature in _features) {
      final km = feature.nearestKm(latitude, longitude);
      if (km < best) {
        best = km;
        nearest = feature;
      }
    }
    if (nearest == null || best > 3) return null;
    return AreaHit(ward: nearest.ward, prabhag: nearest.prabhag, distanceKm: best);
  }
}

class _Feature {
  _Feature({required this.ward, required this.prabhag, required this.outers});

  final String ward;
  final String prabhag;
  final List<List<List<double>>> outers;

  factory _Feature.fromJson(Map json) {
    final polygons = json['polygons'] as List? ?? const [];
    return _Feature(
      ward: json['ward']?.toString() ?? '',
      prabhag: json['prabhag']?.toString() ?? '',
      outers: [
        for (final polygon in polygons)
          if (polygon is Map && polygon['outer'] is List)
            [
              for (final point in polygon['outer'] as List)
                if (point is List && point.length >= 2) [_(point[0]), _(point[1])],
            ],
      ],
    );
  }

  bool contains(double latitude, double longitude) => outers.any((ring) => _inside(latitude, longitude, ring));

  double nearestKm(double latitude, double longitude) {
    var best = double.infinity;
    for (final ring in outers) {
      for (final point in ring) {
        final km = _km(latitude, longitude, point[0], point[1]);
        if (km < best) best = km;
      }
    }
    return best;
  }
}

double _(Object? value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

bool _inside(double latitude, double longitude, List<List<double>> ring) {
  var inside = false;
  for (var i = 0; i < ring.length; i++) {
    final a = ring[i];
    final b = ring[(i + 1) % ring.length];
    final lat1 = a[0], lon1 = a[1], lat2 = b[0], lon2 = b[1];
    if ((lon1 > longitude) != (lon2 > longitude)) {
      final x = lat1 + (lat2 - lat1) * (longitude - lon1) / (lon2 - lon1);
      if (latitude < x) inside = !inside;
    }
  }
  return inside;
}

double _km(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final p1 = lat1 * math.pi / 180;
  final p2 = lat2 * math.pi / 180;
  final dp = (lat2 - lat1) * math.pi / 180;
  final dl = (lon2 - lon1) * math.pi / 180;
  final a = math.pow(math.sin(dp / 2), 2) + math.cos(p1) * math.cos(p2) * math.pow(math.sin(dl / 2), 2);
  return 2 * r * math.asin(math.sqrt(a.toDouble()));
}

/// Match a bundled GIS name to a live PMC id/name map.
String? matchAreaName(String target, Map<String, String> idToName) {
  final wanted = _normalize(target);
  if (wanted.isEmpty || idToName.isEmpty) return null;

  String? bestId;
  var best = 0.0;
  idToName.forEach((id, name) {
    final score = _similarity(wanted, _normalize(name));
    if (score > best) {
      best = score;
      bestId = id;
    }
  });
  return best >= 0.4 ? bestId : null;
}

String _normalize(String value) {
  var text = value
      .toLowerCase()
      .replaceAll(RegExp(r'\d+'), ' ')
      .replaceAll(RegExp(r'[^a-z]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  // GIS spellings that differ from PMC CARE ward labels.
  text = text
      .replaceAll('bibvewadi', 'bibwewadi')
      .replaceAll('wanavadi', 'wanawadi')
      .replaceAll('sahakarnagar', 'katraj ambegaon')
      .replaceAll('mundhawa', 'manjari')
      .replaceAll('yewalewadi', 'undri')
      .replaceAll('dhole pati', 'dhole patil');
  return text;
}

double _similarity(String a, String b) {
  if (a == b) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  if (a.contains(b) || b.contains(a)) {
    final shorter = a.length < b.length ? a.length : b.length;
    final longer = a.length > b.length ? a.length : b.length;
    return shorter / longer;
  }
  final aTokens = a.split(' ').where((t) => t.length > 2).toList();
  final bTokens = b.split(' ').where((t) => t.length > 2).toList();
  if (aTokens.isNotEmpty && bTokens.isNotEmpty) {
    var shared = 0.0;
    for (final token in aTokens) {
      var best = 0.0;
      for (final other in bTokens) {
        final score = _ratio(token, other);
        if (score > best) best = score;
      }
      if (best >= 0.8) shared += best;
    }
    final jaccard = shared / math.max(aTokens.length, bTokens.length);
    if (jaccard >= 0.4) return jaccard;
  }
  return _ratio(a.replaceAll(' ', ''), b.replaceAll(' ', ''));
}

double _ratio(String a, String b) {
  if (a == b) return 1;
  final distance = _levenshtein(a, b);
  final longer = math.max(a.length, b.length);
  if (longer == 0) return 1;
  return 1 - (distance / longer);
}

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final rows = List.generate(a.length + 1, (_) => List<int>.filled(b.length + 1, 0));
  for (var i = 0; i <= a.length; i++) {
    rows[i][0] = i;
  }
  for (var j = 0; j <= b.length; j++) {
    rows[0][j] = j;
  }
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      rows[i][j] = [
        rows[i - 1][j] + 1,
        rows[i][j - 1] + 1,
        rows[i - 1][j - 1] + cost,
      ].reduce(math.min);
    }
  }
  return rows[a.length][b.length];
}
