import '../models.dart';
import 'pmc_api.dart';

PmcSubcategory? subcategoryFor(IssueType issue, List<PmcSubcategory> options) {
  bool match(PmcSubcategory item, List<String> needles) {
    final name = item.name.toLowerCase();
    return needles.any(name.contains);
  }

  final ranked = switch (issue) {
    IssueType.unsterilised => ['unsteril'],
    IssueType.injured || IssueType.sick => ['injured', 'sick'],
    IssueType.aggressive || IssueType.bite => ['rabies', 'voilent', 'violent'],
    IssueType.pack => ['other'],
  };
  for (final item in options) {
    if (match(item, ranked)) return item;
  }
  return null;
}

bool looksLikePune(double latitude, double longitude) {
  return latitude >= 18.40 && latitude <= 18.65 && longitude >= 73.70 && longitude <= 74.05;
}
