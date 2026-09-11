import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:udghosh/models/demo_data.dart';
import 'package:udghosh/NoticePage/model/Notice.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _notices = await ApiService.getNotices();
    } catch (_) {
      _error = 'Could not load notices';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final notices = _notices.isEmpty ? [DemoData.notice()] : _notices;
    final isDemo = _notices.isEmpty;

    return Scaffold(
      backgroundColor: NeoColors.canvasMint,
      appBar: AppBar(
        backgroundColor: NeoColors.canvasMint,
        title: const Text('Notices', style: TextStyle(color: NeoColors.logoTeal, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: NeoColors.logoTeal),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: NeoColors.waveTeal,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: NeoColors.waveTeal))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: NeoColors.alert)),
                    ),
                  for (final n in notices)
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
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: NeoColors.logoTeal, fontSize: 15),
                                ),
                              ),
                              if (isDemo)
                                Text('DEMO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: NeoColors.flameGold.withValues(alpha: 0.9))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(n.content, style: TextStyle(color: NeoColors.textMuted, fontSize: 13, height: 1.4)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                DateFormat('d MMM, h:mm a').format(n.createdAt),
                                style: TextStyle(fontSize: 11, color: NeoColors.textMuted.withValues(alpha: 0.7)),
                              ),
                              if (n.updatedAt.difference(n.createdAt).inSeconds.abs() > 1) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: NeoColors.surfaceRecessed,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('edited', style: TextStyle(fontSize: 9, color: NeoColors.textMuted)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
