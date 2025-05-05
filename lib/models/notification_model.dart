import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Debug print to see the raw JSON
    print("🔄 Parsing notification JSON: $json");

    // Handle timestamp which could be in different formats
    DateTime timestamp;
    try {
      if (json['timestamp'] is Timestamp) {
        timestamp = (json['timestamp'] as Timestamp).toDate();
      } else if (json['timestamp'] is DateTime) {
        timestamp = json['timestamp'] as DateTime;
      } else if (json['timestamp'] is String) {
        timestamp = DateTime.parse(json['timestamp'] as String);
      } else {
        print("⚠️ Invalid timestamp format: ${json['timestamp']}");
        timestamp = DateTime.now(); // Fallback
      }
    } catch (e) {
      print("❌ Error parsing timestamp: $e");
      timestamp = DateTime.now(); // Fallback
    }

    // Handle data field which might be missing or null
    Map<String, dynamic> data = {};
    if (json['data'] != null) {
      if (json['data'] is Map) {
        data = Map<String, dynamic>.from(json['data']);
      } else {
        print("⚠️ Data field is not a Map: ${json['data']}");
      }
    }

    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      data: data,
      timestamp: timestamp,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    // Create a safe copy of data to avoid serialization issues
    Map<String, dynamic> safeData = {};

    // Convert all values to strings to ensure they can be serialized
    data.forEach((key, value) {
      safeData[key] = value?.toString() ?? '';
    });

    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': safeData,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
