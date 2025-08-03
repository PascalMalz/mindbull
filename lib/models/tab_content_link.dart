class TabContentLink {
  final String id;
  final String tabId;
  final String contentType;
  final String objectId;
  final Map<String, dynamic> metadata;
  final int order;
  final DateTime updatedAt;
  final Map<String, dynamic> contentObject;

  TabContentLink({
    required this.id,
    required this.tabId,
    required this.contentType,
    required this.objectId,
    required this.metadata,
    required this.order,
    required this.updatedAt,
    required this.contentObject,
  });

  factory TabContentLink.fromJson(Map<String, dynamic> json) {
    return TabContentLink(
      id: json['id'],
      tabId: json['tab'],
      contentType: json['content_type'],
      objectId: json['object_id'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      order: json['order'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at']),
      contentObject: Map<String, dynamic>.from(json['content_object'] ?? {}),
    );
  }
}
