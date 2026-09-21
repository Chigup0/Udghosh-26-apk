import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:udghosh/models/event.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

/// Which feed an event came from — decides which detail endpoint to re-fetch.
enum EventFeed { upcomingEvent, informalSport }

/// Detail view for one event or informal sport.
///
/// The list payload already carries every field, so the passed-in [initial]
/// renders immediately and the `/:id` fetch refreshes it in the background —
/// the screen is useful offline and never shows a blocking spinner.
class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.initial,
    required this.feed,
  });

  final Event initial;
  final EventFeed feed;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event = widget.initial;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (_event.id <= 0) return; // demo/placeholder rows have no server id
    try {
      final fresh = widget.feed == EventFeed.upcomingEvent
          ? await ApiService.getUpcomingEvent(_event.id)
          : await ApiService.getInformalSport(_event.id);
      if (mounted) setState(() => _event = fresh);
    } on ApiException catch (e) {
      // 404 here means the event was pulled after the list was fetched.
      if (mounted) {
        setState(
          () => _error = e.statusCode == 404
              ? 'This event is no longer listed'
              : e.message,
        );
      }
    } catch (_) {
      // Offline: keep showing the list payload, say nothing.
    }
  }

  Widget _metaRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: NeoColors.waveTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: NeoColors.logoTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _event.fullImageUrl;
    final when = [
      _event.formattedDate,
      _event.formattedTime,
    ].where((s) => s.isNotEmpty).join('  //  ');

    return Scaffold(
      backgroundColor: NeoColors.canvasMint,
      appBar: AppBar(
        backgroundColor: NeoColors.canvasMint,
        iconTheme: IconThemeData(color: NeoColors.logoTeal),
        title: Text(
          widget.feed == EventFeed.upcomingEvent ? 'Event' : 'Informal Sport',
          style: TextStyle(
            color: NeoColors.logoTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: NeoColors.waveTeal,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(NeoRadii.cardLarge),
                child: CachedNetworkImage(
                  imageUrl: image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: NeoColors.surfaceRecessed,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: NeoColors.textMuted,
                    ),
                  ),
                ),
              ),
            if (image.isNotEmpty) const SizedBox(height: 16),
            Text(
              _event.eventName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: NeoColors.logoTeal,
              ),
            ),
            const SizedBox(height: 14),
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (when.isNotEmpty) _metaRow(Icons.schedule_rounded, when),
                  if (_event.venue.isNotEmpty)
                    _metaRow(Icons.place_rounded, _event.venue),
                  if (when.isEmpty && _event.venue.isEmpty)
                    _metaRow(
                      Icons.info_outline_rounded,
                      'Details to be announced',
                    ),
                ],
              ),
            ),
            if (_event.data.isNotEmpty) ...[
              const SizedBox(height: 16),
              NeoCard(
                child: Text(
                  _event.data,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: NeoColors.textMuted,
                  ),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: NeoColors.alert, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
