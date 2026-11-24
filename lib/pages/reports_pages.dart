import 'package:flutter/cupertino.dart';
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

// ───────────────────────── Reports (new report APIs)

/// Report types the app can generate.
class ReportType {
  final String code; // API code (CKP, CKPP, CKPM, GV)
  final String title;
  final String about;
  final List<int> durations;
  const ReportType(this.code, this.title, this.about, this.durations);
  bool get isVibes => code == 'GV';
}

const kReportTypes = [
  ReportType('CKP', 'CK Planner', 'Sentiments & Situations, day by day', [3, 6, 12]),
  ReportType('CKPP', 'CK Planner Plus', 'Planner + 5D month by month', [3, 6, 12]),
  ReportType('CKPM', 'CK Planner Max', 'Planner + 5D weekly and daily', [3, 6, 12]),
  ReportType('GV', 'CK GRAH Vibes', 'GRAH Vibes, month by month', [12]),
];

String reportTitle(String code) {
  switch (code.toUpperCase()) {
    case 'CKP':
      return 'CK Planner';
    case 'CKPP':
      return 'CK Planner Plus';
    case 'CKPM':
      return 'CK Planner Max';
    case 'GV':
      return 'CK GRAH Vibes';
    case 'CVSS':
      return 'CK Planner (earlier)';
    default:
      return code.isEmpty ? 'Report' : code;
  }
}

String _pick(Map<String, dynamic> e, List<String> keys) {
  for (final k in keys) {
    final v = e[k];
    if (v != null && '$v'.trim().isNotEmpty && '$v' != 'null') return '$v'.trim();
  }
  return '';
}

DateTime? _parseDate(String v) {
  if (v.isEmpty) return null;
  for (final f in ['yyyy-MM-dd HH:mm:ss', 'yyyy-MM-dd', 'dd-MM-yyyy HH:mm:ss', 'dd-MM-yyyy', 'yyyy-MM', 'dd/MM/yyyy']) {
    try {
      return DateFormat(f).parseStrict(v);
    } catch (_) {}
  }
  return DateTime.tryParse(v);
}

/// One entry of Report_History_All, read defensively until the field names
/// are confirmed.
class ReportItem {
  final Map<String, dynamic> raw;
  ReportItem(this.raw);
  String get id => _pick(raw, ['ID', 'Id', 'id', 'rID', 'ReportID']);
  String get source => _pick(raw, ['Source', 'source', 'Report', 'Type', 'report_type']).toUpperCase();
  String get title => reportTitle(source);
  String get memberId => _pick(raw, ['mID', 'MID', 'member_id', 'MemberID', 'Member_ID']);
  String get name => _pick(raw, ['Name', 'name', 'Member_Name', 'member_name', 'Client']);
  int get duration => int.tryParse(_pick(raw, ['Duration', 'duration', 'Months'])) ?? 0;
  DateTime? get start => _parseDate(_pick(raw, ['Month', 'Start_Month', 'start_month', 'Report_Date', 'report_date', 'From']));
  DateTime? get created => _parseDate(_pick(raw, ['Created', 'created_at', 'Created_At', 'Issue_Date', 'issue_date', 'Date', 'date']));
  String get status => _pick(raw, ['Status', 'status']).toLowerCase();
  bool get failed => status.contains('fail') || status.contains('error');
  bool get ready =>
      !failed &&
      (status.isEmpty || status.contains('complete') || status.contains('done') || status.contains('success') || status.contains('ready') || status == '1');

  String get period {
    final s = start;
    if (s == null) return duration > 0 ? '$duration months' : '';
    final e = DateTime(s.year, s.month + (duration > 0 ? duration : 1) - 1);
    String m(DateTime d) => DateFormat('MMM yyyy').format(d);
    return duration <= 1 ? m(s) : (s.year == e.year ? '${DateFormat('MMM').format(s)} – ${m(e)}' : '${m(s)} – ${m(e)}');
  }
}

Future<List<ReportItem>> fetchReports() async {
  final r = await Api.post(Endpoints.reportHistoryAll, {'uID': int.tryParse(Session.uid) ?? Session.uid});
  final l = Api.list(r, ['list', 'data', 'reports', 'history']).map(ReportItem.new).toList();
  l.sort((a, b) => (b.created ?? DateTime(0)).compareTo(a.created ?? DateTime(0)));
  return l;
}

