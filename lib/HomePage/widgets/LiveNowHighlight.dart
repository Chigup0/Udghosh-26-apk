import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../SchedulePage/models/LiveMatchModel.dart';
import '../../api.dart';
import '../../utils.dart';
import 'LiveNowHighlightCard.dart';

class LiveNowHighLight extends StatefulWidget {
  const LiveNowHighLight({super.key});

  @override
  State<LiveNowHighLight> createState() => _LiveNowHighLightState();
}

class _LiveNowHighLightState extends State<LiveNowHighLight> {
  String? chipSportValue;
  bool _isLoading = false;
  final List<dynamic> _matches = [];
  final Map<String, int> _liveMatchesLength = {};
  final List<Map<String, dynamic>> _availableSports = [];
  PageController _pageController = PageController(viewportFraction: 1);
  int _currentPage = 0;

  Future<void> onChipTap(String sport) async {
    if (chipSportValue == sport) return;

    setState(() {
      chipSportValue = sport;
      _matches.clear();
    });

    await _fetchMatches(_getSportTableName(sport));
  }

  String _getSportTableName(String sportName) {
    // Convert display name to table name format
    return sportName.toLowerCase().replaceAll(' ', '');
  }

  Future<void> _getLiveMatchesLength() async {
    final String apiUrl = '$apiBaseUrl/getTablesLength';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Clear previous data
        _liveMatchesLength.clear();
        _availableSports.clear();

        // Process API response and map to our sports list
        for (var item in data['data']) {
          String tableName = item[0];
          int count = item[1];

          // Find matching sport from our sports list
          for (var sport in sportsList) {
            String sportTableName = _getSportTableName(sport['name']);
            if (sportTableName == tableName) {
              _liveMatchesLength[sport['name']] = count;
              if (count > 0) {
                _availableSports.add({
                  'name': sport['name'],
                  'icon': sport['icon'],
                  'count': count,
                });
              }
              break;
            }
          }
        }

        // Set initial sport to first available sport with live matches
        if (_availableSports.isNotEmpty) {
          final sortedSports = List<Map<String, dynamic>>.from(_availableSports)
            ..sort(
              (a, b) => a['name'].toString().compareTo(b['name'].toString()),
            );

          // Use state variable directly, no local shadow
          setState(() {
            chipSportValue = sortedSports.first['name'];
          });

          // Fetch matches using state variable
          await _fetchMatches(_getSportTableName(chipSportValue!));
        } else {
          if (kDebugMode) {
            print('Failed to load table lengths: ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching table lengths: $e');
      }
    }
  }

  Future<void> _fetchMatches(String sportTableName) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final String apiUrl =
        '$apiBaseUrl/getLiveMatches'
        '?page=1'
        '&sortBy=time'
        '&order=ASC'
        '&search='
        '&sportTableName=$sportTableName';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _matches.clear();
          _matches.addAll(data['matches'] ?? []);
        });
      } else {
        if (kDebugMode) {
          print('Failed to load matches: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching matches: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLiveMatchesLength();
  }

  @override
  Widget build(BuildContext context) {
    // Show widget only if there are live matches
    if (_availableSports.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSportsChips(),
        const SizedBox(height: 20),
        _buildMatchesList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 40.0, bottom: 20.0),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Live Now",
            style: TextStyle(
              fontFamily: globalFontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: lightTextColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSportsChips() {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     padding: const EdgeInsets.only(left: 20.0),
  //     child: Row(
  //       children: _availableSports.map((sport) {
  //         return Padding(
  //           padding: const EdgeInsets.only(right: 8.0),
  //           child: _buildSportChip(
  //             sport['name'],
  //             sport['icon'],
  //             sport['count'],
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  Widget _buildSportsChips() {
    // Create a sorted copy of the list
    final sortedSports = List<Map<String, dynamic>>.from(_availableSports)
      ..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: sortedSports.map((sport) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildSportChip(
              sport['name'],
              sport['icon'],
              sport['count'],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSportChip(String sportName, IconData icon, int count) {
    bool isActive = chipSportValue == sportName;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? yellowColor : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: isActive ? darkYellowColor : Colors.grey.shade400,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChipTap(sportName),
          splashColor: yellowColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  size: 20.0,
                ),
                const SizedBox(width: 6.0),
                Text(
                  sportName,
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? whiteColor : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.2)
                        : yellowColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No live matches at the moment',
            style: TextStyle(
              fontFamily: globalFontFamily,
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    // Convert matches to model list
    List<LiveNowMatchModel> models = _matches
        .map<LiveNowMatchModel>((json) => LiveNowMatchModel.fromJson(json))
        .toList();

    // Group into pairs (2 matches per page)
    final pages = chunkMatches(models);

    return Column(
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final chunk = pages[index];
              return Column(
                children: [
                  SizedBox(height: 55, child: LiveNowCard(match: chunk[0])),
                  if (chunk.length > 1) ...[
                    const SizedBox(height: 10),
                    SizedBox(height: 55, child: LiveNowCard(match: chunk[1])),
                  ],
                ],
              );
            },
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 10 : 6,
              height: _currentPage == index ? 10 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? yellowColor
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<List<LiveNowMatchModel>> chunkMatches(List<LiveNowMatchModel> matches) {
    List<List<LiveNowMatchModel>> chunks = [];
    for (int i = 0; i < matches.length; i += 2) {
      chunks.add(
        matches.sublist(i, i + 2 > matches.length ? matches.length : i + 2),
      );
    }
    return chunks;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
