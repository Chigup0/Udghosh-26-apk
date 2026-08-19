import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udghosh/DashBoard/pages/dashboard.dart';
import 'package:udghosh/SchedulePage/models/LiveMatchModel.dart';
import 'package:udghosh/SchedulePage/widgets/ScoreUi.dart';
import 'package:udghosh/utils.dart';
import 'package:udghosh/widgets/widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:udghosh/api.dart';
import 'package:http/http.dart' as http;

class LivePage extends StatefulWidget {
  const LivePage({super.key, required this.match});
  final LiveNowMatchModel match;

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  bool isAdminLoggedIn = false;
  YoutubePlayerController? _controller;
  String videoID = "";
  String _selectedQuality = 'hd720';
  bool isVideoAvailable = false;
  bool hasVideoError = false;
  String videoErrorMessage = '';

  // Match scores - using late to initialize in initState
  late String set1Score1, set1Score2, set2Score1, set2Score2;
  late String set3Score1, set3Score2, set4Score1, set4Score2;
  late String set5Score1, set5Score2;
  late String team1Goals, team2Goals;
  late String team1Score, team2Score;
  late String team1_score, team1_wickets, team2_score, team2_wickets;
  late String team1_overs, team2_overs;
  late String active;

  final Map<String, String> _qualityOptions = {
    '360p': 'small',
    '480p': 'medium',
    '720p': 'hd720',
    '1080p': 'hd1080',
    '1440p': 'hd1440',
    '2160p': 'highres',
  };

  @override
  void initState() {
    super.initState();
    _initializeScores();
    _initializeYouTubePlayer();
    _checkLogin();
  }

  void _initializeScores() {
    set1Score1 = widget.match.set1Score1;
    set1Score2 = widget.match.set1Score2;
    set2Score1 = widget.match.set2Score1;
    set2Score2 = widget.match.set2Score2;
    set3Score1 = widget.match.set3Score1;
    set3Score2 = widget.match.set3Score2;
    set4Score1 = widget.match.set4Score1;
    set4Score2 = widget.match.set4Score2;
    set5Score1 = widget.match.set5Score1;
    set5Score2 = widget.match.set5Score2;
    team1Goals = widget.match.team1Goals;
    team2Goals = widget.match.team2Goals;
    team1Score = widget.match.team1Score;
    team2Score = widget.match.team2Score;
    team1_score = widget.match.team1_score ?? '0';
    team1_wickets = widget.match.team1_wickets ?? '0';
    team2_score = widget.match.team2_score ?? '0';
    team2_wickets = widget.match.team2_wickets ?? '0';
    team1_overs = widget.match.team1_overs;
    team2_overs = widget.match.team2_overs;
    active = widget.match.active ?? '1';
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final adminSport =
        prefs.getString('adminSport') ?? ''; // e.g., "basketball"

    if (mounted && token.isNotEmpty && adminSport.isNotEmpty) {
      // Only allow admin if the adminSport matches the current match sport
      final matchSport = widget.match.sport?.replaceAll(' ', '').toLowerCase();
      if (matchSport == adminSport.toLowerCase() || adminSport == 'events') {
        setState(() {
          isAdminLoggedIn = true;
        });
      }
    }
  }

