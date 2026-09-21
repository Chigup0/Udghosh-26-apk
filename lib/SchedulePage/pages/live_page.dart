// ignore_for_file: avoid_print, unused_local_variable, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:udghosh/SchedulePage/models/LiveMatchModel.dart';
import 'package:udghosh/SchedulePage/widgets/ScoreUi.dart';
import 'package:udghosh/utils.dart';
import 'package:udghosh/widgets/widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key, required this.match});
  final LiveNowMatchModel match;

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
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

  @override
  Widget build(BuildContext context) {
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
    return liveMatchScore(widget.match, compact: false);
  }
}
