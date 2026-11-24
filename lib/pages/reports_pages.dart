import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

// ───────────────────────── Reports tab (client) & app-level list

enum ReportState { generating, ready, failed }

ReportState reportState(Map<String, dynamic> e) {
  final st = '${e['Status'] ?? e['status'] ?? ''}'.toLowerCase();
  final link = '${e['Download_Link'] ?? ''}'.trim();
  if (st.contains('fail') || st.contains('error') || st.contains('reject')) return ReportState.failed;
  if (link.isNotEmpty && link != 'null') return ReportState.ready;
  if (st.contains('complete') || st.contains('done') || st.contains('success')) return ReportState.ready;
  return ReportState.generating;
}

class ReportRow extends StatelessWidget {
  final Map<String, dynamic> e;
  final bool showClient;
  final VoidCallback? onRetry;
  const ReportRow(this.e, {super.key, this.showClient = false, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final st = reportState(e);
    final link = '${e['Download_Link'] ?? ''}'.trim();
    final type = '${e['Type'] ?? e['Report'] ?? 'CK Planner'}';
    final name = '${e['Name'] ?? ''}';
    final date = '${e['Date'] ?? e['created_at'] ?? e['Created'] ?? ''}';
    final col = st == ReportState.ready ? const Color(0xFF5EE38A) : st == ReportState.failed ? const Color(0xFFF59E0B) : CkColors.cyan;
    final label = st == ReportState.ready ? 'READY' : st == ReportState.failed ? 'FAILED' : 'GENERATING';
    return Glass(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Image.asset('assets/icons/ck_planner.png', width: 26, height: 26),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(showClient && name.isNotEmpty ? '$name · $type' : type,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Row(children: [
                if (st == ReportState.generating) const _Pulse(),
                Text(label, style: CkText.mono(10.5, color: col)),
                if (date.isNotEmpty && date != 'null') Text('  ·  $date', style: CkText.mono(10.5, color: CkColors.labelMono)),
              ]),
            ]),
          ),
        ]),
        if (st == ReportState.generating)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Being prepared. Pull down to refresh.', style: TextStyle(fontSize: 12, color: CkColors.textSecondary)),
          ),
        if (st == ReportState.ready && link.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              Expanded(child: GhostButton('Open PDF', icon: Icons.picture_as_pdf_outlined, onTap: () => openLink(link))),
              const SizedBox(width: 8),
              Expanded(child: GhostButton('Share', icon: Icons.ios_share_rounded, onTap: () => openLink(link))),
            ]),
          ),
        if (st == ReportState.failed && onRetry != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: GhostButton('Retry', icon: Icons.refresh_rounded, onTap: onRetry),
          ),
      ]),
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse();
  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: .25, end: 1.0).animate(_c),
        child: Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(right: 6),
          decoration: const BoxDecoration(color: CkColors.cyan, shape: BoxShape.circle),
        ),
      );
}

Future<List<Map<String, dynamic>>> fetchReports() async {
  final r = await Api.post(Endpoints.reportHistory, {'uID': Session.uid});
  return Api.list(r, ['list']);
}

class ClientReportsPage extends StatefulWidget {
  const ClientReportsPage({super.key});
  @override
  State<ClientReportsPage> createState() => _ClientReportsPageState();
}

class _ClientReportsPageState extends State<ClientReportsPage> {
  late Future<List<Map<String, dynamic>>> _f = fetchReports();

  @override
  Widget build(BuildContext context) {
    final c = Session.client.value;
    return ClientPage(
      title: 'Reports',
      isRoot: true,
      onRefresh: () async => setState(() => _f = fetchReports()),
      children: [
        Text('NEW REPORT', style: CkText.label),
        const SizedBox(height: 8),
        Pressable(
          scale: .985,
          onTap: () => pushModule(context, const PlannerPage()),
          child: Glass(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Image.asset('assets/icons/ck_planner.png', width: 30, height: 30),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CK Planner', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('Sentiments & Situations, 3 · 6 · 12 months', style: TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: CkColors.labelMono),
            ]),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 8, 2, 0),
          child: Text('CK BluePrint, CK Trajectory and CK Profile will appear here as they launch.',
              style: TextStyle(fontSize: 11.5, color: CkColors.labelMono)),
        ),
        const SizedBox(height: 18),
        Text('THIS CLIENT · HISTORY', style: CkText.label),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _f,
          builder: (ctx, s) {
            if (s.hasError) return ErrorBox(message: 'Couldn\'t load reports.', onRetry: () => setState(() => _f = fetchReports()));
            if (!s.hasData) return const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)));
            final name = (c?.name ?? '').toLowerCase().trim();
            final l = s.data!.where((e) => '${e['Name'] ?? ''}'.toLowerCase().trim() == name).toList();
            if (l.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 10),
                child: EmptyBox(icon: Icons.description_outlined, title: 'No reports yet', body: 'Reports you generate for this client appear here.'),
              );
            }
            return Column(children: [for (final e in l) ReportRow(e, onRetry: () => pushModule(context, const PlannerPage()))]);
          },
        ),
      ],
    );
  }
}

/// App-level Reports tab: every report across clients.
class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});
  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  late Future<List<Map<String, dynamic>>> _f = fetchReports();
  String _q = '';
  @override
  Widget build(BuildContext context) => CkScaffold(
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async => setState(() => _f = fetchReports()),
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
              children: [
                Text('ALL CLIENTS', style: CkText.label),
                const SizedBox(height: 6),
                Text('Reports', style: CkText.h(26)),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (v) => setState(() => _q = v.toLowerCase()),
                  decoration: const InputDecoration(hintText: 'Search client or report', prefixIcon: Icon(Icons.search_rounded)),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _f,
                  builder: (ctx, s) {
                    if (s.hasError) return ErrorBox(message: 'Couldn\'t load reports.', onRetry: () => setState(() => _f = fetchReports()));
                    if (!s.hasData) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)));
                    final l = s.data!.where((e) => '${e['Name']} ${e['Type']}'.toLowerCase().contains(_q)).toList();
                    if (l.isEmpty) {
                      return const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: EmptyBox(icon: Icons.description_outlined, title: 'No reports', body: 'Reports you generate will show here.'));
                    }
                    return Column(children: [
                      for (var i = 0; i < l.length; i++) i < 7 ? FadeSlideIn(index: i, child: ReportRow(l[i], showClient: true)) : ReportRow(l[i], showClient: true)
                    ]);
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

Future<void> openLink(String link) async {
  final u = Uri.tryParse(link);
  if (u != null) await launchUrl(u, mode: LaunchMode.externalApplication);
}
