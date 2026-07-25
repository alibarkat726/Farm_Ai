class HistoryItem {
  final int id;
  final String? cropType;
  final String? month;
  final String? location;
  final String? likelyCauseSummary;
  final String? urgency;
  final bool hasImage;
  final DateTime createdAt;

  const HistoryItem({
    required this.id,
    this.cropType,
    this.month,
    this.location,
    this.likelyCauseSummary,
    this.urgency,
    required this.hasImage,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as int,
      cropType: json['cropType'] as String?,
      month: json['month'] as String?,
      location: json['location'] as String?,
      likelyCauseSummary: json['likelyCauseSummary'] as String?,
      urgency: json['urgency'] as String?,
      hasImage: json['hasImage'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
