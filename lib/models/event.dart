import 'package:intl/intl.dart';
import 'package:udghosh/api.dart';

class Event {
  final int id;
  final String eventName;
  final String data;
  final String time;
  final DateTime date;
  final String venue;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.eventName,
    required this.data,
    required this.time,
    required this.date,
    required this.venue,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['event_name'],
      data: json['data'] ?? '',
      time: json['time'],
      date: DateTime.parse(json['date']),
      venue: json['venue'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Format the date as "Sep 19, 2025"
  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format the time as "5:05 PM"
  String get formattedTime {
    // Parse time string with seconds
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Full URL for the image
  String get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    if (imageUrl!.startsWith('http')) return imageUrl!;
    return '$apiImgUrl$imageUrl'; // Replace with your base URL
  }
}
