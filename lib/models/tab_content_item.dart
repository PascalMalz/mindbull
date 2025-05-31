import 'package:flutter/material.dart';

enum TabContentType {
  exercise,
  post,
  audio,
  checklist,
  unknown;

  // Map backend strings to enum
  static TabContentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'exercise':
        return TabContentType.exercise;
      case 'post':
        return TabContentType.post;
      case 'audio':
        return TabContentType.audio;
      case 'checklist':
        return TabContentType.checklist;
      default:
        return TabContentType.unknown;
    }
  }

  // Convert enum to readable label
  String toLabel() {
    switch (this) {
      case TabContentType.exercise:
        return 'Exercise';
      case TabContentType.post:
        return 'Post';
      case TabContentType.audio:
        return 'Audio';
      case TabContentType.checklist:
        return 'Checklist';
      case TabContentType.unknown:
      default:
        return 'Unknown';
    }
  }

  // Optional: Icon for each type
  IconData toIcon() {
    switch (this) {
      case TabContentType.exercise:
        return Icons.fitness_center;
      case TabContentType.post:
        return Icons.chat;
      case TabContentType.audio:
        return Icons.audiotrack;
      case TabContentType.checklist:
        return Icons.checklist;
      case TabContentType.unknown:
      default:
        return Icons.help_outline;
    }
  }
}

class TabContentItem {
  final String id; // UUID or backend ID
  final TabContentType type;
  final String title;
  final int order; // Position in the tab
  final Map<String, dynamic>? metadata;

  TabContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.order,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'order': order,
        'metadata': metadata,
      };

  static TabContentItem fromJson(Map<String, dynamic> json) => TabContentItem(
        id: json['id'],
        type: TabContentType.values.firstWhere((e) => e.name == json['type']),
        title: json['title'],
        order: json['order'],
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  TabContentItem copyWith({
    String? id,
    TabContentType? type,
    String? title,
    int? order,
    Map<String, dynamic>? metadata,
  }) {
    return TabContentItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      order: order ?? this.order,
      metadata: metadata ?? this.metadata,
    );
  }
}
