import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
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

/// A report the app can generate.
class ReportType {
  final String code; // API code (CKP, CKPP, CKPM, GV, GI)
  final String title;
  final String about;
  final String cover; // short asset key: assets/covers/<k>.jpg, assets/samples/<k>.pdf
  final bool soon;
  const ReportType(this.code, this.title, this.about, this.cover, {this.soon = false});
  bool get isVibes => code == 'GV';
  String get coverAsset => 'assets/covers/$cover.jpg';
  String get sampleAsset => 'assets/samples/$cover.pdf';
}

/// A group of reports, as in the software: BluePrint, Trajectory, Predictions.
class ReportGroup {
  final String title;
  final String sub;
  final List<ReportType> types;
  final List<int> durations;
  final bool soon;
  const ReportGroup(this.title, this.sub, this.types, this.durations, {this.soon = false});
}

const kBlueprint = ReportType('BP', 'CK BluePrint', 'The birth pattern, explained', 'bp', soon: true);
const kVibes = ReportType('GV', 'CK GRAH Vibes', 'How each GRAH supports or strains the year, month by month', 'vb');
const kIntensity = ReportType('GI', 'CK GRAH Intensity', 'How strongly each GRAH is activated, day by day', 'in', soon: true);
const kPlanner = ReportType('CKP', 'CK Planner', 'Daily Sentiments and Situations', 'pl');
const kPlannerPlus = ReportType('CKPP', 'CK Planner Plus', 'Planner + monthly Career, Finance, Health, Social, Love', 'pp');
const kPlannerMax = ReportType('CKPM', 'CK Planner Max', 'Planner + 5D monthly, weekly and daily', 'pm');

const kReportGroups = [
  ReportGroup('CK BluePrint', 'Foundation', [kBlueprint], [], soon: true),
  ReportGroup('CK Trajectory', 'Movement', [kVibes, kIntensity], [12]),
  ReportGroup('CK Predictions', 'Planning', [kPlanner, kPlannerPlus, kPlannerMax], [3, 6, 12]),
];

const kReportTypes = [kPlanner, kPlannerPlus, kPlannerMax, kVibes];

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
  for (final f in ['dd-MM-yyyy', 'yyyy-MM-dd', 'yyyy-MM', 'dd/MM/yyyy']) {
    try {
      return DateFormat(f).parseStrict(v);
    } catch (_) {}
  }
  return DateTime.tryParse(v);
}

bool _truthy(dynamic v) => v == true || v == 1 || '$v'.toLowerCase() == 'true' || '$v' == '1';

enum ReportState { generating, ready, expired, failed }

/// One entry of Report_History_All:
/// {ID, Source, Date "dd-MM-yyyy", Type "CK Planner Max 12 Months", Name,
///  Month "yyyy-MM", Status "Pending"|"Genrated", Download_Link, Can_View}
class ReportItem {
  final Map<String, dynamic> raw;
  ReportItem(this.raw);
  String get id => _pick(raw, ['ID']);
  String get source => _pick(raw, ['Source']).toUpperCase();
  String get title => reportTitle(source);
  String get name => _pick(raw, ['Name']);
  String get memberId => _pick(raw, ['mID', 'MID']);
  int get duration {
    final m = RegExp(r'(\d+)\s*Month', caseSensitive: false).firstMatch(_pick(raw, ['Type']));
    return int.tryParse(m?.group(1) ?? '') ?? int.tryParse(_pick(raw, ['Duration'])) ?? 0;
  }

  DateTime? get start => _parseDate(_pick(raw, ['Month']));
  DateTime? get created => _parseDate(_pick(raw, ['Date']));
  String get status => _pick(raw, ['Status']).toLowerCase();

  /// Status says whether the server finished; Can_View false on a finished
  /// report means it has expired.
  ReportState get state {
    if (status.contains('pend') || status.contains('process') || status.contains('queue')) return ReportState.generating;
    if (status.contains('fail') || status.contains('error')) return ReportState.failed;
    return _truthy(raw['Can_View']) ? ReportState.ready : ReportState.expired;
  }

  bool get pending => state == ReportState.generating;
  bool get ready => state == ReportState.ready;
  bool get failed => state == ReportState.failed;
  bool get expired => state == ReportState.expired;
  String get key => '$source|$id';

