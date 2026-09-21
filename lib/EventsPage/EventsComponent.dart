import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:udghosh/utils.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/models/event.dart';

class EventsCarouselPortrait extends StatefulWidget {
  @override
  _EventsCarouselPortraitState createState() => _EventsCarouselPortraitState();
}

class _EventsCarouselPortraitState extends State<EventsCarouselPortrait> {
  List<Event> events = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetchedEvents = await ApiService.getUpcomingEvents();
      setState(() {
        events = fetchedEvents;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean section header
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 15.0, bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Upcoming Events",
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: lightTextColor,
                    letterSpacing: 0.3,
                  ),
                ),
                Spacer(),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: TextStyle(
                fontFamily: globalFontFamily,
                color: lightTextColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchEvents,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Text(
          'No upcoming events',
          style: TextStyle(
            fontFamily: globalFontFamily,
            color: lightTextColor.withValues(alpha: 0.6),
            fontSize: 16,
          ),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 260,
        aspectRatio: 1 / 1,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: events.length > 1,
        reverse: false,
        autoPlay: events.length > 1,
        autoPlayInterval: Duration(seconds: 4),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
        scrollDirection: Axis.horizontal,
      ),
      items: events.map((event) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF1E3A8A).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(child: _buildEventImage(event)),

                    // Simple dark gradient overlay
                    // Positioned.fill(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       gradient: LinearGradient(
                    //         begin: Alignment.topCenter,
                    //         end: Alignment.bottomCenter,
                    //         colors: [
                    //           Colors.transparent,
                    //           Color(0xFF0F172A).withValues(alpha: 0.7),
                    //           Color(0xFF0F172A).withValues(alpha: 0.9),
                    //         ],
                    //         stops: [0.0, 0.6, 1.0],
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // Content
                    // Positioned(
                    //   bottom: 20,
                    //   left: 20,
                    //   right: 20,
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       // Event name
                    //       Text(
                    //         event.eventName,
                    //         style: TextStyle(
                    //           fontFamily: globalFontFamily,
                    //           color: Colors.white,
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.w600,
                    //           height: 1.2,
                    //         ),
                    //         maxLines: 2,
                    //         overflow: TextOverflow.ellipsis,
                    //       ),

                    //       SizedBox(height: 12),

                    //       // Event details container
                    //       Container(
                    //         padding: EdgeInsets.symmetric(
                    //           horizontal: 14,
                    //           vertical: 10,
                    //         ),
                    //         decoration: BoxDecoration(
                    //           color: Color(0xFF1E3A8A).withValues(alpha: 0.15),
                    //           borderRadius: BorderRadius.circular(12),
                    //           border: Border.all(
                    //             color: Color(0xFF1E3A8A).withValues(alpha: 0.3),
                    //             width: 1,
                    //           ),
                    //         ),
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             // Time and Date
                    //             Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.schedule_outlined,
                    //                   color: Color(0xFF3B82F6),
                    //                   size: 16,
                    //                 ),
                    //                 SizedBox(width: 8),
                    //                 Text(
                    //                   event.formattedTime,
                    //                   style: TextStyle(
                    //                     color: Colors.white,
                    //                     fontSize: 13,
                    //                     fontWeight: FontWeight.w500,
                    //                     fontFamily: globalFontFamily,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),

                    //             SizedBox(height: 6),

                    //             Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.calendar_today_outlined,
                    //                   color: Color(0xFF3B82F6),
                    //                   size: 16,
                    //                 ),
                    //                 SizedBox(width: 8),
                    //                 Text(
                    //                   event.formattedDate,
                    //                   style: TextStyle(
                    //                     color: Colors.white,
                    //                     fontSize: 13,
                    //                     fontWeight: FontWeight.w500,
                    //                     fontFamily: globalFontFamily,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),

                    //             SizedBox(height: 6),

                    //             // Venue
                    //             Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.location_on_outlined,
                    //                   color: Color(0xFF3B82F6),
                    //                   size: 16,
                    //                 ),
                    //                 SizedBox(width: 8),
                    //                 Expanded(
                    //                   child: Text(
                    //                     event.venue,
                    //                     style: TextStyle(
                    //                       color: Colors.white.withValues(alpha: 0.9),
                    //                       fontSize: 13,
                    //                       fontWeight: FontWeight.w400,
                    //                       fontFamily: globalFontFamily,
                    //                     ),
                    //                     maxLines: 1,
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEventImage(Event event) {
    if (event.imageUrl == null || event.imageUrl!.isEmpty) {
      return Image.asset(
        'assets/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Color(0xFF1E3A8A).withValues(alpha: 0.1),
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                color: Color(0xFF1E3A8A).withValues(alpha: 0.5),
                size: 48,
              ),
            ),
          );
        },
      );
    }

    print("Loading event image: ${event.fullImageUrl}");

    return CachedNetworkImage(
      imageUrl: event.fullImageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Color(0xFF1E3A8A).withValues(alpha: 0.1),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Color(0xFF1E3A8A).withValues(alpha: 0.1),
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                color: Color(0xFF1E3A8A).withValues(alpha: 0.5),
                size: 48,
              ),
            ),
          );
        },
      ),
    );
  }
}
