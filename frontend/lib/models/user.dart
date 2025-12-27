import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String gender; // 'male' or 'female'
  final String nativeLanguage;
  final String targetLanguage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.gender,
    required this.nativeLanguage,
    required this.targetLanguage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'nativeLanguage': nativeLanguage,
      'targetLanguage': targetLanguage,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'],
      gender: map['gender'] ?? 'male',
      nativeLanguage: map['nativeLanguage'] ?? 'Chinese',
      targetLanguage: map['targetLanguage'] ?? 'English',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? gender,
    String? nativeLanguage,
    String? targetLanguage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}