  String get period {
    final s = start;
    if (s == null) return duration > 0 ? '$duration months' : '';
    final e = DateTime(s.year, s.month + (duration > 0 ? duration : 1) - 1);
    String m(DateTime d) => DateFormat('MMM yyyy').format(d);
    return duration <= 1 ? m(s) : (s.year == e.year ? '${DateFormat('MMM').format(s)} – ${m(e)}' : '${m(s)} – ${m(e)}');
  }

  String get fileName {
    final n = '$title - $name - ${start == null ? id : DateFormat('MMM yyyy').format(start!)}'.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
    return '$n.pdf';
  }
}

/// Report history, shared by Dashboard, Reports and search (one call per
/// 30 s at most); [force] after generating, polling or pull-to-refresh.
Future<List<ReportItem>> fetchReports({bool force = false}) =>
    Api.shared('reports:${Session.uid}', _fetchReports, ttl: const Duration(seconds: 30), force: force);

Future<List<ReportItem>> _fetchReports() async {
  final r = await Api.post(Endpoints.reportHistoryAll, {'uID': int.tryParse(Session.uid) ?? Session.uid});
  // Server order is newest first; keep it.
  return Api.list(r, ['list', 'data']).map(ReportItem.new).toList();
}

/// Reports for the open client. History has no mID yet, so match by name.
List<ReportItem> reportsFor(List<ReportItem> all, Client? c) {
  if (c == null) return [];
  if (all.any((e) => e.memberId.isNotEmpty)) return all.where((e) => e.memberId == c.mId).toList();
  final name = c.name.toLowerCase().trim();
  return all.where((e) => e.name.toLowerCase().trim() == name).toList();
}

// ───────────────────────── PDF: view link → printed on the device

class ReportPdf {
  static final _cache = <String, Uint8List>{};

  static Future<String> link(ReportItem it) async {
    final r = await Api.post(Endpoints.reportViewLink, {
      'uID': int.tryParse(Session.uid) ?? Session.uid,
      'Source': it.source,
      'ID': int.tryParse(it.id) ?? it.id,
    });
    var link = _pick(r, ['link', 'Link', 'url', 'URL', 'View_Link', 'view_link', 'Download_Link', 'data']);
    if (!link.startsWith('http')) {
      for (final v in r.values) {
        if (v is String && v.startsWith('http')) link = v;
      }
    }
    if (!link.startsWith('http')) throw Exception(Api.msg(r, 'The report isn\'t available'));
    return link;
  }

  /// Loads the report page and prints it to a PDF in the phone's WebView —
  /// the same result as Chrome's "Save as PDF".
  static Future<Uint8List> build(ReportItem it) async {
    final hit = _cache[it.key];
    if (hit != null) return hit;
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/ck_${it.source}_${it.id}.pdf');
    if (await f.exists() && await f.length() > 1000) {
      return _cache[it.key] = await f.readAsBytes();
    }
    final link = await ReportPdf.link(it);
    final res = await Dio().get<String>(link, options: Options(responseType: ResponseType.plain));
    final html = res.data ?? '';
    if (html.trim().isEmpty) throw Exception('Empty report page');
    final bytes = await Printing.convertHtml(html: html, baseUrl: link, format: PdfPageFormat.a4);
    await f.writeAsBytes(bytes, flush: true);
    return _cache[it.key] = bytes;
  }
}

enum _PdfAction { open, share }

/// Reports open in Chrome (Print → Save as PDF there), as on the website.
/// Share sends the report's view link.
Future<void> _runPdf(BuildContext context, ReportItem it, _PdfAction a) async {
  try {
    final link = await ReportPdf.link(it);
    if (a == _PdfAction.open) {
      await openLink(link);
    } else {
      await SharePlus.instance.share(ShareParams(text: '${it.title} · ${it.name}\n$link', subject: it.title));
    }
  } catch (e) {
    if (context.mounted) toast(context, e.toString().replaceFirst('Exception: ', ''), error: true);
  }
}

Future<void> savePdf(BuildContext context, Uint8List bytes, String name) async {
  try {
    final path = await FilePicker.platform.saveFile(dialogTitle: 'Save report', fileName: name, bytes: bytes, type: FileType.custom, allowedExtensions: ['pdf']);
    if (path != null && context.mounted) toast(context, 'Saved $name');
  } catch (_) {
    if (context.mounted) toast(context, 'Couldn\'t save the file.', error: true);
  }
}

