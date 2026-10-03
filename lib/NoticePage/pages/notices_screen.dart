import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/NoticePage/model/Notice.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/app_lottie.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

/// Pushed from the Other tab — plain-text announcement feed.
class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  List<Notice> _notices = [];
  bool _loading = true;
  ApiException? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      _notices = await ApiService.getNotices();
    } on ApiException catch (e) {
      _failure = e;
    } catch (_) {
      _failure = ApiException(0, 'Could not load notices');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.canvasMint,
      appBar: AppBar(
        backgroundColor: NeoColors.canvasMint,
        title: Text(
          'Notices',
          style: TextStyle(
            color: NeoColors.logoTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: NeoColors.logoTeal),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: NeoColors.waveTeal,
        child: _loading
            ? const AppLoader()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // A failure with nothing cached replaces the feed entirely
                  // — no notices are rendered underneath it.
                  if (_failure != null && _notices.isEmpty)
                    AppStateView(
                      anim: _failure!.isOffline
                          ? AppAnim.offline
                          : AppAnim.serverDown,
                      title: _failure!.isOffline
                          ? 'You are offline'
                          : 'Notices are unavailable',
                      message: _failure!.isOffline
                          ? 'Reconnect to read the latest announcements.'
                          : _failure!.message,
                      onRetry: _failure!.isRetryable ? _load : null,
                    )
                  else if (_notices.isEmpty)
                    const AppStateView(
                      anim: AppAnim.empty,
                      title: 'No notices yet',
                      message:
                          'Announcements from the organisers will '
                          'show up here.',
                    )
                  else ...[
                    if (_failure != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _failure!.message,
                          style: TextStyle(color: NeoColors.alert),
                        ),
                      ),
                    for (final n in _notices)
                      NeoCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: NeoColors.logoTeal,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              n.content,
                              style: TextStyle(
                                color: NeoColors.textMuted,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (n.createdAt != null)
                                  Text(
                                    DateFormat(
                                      'd MMM, h:mm a',
                                    ).format(n.createdAt!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: NeoColors.textMuted.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                if (n.isEdited) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NeoColors.surfaceRecessed,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'edited',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: NeoColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}
