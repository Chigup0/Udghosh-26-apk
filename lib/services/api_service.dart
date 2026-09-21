import 'dart:async';
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
  ApiException(this.statusCode, this.message, [ApiFailure? failure])
    : failure = failure ?? _classify(statusCode);

  final int statusCode;
  final String message;

  /// Coarse reason, used to pick a state illustration.
  final ApiFailure failure;

  static ApiFailure _classify(int code) {
    if (code == 0) return ApiFailure.offline;
    if (code >= 500) return ApiFailure.server;
    if (code >= 400) return ApiFailure.request;
    return ApiFailure.unknown;
  }

  bool get isOffline => failure == ApiFailure.offline;
  bool get isServerDown => failure == ApiFailure.server;

  /// Whether retrying unchanged could plausibly succeed.
  bool get isRetryable =>
      failure == ApiFailure.offline ||
      failure == ApiFailure.timeout ||
      failure == ApiFailure.server;

  @override
  String toString() => message;
}

/// Why a request failed, so screens can tell "you are offline" apart from
/// "the server is down" apart from "that is genuinely empty".
enum ApiFailure {
  /// No connection — the request never left the device.
  offline,

  /// Connected, but nothing answered in time.
  timeout,

  /// Reached the server and it returned 5xx.
  server,

  /// A 4xx the caller is expected to handle (404 / 429 / 401 / 400).
  request,

  /// Anything else, including an unparseable response.
  unknown,
}

/// One page of a list endpoint.
///
/// The backend never returns a total count — the documented rule is "keep
/// loading pages until the page is shorter than `limit`", which [hasMore]
/// encodes so callers don't re-derive it (and don't hardcode `10`).
class Paged<T> {
  const Paged({required this.items, required this.page, required this.limit});

  final List<T> items;
  final int page;
  final int limit;

