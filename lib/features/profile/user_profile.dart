class UserProfile {
  const UserProfile({
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthCity,
    required this.birthLatitude,
    required this.birthLongitude,
    this.gender,
    this.sunSign,
    this.risingSign,
  });

  final String name;
  final DateTime birthDate;
  final Duration birthTime;
  final String birthCity;
  final double birthLatitude;
  final double birthLongitude;
  final String? gender;
  final String? sunSign;
  final String? risingSign;

  UserProfile copyWith({
    String? name,
    DateTime? birthDate,
    Duration? birthTime,
    String? birthCity,
    double? birthLatitude,
    double? birthLongitude,
    String? gender,
    String? sunSign,
    String? risingSign,
  }) {
    return UserProfile(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthCity: birthCity ?? this.birthCity,
      birthLatitude: birthLatitude ?? this.birthLatitude,
      birthLongitude: birthLongitude ?? this.birthLongitude,
      gender: gender ?? this.gender,
      sunSign: sunSign ?? this.sunSign,
      risingSign: risingSign ?? this.risingSign,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'birthTime': birthTime.inMinutes,
      'birthCity': birthCity,
      'birthLatitude': birthLatitude,
      'birthLongitude': birthLongitude,
      'gender': gender,
      'sunSign': sunSign,
      'risingSign': risingSign,
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      birthDate: DateTime.tryParse(json['birthDate'] as String? ?? '') ??
          DateTime.now(),
      birthTime: Duration(minutes: (json['birthTime'] as num?)?.toInt() ?? 0),
      birthCity: json['birthCity'] as String? ?? '',
      birthLatitude: (json['birthLatitude'] as num?)?.toDouble() ?? 0,
      birthLongitude: (json['birthLongitude'] as num?)?.toDouble() ?? 0,
      gender: json['gender'] as String?,
      sunSign: json['sunSign'] as String?,
      risingSign: json['risingSign'] as String?,
    );
  }
}
