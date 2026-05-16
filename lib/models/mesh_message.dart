import 'package:flutter/foundation.dart';

enum MessageType {
  dangerZone,
  familySearch,
  medicalAlert,
  generalChat
}

class MeshMessage {
  final String id;
  final MessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final Duration ttl;
  final List<String> path; // List of node IDs the message has passed through

  MeshMessage({
    required this.type,
    required this.data,
    required this.ttl,
    String? id,
    DateTime? timestamp,
    List<String>? path,
  })  : id = id ?? UniqueKey().toString(),
        timestamp = timestamp ?? DateTime.now(),
        path = path ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'ttl_hours': ttl.inHours,
      'path': path,
    };
  }

  factory MeshMessage.fromJson(Map<String, dynamic> json) {
    return MeshMessage(
      id: json['id'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      ttl: Duration(hours: json['ttl_hours']),
      path: List<String>.from(json['path'] ?? []),
    );
  }
}