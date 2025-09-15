class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> favoriteRoutes;
  final Map<String, dynamic> preferences;
  final bool isEmailVerified;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.favoriteRoutes = const [],
    this.preferences = const {},
    this.isEmailVerified = false,
    this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] as DateTime
          : DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      lastLoginAt: map['lastLoginAt'] != null 
          ? (map['lastLoginAt'] is DateTime 
              ? map['lastLoginAt'] as DateTime
              : DateTime.parse(map['lastLoginAt'].toString()))
          : null,
      favoriteRoutes: List<String>.from(map['favoriteRoutes'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      fcmToken: map['fcmToken']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'favoriteRoutes': favoriteRoutes,
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? favoriteRoutes,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  // Helper methods
  String get displayName => name.isNotEmpty ? name : email.split('@').first;
  
  String get initials {
    if (name.isNotEmpty) {
      final names = name.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool get hasProfileImage => profileImageUrl != null && profileImageUrl!.isNotEmpty;
  
  String get formattedPhoneNumber {
    if (phoneNumber == null || phoneNumber!.isEmpty) return 'Not provided';
    return phoneNumber!;
  }

  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedLastLogin {
    if (lastLoginAt == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Preferences helpers
  bool get notificationsEnabled => preferences['notifications'] as bool? ?? true;
  bool get locationTrackingEnabled => preferences['locationTracking'] as bool? ?? true;
  String get preferredLanguage => preferences['language'] as String? ?? 'en';
  String get themeMode => preferences['themeMode'] as String? ?? 'system';
}
