class IssueSummary {
  final String id;
  final String commonName;
  final List<String> affectedCrops;
  final String category;

  const IssueSummary({
    required this.id,
    required this.commonName,
    required this.affectedCrops,
    required this.category,
  });

  factory IssueSummary.fromJson(Map<String, dynamic> json) {
    final crops = json['affectedCrops'] as List<dynamic>? ?? [];
    return IssueSummary(
      id: json['id'] as String,
      commonName: json['commonName'] as String,
      affectedCrops: crops.map((e) => e.toString()).toList(),
      category: json['category'] as String? ?? '',
    );
  }
}

class IssueDetail {
  final String id;
  final String commonName;
  final List<String> affectedCrops;
  final String category;
  final List<String> symptoms;
  final List<String> typicalSeason;
  final String conditionsThatFavorIt;
  final List<String> treatment;
  final List<String> prevention;
  final String urgency;
  final String notes;

  const IssueDetail({
    required this.id,
    required this.commonName,
    required this.affectedCrops,
    required this.category,
    required this.symptoms,
    required this.typicalSeason,
    required this.conditionsThatFavorIt,
    required this.treatment,
    required this.prevention,
    required this.urgency,
    required this.notes,
  });

  factory IssueDetail.fromJson(Map<String, dynamic> json) {
    List<String> stringList(dynamic value) {
      final list = value as List<dynamic>? ?? [];
      return list.map((e) => e.toString()).toList();
    }

    return IssueDetail(
      id: json['id'] as String,
      commonName: json['commonName'] as String,
      affectedCrops: stringList(json['affectedCrops']),
      category: json['category'] as String? ?? '',
      symptoms: stringList(json['symptoms']),
      typicalSeason: stringList(json['typicalSeason']),
      conditionsThatFavorIt: json['conditionsThatFavorIt'] as String? ?? '',
      treatment: stringList(json['treatment']),
      prevention: stringList(json['prevention']),
      urgency: json['urgency'] as String? ?? 'moderate',
      notes: json['notes'] as String? ?? '',
    );
  }
}