/// In-app PDF viewer with Share and Download.
class PdfViewPage extends StatelessWidget {
  final String title;
  final String sub;
  final Uint8List? bytes;
  final String? asset;
  final String fileName;
  const PdfViewPage({super.key, required this.title, this.sub = '', this.bytes, this.asset, required this.fileName});

  Future<Uint8List> _load() async => bytes ?? (await rootBundle.load(asset!)).buffer.asUint8List();

  @override
  Widget build(BuildContext context) => CkScaffold(
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(children: [
                CircleBtn(Icons.arrow_back_rounded, label: 'Back', size: 40, onTap: () => Navigator.pop(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.h(16.5)),
                    if (sub.isNotEmpty) Text(sub, style: CkText.mono(11, color: CkColors.textSecondary)),
                  ]),
                ),
                CircleBtn(Icons.ios_share_rounded, label: 'Share', size: 40, onTap: () async => Printing.sharePdf(bytes: await _load(), filename: fileName)),
                const SizedBox(width: 8),
                CircleBtn(Icons.download_rounded, label: 'Download', size: 40, onTap: () async {
                  final b = await _load();
                  if (context.mounted) await savePdf(context, b, fileName);
                }),
              ]),
            ),
            Expanded(
              child: PdfPreview(
                build: (_) => _load(),
                useActions: false,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                scrollViewDecoration: const BoxDecoration(color: Colors.transparent),
                pdfPreviewPageDecoration: const BoxDecoration(boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6))]),
                loadingWidget: const Center(child: CircularProgressIndicator(color: CkColors.cyan, strokeWidth: 2.4)),
              ),
            ),
          ]),
        ),
      );
}

// ───────────────────────── history row

const _kTypeLook = {
  'CKP': ('pl', 'Planner', Color(0xFF7FB2FF)),
  'CKPP': ('pp', 'Planner Plus', Color(0xFFF5D547)),
  'CKPM': ('pm', 'Planner Max', Color(0xFFFF7A8A)),
  'GV': ('vb', 'GRAH Vibes', Color(0xFFA98BFF)),
  'CVSS': ('pl', 'Planner (earlier)', Color(0xFF7FB2FF)),
};

/// One report, built to scan: whose · which · duration · period · made.
class ReportRow extends StatelessWidget {
  final ReportItem it;
  final bool showClient;
  final bool compact;
  const ReportRow(this.it, {super.key, this.showClient = false, this.compact = false});

  String get _short {
    final s = it.start;
    if (s == null) return '';
    final e = DateTime(s.year, s.month + (it.duration > 0 ? it.duration : 1) - 1);
    return '${DateFormat('MMM yy').format(s)} → ${DateFormat('MMM yy').format(e)}';
  }

  String get _made {
    final c = it.created;
    if (c == null) return '';
    final now = DateTime.now();
    if (c.year == now.year && c.month == now.month && c.day == now.day) return 'made today';
    return 'made ${DateFormat('d MMM').format(c)}';
  }

