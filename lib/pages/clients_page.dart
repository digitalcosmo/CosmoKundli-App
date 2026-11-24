import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
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

Future<List<Client>> fetchClients() async {
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
  if (!context.mounted) return;
  if (action == 'edit') {
    final saved = await Get.to(() => ClientFormPage(editId: c.mId));
    if (saved != null) onChanged?.call();
  } else if (action == 'delete') {
    final ok = await confirm(context, 'Delete ${c.name}?', 'This removes the client and their charts from your list.', ok: 'Delete', danger: true);
    if (!ok || !context.mounted) return;
    try {
      final r = await Api.post(Endpoints.memberDelete, {'uID': Session.uid, 'mID': c.mId});
      if (!context.mounted) return;
      if (Api.ok(r)) {
        await Session.forget(c.mId);
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

  @override
  void initState() {
    super.initState();
    _future = fetchClients();
  }

  void _reload() => setState(() => _future = fetchClients());

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
            padding: const EdgeInsets.symmetric(horizontal: 18),
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
        child: FutureBuilder<List<Client>>(
          future: _future,
          builder: (c, s) {
            final all = s.data ?? [];
            final q = _q.toLowerCase();
            final list = q.isEmpty
                ? all
                : all.where((e) => e.name.toLowerCase().contains(q) || e.city.toLowerCase().contains(q) || e.dateText.toLowerCase().contains(q)).toList();
            final recent = Session.recent.where((r) => all.isEmpty || all.any((a) => a.mId == r.mId)).toList();
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
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
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
                          if (recent.isNotEmpty && _q.isEmpty) ...[
                            const SizedBox(height: 20),
                            const Text('RECENTLY OPENED', style: CkText.label),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 82,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: recent
                                    .map((r) => Padding(
                                          padding: const EdgeInsets.only(right: 14),
                                          child: Pressable(
                                            onTap: () => openClient(all.firstWhere((a) => a.mId == r.mId, orElse: () => r)),
                                            child: SizedBox(
                                              width: 64,
                                              child: Column(children: [
                                                _Avatar(r, size: 56),
                                                const SizedBox(height: 6),
                                                Text(r.name.split(' ').first,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontSize: 11, color: CkColors.textSecondary)),
                                              ]),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Row(children: [
                            const Text('ALL CLIENTS', style: CkText.label),
                            const Spacer(),
                            if (s.hasData) Text('${all.length} · A–Z', style: CkText.muted.copyWith(fontSize: 12)),
                          ]),
                          const SizedBox(height: 6),
                        ]),
                      ),
                    ),
                    if (s.connectionState != ConnectionState.done)
                      const SliverToBoxAdapter(
                          child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2.4))))
                    else if (s.hasError)
                      SliverToBoxAdapter(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: ErrorBox(message: 'Couldn\'t load your clients.', onRetry: _reload)))
                    else if (list.isEmpty)
                      SliverToBoxAdapter(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: EmptyBox(
                            icon: Icons.people_outline_rounded,
                            title: _q.isEmpty ? 'No clients yet' : 'No match',
                            body: _q.isEmpty ? 'Add your first client to see their CosmoKundli.' : 'Try another name or city.'),
                      ))
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(18, 0, 30, widget.embedded ? 190 : 120),
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
              if (letters.length > 4 && _q.isEmpty)
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
  static const _cols = [Color(0xFF4C8DFF), Color(0xFF8B84FF), Color(0xFF437FD7), Color(0xFF10B981), Color(0xFFEC4899), Color(0xFF8B84FF)];
  @override
  Widget build(BuildContext context) {
    final col = _cols[c.name.hashCode.abs() % _cols.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x598CBEFF)),
      ),
      alignment: Alignment.center,
      child: Text(c.initials, style: CkText.h(size * .3).copyWith(color: Color.lerp(col, Colors.white, .75))),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final int index;
  final VoidCallback onChanged;
  const _ClientCard({super.key, required this.client, required this.index, required this.onChanged});
  @override
  Widget build(BuildContext context) => _maybeAnimate(
        index,
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Pressable(
            scale: .98,
            onTap: () => openClient(client),
            child: Glass(
              radius: 16,
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
              child: Row(children: [
                _Avatar(client),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(child: Text(client.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                      if (client.genderText.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(client.genderText, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      [
                        client.birth == null ? client.dateText : DateFormat('dd-MM-yyyy').format(client.birth!),
                        client.timeText,
                        client.city,
                      ].where((e) => e.trim().isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CkText.mono(11.5, color: CkColors.textSecondary),
                    ),
                  ]),
                ),
                IconButton(
                  tooltip: 'More for ${client.name}',
                  onPressed: () => clientMenu(context, client, onChanged: onChanged),
                  icon: const Icon(Icons.more_vert_rounded, color: CkColors.textSecondary),
                ),
              ]),
            ),
          ),
        ),
      );
}

// Only the first screenful animates in; cards re-created while scrolling
// appear instantly so the list never flickers.
Widget _maybeAnimate(int index, Widget child) =>
    index < 8 ? FadeSlideIn(index: index, child: child) : child;

Future<void> editClient(BuildContext context, Client c) async {
  final saved = await Get.to(() => ClientFormPage(editId: c.mId));
  if (saved != null) Session.client.value = Session.client.value;
}
