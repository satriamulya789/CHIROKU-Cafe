class PushNotificationModel {
  final int id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  PushNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'] ?? 'system',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }
}