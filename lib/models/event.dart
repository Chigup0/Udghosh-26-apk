import 'package:intl/intl.dart';
import 'package:udghosh/config/app_config.dart';

/// One row from `/upcoming-events` or `/informal-sports` — both feeds share
/// this payload shape.
///
/// Every field is parsed defensively: the backend sends `null` for anything
/// unset, and a single null venue or malformed date used to take the whole
/// list down.
class Event {
  final int id;
  final String eventName;
  final String data;
  final String time;
  final DateTime? date;
  final String venue;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.eventName,
    required this.data,
    required this.time,
    required this.date,
    required this.venue,
    this.imageUrl,
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

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: int.tryParse('${json['id']}') ?? 0,
      eventName: (json['event_name'] ?? 'Untitled').toString(),
      data: (json['data'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      date: _parseDate(json['date']),
      venue: (json['venue'] ?? '').toString(),
      imageUrl: AppConfig.resolveImageUrl(json['image_url']?.toString()),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// "Sep 19, 2025", or empty when the backend sent no date.
  String get formattedDate {
    final d = date;
    if (d == null) return '';
    return DateFormat('MMM dd, yyyy').format(d);
  }

  /// "5:05 PM" from the backend's "HH:MM:SS".
  String get formattedTime {
    if (time.isEmpty) return '';
    try {
      final parsed = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('h:mm a').format(parsed);
    } catch (_) {
      return time;
    }
  }

  /// Full image URL, or empty when there is no usable image. Legacy
  /// `/uploads/...` paths no longer resolve and are treated as missing.
  String get fullImageUrl => imageUrl ?? '';
}
