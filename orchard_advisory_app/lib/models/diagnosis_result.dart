class LikelyCause {
  final String issueId;
  final String commonName;
  final String confidence;
  final String reasoning;

  const LikelyCause({
    required this.issueId,
    required this.commonName,
    required this.confidence,
    required this.reasoning,
  });

  factory LikelyCause.fromJson(Map<String, dynamic> json) {
    return LikelyCause(
      issueId: json['issueId'] as String? ?? 'unknown',
      commonName: json['commonName'] as String? ?? 'Unknown',
      confidence: json['confidence'] as String? ?? 'low',
      reasoning: json['reasoning'] as String? ?? '',
    );
  }
}

class DiagnosisResult {
  final List<LikelyCause> likelyCauses;
  final String recommendedAction;
  final List<String> treatmentSteps;
  final String urgency;
  final bool consultExtensionOffice;
  final String disclaimer;

  const DiagnosisResult({
    required this.likelyCauses,
    required this.recommendedAction,
    required this.treatmentSteps,
    required this.urgency,
    required this.consultExtensionOffice,
    required this.disclaimer,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    final causesRaw = json['likelyCauses'] as List<dynamic>? ?? [];
    final stepsRaw = json['treatmentSteps'] as List<dynamic>? ?? [];
    return DiagnosisResult(
      likelyCauses: causesRaw
          .map((e) => LikelyCause.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedAction: json['recommendedAction'] as String? ?? '',
      treatmentSteps: stepsRaw.map((e) => e.toString()).toList(),
      urgency: json['urgency'] as String? ?? 'moderate',
      consultExtensionOffice: json['consultExtensionOffice'] as bool? ?? false,
      disclaimer: json['disclaimer'] as String? ??
          'This is guidance only, not a substitute for an in-person agricultural expert.',
    );
  }
}