  @override
  Widget build(BuildContext context) {
    final look = _kTypeLook[it.source] ?? ('pl', it.title, CkColors.cyan);
    final s = it.state;
    final typeLine = Row(children: [
      Flexible(child: Text(look.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: showClient ? 12.5 : 15, fontWeight: FontWeight.w600, color: look.$3))),
      if (it.duration > 0) ...[
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: look.$3.withValues(alpha: .45))),
          child: Text('${it.duration}M', style: CkText.mono(10.5, color: look.$3)),
        ),
      ],
    ]);
    final right = switch (s) {
      ReportState.ready => Row(mainAxisSize: MainAxisSize.min, children: [
          Semantics(
            button: true,
            label: 'Share',
            child: Pressable(
              onTap: () => _runPdf(context, it, _PdfAction.share),
              child: const SizedBox(width: 36, height: 38, child: Icon(Icons.ios_share_rounded, size: 18, color: CkColors.textTertiary)),
            ),
          ),
          Semantics(
            button: true,
            label: 'Open',
            child: Pressable(
              onTap: () => _runPdf(context, it, _PdfAction.open),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: CkColors.cyan, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.open_in_new_rounded, size: 18, color: Color(0xFF06204F)),
              ),
            ),
          ),
        ]),
      ReportState.generating => Row(mainAxisSize: MainAxisSize.min, children: [
          const _Pulse(),
          Text('GENERATING', style: CkText.mono(10, color: CkColors.cyan)),
        ]),
      ReportState.expired => Text('EXPIRED', style: CkText.mono(10, color: CkColors.textMuted)),
      ReportState.failed => Text('FAILED', style: CkText.mono(10, color: const Color(0xFFEF4444))),
    };
    final body = Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.asset('assets/covers/${look.$1}.jpg', width: compact ? 26 : 30, height: compact ? 36 : 42, fit: BoxFit.cover),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (showClient) ...[
            Text(it.name.isEmpty ? '—' : it.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
          ],
          typeLine,
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: _short),
              if (_made.isNotEmpty) TextSpan(text: '${_short.isEmpty ? '' : ' · '}$_made', style: const TextStyle(color: CkColors.labelMono)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CkText.mono(11, color: CkColors.textSecondary),
          ),
        ]),
      ),
      const SizedBox(width: 6),
      right,
    ]);
    final faded = greyed(body, on: s == ReportState.expired);
    final card = compact
        ? Container(
            padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
            decoration: BoxDecoration(color: CkColors.field, borderRadius: BorderRadius.circular(12), border: Border.all(color: CkColors.panelStroke)),
            child: faded,
          )
        : Glass(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.fromLTRB(10, 10, 8, 10), child: faded);
    return card;
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

/// Keeps a history list fresh while anything is generating.
mixin _HistoryPoll<T extends StatefulWidget> on State<T> {
  late Future<List<ReportItem>> history = fetchReports();
  Timer? _poll;

  void reloadHistory() => setState(() => history = fetchReports(force: true));

  void watch(List<ReportItem> l) {
    final busy = l.any((e) => e.pending);
    if (busy && _poll == null) {
      _poll = Timer.periodic(const Duration(seconds: 6), (_) async {
        try {
          final n = await fetchReports(force: true);
          if (!mounted) return;
          setState(() => history = Future.value(n));
          if (!n.any((e) => e.pending)) {
            _poll?.cancel();
            _poll = null;
          }
        } catch (_) {}
      });
    } else if (!busy && _poll != null) {
      _poll?.cancel();
      _poll = null;
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}

// ───────────────────────── prices

/// Report_Prices: {credit, reports:[{Source, Name, Available, Prices:[{Duration, Credit}]}]}
class PriceBook {
  final num balance;
  final Map<String, Map<int, num>> prices;
  final Set<String> unavailable;
  const PriceBook(this.balance, this.prices, this.unavailable);

  num? price(String code, int months) => prices[code]?[months];

  /// Full price = the 3-month rate scaled to the duration, as the software shows it.
  num? full(String code, int months) {
    final base = prices[code]?[3];
    if (base == null || months <= 3) return null;
    return base * months / 3;
  }

  int? save(String code, int months) {
    final p = price(code, months), f = full(code, months);
    if (p == null || f == null || f <= p) return null;
    return ((f - p) / f * 100).round();
  }
}

Future<PriceBook> fetchPrices() async {
  final r = await Api.post(Endpoints.reportPrices, {'uID': int.tryParse(Session.uid) ?? Session.uid});
  final out = <String, Map<int, num>>{};
  final off = <String>{};
  for (final e in Api.list(r, ['reports', 'list', 'data'])) {
    final code = _pick(e, ['Source']).toUpperCase();
    if (code.isEmpty) continue;
    if (e.containsKey('Available') && !_truthy(e['Available'])) off.add(code);
    final ps = e['Prices'];
    if (ps is List) {
      for (final p in ps.whereType<Map>()) {
        final d = int.tryParse('${p['Duration']}');
        final c = num.tryParse('${p['Credit']}');
        if (d != null && c != null) out.putIfAbsent(code, () => {})[d] = c;
      }
    }
  }
  return PriceBook(num.tryParse('${r['credit'] ?? r['Credit'] ?? ''}') ?? 0, out, off);
}

final _nf = NumberFormat.decimalPattern('en_IN');

// ───────────────────────── client Reports tab

class ClientReportsPage extends StatefulWidget {
  const ClientReportsPage({super.key});
  @override
  State<ClientReportsPage> createState() => _ClientReportsPageState();
}

class _ClientReportsPageState extends State<ClientReportsPage> with _HistoryPoll {
  Future<void> _openGroup(ReportGroup g) async {
    final made = await Navigator.of(context).push<bool>(CkRoute(builder: (_) => ReportGroupPage(group: g)));
    if (made == true) reloadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final c = Session.client.value;
    return ClientPage(
      title: 'Reports',
      isRoot: true,
      onRefresh: () async => reloadHistory(),
      children: [
        Text('NEW REPORT', style: CkText.label),
        for (var i = 0; i < kReportGroups.length; i++)
          FadeSlideIn(index: i, child: _GroupCard(kReportGroups[i], onTap: () => _openGroup(kReportGroups[i]))),
        const SizedBox(height: 20),
        Text('HISTORY', style: CkText.label),
        DataBuilder<List<ReportItem>>(
          future: history,
          builder: (ctx, s) {
            if (s.hasError) return ErrorBox(message: 'Couldn\'t load reports.', onRetry: reloadHistory);
            if (!s.hasData) return Skels.reportRows(3);
            final l = reportsFor(s.data!, c);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) watch(l);
            });
            if (l.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 10),
                child: EmptyBox(icon: Icons.description_outlined, title: 'No reports yet', body: 'Reports you generate for this client appear here.'),
              );
            }
            return Column(children: [for (final e in l) ReportRow(e, key: ValueKey(e.key))]);
          },
        ),
      ],
    );
  }
}

