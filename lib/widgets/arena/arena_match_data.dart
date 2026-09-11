import 'package:flutter/foundation.dart';
import 'package:udghosh/SchedulePage/models/LiveMatchModel.dart';
import 'package:udghosh/SchedulePage/models/MatchesModel.dart';
import 'arena_scoreline.dart';
import 'arena_status_capsule.dart';

const _playerSports = {'badminton', 'taekwondo', 'chess', 'squash'};

/// Flat view-model the [ArenaMatchCard] renders from — decouples the card
/// UI from the two very differently-shaped source models
/// ([LiveNowMatchModel] for live/completed, [UpcomingMatchesModel] for
/// scheduled fixtures).
class ArenaMatchData {
  final ArenaMatchStatus status;
  final String sport;
  final String? category;
  final String teamLeft;
  final String teamRight;
  final String venue;
  final String? venueTag;
  final String? scheduledTime;
  final String? liveClock;
  final ArenaScoreline? scoreline;
  final List<String> microStats;
  final int? stageNumber;
  final String? stageLabel;
  final double delayMinutes;
  final VoidCallback? onAction;
  final String actionLabel;
  final VoidCallback? onTap;

  const ArenaMatchData({
    required this.status,
    required this.sport,
    required this.teamLeft,
    required this.teamRight,
    required this.venue,
    this.category,
    this.venueTag,
    this.scheduledTime,
    this.liveClock,
    this.scoreline,
    this.microStats = const [],
    this.stageNumber,
    this.stageLabel,
    this.delayMinutes = 0,
    this.onAction,
    this.actionLabel = 'LIVE STATS',
    this.onTap,
  });

  factory ArenaMatchData.fromLive(
    LiveNowMatchModel m, {
    required ArenaMatchStatus status,
    int? stageNumber,
    String? stageLabel,
    String? venueTag,
    String? liveClock,
    VoidCallback? onAction,
    VoidCallback? onTap,
  }) {
    final sport = (m.sport ?? '').toLowerCase();
    final usesPlayers = _playerSports.contains(sport);
    final teamLeft = (usesPlayers ? m.player1 : m.team1) ?? '';
    final teamRight = (usesPlayers ? m.player2 : m.team2) ?? '';
    final scoreline = resolveScoreline(m);
    return ArenaMatchData(
      status: status,
      sport: m.sport ?? '',
      category: m.category,
      teamLeft: teamLeft.toUpperCase(),
      teamRight: teamRight.toUpperCase(),
      venue: m.venue ?? '',
      venueTag: venueTag,
      liveClock: liveClock,
      scoreline: scoreline,
      microStats: resolveSetMicroStats(m),
      stageNumber: stageNumber,
      stageLabel: stageLabel,
      onAction: onAction,
      actionLabel: status == ArenaMatchStatus.live ? 'LIVE STATS' : 'BOX SCORE',
      onTap: onTap,
    );
  }

  factory ArenaMatchData.fromUpcoming(
    UpcomingMatchesModel m, {
    int? stageNumber,
    String? stageLabel,
    String? venueTag,
    VoidCallback? onAction,
    VoidCallback? onTap,
  }) {
    return ArenaMatchData(
      status: ArenaMatchStatus.scheduled,
      sport: m.sport,
      category: m.category,
      teamLeft: m.team1.toUpperCase(),
      teamRight: m.team2.toUpperCase(),
      venue: m.venue,
      venueTag: venueTag,
      scheduledTime: m.matchTime,
      stageNumber: stageNumber,
      stageLabel: stageLabel,
      delayMinutes: m.delayMinutes,
      onAction: onAction,
      actionLabel: 'NOTIFY ME',
      onTap: onTap,
    );
  }
}