  bool get hasMore => items.length >= limit;
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 12);

  static Uri _uri(String path, [Map<String, String?>? query]) {
    final base = Uri.parse(AppConfig.baseUrl);
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.isNotEmpty) params[key] = value;
    });
    return base.replace(
      path: '${base.path}/$path',
      queryParameters: params.isEmpty ? null : params,
    );
  }

  static Future<dynamic> _get(String path, [Map<String, String?>? query]) {
    return _send(
      () => http
          .get(_uri(path, query), headers: AppConfig.jsonHeaders)
          .timeout(_timeout),
    );
  }

  static Future<dynamic> _post(String path, Map<String, dynamic> body) {
    return _send(
      () => http
          .post(
            _uri(path),
            headers: AppConfig.jsonHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout),
    );
  }

  /// Runs a request and normalises transport failures into [ApiException].
  ///
  /// `http` reports a dead radio, a DNS failure and a refused connection all as
  /// `ClientException` on every platform, so this needs no `dart:io` import and
  /// still compiles for web.
  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      return _decode(await request());
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        0,
        'The server took too long to respond.',
        ApiFailure.timeout,
      );
    } on http.ClientException {
      throw ApiException(0, 'No internet connection.', ApiFailure.offline);
    } catch (_) {
      throw ApiException(0, 'Could not reach the server.', ApiFailure.unknown);
    }
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
      // Non-JSON error body (e.g. an HTML error page) — keep the generic
      // message rather than surfacing markup to the user.
    }
    throw ApiException(response.statusCode, message);
  }

  // ---------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------

  static Future<void> requestOtp(String email) async {
    await _post('auth/requestotp', {'email': email});
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    final data = await _post('auth/verifyotp', {'email': email, 'otp': otp});
    return (data as Map).cast<String, dynamic>();
  }

  // ---------------------------------------------------------------------
  // Matches
  // ---------------------------------------------------------------------

  static Future<Paged<MatchRecord>> getLiveMatches(
    String sport, {
    String? search,
    int page = 1,
    int limit = AppConfig.defaultPageSize,
  }) async {
    final data = await _get('getLiveMatches', {
      'sportTableName': sport,
      'search': search,
      'page': '$page',
      'limit': '$limit',
    });
    return _pageOf(sport, data, page, limit);
  }

  /// Upcoming matches. [sport] may be [AppConfig.allSports] to fetch the whole
  /// schedule — this is the only match endpoint that accepts `all`.
  static Future<Paged<MatchRecord>> getUpcomingMatches(
    String sport, {
    String? search,
    int page = 1,
    int limit = AppConfig.defaultPageSize,
  }) async {
    final data = await _get('matches', {
      'sportTableName': sport,
      'search': search,
      'page': '$page',
      'limit': '$limit',
    });
    return _pageOf(sport, data, page, limit);
  }

  static Future<Paged<MatchRecord>> getCompletedMatches(
    String sport, {
    String order = 'DESC',
    String? search,
    int page = 1,
    int limit = AppConfig.defaultPageSize,
  }) async {
    final data = await _get('getCompletedMatches', {
      'sportTableName': sport,
      'order': order,
      'search': search,
      'page': '$page',
      'limit': '$limit',
    });
    return _pageOf(sport, data, page, limit);
  }

  static Paged<MatchRecord> _pageOf(
    String sport,
    dynamic data,
    int page,
    int limit,
  ) {
    List<dynamic> raw;
    if (data is Map && data['matches'] is List) {
      raw = data['matches'] as List;
    } else if (data is List) {
      raw = data;
    } else {
      raw = const [];
    }
    // Trust the server's echoed limit when present, so `hasMore` compares
    // against the limit the server actually applied.
    final effectiveLimit = (data is Map)
        ? int.tryParse('${data['limit']}') ?? limit
        : limit;

    // `/matches` always uses team1/team2 even for player sports, while the
    // live/completed feeds use player1/player2 — MatchRecord handles both.
    final items = raw
        .whereType<Map>()
        .map((m) => MatchRecord.fromJson(sport, m.cast<String, dynamic>()))
        .toList();
    return Paged(items: items, page: page, limit: effectiveLimit);
  }

  /// Live match count per sport, e.g. `{"cricket": 2, "basketball": 1}`.
  ///
  /// The endpoint answers `{"success": true, "data": [["cricket", 2], ...]}`,
  /// so the pair array has to be unwrapped from `data` before it can be read.
  /// Bare-list and bare-map shapes are still accepted in case a deployment
  /// differs. Sports with zero live matches are omitted.
  static Future<Map<String, int>> getTablesLength() async {
    final response = await _get('getTablesLength');
    final payload = (response is Map && response['data'] != null)
        ? response['data']
        : response;

    final result = <String, int>{};

    void put(Object? sport, Object? count) {
      final parsed = int.tryParse('$count');
      if (parsed == null || parsed <= 0) return;
      result[AppConfig.normalizeSport('$sport')] = parsed;
    }

    if (payload is List) {
      // Documented shape: [["cricket", 2], ["volleyball", 0]]
      for (final entry in payload) {
        if (entry is List && entry.length >= 2) {
          put(entry[0], entry[1]);
        } else if (entry is Map) {
          put(
            entry['sport'] ?? entry['name'],
            entry['count'] ?? entry['length'],
          );
        }
      }
    } else if (payload is Map) {
      // Fallback shape: {"cricket": 2, "volleyball": 0}
      payload.forEach(put);
    }
    return result;
  }

  // ---------------------------------------------------------------------
  // Notices
  // ---------------------------------------------------------------------

  static Future<List<Notice>> getNotices() async {
    final data = await _get('notices');
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((j) => Notice.fromJson(j.cast<String, dynamic>()))
        .toList();
  }

  /// Single notice — the detail endpoint wraps it as `{notice: {...}}`.
  static Future<Notice> getNotice(int id) async {
    final data = await _get('notices/$id');
    final raw = (data is Map && data['notice'] is Map) ? data['notice'] : data;
    return Notice.fromJson((raw as Map).cast<String, dynamic>());
  }

  // ---------------------------------------------------------------------
  // Gallery
  // ---------------------------------------------------------------------

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

  // ---------------------------------------------------------------------
  // Events / Informal sports (identical payload shape, different feeds)
  // ---------------------------------------------------------------------

  static Future<List<Event>> getUpcomingEvents() =>
      _fetchEvents('upcoming-events');

  static Future<Event> getUpcomingEvent(int id) =>
      _fetchEvent('upcoming-events/$id');

  static Future<List<Event>> getInformalSports() =>
      _fetchEvents('informal-sports');

  static Future<Event> getInformalSport(int id) =>
      _fetchEvent('informal-sports/$id');

  static Future<List<Event>> _fetchEvents(String endpoint) async {
    final data = await _get(endpoint);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((j) => Event.fromJson(j.cast<String, dynamic>()))
        .toList();
  }

  static Future<Event> _fetchEvent(String endpoint) async {
    final data = await _get(endpoint);
    final raw = (data is Map && data['event'] is Map) ? data['event'] : data;
    return Event.fromJson((raw as Map).cast<String, dynamic>());
  }
}