Future<void> downloadReport(BuildContext context, ReportItem it) async {
  try {
    final r = await Api.post(Endpoints.reportViewLink, {
      'uID': int.tryParse(Session.uid) ?? Session.uid,
      'Source': it.source,
      'ID': int.tryParse(it.id) ?? it.id,
    });
    final link = _pick(r, ['link', 'Link', 'url', 'URL', 'View_Link', 'view_link', 'Download_Link', 'data']);
    if (link.startsWith('http')) {
      await openLink(link);
    } else if (context.mounted) {
      toast(context, Api.msg(r, 'The report isn\'t ready yet'), error: true);
    }
  } catch (_) {
    if (context.mounted) toast(context, 'Couldn\'t get the report link.', error: true);
  }
}

class ReportRow extends StatelessWidget {
  final ReportItem it;
  final bool showClient;
  const ReportRow(this.it, {super.key, this.showClient = false});

  @override
  Widget build(BuildContext context) {
    final icon = ckIconAsset(it.title) ?? 'assets/icons/ck_planner.png';
    final title = [
      if (showClient && it.name.isNotEmpty) it.name,
      it.title + (it.duration > 0 ? ' · ${it.duration} months' : ''),
    ].join(' · ');
    return Glass(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      child: Row(children: [
        Image.asset(icon, width: 24, height: 24),
        const SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(children: [
                if (it.period.isNotEmpty) ...[
                  const TextSpan(text: 'Period ', style: TextStyle(color: CkColors.labelMono)),
                  TextSpan(text: it.period),
                  const TextSpan(text: '    '),
                ],
                if (it.created != null) ...[
                  const TextSpan(text: 'Created ', style: TextStyle(color: CkColors.labelMono)),
                  TextSpan(text: DateFormat('d MMM yyyy').format(it.created!)),
                ],
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: CkColors.textTertiary),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        if (it.failed)
          Text('FAILED', style: CkText.mono(10.5, color: const Color(0xFFF59E0B)))
        else if (it.ready)
          Pressable(
            onTap: () => downloadReport(context, it),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: CkColors.cyan, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.download_rounded, color: Color(0xFF06204F)),
            ),
          )
        else
          Row(children: [
            const _Pulse(),
            Text('GENERATING', style: CkText.mono(10.5, color: CkColors.cyan)),
          ]),
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

/// Credits per report type and duration, from Report_Prices.
Future<Map<String, num>> fetchPrices() async {
  final out = <String, num>{};
  try {
    final r = await Api.post(Endpoints.reportPrices, {'uID': int.tryParse(Session.uid) ?? Session.uid});
    for (final e in Api.list(r, ['list', 'data', 'prices'])) {
      final code = _pick(e, ['Report', 'Source', 'Code', 'Type', 'report']).toUpperCase();
      final dur = _pick(e, ['Duration', 'duration', 'Months']);
      final price = num.tryParse(_pick(e, ['Price', 'price', 'Credit', 'Credits', 'credit', 'Amount']));
      if (code.isNotEmpty && price != null) out['$code|$dur'] = price;
    }
  } catch (_) {}
  return out;
}

class ClientReportsPage extends StatefulWidget {
  const ClientReportsPage({super.key});
  @override
  State<ClientReportsPage> createState() => _ClientReportsPageState();
}

class _ClientReportsPageState extends State<ClientReportsPage> {
  late Future<List<ReportItem>> _f = fetchReports();
  late final Future<Map<String, dynamic>> _credits = Api.post(Endpoints.credits, {'uID': Session.uid});

  void _reload() => setState(() => _f = fetchReports());

  @override
  Widget build(BuildContext context) {
    final c = Session.client.value;
    return ClientPage(
      title: 'Reports',
      isRoot: true,
      onRefresh: () async => _reload(),
      children: [
        Row(children: [
          Expanded(child: Text('NEW REPORT', style: CkText.label)),
          FutureBuilder<Map<String, dynamic>>(
            future: _credits,
            builder: (_, s) {
              final v = s.data?['Remaining_Credit'];
              return Text(v == null ? '' : 'BALANCE ${NumberFormat.decimalPattern('en_IN').format(num.tryParse('$v') ?? 0)} CR',
                  style: CkText.mono(10.5, color: CkColors.textSecondary));
            },
          ),
        ]),
        Glass(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Column(children: [
            for (var i = 0; i < kReportTypes.length; i++)
              Pressable(
                scale: .985,
                onTap: () async {
                  final made = await Navigator.of(context).push<bool>(CupertinoPageRoute(builder: (_) => GenerateReportPage(type: kReportTypes[i])));
                  if (made == true) _reload();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0x1A8CBEFF)))),
                  child: Row(children: [
                    Image.asset(ckIconAsset(kReportTypes[i].title) ?? 'assets/icons/ck_planner.png', width: 26, height: 26),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(kReportTypes[i].title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 1),
                        Text(kReportTypes[i].about, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
                      ]),
                    ),
                    Text(kReportTypes[i].durations.map((d) => '$d').join(' · '), style: CkText.mono(10.5, color: CkColors.labelMono)),
                    const Icon(Icons.chevron_right_rounded, color: CkColors.labelMono),
                  ]),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 18),
        Text('THIS CLIENT · HISTORY', style: CkText.label),
        FutureBuilder<List<ReportItem>>(
          future: _f,
          builder: (ctx, s) {
            if (s.hasError) return ErrorBox(message: 'Couldn\'t load reports.', onRetry: _reload);
            if (!s.hasData) return const SkeletonList(rows: 3);
            final all = s.data!;
            final byId = all.any((e) => e.memberId.isNotEmpty);
            final name = (c?.name ?? '').toLowerCase().trim();
            final l = all.where((e) => byId ? e.memberId == c?.mId : e.name.toLowerCase().trim() == name).toList();
            if (l.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 10),
                child: EmptyBox(icon: Icons.description_outlined, title: 'No reports yet', body: 'Reports you generate for this client appear here.'),
              );
            }
            return Column(children: [for (var i = 0; i < l.length; i++) i < 7 ? FadeSlideIn(index: i, child: ReportRow(l[i])) : ReportRow(l[i])]);
          },
        ),
      ],
    );
  }
}

