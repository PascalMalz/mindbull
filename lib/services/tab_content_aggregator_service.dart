import '../models/tab_content_item.dart';
import '../models/tab_content_link.dart';
import '../models/exercise.dart';
import '../models/audio.dart';
import '../models/post.dart';
import '../models/composition.dart';
import '../api/api_tab_content_service.dart';

/// Service to aggregate mixed tab content (exercises, audio, posts, etc.) into
/// a unified list of [TabContentItem]s that can be rendered dynamically.
class TabContentAggregatorService {
  Future<List<TabContentItem>> fetchAndAggregate(String tabId) async {
    final List<TabContentLink> rawLinks =
        await ApiTabContentService().fetchTabContentLinks(tabId);
    List<TabContentItem> items = [];

    for (final link in rawLinks) {
      final type = TabContentType.fromString(link.contentType);
      final objectData = link.contentObject;
      dynamic content;
      String title = "Untitled";

      switch (type) {
        case TabContentType.exercise:
          content = Exercise.fromJson(objectData);
          title = content.name;
          break;

        case TabContentType.audio:
          content = Audio.fromJson(objectData);
          title = content.audioTitle;
          break;

        case TabContentType.post:
          content = Post.fromJson(objectData);
          title = content.postDescription?.substring(0, 30) ?? "Post";
          break;

        case TabContentType.checklist:
          title = objectData['title'] ?? 'Checklist';
          break;

        case TabContentType.audioPlaylist:
          title = objectData['title'] ?? 'Audio Playlist';
          break;

        case TabContentType.reminder:
          title = objectData['label'] ?? 'Reminder';
          break;

        case TabContentType.separator:
          title = objectData['label'] ?? 'Separator';
          break;

        case TabContentType.unknown:
        default:
          print("Unknown content type: ${link.contentType}");
          continue;
      }

      items.add(
        TabContentItem(
          id: link.objectId,
          type: type,
          title: title,
          order: link.order,
          metadata: link.metadata,
        ),
      );
    }

    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }
}
