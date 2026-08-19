import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udghosh/api.dart';
import 'package:udghosh/models/event.dart'; // make sure Event is imported

class ApiService {
  // Generic GET request handler
  static Future<List<Event>> _fetchEvents(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load $endpoint');
      }
    } catch (e) {
      throw Exception('Error fetching $endpoint: $e');
    }
  }

  static Future<List<Event>> getUpcomingEvents() async {
    return _fetchEvents('upcoming-events');
  }

  static Future<List<Event>> getInformalSports() async {
    return _fetchEvents('informal-sports');
  }
}