class GenerateReportPage extends StatefulWidget {
  final ReportType type;
  const GenerateReportPage({super.key, required this.type});
  @override
  State<GenerateReportPage> createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  DateTime _start = DateTime(DateTime.now().year, DateTime.now().month);
  late int _months = widget.type.durations.last == 12 && widget.type.durations.length == 1 ? 12 : 6;
  bool _busy = false;
  late final Future<Map<String, num>> _prices = fetchPrices();

  Future<void> _generate() async {
    final c = Session.client.value;
    if (c == null) return;
    final ok = await confirm(context, 'Generate ${widget.type.title}?',
        '$_months months for ${c.name}, starting ${DateFormat('MMMM yyyy').format(_start)}. Credits will be used.',
        ok: 'Generate');
    if (!ok) return;
    setState(() => _busy = true);
    try {
      final base = {
        'uID': int.tryParse(Session.uid) ?? Session.uid,
        'mID': int.tryParse(c.mId) ?? c.mId,
        'Month': DateFormat('yyyy-MM').format(_start),
        'Duration': _months,
      };
      final r = widget.type.isVibes
          ? await Api.post(Endpoints.vibesGenerate, base)
          : await Api.post(Endpoints.plannerGenerate, {...base, 'Report': widget.type.code});
      if (!mounted) return;
      toast(context, Api.msg(r, Api.ok(r) ? 'Report requested. It will appear in history.' : 'Couldn\'t generate the report'), error: !Api.ok(r));
      if (Api.ok(r)) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => ClientPage(
        title: widget.type.title,
        children: [
          Text(widget.type.about, style: CkText.muted),
          const SizedBox(height: 14),
          Text('START MONTH', style: CkText.label),
          const SizedBox(height: 6),
          MonthBar(month: _start, onChanged: (m) => setState(() => _start = m)),
          const SizedBox(height: 14),
          Text('DURATION', style: CkText.label),
          const SizedBox(height: 6),
          Segmented<int>(
            values: widget.type.durations,
            selected: _months,
            label: (v) => '$v months',
            onChanged: (v) => setState(() => _months = v),
            height: 44,
          ),
          Glass(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PERIOD', style: CkText.label),
                  const SizedBox(height: 4),
                  Text('${DateFormat('MMM yyyy').format(_start)} – ${DateFormat('MMM yyyy').format(DateTime(_start.year, _start.month + _months - 1))}',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                ]),
              ),
              FutureBuilder<Map<String, num>>(
                future: _prices,
                builder: (_, s) {
                  final p = s.data?['${widget.type.code}|$_months'];
                  return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('CREDITS', style: CkText.label),
                    const SizedBox(height: 4),
                    Text(p == null ? '—' : NumberFormat.decimalPattern('en_IN').format(p), style: CkText.mono(16)),
                  ]);
                },
              ),
            ]),
          ),
          const SizedBox(height: 16),
          PrimaryButton('Generate report', loading: _busy, onTap: _generate),
        ],
      );
}

/// App-level Reports tab: every report across clients.
class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});
  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  late Future<List<ReportItem>> _f = fetchReports();
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
                FutureBuilder<List<ReportItem>>(
                  future: _f,
                  builder: (ctx, s) {
                    if (s.hasError) return ErrorBox(message: 'Couldn\'t load reports.', onRetry: () => setState(() => _f = fetchReports()));
                    if (!s.hasData) return const SkeletonList(rows: 7);
                    final l = s.data!.where((e) => '${e.name} ${e.title}'.toLowerCase().contains(_q)).toList();
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
