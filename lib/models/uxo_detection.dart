class UXODetection {
  final bool detected;
  final String type;
  final double confidence;
  final String riskLevel;
  final double safeDistance;
  final List<String> recommendations;
  final DateTime timestamp;

  UXODetection({
    required this.detected,
    this.type = 'Unknown',
    required this.confidence,
    required this.riskLevel,
    required this.safeDistance,
    this.recommendations = const [],
    required this.timestamp,
  });

  factory UXODetection.none() {
    return UXODetection(
      detected: false,
      confidence: 0.0,
      riskLevel: 'LOW',
      safeDistance: 0.0,
      timestamp: DateTime.now(),
    );
  }
}
