// ignore_for_file: file_names

/// One announcement from `/notices`.
///
/// `title` and `content` are plain text and must be rendered as text, never
/// as HTML. Timestamps are nullable so a malformed date hides the caption
/// instead of throwing mid-list.
class Notice {
  final int id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// True when the notice has been edited since it was posted.
  bool get isEdited {
    final created = createdAt;
    final updated = updatedAt;
    if (created == null || updated == null) return false;
    return updated.difference(created).inSeconds.abs() > 1;
  }

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}
