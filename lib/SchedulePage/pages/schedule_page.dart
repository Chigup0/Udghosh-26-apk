// ignore_for_file: avoid_print, library_private_types_in_public_api, prefer_const_constructors_in_immutables, unused_local_variable

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:udghosh/api.dart';
import 'package:udghosh/utils.dart';
import 'package:flutter/services.dart';
import '../../widgets/widgets.dart';
import 'LiveMatchesPage.dart';
import 'ResultsMatchesPage.dart';
import 'UpcomingMatchesPage.dart';
import '../widgets/widgets.dart';

class SchedulePage extends StatefulWidget {
  SchedulePage({super.key, this.defaultIndex = -1});
  final int defaultIndex;

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  int currentIndex = 1;
  List<bool> hasMore = [true, true, true];
  List<List<dynamic>> matches = [[], [], []];
  List<String> apiUrls = [];
  List<String> apiUrlsStudent = [
    'getLiveMatches',
    'matches',
    'getCompletedMatches',
  ];
  List<int> pages = [1, 1, 1];
  List<bool> isLoading = [false, false, false];
  List<int> currSport = [0, 0, 0];

  final int _limit = 10;
  String _searchQuery = '';
  double tabPadding = 10;

  Future<void> searchFun(String value) async {
    setState(() {
      _searchQuery = value;
      matches[currentIndex].clear();
      pages[currentIndex] = 1;
      hasMore[currentIndex] = true;
    });
    if (currentIndex == 1) {
      if (currSport[currentIndex] == 0) {
        await _fetchMatches('All');
      } else {
        _fetchMatches(sportsList[currSport[currentIndex] - 1]['name']);
      }
    } else {
      _fetchMatches(sportsList[currSport[currentIndex]]['name']);
    }
  }