class _CoverStack extends StatelessWidget {
  final List<String> covers;
  const _CoverStack(this.covers);
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 92,
        height: 96,
        child: Stack(children: [
          for (var k = 0; k < covers.length; k++)
            Positioned(
              left: k * 14.0,
              top: k * 4.0,
              child: _Cover(covers[k], width: 62),
            ),
        ]),
      );
}

class _Cover extends StatelessWidget {
  final String asset;
  final double width;
  const _Cover(this.asset, {this.width = 66});
  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: width * 1.41,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6))],
          image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
        ),
      );
}

class _SoonTag extends StatelessWidget {
  const _SoonTag([this.text = 'SOON']);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: CkColors.panelStroke)),
        child: Text(text, style: CkText.mono(9.5, color: CkColors.textSecondary)),
      );
}

class _GroupCard extends StatelessWidget {
  final ReportGroup g;
  final VoidCallback onTap;
  const _GroupCard(this.g, {required this.onTap});
  @override
  Widget build(BuildContext context) {
    final card = Glass(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        _CoverStack(g.types.reversed.map((t) => t.coverAsset).toList()),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(g.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
              if (g.soon) ...[const SizedBox(width: 8), const _SoonTag()],
            ]),
            const SizedBox(height: 2),
            Text(g.sub, style: const TextStyle(fontSize: 12.5, color: CkColors.textSecondary)),
            const SizedBox(height: 8),
            Text(g.types.map((t) => t.title.replaceFirst('CK ', '').replaceFirst('GRAH ', '')).join(' · '),
                style: CkText.mono(11, color: CkColors.labelMono)),
          ]),
        ),
        if (!g.soon) const Icon(Icons.chevron_right_rounded, color: CkColors.labelMono),
      ]),
    );
    if (g.soon) return Opacity(opacity: .55, child: card);
    return Pressable(scale: .985, onTap: onTap, child: card);
  }
}

// ───────────────────────── group page: duration → report

class ReportGroupPage extends StatefulWidget {
  final ReportGroup group;
  const ReportGroupPage({super.key, required this.group});
  @override
  State<ReportGroupPage> createState() => _ReportGroupPageState();
}

class _ReportGroupPageState extends State<ReportGroupPage> {
  late int _months = widget.group.durations.last;
  late Future<PriceBook> _prices = fetchPrices();

