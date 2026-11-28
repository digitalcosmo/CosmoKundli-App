import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
import '../core/client_data.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import 'account_pages.dart';
import 'client_form_page.dart';
import 'client_shell.dart';

class ClientsPage extends StatefulWidget {
  final bool embedded;
  const ClientsPage({super.key, this.embedded = false});
  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

/// Client list, shared by every screen that needs it (one call per minute
/// at most); [force] after adding, editing or deleting, or pull-to-refresh.
Future<List<Client>> fetchClients({bool force = false}) =>
    Api.shared('clients:${Session.uid}', _fetchClients, force: force);

Future<List<Client>> _fetchClients() async {
  final r = await Api.post(Endpoints.memberList, {'uID': Session.uid});
  final list = Api.list(r, ['members', 'list']).map(Client.fromJson).where((c) => c.mId.isNotEmpty).toList();
  list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return list;
}

void openClient(Client c) {
  Session.open(c);
  Get.to(() => const ClientShell());
}

Future<void> clientMenu(BuildContext context, Client c, {VoidCallback? onChanged, bool fromShell = false}) async {
  final action = await showModalBottomSheet<String>(
    useRootNavigator: true,
    context: context,
    builder: (s) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: CkColors.glassStroke, borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 12),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text(c.name, style: CkText.h(17))),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: Color(0xFFFFB27A)),
            title: const Text('Edit details'),
            onTap: () => Navigator.pop(s, 'edit'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF8A8A)),
            title: const Text('Delete client', style: TextStyle(color: Color(0xFFFF8A8A))),
            onTap: () => Navigator.pop(s, 'delete'),
          ),
        ]),
      ),
    ),
  );
  if (!context.mounted || action == null) return;
  await clientAction(context, c, action, onChanged: onChanged, fromShell: fromShell);
}

Future<void> clientAction(BuildContext context, Client c, String action, {VoidCallback? onChanged, bool fromShell = false}) async {
  if (action == 'edit') {
    final saved = await Get.to(() => ClientFormPage(editId: c.mId));
    if (saved != null) onChanged?.call();
  } else if (action == 'delete') {
    final ok = await confirm(context, 'Delete ${c.name}?', 'This can\'t be undone.', ok: 'Delete', danger: true);
    if (!ok || !context.mounted) return;
    try {
      final r = await Api.post(Endpoints.memberDelete, {'uID': Session.uid, 'mID': c.mId});
      if (!context.mounted) return;
      if (Api.ok(r)) {
        await Session.forget(c.mId);
        Api.forget('clients:${Session.uid}');
        ClientData.forgetClient(c.mId);
        toast(context, Api.msg(r, 'Client deleted'));
        if (fromShell) Get.back();
        onChanged?.call();
      } else {
        toast(context, Api.msg(r), error: true);
      }
    } catch (_) {
      if (context.mounted) toast(context, 'Couldn\'t delete. Try again.', error: true);
    }
  }
}

class _ClientsPageState extends State<ClientsPage> {
  late Future<List<Client>> _future;
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _keys = <String, GlobalKey>{};
  String _q = '';
  String _sort = 'az'; // az, za, new, old
  Set<int> _gender = {}; // 1 female, 2 male
  Set<String> _year = {};
  Set<String> _place = {};