  void _initializeYouTubePlayer() {
    try {
      final url = widget.match.liveStreamUrl?.trim() ?? '';

      if (url.isEmpty) {
        setState(() {
          isVideoAvailable = false;
          hasVideoError = false;
        });
        return;
      }

      final extractedVideoId = YoutubePlayer.convertUrlToId(url);

      if (extractedVideoId == null || extractedVideoId.isEmpty) {
        setState(() {
          isVideoAvailable = false;
          hasVideoError = true;
          videoErrorMessage = 'Invalid YouTube URL';
        });
        return;
      }

      videoID = extractedVideoId;

      _controller = YoutubePlayerController(
        initialVideoId: videoID,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          isLive: true,
          forceHD: false,
          enableCaption: false,
        ),
      );

      _controller!.addListener(_onPlayerStateChange);

      setState(() {
        isVideoAvailable = true;
        hasVideoError = false;
      });
    } catch (e) {
      debugPrint('Error initializing YouTube player: $e');
      setState(() {
        isVideoAvailable = false;
        hasVideoError = true;
        videoErrorMessage = 'Failed to load video';
      });
    }
  }

  void _onPlayerStateChange() {
    if (_controller == null) return;

    try {
      final state = _controller!.value.playerState;
      if (state == PlayerState.unknown && mounted) {
        setState(() {
          hasVideoError = true;
          videoErrorMessage = 'Video player error';
        });
      }
    } catch (e) {
      debugPrint('Error in player state change: $e');
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerStateChange);
    _controller?.dispose();
    super.dispose();
  }

  void _changeVideoQuality(String quality) {
    if (_controller == null || videoID.isEmpty) return;

    try {
      setState(() => _selectedQuality = quality);
      _controller!.load(videoID);
    } catch (e) {
      debugPrint('Error changing video quality: $e');
      if (mounted) {
        setState(() {
          hasVideoError = true;
          videoErrorMessage = 'Failed to change quality';
        });
      }
    }
  }

  Widget _buildVideoSection() {
    if (hasVideoError) {
      return _buildErrorWidget();
    }

    if (!isVideoAvailable || _controller == null) {
      return _buildNoVideoWidget();
    }

    return Column(
      children: [
        YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          onReady: () => debugPrint('Player ready'),
          onEnded: (_) => debugPrint('Video ended'),
        ),
        _buildQualitySelector(),
      ],
    );
  }

  Widget _buildQualitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<String>(
            value: _selectedQuality,
            items: _qualityOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.value,
                child: Text(
                  style: TextStyle(fontFamily: globalFontFamily),
                  entry.key,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) _changeVideoQuality(value);
            },
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      color: Colors.red.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'Video Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade700,
                fontFamily: globalFontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                videoErrorMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade600,
                  fontFamily: globalFontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasVideoError = false;
                  videoErrorMessage = '';
                });
                _initializeYouTubePlayer();
              },
              child: Text(
                style: TextStyle(fontFamily: globalFontFamily),
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoVideoWidget() {
    return Container(
      height: 200,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              color: Colors.grey.shade500,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              widget.match.status == 'live'
                  ? 'No Live Stream Available'
                  : 'No Video Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
                fontFamily: globalFontFamily,
              ),
            ),
            if (widget.match.liveStreamUrl?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Check your internet connection',
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _initializeYouTubePlayer();
                },
                child: Text(
                  style: TextStyle(fontFamily: globalFontFamily),
                  'Retry',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateScore(
    String columnName,
    String newValue, {
    bool winner = false,
  }) async {
    if (!isAdminLoggedIn) return; // <-- block if not allowed
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) return;

      String sport = widget.match.sport!.replaceAll(' ', '').toLowerCase();
      String matchId = widget.match.matchId.toString();

      final response = await http.post(
        Uri.parse('$apiBaseUrl/changeValue'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tableName': sport,
          'rowId': matchId,
          'columnName': columnName,
          'newValue': newValue,
          'winner': winner,
        }),
      );
    } catch (e) {
      debugPrint('Error updating score: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(isAdminLoggedIn);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: TextStyle(fontFamily: globalFontFamily),
          'Live Match',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVideoSection(),
            const Divider(),
            _buildScoreSection(),
            if (isAdminLoggedIn) _buildAdminControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    // Build score display based on sport type
    final match = widget.match;

    String team1 = match.team1!.toUpperCase();
    String team2 = match.team2!.toUpperCase();

    switch (match.sport?.toLowerCase()) {
      case 'badminton':
      case 'taekwondo':
      case 'chess':
      case 'squash':
        team1 = match.player1!.toUpperCase();
        team2 = match.player2!.toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTeamInfo(team1, isTeam1: true),
          _buildScoreDisplay(),
          _buildTeamInfo(team2, isTeam1: false),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String teamName, {required bool isTeam1}) {
    return Column(
      children: [
        // Add team logo here
        TeamLogo(teamName: teamName, size: 50),
        const SizedBox(height: 8),
        Text(
          teamName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: globalFontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    return liveMatchScore(
      widget.match,
      compact: false,
      onSetChanged: (newSet) {
        setState(() {
          active = newSet;
          widget.match.active = newSet;
        });
        _updateScore("active", newSet);
      },
    );
  }

  Widget _buildAdminControls() {
    final match = widget.match;
    final sportWidget = _sportSpecificAdmin(match);

    return Column(
      children: [sportWidget, const Divider(), _buildActiveToggle(match)],
    );
  }

  Widget _sportSpecificAdmin(match) {
    final match = widget.match;

    switch (match.sport?.toLowerCase()) {
      case 'basketball':
        return _basketballAdmin(match);
      case 'cricket':
        return _cricketAdmin(match);
      case 'football':
      case 'hockey':
        return _goalGameAdmin(match);
      case 'volleyball':
      case 'tabletennis':
      case 'lawntennis':
      case 'badminton':
      case 'squash':
        return _setSportAdmin(match);
      case 'kabaddi':
      case 'khokho':
      case 'ultimatefrisbee':
        return _pointsGameAdmin(match);
      case 'taekwondo':
        return _taekwondoAdmin(match);
      case 'athletics':
      case 'aquatics':
        return _individualAdmin(match);
      case 'chess':
        return _chessAdmin(match);
      case 'weightlifting':
      case 'powerlifting':
        return _liftingAdmin(match);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _basketballAdmin(LiveNowMatchModel match) {
    return Column(
      children: [
        _scoreInput("Team 1 Score", match.team1Score, (val) {
          _updateScore("team1_score", val);
        }),
        _scoreInput("Team 2 Score", match.team2Score, (val) {
          _updateScore("team2_score", val);
        }),
      ],
    );
  }

  Widget _cricketAdmin(LiveNowMatchModel match) {
    String currentBattingTeam = match.active ?? '1';
    
    List<DropdownMenuItem<String>> battingTeamItems = [
      DropdownMenuItem<String>(
        value: '1',
        child: Text(match.team1 ?? 'Team 1'),
      ),
      DropdownMenuItem<String>(
        value: '2',
        child: Text(match.team2 ?? 'Team 2'),
      ),
    ];

    return Column(
      children: [
        // Batting team selector
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Batting Team:',
                  style: TextStyle(
                    fontFamily: globalFontFamily, 
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: DropdownButton<String>(
                  value: battingTeamItems.any((item) => item.value == currentBattingTeam)
                      ? currentBattingTeam
                      : '1',
                  items: battingTeamItems,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        active = newValue;
                        widget.match.active = newValue;
                      });
                      _updateScore("active", newValue);
                    }
                  },
                  isExpanded: true,
                  hint: Text(
                    'Select Batting Team',
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        
        // Team 1 scores
        Text(
          match.team1 ?? 'Team 1',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: globalFontFamily,
          ),
        ),
        _scoreInput("Team 1 Runs", match.team1_score!, (val) {
          _updateScore("team1_score", val);
        }),
        _scoreInput("Team 1 Wickets", match.team1_wickets!, (val) {
          _updateScore("team1_wickets", val);
        }),
        _scoreInput("Team 1 Overs", match.team1_overs, (val) {
          _updateScore("team1_overs", val);
        }),
        const Divider(),
        
        // Team 2 scores
        Text(
          match.team2 ?? 'Team 2',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: globalFontFamily,
          ),
        ),
        _scoreInput("Team 2 Runs", match.team2_score!, (val) {
          _updateScore("team2_score", val);
        }),
        _scoreInput("Team 2 Wickets", match.team2_wickets!, (val) {
          _updateScore("team2_wickets", val);
        }),
        _scoreInput("Team 2 Overs", match.team2_overs, (val) {
          _updateScore("team2_overs", val);
        }),
      ],
    );
  }

  Widget _goalGameAdmin(LiveNowMatchModel match) {
    return Column(
      children: [
        _scoreInput("Team 1 Goals", match.team1Goals, (val) {
          _updateScore("team1_goals", val);
        }),
        _scoreInput("Team 2 Goals", match.team2Goals, (val) {
          _updateScore("team2_goals", val);
        }),
      ],
    );
  }

  Widget _setSportAdmin(LiveNowMatchModel match) {
    return Column(
      children: [
        // Set selection chips
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Set:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: globalFontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  String setNumber = (index + 1).toString();
                  bool isActive = setNumber == (match.active ?? '1');

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        active = setNumber;
                        widget.match.active = setNumber;
                      });
                      _updateScore("active", setNumber);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.red.shade400
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? Colors.red.shade600
                              : Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Set $setNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.grey.shade700,
                          fontFamily: globalFontFamily,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const Divider(),
        // Score inputs for all sets
        for (int i = 1; i <= 5; i++) ...[
          _scoreInput("Set $i - Player 1", _getSetScore(match, i, true), (val) {
            _updateScore("set${i}_score1", val);
          }),
          _scoreInput("Set $i - Player 2", _getSetScore(match, i, false), (
            val,
          ) {
            _updateScore("set${i}_score2", val);
          }),
          const Divider(),
        ],
      ],
    );
  }

  String _getSetScore(LiveNowMatchModel match, int set, bool team1) {
    switch (set) {
      case 1:
        return team1 ? match.set1Score1 : match.set1Score2;
      case 2:
        return team1 ? match.set2Score1 : match.set2Score2;
      case 3:
        return team1 ? match.set3Score1 : match.set3Score2;
      case 4:
        return team1 ? match.set4Score1 : match.set4Score2;
      case 5:
        return team1 ? match.set5Score1 : match.set5Score2;
      default:
        return "0";
    }
  }

  Widget _pointsGameAdmin(LiveNowMatchModel match) {
    return Column(
      children: [
        _scoreInput("Team 1 Points", match.team1Points, (val) {
          _updateScore("team1_points", val);
        }),
        _scoreInput("Team 2 Points", match.team2Points, (val) {
          _updateScore("team2_points", val);
        }),
      ],
    );
  }

  Widget _taekwondoAdmin(LiveNowMatchModel match) {
    return Column(
      children: [
        _scoreInput("Player 1 Points", match.player1Points, (val) {
          _updateScore("player1_points", val);
        }),
        _scoreInput("Player 2 Points", match.player2Points, (val) {
          _updateScore("player2_points", val);
        }),
      ],
    );
  }

  Widget _individualAdmin(LiveNowMatchModel match) {
    return _scoreInput("Result", match.athleteResult, (val) {
      _updateScore("result", val);
    });
  }

  Widget _chessAdmin(LiveNowMatchModel match) {
    String currentWinner = match.winner?.toString() ?? '';

    List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem<String>(value: '', child: Text('Select Winner')),
      DropdownMenuItem<String>(
        value: '1',
        child: Text(match.player1 ?? 'Player 1'),
      ),
      DropdownMenuItem<String>(
        value: '2',
        child: Text(match.player2 ?? 'Player 2'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Winner:',
              style: TextStyle(fontFamily: globalFontFamily, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 150,
            child: DropdownButton<String>(
              value: dropdownItems.any((item) => item.value == currentWinner)
                  ? currentWinner
                  : '',
              items: dropdownItems,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateScore("winner", newValue);
                  setState(() {
                    match.winner = newValue.isEmpty
                        ? null
                        : int.parse(newValue);
                  });
                }
              },
              isExpanded: true,
              hint: Text(
                'Select Winner',
                style: TextStyle(fontFamily: globalFontFamily, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liftingAdmin(LiveNowMatchModel match) {
    return Column(
      children: [
        _scoreInput("Snatch", match.snatchBest, (val) {
          _updateScore("snatch_best", val);
        }),
        _scoreInput("Clean & Jerk", match.cleanJerkBest, (val) {
          _updateScore("cleanjerk_best", val);
        }),
        _scoreInput("Total", match.weightTotal, (val) {
          _updateScore("total", val);
        }),
      ],
    );
  }

  Widget _scoreInput(String label, String value, Function(String) onSave) {
    final controller = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              style: TextStyle(fontFamily: globalFontFamily, fontSize: 14),
              label,
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              ),
              onSubmitted: (val) => onSave(val),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.green),
            onPressed: () => onSave(controller.text),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToggle(LiveNowMatchModel match) {
    return GestureDetector(
      onLongPress: () {
        final newValue = match.status == 'live' ? "completed" : "live";
        _updateScore("status", newValue, winner: true); // reuse your API call

        // navigate to CompleteMatch page
        if (newValue == "completed") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashBoard(index: 1)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashBoard(index: 1)),
          );
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: match.active == 1 ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  match.status == 'live' ? "Complete Match" : "Make Live",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: globalFontFamily,
                  ),
                ),
              ),
            ),
          ),
          Text(
            style: TextStyle(fontFamily: globalFontFamily),
            "Long press to ${match.status == 'live' ? "complete" : "make live"}",
          ),

          SizedBox(height: 100),
        ],
      ),
    );
  }
}