  Future<void> _generate(ReportType t, PriceBook book) async {
    final price = book.price(t.code, _months);
    if (price == null) return;
    final made = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(type: t, months: _months, price: price, balance: book.balance),
    );
    if (made == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    return ClientPage(
      title: g.title,
      onRefresh: () async => setState(() => _prices = fetchPrices()),
      children: [
        Text('1 · DURATION', style: CkText.label),
        const SizedBox(height: 8),
        Segmented<int>(
          values: g.durations,
          selected: _months,
          label: (v) => '$v months',
          onChanged: (v) => setState(() => _months = v),
          height: 44,
        ),
        const SizedBox(height: 18),
        Text('2 · REPORT', style: CkText.label),
        DataBuilder<PriceBook>(
          future: _prices,
          builder: (ctx, s) {
            if (s.hasError) return ErrorBox(message: 'Couldn\'t load prices.', onRetry: () => setState(() => _prices = fetchPrices()));
            final book = s.data;
            return Column(children: [
              for (var i = 0; i < g.types.length; i++)
                FadeSlideIn(index: i, child: _ReportCard(type: g.types[i], months: _months, book: book, onGenerate: () => _generate(g.types[i], book!))),
            ]);
          },
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportType type;
  final int months;
  final PriceBook? book;
  final VoidCallback onGenerate;
  const _ReportCard({required this.type, required this.months, required this.book, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final soon = type.soon || (book?.unavailable.contains(type.code) ?? false);
    final price = book?.price(type.code, months);
    final full = book?.full(type.code, months);
    final save = book?.save(type.code, months);
    final card = Glass(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Cover(type.coverAsset),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(type.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(type.about, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary, height: 1.35)),
            if (!soon) ...[
              const SizedBox(height: 10),
              if (book == null)
                const Skeleton(width: 110, height: 22, radius: 6)
              else if (price == null)
                Text('Not offered for $months months', style: const TextStyle(fontSize: 12, color: CkColors.textMuted))
              else ...[
                Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                  Text(_nf.format(price), style: CkText.mono(22)),
                  const SizedBox(width: 6),
                  const Text('credits', style: TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                ]),
                if (save != null && full != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(children: [
                      Text(_nf.format(full), style: CkText.mono(12, color: CkColors.labelMono).copyWith(decoration: TextDecoration.lineThrough, decorationColor: CkColors.labelMono)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x265EE38A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0x805EE38A)),
                        ),
                        child: Text('SAVE $save%', style: CkText.mono(10.5, color: const Color(0xFF7BEA9E))),
                      ),
                    ]),
                  ),
              ],
            ],
            const SizedBox(height: 10),
            Row(children: [
              Pressable(
                onTap: () => Navigator.of(context).push(CkRoute(
                    builder: (_) => PdfViewPage(title: '${type.title} · sample', asset: type.sampleAsset, fileName: '${type.title} sample.pdf'))),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('View sample', style: TextStyle(fontSize: 13, color: CkColors.cyan, fontWeight: FontWeight.w500)),
                ),
              ),
              const Spacer(),
              if (soon)
                const _SoonTag('COMING SOON')
              else if (price != null)
                Pressable(
                  onTap: onGenerate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(gradient: CkColors.cta, borderRadius: BorderRadius.circular(11)),
                    child: const Text('Generate', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
            ]),
          ]),
        ),
      ]),
    );
    return soon ? Opacity(opacity: .6, child: card) : card;
  }
}

// ───────────────────────── confirm sheet

class _ConfirmSheet extends StatefulWidget {
  final ReportType type;
  final int months;
  final num price;
  final num balance;
  const _ConfirmSheet({required this.type, required this.months, required this.price, required this.balance});
  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  DateTime _start = DateTime(DateTime.now().year, DateTime.now().month + 1);
  bool _busy = false;

  bool get _low => widget.balance > 0 && widget.balance < widget.price;

