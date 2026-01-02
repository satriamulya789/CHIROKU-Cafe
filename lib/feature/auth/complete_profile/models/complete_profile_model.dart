class CompleteProfileModel {
  final String userId;
  final String fullName;
  final String? avatarUrl;

  CompleteProfileModel({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
  factory CompleteProfileModel.fromJson(Map<String, dynamic> json) {
    return CompleteProfileModel(
      userId: json['id'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