  List<Client> _apply(List<Client> all) {
    final q = _q.toLowerCase();
    var l = all.where((e) {
      if (q.isNotEmpty && !(e.name.toLowerCase().contains(q) || e.city.toLowerCase().contains(q) || e.dateText.toLowerCase().contains(q))) return false;
      if (_gender.isNotEmpty) {
        final g = e.isFemale ? 1 : (e.genderText.isEmpty ? 0 : 2);
        if (!_gender.contains(g)) return false;
      }
      if (_year.isNotEmpty && !_year.contains('${e.birth?.year ?? ''}')) return false;
      if (_place.isNotEmpty && !_place.contains(e.city.trim())) return false;
      return true;
    }).toList();
    int id(Client c) => int.tryParse(c.mId) ?? 0;
    switch (_sort) {
      case 'za':
        l.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case 'new':
        l.sort((a, b) => id(b).compareTo(id(a)));
      case 'old':
        l.sort((a, b) => id(a).compareTo(id(b)));
      default:
        l.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return l;
  }

  static const _sorts = [
    SortOption('az', 'Name A–Z', ascending: true),
    SortOption('za', 'Name Z–A', ascending: false),
    SortOption('new', 'Recently added', ascending: false),
    SortOption('old', 'Oldest added', ascending: true),
  ];

  Widget _filters(List<Client> all) {
    final years = {for (final c in all) if (c.birth != null) '${c.birth!.year}'}.toList()..sort((a, b) => b.compareTo(a));
    final places = {for (final c in all) if (c.city.trim().isNotEmpty) c.city.trim()}.toList()..sort();
    final sortCur = _sorts.firstWhere((o) => o.value == _sort);
    String join(Iterable<String> l) => l.length == 1 ? l.first : '${l.length} selected';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: FilterDropdown<int>(
            label: 'Gender',
            values: _gender,
            allCount: all.length,
            onChanged: (v) => setState(() => _gender = v),
            options: [
              FilterOption(1, 'Female', count: all.where((e) => e.isFemale).length),
              FilterOption(2, 'Male', count: all.where((e) => !e.isFemale && e.genderText.isNotEmpty).length),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: FilterDropdown<String>(
            label: 'Year',
            values: _year,
            allLabel: 'Any',
            onChanged: (v) => setState(() => _year = v),
            options: [for (final y in years) FilterOption(y, y)],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: FilterDropdown<String>(
            label: 'Place',
            values: _place,
            allLabel: 'Any',
            onChanged: (v) => setState(() => _place = v),
            options: [for (final p in places) FilterOption(p, p)],
          ),
        ),
        const SizedBox(width: 6),
        SortButton<String>(value: _sort, options: _sorts, onChanged: (v) => setState(() => _sort = v)),
      ]),
      ActiveFilters([
        if (_gender.isNotEmpty) (Icons.check_rounded, join(_gender.map((g) => g == 1 ? 'Female' : 'Male')), () => setState(() => _gender = {})),
        if (_year.isNotEmpty) (Icons.check_rounded, join(_year), () => setState(() => _year = {})),
        if (_place.isNotEmpty) (Icons.check_rounded, join(_place), () => setState(() => _place = {})),
        if (_sort != 'az') (sortCur.ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, sortCur.label, () => setState(() => _sort = 'az')),
      ]),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _future = fetchClients();
  }

  void _reload() => setState(() => _future = fetchClients(force: true));

  void _jump(String letter) {
    final k = _keys[letter];
    if (k?.currentContext != null) {
      Scrollable.ensureVisible(k!.currentContext!, duration: CkMotion.base, curve: CkMotion.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: widget.embedded ? 74 : 8),
        child: Pressable(
          onTap: () async {
            final r = await Get.to(() => const ClientFormPage());
            if (r != null) _reload();
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF07E22)]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Color(0x66F07E22), blurRadius: 24, offset: Offset(0, 8))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, color: Colors.white),
              const SizedBox(width: 6),
              Text('New client', style: CkText.h(15, w: FontWeight.w600)),
            ]),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: DataBuilder<List<Client>>(
          future: _future,
          builder: (c, s) {
            final all = s.data ?? [];
            final list = _apply(all);
            _keys.clear();
            final letters = <String>[];
            for (final cl in list) {
              final l = cl.name.isEmpty ? '#' : cl.name[0].toUpperCase();
              if (!letters.contains(l)) letters.add(l);
            }
            return Stack(children: [
              RefreshIndicator(
                onRefresh: () async => _reload(),
                child: CustomScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 18, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(s.hasData ? '${all.length} CLIENTS' : 'CLIENTS', style: CkText.label),
                                const SizedBox(height: 6),
                                Text('Clients', style: CkText.h(26)),
                              ]),
                            ),
                            if (!widget.embedded) Pressable(
                              onTap: () => Get.to(() => const AccountPage()),
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0x1AFFFFFF),
                                    border: Border.all(color: const Color(0x4DFFFFFF))),
                                child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _search,
                            onChanged: (v) => setState(() => _q = v),
                            decoration: InputDecoration(
                              hintText: 'Search name, city or date',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _q.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () => setState(() {
                                            _search.clear();
                                            _q = '';
                                          }),
                                      icon: const Icon(Icons.close_rounded)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _filters(all),
                          const SizedBox(height: 6),
                        ]),
                      ),
                    ),
                    if (s.connectionState != ConnectionState.done)
                      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Skels.clientCards(8)))
                    else if (s.hasError)
                      SliverToBoxAdapter(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ErrorBox(message: 'Couldn\'t load your clients.', onRetry: _reload)))
                    else if (list.isEmpty)
                      SliverToBoxAdapter(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: EmptyBox(
                            icon: Icons.people_outline_rounded,
                            title: _q.isEmpty ? 'No clients yet' : 'No match',
                            body: _q.isEmpty ? 'Add your first client to see their CosmoKundli.' : 'Try another name or city.'),
                      ))
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, widget.embedded ? 190 : 120),
                        sliver: SliverList.builder(
                          itemCount: list.length,
                          itemBuilder: (c, i) {
                            final cl = list[i];
                            final l = cl.name.isEmpty ? '#' : cl.name[0].toUpperCase();
                            Key? key;
                            if (i == 0 || (list[i - 1].name.isEmpty ? '#' : list[i - 1].name[0].toUpperCase()) != l) {
                              key = _keys.putIfAbsent(l, () => GlobalKey());
                            }
                            return _ClientCard(key: key, client: cl, index: i, onChanged: _reload);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              if (false)
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                      decoration: BoxDecoration(color: const Color(0x660E2F66), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: letters
                            .map((l) => GestureDetector(
                                  onTap: () => _jump(l),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 4),
                                    child: Text(l, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: CkColors.textSecondary)),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Client c;
  final double size;
  const _Avatar(this.c, {this.size = 46});
  @override
  Widget build(BuildContext context) {
    final col = c.isFemale ? const Color(0xFFF4A6D7) : CkColors.cyan;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x0FFFFFFF),
        border: Border.all(color: col.withValues(alpha: .45), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(c.initials, style: CkText.h(size * .32).copyWith(color: col)),
    );
  }
}

/// Glass client card: tap opens, ⋮ or swipe-left reveals Edit / Delete.
class _ClientCard extends StatefulWidget {
  final Client client;
  final int index;
  final VoidCallback onChanged;
  const _ClientCard({super.key, required this.client, required this.index, required this.onChanged});
  @override
  State<_ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<_ClientCard> {
  static const _reveal = 140.0;
  double _dx = 0;
  bool _dragging = false;

  void _snap(bool open) => setState(() {
        _dragging = false;
        _dx = open ? -_reveal : 0;
      });

  Future<void> _act(String a) async {
    _snap(false);
    await clientAction(context, widget.client, a, onChanged: widget.onChanged);
  }

  Widget _btn(String t, Color c, String a) => Expanded(
        child: Pressable(
          onTap: () => _act(a),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.withValues(alpha: .2), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withValues(alpha: .6))),
            child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: a == 'delete' ? const Color(0xFFF6B8B8) : Colors.white)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cl = widget.client;
    final line = [
      cl.birth == null ? cl.dateText : DateFormat('dd MMM yyyy').format(cl.birth!),
      cl.timeText,
      cl.city,
    ].where((e) => e.trim().isNotEmpty).join(' · ');
    // only the first screenful animates in; cards built while scrolling
    // appear at once (no delayed fades = no flicker on fast scroll)
    final Widget Function(Widget) enter = widget.index < 10 ? (c) => FadeSlideIn(index: widget.index, child: c) : (c) => c;
    return RepaintBoundary(child: enter(
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(children: [
            // actions exist only while the card is swiped open, so they never
            // show through the see-through card while scrolling
            if (_dx < 0 || _dragging)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: _reveal - 8,
                  child: Row(children: [
                    _btn('Edit', CkColors.cyan, 'edit'),
                    const SizedBox(width: 6),
                    _btn('Delete', const Color(0xFFEF4444), 'delete'),
                  ]),
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragStart: (_) => setState(() => _dragging = true),
              onHorizontalDragUpdate: (d) => setState(() => _dx = (_dx + d.delta.dx).clamp(-_reveal, 0)),
              onHorizontalDragEnd: (d) => _snap(d.primaryVelocity != null && d.primaryVelocity! < -200 ? true : _dx < -_reveal / 2 && (d.primaryVelocity ?? 0) <= 200),
              child: AnimatedContainer(
                duration: _dragging ? Duration.zero : CkMotion.base,
                curve: kEase,
                transform: Matrix4.translationValues(_dx, 0, 0),
                child: Pressable(
                  scale: .98,
                  onTap: () => _dx < 0 ? _snap(false) : openClient(cl),
                  child: Glass(
                    radius: 18,
                    // same glass as every other card
                    padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                    child: Row(children: [
                      _Avatar(cl, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Flexible(child: Text(cl.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                            if (cl.genderText.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(6)),
                                child: Text(cl.isFemale ? 'F' : 'M', style: CkText.mono(10, color: CkColors.textSecondary)),
                              ),
                            ],
                          ]),
                          const SizedBox(height: 4),
                          Text(line, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.mono(11.5, color: CkColors.textSecondary)),
                        ]),
                      ),
                      IconButton(
                        tooltip: 'More for ${cl.name}',
                        onPressed: () => clientMenu(context, cl, onChanged: widget.onChanged),
                        icon: const Icon(Icons.more_vert_rounded, color: CkColors.textSecondary),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    ));
  }
}

Future<void> editClient(BuildContext context, Client c) async {
  final saved = await Get.to(() => ClientFormPage(editId: c.mId));
  if (saved != null) {
    // birth data may have changed: drop everything kept for this client
    await ClientData.forgetClient(c.mId);
    Api.forget('clients:${Session.uid}');
    Session.client.value = Session.client.value;
  }
}