  Future<void> _go() async {
    final c = Session.client.value;
    if (c == null) return;
    setState(() => _busy = true);
    try {
      final base = {
        'uID': int.tryParse(Session.uid) ?? Session.uid,
        'mID': int.tryParse(c.mId) ?? c.mId,
        'Month': DateFormat('yyyy-MM').format(_start),
        'Duration': widget.months,
      };
      final r = widget.type.isVibes
          ? await Api.post(Endpoints.vibesGenerate, base)
          : await Api.post(Endpoints.plannerGenerate, {...base, 'Report': widget.type.code});
      if (!mounted) return;
      final ok = Api.ok(r);
      toast(context, Api.msg(r, ok ? 'Generating ${widget.type.title}. It will be ready in History.' : 'Couldn\'t generate the report'), error: !ok);
      if (ok) {
        Api.forget('credits:${Session.uid}');
        Api.forget('reports:${Session.uid}');
        Navigator.pop(context, true);
        return;
      }
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = Session.client.value;
    final end = DateTime(_start.year, _start.month + widget.months - 1);
    final next = DateTime(DateTime.now().year, DateTime.now().month + 1);
    final lead = _start == next ? 'Starts next month' : 'Starts';
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 18, 22 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xF82856AA), Color(0xFC0E2860)]),
        border: Border(top: BorderSide(color: Color(0x4DA0C8FF))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0x4DFFFFFF), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          _Cover(widget.type.coverAsset, width: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${widget.type.title} · ${widget.months} months', style: CkText.h(18)),
              const SizedBox(height: 2),
              Text('for ${c?.name ?? ''}', style: const TextStyle(fontSize: 13, color: CkColors.textSecondary)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
          decoration: BoxDecoration(color: CkColors.field, borderRadius: BorderRadius.circular(12), border: Border.all(color: CkColors.panelStroke)),
          child: Row(children: [
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: '$lead · '),
                TextSpan(
                    text: '${DateFormat('MMM yyyy').format(_start)} – ${DateFormat('MMM yyyy').format(end)}',
                    style: const TextStyle(color: CkColors.textTertiary)),
              ]), style: const TextStyle(fontSize: 13.5)),
            ),
            TextButton(
              onPressed: () async {
                final m = await pickMonth(context, _start);
                if (m != null) setState(() => _start = DateTime(m.year, m.month));
              },
              child: const Text('Change', style: TextStyle(color: CkColors.cyan)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _low
            ? PrimaryButton('Buy credits', icon: Icons.add_card_rounded, onTap: () => openLink('https://software.cosmokundli.com/'))
            : PrimaryButton('Generate · ${_nf.format(widget.price)} credits', loading: _busy, onTap: _go),
        const SizedBox(height: 8),
        Text(
          _low
              ? 'You need ${_nf.format(widget.price - widget.balance)} more credits · balance ${_nf.format(widget.balance)}'
              : widget.balance > 0
                  ? 'Balance ${_nf.format(widget.balance)} credits'
                  : '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: CkColors.labelMono),
        ),
      ]),
    );
  }
}

