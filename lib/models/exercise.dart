class Exercise {
  final String exerciseUuid;
  final String exerciseType;
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
    required this.exerciseType,
    required this.name,
    required this.description,
    required this.instructions,
    this.thumbnail,
    this.media,
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
      exerciseType:
          json['exercise_type_name'] ?? 'Unknown', // Provide a default if null
      name: json['name'] ?? 'Unnamed Exercise',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      thumbnail: json['thumbnail'] ?? '', // Use an empty string if null
      media: json['media'] ?? '', // Use an empty string if null
      duration:
          json['duration'] ?? '00:00:00', // Provide default duration if null
      xp: json['xp'] ?? 0, // Default to 0 XP if null
      isDefault: json['is_default'] ?? false,
      isExclusive: json['is_exclusive'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tags: List<String>.from(json['tags'] ?? []), // Handle empty tags
      createdBy: json['created_by'].toString(), // Ensure UUID is stringified
    );
  }

  // Convert an Exercise to JSON (if needed for POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'exercise_uuid': exerciseUuid,
      'exercise_type_name': exerciseType,
      'name': name,
      'description': description,
      'instructions': instructions,
      'thumbnail': thumbnail,
      'media': media,
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

  // Override toString for structured printing
  @override
  String toString() {
    return '''
Exercise(
  UUID: $exerciseUuid,
  Type: $exerciseType,
  Name: $name,
  Description: $description,
  Instructions: $instructions,
  Thumbnail: $thumbnail,
  Media: $media,
  Duration: $duration,
  XP: $xp,
  Is Default: $isDefault,
  Is Exclusive: $isExclusive,
  Created At: $createdAt,
  Updated At: $updatedAt,
  Tags: $tags,
  Created By: $createdBy
)''';
  }
}
