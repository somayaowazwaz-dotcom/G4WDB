class SurvivalSupply {
  final String id;
  final String name;
  final double totalAmount;
  final double dailyUsage;
  final String unit;
  final String category;

  SurvivalSupply({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.dailyUsage,
    required this.unit,
    required this.category,
  });

  double get daysRemaining => dailyUsage > 0 ? totalAmount / dailyUsage : double.infinity;

  String get status {
    if (daysRemaining < 1) return "CRITICAL";
    if (daysRemaining < 3) return "LOW";
    return "OK";
  }

  SurvivalSupply copyWith({
    String? id,
    String? name,
    double? totalAmount,
    double? dailyUsage,
    String? unit,
    String? category,
  }) {
    return SurvivalSupply(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      dailyUsage: dailyUsage ?? this.dailyUsage,
      unit: unit ?? this.unit,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'dailyUsage': dailyUsage,
      'unit': unit,
      'category': category,
    };
  }

  factory SurvivalSupply.fromMap(Map<String, dynamic> map) {
    return SurvivalSupply(
      id: map['id'],
      name: map['name'],
      totalAmount: map['totalAmount'],
      dailyUsage: map['dailyUsage'],
      unit: map['unit'],
      category: map['category'],
    );
  }
}