// ───────────────────────── app-level Reports tab

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});
  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> with _HistoryPoll {
  String _q = '';
  Set<ReportState> _state = {};
  Set<String> _type = {};
  String _sort = 'new';
  static const _types = [('CKP', 'Planner'), ('CKPP', 'Planner Plus'), ('CKPM', 'Planner Max'), ('GV', 'GRAH Vibes')];
  static const _sorts = [
    SortOption('new', 'Newest first', ascending: false),
    SortOption('old', 'Oldest first', ascending: true),
    SortOption('az', 'Client A–Z', ascending: true),
    SortOption('za', 'Client Z–A', ascending: false),
  ];
  static String _stateLabel(ReportState s) => switch (s) { ReportState.generating => 'Generating', ReportState.ready => 'Ready', ReportState.expired => 'Expired', _ => s.name };
  late Future<Map<String, dynamic>> _credits = Api.post(Endpoints.credits, {'uID': Session.uid});

  @override
  Widget build(BuildContext context) => CkScaffold(
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              reloadHistory();
              setState(() => _credits = Api.post(Endpoints.credits, {'uID': Session.uid}));
            },
            child: DataBuilder<List<ReportItem>>(
              future: history,
              builder: (ctx, s) {
                final all = s.data ?? const <ReportItem>[];
                if (s.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) watch(all);
                  });
                }
                int count(ReportState? st) => st == null ? all.length : all.where((e) => e.state == st).length;
                final l = all
                    .where((e) => _state.isEmpty || _state.contains(e.state))
                    .where((e) => _type.isEmpty || _type.contains(e.source))
                    .where((e) => _q.isEmpty || '${e.name} ${e.title}'.toLowerCase().contains(_q))
                    .toList();
                int byDate(ReportItem a, ReportItem b) {
                  final c = (a.created ?? DateTime(0)).compareTo(b.created ?? DateTime(0));
                  return c != 0 ? c : (int.tryParse(a.id) ?? 0).compareTo(int.tryParse(b.id) ?? 0);
                }

                switch (_sort) {
                  case 'old':
                    l.sort(byDate);
                  case 'az':
                    l.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  case 'za':
                    l.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                  default:
                    l.sort((a, b) => byDate(b, a));
                }
                final grouped = _sort == 'new' || _sort == 'old';
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final groups = <String, List<ReportItem>>{};
                for (final e in l) {
                  final c = e.created;
                  final g = c == null
                      ? 'Earlier'
                      : !c.isBefore(today)
                          ? 'Today'
                          : c.isAfter(today.subtract(const Duration(days: 7)))
                              ? 'This week'
                              : 'Earlier';
                  groups.putIfAbsent(g, () => []).add(e);
                }
                return ListView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 16, 18, 120),
                  children: [
                    Text('ALL CLIENTS', style: CkText.label),
                    const SizedBox(height: 6),
                    Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                      Expanded(child: Text('Reports', style: CkText.h(26))),
                      DataBuilder<Map<String, dynamic>>(
                        future: _credits,
                        builder: (_, cs) {
                          final v = num.tryParse('${cs.data?['Remaining_Credit'] ?? ''}');
                          return Text(v == null ? '' : '${_nf.format(v)} CR', style: CkText.mono(12, color: CkColors.textSecondary));
                        },
                      ),
                    ]),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                      decoration: const InputDecoration(hintText: 'Search client or report', prefixIcon: Icon(Icons.search_rounded)),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: FilterDropdown<ReportState>(
                          label: 'Status',
                          values: _state,
                          allCount: count(null),
                          onChanged: (v) => setState(() => _state = v),
                          options: [
                            FilterOption(ReportState.generating, 'Generating', count: count(ReportState.generating)),
                            FilterOption(ReportState.ready, 'Ready', count: count(ReportState.ready)),
                            FilterOption(ReportState.expired, 'Expired', count: count(ReportState.expired)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilterDropdown<String>(
                          label: 'Report',
                          values: _type,
                          allCount: all.length,
                          onChanged: (v) => setState(() => _type = v),
                          options: [
                            for (final e in _types)
                              FilterOption(e.$1, e.$2, count: all.where((x) => x.source == e.$1).length),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SortButton<String>(
                        value: _sort,
                        onChanged: (v) => setState(() => _sort = v),
                        options: _sorts,
                      ),
                    ]),
                    ActiveFilters([
                      if (_state.isNotEmpty)
                        (Icons.check_rounded, _state.length == 1 ? _stateLabel(_state.first) : '${_state.length} selected', () => setState(() => _state = {})),
                      if (_type.isNotEmpty)
                        (Icons.check_rounded, _type.length == 1 ? _types.firstWhere((t) => t.$1 == _type.first, orElse: () => (_type.first, _type.first)).$2 : '${_type.length} selected', () => setState(() => _type = {})),
                      if (_sort != 'new')
                        (() {
                          final c = _sorts.firstWhere((o) => o.value == _sort);
                          return (c.ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, c.label, () => setState(() => _sort = 'new'));
                        })(),
                    ]),
                    if (s.hasError)
                      ErrorBox(message: 'Couldn\'t load reports.', onRetry: reloadHistory)
                    else if (!s.hasData)
                      Skels.reportRows(6)
                    else if (l.isEmpty)
                      const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: EmptyBox(icon: Icons.description_outlined, title: 'No reports', body: 'Nothing matches these filters.'))
                    else if (!grouped)
                      for (final e in l) ReportRow(e, key: ValueKey(e.key), showClient: true)
                    else
                      for (final g in _sort == 'old' ? const ['Earlier', 'This week', 'Today'] : const ['Today', 'This week', 'Earlier'])
                        if (groups[g] != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 18, bottom: 2),
                            child: Text('${g.toUpperCase()} · ${groups[g]!.length}', style: CkText.label),
                          ),
                          for (final e in groups[g]!) ReportRow(e, key: ValueKey(e.key), showClient: true),
                        ],
                  ],
                );
              },
            ),
          ),
        ),
      );
}

Future<void> openLink(String link) async {
  final u = Uri.tryParse(link);
  if (u != null) await launchUrl(u, mode: LaunchMode.externalApplication);
}
