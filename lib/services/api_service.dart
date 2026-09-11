import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/models/event.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/models/gallery_item.dart';
import 'package:udghosh/NoticePage/model/Notice.dart';

/// Thin exception carrying the HTTP status code so callers (and the login
/// screen especially) can branch on 400 / 401 / 404 / 429 without re-parsing
/// the response body.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 12);

  static Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(AppConfig.baseUrl);
    return base.replace(
      path: '${base.path}/$path',
      queryParameters: query,
    );
  }

  static Future<dynamic> _get(String path, [Map<String, String>? query]) async {
    final response = await http
        .get(_uri(path, query), headers: AppConfig.jsonHeaders)
        .timeout(_timeout);
    return _decode(response);
  }

  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(
          _uri(path),
          headers: AppConfig.jsonHeaders,
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _decode(response);
  }

  static dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    String message = 'Request failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) {
        message = body['error'].toString();
      } else if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {
      // Non-JSON error body — keep the generic message.
    }
    throw ApiException(response.statusCode, message);
  }

  // ---------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------

  static Future<void> requestOtp(String email) async {
    await _post('auth/requestotp', {'email': email});
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final data = await _post('auth/verifyotp', {'email': email, 'otp': otp});
    return (data as Map).cast<String, dynamic>();
  }

  // ---------------------------------------------------------------------
  // Matches
  // ---------------------------------------------------------------------

  static Future<List<MatchRecord>> getLiveMatches(String sport) async {
    final data = await _get('getLiveMatches', {'sportTableName': sport});
    return _extractMatches(sport, data);
  }

  static Future<List<MatchRecord>> getUpcomingMatches(
    String sport, {
    int page = 1,
    int limit = 10,
  }) async {
    final data = await _get('matches', {
      'sportTableName': sport,
      'page': '$page',
      'limit': '$limit',
    });
    return _extractMatches(sport, data);
  }

  static Future<List<MatchRecord>> getCompletedMatches(
    String sport, {
    String order = 'DESC',
  }) async {
    final data = await _get('getCompletedMatches', {
      'sportTableName': sport,
      'order': order,
    });
    return _extractMatches(sport, data);
  }

  static List<MatchRecord> _extractMatches(String sport, dynamic data) {
    List<dynamic> raw;
    if (data is Map && data['matches'] is List) {
      raw = data['matches'] as List;
    } else if (data is List) {
      raw = data;
    } else {
      raw = const [];
    }
    return raw
        .whereType<Map>()
        .map((m) => MatchRecord.fromJson(sport, m.cast<String, dynamic>()))
        .toList();
  }

  /// e.g. `{"cricket": 2, "football": 1}` — sports with active live matches.
  static Future<Map<String, int>> getTablesLength() async {
    final data = await _get('getTablesLength');
    final result = <String, int>{};
    if (data is Map) {
      data.forEach((key, value) {
        final count = int.tryParse('$value');
        if (count != null && count > 0) result[key.toString()] = count;
      });
    } else if (data is List) {
      // Some deployments return [["cricket", 2], ...]
      for (final entry in data) {
        if (entry is List && entry.length >= 2) {
          final count = int.tryParse('${entry[1]}');
          if (count != null && count > 0) result[entry[0].toString()] = count;
        }
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------
  // Notices / Events / Gallery
  // ---------------------------------------------------------------------

  static Future<List<Notice>> getNotices() async {
    final data = await _get('notices');
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((j) => Notice.fromJson(j.cast<String, dynamic>()))
        .toList();
  }

  static Future<List<GalleryItem>> getGallery() async {
    final data = await _get('gallery');
    List<dynamic> raw;
    if (data is Map && data['images'] is List) {
      raw = data['images'] as List;
    } else if (data is List) {
      raw = data;
    } else {
      raw = const [];
    }
    return raw
        .whereType<Map>()
        .map((j) => GalleryItem.fromJson(j.cast<String, dynamic>()))
        .whereType<GalleryItem>()
        .toList();
  }

  static Future<List<Event>> getUpcomingEvents() => _fetchEvents('upcoming-events');

  static Future<List<Event>> getInformalSports() => _fetchEvents('informal-sports');

  static Future<List<Event>> _fetchEvents(String endpoint) async {
    final data = await _get(endpoint);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((j) => Event.fromJson(j.cast<String, dynamic>()))
        .toList();
  }
}
