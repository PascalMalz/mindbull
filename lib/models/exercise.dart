class Exercise {
  final String exerciseUuid;
  final String name;
  final String description;
  final String instructions;
  final String? thumbnail;
  final String? media; // Media file URL (video/audio)
  final String duration;
  final int xp;
  final bool isDefault;
  final bool isExclusive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String createdBy;

  Exercise({
    required this.exerciseUuid,
    required this.name,
    required this.description,
    required this.instructions,
    this.thumbnail,
    this.media, // Optional media field
    required this.duration,
    required this.xp,
    required this.isDefault,
    required this.isExclusive,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.createdBy,
  });

  // Factory constructor to create an Exercise from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseUuid: json['exercise_uuid'],
      name: json['name'],
      description: json['description'],
      instructions: json['instructions'],
      thumbnail: json['thumbnail'],
      media: json['media'], // Extract media from JSON
      duration: json['duration'],
      xp: json['xp'],
      isDefault: json['is_default'],
      isExclusive: json['is_exclusive'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tags: List<String>.from(json['tags'] ?? []),
      createdBy: json['created_by'],
    );
  }

  // Convert an Exercise to JSON (if needed for POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'exercise_uuid': exerciseUuid,
      'name': name,
      'description': description,
      'instructions': instructions,
      'thumbnail': thumbnail,
      'media': media, // Include media in JSON
      'duration': duration,
      'xp': xp,
      'is_default': isDefault,
      'is_exclusive': isExclusive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
      'created_by': createdBy,
    };
  }
}