  @override
  void initState() {
    super.initState();
    apiUrls = apiUrlsStudent;

    if (widget.defaultIndex != -1) {
      currSport = [
        widget.defaultIndex,
        widget.defaultIndex + 1,
        widget.defaultIndex,
      ];
    } else {
      // Default to "All" for Upcoming tab
      currSport[1] = 0; // 0 will now represent "All"
    }

    _fetchMatches(
      currentIndex == 1 ? 'All' : sportsList[currSport[currentIndex]]['name'],
    );
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  Future<void> onChipTap(int index) async {
    setState(() {
      currSport[currentIndex] = index;
      matches[currentIndex].clear();
      pages[currentIndex] = 1;
      hasMore[currentIndex] = true;
    });

    if (currentIndex == 1) {
      if (index == 0) {
        await _fetchMatches('All');
      } else {
        await _fetchMatches(sportsList[index - 1]['name']);
      }
    } else {
      await _fetchMatches(sportsList[index]['name']);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 40,
                      ),
                      child: pageTitleText('Matches'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: containerDecoration,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              matches[currentIndex].clear();
              pages[currentIndex] = 1;
              hasMore[currentIndex] = true;
            });
            if (currentIndex == 1) {
              if (currSport[currentIndex] == 0) {
                await _fetchMatches('All');
              } else {
                await _fetchMatches(
                  sportsList[currSport[currentIndex] - 1]['name'],
                );
              }
            } else {
              await _fetchMatches(sportsList[currSport[currentIndex]]['name']);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipPath(
                  clipper: OctagonClipper3(padding: 10),
                  child: SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              currentIndex = 0;
                            });
                            if (matches[currentIndex].isEmpty) {
                              _fetchMatches(
                                sportsList[currSport[currentIndex]]['name'],
                              );
                            }
                          },
                          child: AnimatedContainer(
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.all(
                              (currentIndex == 0) ? tabPadding : 8.0,
                            ),
                            duration: const Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: (currentIndex == 0)
                                  ? yellowColor
                                  : Colors.grey.shade300,
                            ),
                            child: customText(
                              "Live Now",
                              (currentIndex == 0) ? 18 : 15,
                              FontWeight.w600,
                              (currentIndex == 0)
                                  ? Colors.white
                                  : const Color.fromARGB(255, 61, 61, 61),
                              1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              currentIndex = 1;
                            });
                            if (matches[currentIndex].isEmpty) {
                              _fetchMatches(
                                sportsList[currSport[currentIndex]]['name'],
                              );
                            }
                          },
                          child: AnimatedContainer(
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.all(
                              (currentIndex == 1) ? tabPadding : 8.0,
                            ),
                            duration: const Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: (currentIndex == 1)
                                  ? yellowColor
                                  : Colors.grey.shade300,
                            ),
                            child: customText(
                              "Upcoming",
                              (currentIndex == 1) ? 18 : 15,
                              FontWeight.w600,
                              (currentIndex == 1)
                                  ? Colors.white
                                  : const Color.fromARGB(255, 61, 61, 61),
                              1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              currentIndex = 2;
                            });
                            if (matches[currentIndex].isEmpty) {
                              _fetchMatches(
                                sportsList[currSport[currentIndex]]['name'],
                              );
                            }
                          },
                          child: AnimatedContainer(
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.all(
                              (currentIndex == 2) ? tabPadding : 8.0,
                            ),
                            duration: const Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: (currentIndex == 2)
                                  ? yellowColor
                                  : Colors.grey.shade300,
                              // borderRadius: BorderRadius.circular(50),
                            ),
                            child: customText(
                              " Results ",
                              (currentIndex == 2) ? 18 : 15,
                              FontWeight.w600,
                              (currentIndex == 2)
                                  ? Colors.white
                                  : const Color.fromARGB(255, 61, 61, 61),
                              1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  bottom: 10,
                  top: 10,
                  right: 10,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (currentIndex == 1) sportChip('All', Icons.sports, 0),
                      ...(sportsList.asMap().entries.map((entry) {
                        int index = entry.key;
                        return sportChip(
                          sportsList[index]['name'],
                          sportsList[index]['icon'],
                          index + ((currentIndex == 1) ? 1 : 0),
                        );
                      }).toList()),
                    ], // Updated to use Icons.sports
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        !isLoading[currentIndex]) {
                      if (currentIndex == 1) {
                        if (currSport[currentIndex] == 0) {
                          _fetchMatches('All');
                        } else {
                          _fetchMatches(
                            sportsList[currSport[currentIndex] - 1]['name'],
                          );
                        }
                      } else {
                        _fetchMatches(
                          sportsList[currSport[currentIndex]]['name'],
                        );
                      }
                    }
                    return false;
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          250, // Adjust based on your layout
                    ),
                    child: currentIndex == 0
                        ? LiveMatchesPage(
                            matches: matches[currentIndex],
                            hasMore: hasMore[currentIndex],
                          )
                        : currentIndex == 1
                        ? UpcomingMatchesPage(
                            matches: matches[currentIndex],
                            hasMore: hasMore[currentIndex],
                          )
                        : MatchResultsPage(
                            matches: matches[currentIndex],
                            hasMore: hasMore[currentIndex],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sportChip(String sport, dynamic icon, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: customChip2(
        sport,
        icon,
        currSport[currentIndex] == index,
        () async {
          await onChipTap(index);
        },
      ),
    );
  }

  Future<void> _fetchMatches(String sportTableName) async {
    print('fetching matches');
    print(sportTableName);
    if (isLoading[currentIndex] || !hasMore[currentIndex]) return;
    setState(() {
      isLoading[currentIndex] = true;
    });
    final String apiUrl =
        '$apiBaseUrl/${apiUrls[currentIndex]}?page=${pages[currentIndex]}&limit=$_limit&sortBy=time&order=ASC&search=$_searchQuery&sportTableName=$sportTableName';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          matches[currentIndex].addAll(data['matches']);
          pages[currentIndex]++;
          if (data['matches'].length < _limit) {
            hasMore[currentIndex] = false;
          }
        });
      } else {
        print('Failed to load matches');
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
    setState(() {
      isLoading[currentIndex] = false;
    });
  }

  Widget search() {
    return ClipPath(
      clipper: OctagonClipper(padding: 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: blueColor),
          color: blueColor,
        ),
        child: ClipPath(
          clipper: OctagonClipper(padding: 10),
          child: Container(
            width: 100,
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (val) async {
                      await searchFun(searchController.text);
                    },
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(6.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: OctagonalIconButton(
                    onTap: () async {
                      await searchFun(searchController.text);
                    },
                    icon: Icons.check_rounded,
                    iconColor: yellowColor,
                    bgColor: yellowColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OctagonalIconButton extends StatelessWidget {
  const OctagonalIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
  final Function() onTap;
  final dynamic icon;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: OctagonClipper(padding: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: bgColor),
            color: bgColor,
          ),
          child: ClipPath(
            clipper: OctagonClipper(padding: 10),
            child: Container(
              // color: Colors.white,
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(10)
                color: Colors.white.withValues(alpha: 0.8),
              ),
              child: Icon(icon, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

class OctagonClipper3 extends CustomClipper<Path> {
  final double padding;
  OctagonClipper3({required this.padding});
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double width = size.width;
    final double height = size.height;

    // const double padding = 20; // Adjust this value to modify the octagon cut

    path.moveTo(0, padding); // Top-left cut
    path.lineTo(padding, 0);
    path.lineTo(width - padding, 0);
    path.lineTo(width, padding);
    path.lineTo(width, height - padding);
    path.lineTo(width - padding, height);
    path.lineTo(padding, height); // Bottom-left cut
    path.lineTo(0, height - padding); // Left-bottom cut

    path.close(); // Close the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
