class TriageResult {
  final String category;
  final String priority;
  final List<String> actions;
  final List<String> treatments;
  final List<Map<String, dynamic>> guidelines;
  final DateTime timestamp;
  final String? notes;
  
  TriageResult({
    required this.category,
    required this.priority,
    required this.actions,
    required this.treatments,
    this.guidelines = const [],
    required this.timestamp,
    this.notes,
  });
  
  TriageResult copyWith({
    String? category,
    String? priority,
    List<String>? actions,
    List<String>? treatments,
    List<Map<String, dynamic>>? guidelines,
    DateTime? timestamp,
    String? notes,
  }) {
    return TriageResult(
      category: category ?? this.category,
      priority: priority ?? this.priority,
      actions: actions ?? this.actions,
      treatments: treatments ?? this.treatments,
      guidelines: guidelines ?? this.guidelines,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }
}