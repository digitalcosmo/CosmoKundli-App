import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import 'account_pages.dart';
import 'client_shell.dart';

class ReportsSection extends StatelessWidget {
  const ReportsSection({super.key});
  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Reports',
        isRoot: true,
        children: [
          const SectionIntro('Generate reports for this client · uses your credits'),
          ModuleCard(
            title: 'CK Planner',
            description: 'Day-by-day planning for 3, 6 or 12 months',
            icon: Icons.event_note_rounded,
            onTap: () => pushModule(context, const PlannerPage()),
          ),
          const ModuleCard(index: 1, comingSoon: true, title: 'CK BluePrint', description: 'The birth pattern, explained', icon: Icons.blur_circular_rounded),
          const ModuleCard(index: 2, comingSoon: true, title: 'CK Trajectory', description: 'Vibes and Intensity of each GRAH', icon: Icons.timeline_rounded),
          const ModuleCard(index: 3, comingSoon: true, title: 'CK Profile', description: 'Snapshot of the GRAH pattern at birth', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          GhostButton('Report history', icon: Icons.history_rounded, onTap: () => Get.to(() => const HistoryPage())),
        ],
      );
}

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});
  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  DateTime _start = DateTime(DateTime.now().year, DateTime.now().month);
  int _months = 6;
  bool _busy = false;

  Future<void> _generate() async {
    final c = Session.client.value;
    if (c == null) return;
    final ok = await confirm(context, 'Generate report?',
        '$_months-month report for ${c.name}, starting ${DateFormat('MMMM yyyy').format(_start)}. Credits will be used.',
        ok: 'Generate');
    if (!ok) return;
    setState(() => _busy = true);
    try {
      final ep = _months == 3 ? Endpoints.cosmoPower3 : _months == 6 ? Endpoints.cosmoPower6 : Endpoints.cosmoPower12;
      final r = await Api.post(ep, {'uID': Session.uid, 'mID': c.mId, 'Month': DateFormat('yyyy-MM').format(_start)});
      if (!mounted) return;
      toast(context, Api.msg(r, Api.ok(r) ? 'Report requested. You\'ll find it in Report history.' : 'Couldn\'t generate the report'),
          error: !Api.ok(r));
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'CK Planner',
        children: [
          Row(children: [
            Expanded(
              child: Pressable(
                onTap: () async {
                  final m = await pickMonth(context, _start);
                  if (m != null) setState(() => _start = m);
                },
                child: Glass(
                  height: 46,
                  radius: 16,
                  shadow: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 17, color: CkColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Start · ${DateFormat('MMM yyyy').format(_start)}', style: const TextStyle(fontSize: 13.5))),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Segmented<int>(
                values: const [3, 6, 12],
                selected: _months,
                label: (v) => '${v}M',
                onChanged: (v) => setState(() => _months = v),
                height: 46,
              ),
            ),
          ]),
          Glass(
            margin: const EdgeInsets.only(top: 12),
            radius: 18,
            stroke: CkColors.orangeStroke,
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CK Planner · $_months months', style: CkText.h(18)),
              const SizedBox(height: 4),
              Text('${DateFormat('MMMM yyyy').format(_start)} → '
                  '${DateFormat('MMMM yyyy').format(DateTime(_start.year, _start.month + _months - 1))}',
                  style: CkText.muted),
              const Divider(height: 24),
              ...['Daily Sentiments', 'Daily Situations'].map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded, size: 17, color: Color(0xFF74E2B7)),
                      const SizedBox(width: 8),
                      Text(f, style: const TextStyle(fontSize: 13.5)),
                    ]),
                  )),
              const SizedBox(height: 12),
              PrimaryButton('Generate report', icon: Icons.auto_awesome_rounded, loading: _busy, onTap: _generate),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 10, 4, 0),
            child: Text('Generated reports appear in Report history, where you can download them.',
                style: TextStyle(fontSize: 11.5, color: CkColors.textMuted)),
          ),
        ],
      );
}
