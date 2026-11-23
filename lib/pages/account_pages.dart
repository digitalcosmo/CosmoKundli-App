import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../main.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';

/// Shared frame for account pages: back button, title, scrolling body,
/// optional fixed action button.
class AccountFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? action;
  const AccountFrame({super.key, required this.title, required this.children, this.action});
  @override
  Widget build(BuildContext context) => CkScaffold(
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Row(children: [
                CircleBtn(Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: () => Get.back()),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: CkText.h(22))),
              ]),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 6, 16, action == null ? 30 : 110),
                children: children,
              ),
            ),
          ]),
        ),
        bottomNavigationBar: action == null
            ? null
            : SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 12), child: action)),
      );
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final Future<List<Map<String, dynamic>>> _f = Future.wait([
    Api.post(Endpoints.profileDetails, {'uID': Session.uid}),
    Api.post(Endpoints.credits, {'uID': Session.uid}),
  ]);

  Widget _row(String t, IconData i, String d, Widget page, bool first) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.to(() => page),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0x14FFFFFF)))),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: CkColors.orangeTint, borderRadius: BorderRadius.circular(12), border: Border.all(color: CkColors.orangeStroke)),
              child: Icon(i, size: 18, color: const Color(0xFFFFB27A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                if (d.isNotEmpty) Text(d, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: CkColors.textMuted),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => AccountFrame(
        title: 'Account',
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _f,
            builder: (c, s) {
              final p = s.data?[0] ?? {};
              final cr = s.data?[1] ?? {};
              final name = (p['Name'] ?? '').toString();
              return Glass(
                radius: 26,
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(gradient: CkColors.cta, borderRadius: BorderRadius.circular(21)),
                      alignment: Alignment.center,
                      child: Text(name.isEmpty ? '' : name.trim().split(' ').map((e) => e.isEmpty ? '' : e[0]).take(2).join().toUpperCase(),
                          style: CkText.h(20)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name.isEmpty ? (s.hasData ? 'Your account' : '…') : name, style: CkText.h(18)),
                        Text((p['Email'] ?? '').toString(), style: CkText.muted),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: CkColors.glassFill, borderRadius: BorderRadius.circular(18)),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('AVAILABLE CREDIT', style: CkText.label),
                          Text(cr['Remaining_Credit'] == null ? '—' : NumberFormat.decimalPattern('en_IN').format(num.tryParse('${cr['Remaining_Credit']}') ?? 0),
                              style: CkText.h(24, color: const Color(0xFFF7A45E))),
                        ]),
                      ),
                      SizedBox(width: 120, child: PrimaryButton('Buy credit', height: 42, onTap: () => _buy(context))),
                    ]),
                  ),
                ]),
              );
            },
          ),
          Glass(
            margin: const EdgeInsets.only(top: 12),
            radius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(children: [
              _row('Personal details', Icons.person_outline_rounded, 'Name, mobile, date of birth', const PersonalPage(), true),
              _row('Display details', Icons.visibility_outlined, 'How you appear on client reports', const DisplayPage(), false),
              _row('App details', Icons.phone_iphone_rounded, 'Your MyAcharyaji client app', const AppDetailsPage(), false),
              _row('Credit transactions', Icons.account_balance_wallet_outlined, 'Balance and history', const CreditsPage(), false),
              _row('Report history', Icons.history_rounded, 'Every report you generated', const HistoryPage(), false),
              _row('Change password', Icons.lock_outline_rounded, '', const PasswordPage(), false),
            ]),
          ),
          Glass(
            margin: const EdgeInsets.only(top: 12),
            radius: 20,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: CkColors.orangeTint, borderRadius: BorderRadius.circular(12), border: Border.all(color: CkColors.orangeStroke)),
                child: const Icon(Icons.translate_rounded, size: 18, color: Color(0xFFFFB27A)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Chart language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                  Text('Rashi and GRAH labels on charts', style: TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
                ]),
              ),
              ValueListenableBuilder<String>(
                valueListenable: Session.lang,
                builder: (c, l, _) => SizedBox(
                  width: 132,
                  child: Segmented<String>(
                    values: const ['en', 'hi', 'gu'],
                    selected: l,
                    height: 36,
                    label: (v) => v.toUpperCase(),
                    onChanged: Session.setLang,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          GhostButton('Log out', icon: Icons.logout_rounded, color: const Color(0xFFFF8A8A), onTap: () async {
            if (await confirm(context, 'Log out?', 'You can sign in again any time.', ok: 'Log out', danger: true)) {
              await Session.signOut();
              goLogin();
            }
          }),
        ],
      );

  void _buy(BuildContext context) async {
    final uri = Uri.parse('https://software.cosmokundli.com/');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      toast(context, 'Couldn\'t open the website', error: true);
    }
  }
}

// ───────────────────────── Personal

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});
  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  String _gender = 'Male';
  DateTime? _dob;
  bool _loading = true, _busy = false;

  @override
  void initState() {
    super.initState();
    Api.post(Endpoints.profileDetails, {'uID': Session.uid}).then((r) {
      _name.text = '${r['Name'] ?? ''}';
      _mobile.text = '${r['Mobile'] ?? ''}';
      _email.text = '${r['Email'] ?? ''}';
      _gender = '${r['Gender'] ?? ''}'.toLowerCase().startsWith('f') ? 'Female' : 'Male';
      for (final f in ['yyyy-MM-dd', 'dd-MM-yyyy']) {
        try {
          _dob = DateFormat(f).parseStrict('${r['DOB']}');
          break;
        } catch (_) {}
      }
      if (mounted) setState(() => _loading = false);
    }).catchError((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final r = await Api.post(Endpoints.profileUpdate, {
        'uID': Session.uid,
        'name': _name.text.trim(),
        'gender': _gender.toLowerCase(),
        'dob': _dob == null ? '' : DateFormat('yyyy-MM-dd').format(_dob!),
        'mobile': _mobile.text.trim(),
      });
      if (mounted) toast(context, Api.msg(r, Api.ok(r) ? 'Saved' : 'Couldn\'t save'), error: !Api.ok(r));
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => AccountFrame(
        title: 'Personal details',
        action: _loading ? null : PrimaryButton('Save changes', loading: _busy, onTap: _save),
        children: _loading
            ? [const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)))]
            : [
                Glass(
                  radius: 24,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Field('Name', controller: _name, required: true),
                    Field('Mobile number', controller: _mobile, keyboard: TextInputType.phone),
                    const SizedBox(height: 12),
                    const Text('GENDER', style: CkText.label),
                    const SizedBox(height: 6),
                    ChoiceChips<String>(values: const ['Female', 'Male'], selected: _gender, label: (v) => v, onChanged: (v) => setState(() => _gender = v)),
                    Field('Date of birth',
                        controller: TextEditingController(text: _dob == null ? '' : DateFormat('dd MMM yyyy').format(_dob!)),
                        icon: Icons.calendar_today_outlined,
                        readOnly: true, onTap: () async {
                      final d = await showDatePicker(
                          context: context, initialDate: _dob ?? DateTime(1990), firstDate: DateTime(1900), lastDate: DateTime.now());
                      if (d != null) setState(() => _dob = d);
                    }),
                    Field('Email', controller: _email, readOnly: true),
                  ]),
                ),
              ],
      );
}

// ───────────────────────── Display details (4-page report preview)

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});
  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _message = TextEditingController();
  final _address = TextEditingController();
  final _email = TextEditingController();
  String _front = '', _back = '';
  bool _loading = true, _busy = false, _uploading = false;
  int _page = 0;
  final _pc = PageController(viewportFraction: .78);

  @override
  void initState() {
    super.initState();
    Api.post(Endpoints.displayDetails, {'uID': Session.uid}).then((r) {
      _name.text = '${r['Name'] ?? ''}';
      _mobile.text = '${r['Mobile'] ?? ''}';
      _message.text = '${r['Message'] ?? ''}';
      _address.text = '${r['Address'] ?? ''}';
      _email.text = '${r['Email'] ?? ''}';
      _front = '${r['Front_Img'] ?? ''}';
      _back = '${r['Back_Img'] ?? ''}';
      if (mounted) setState(() => _loading = false);
    }).catchError((_) {
      if (mounted) setState(() => _loading = false);
    });
    for (final c in [_name, _mobile, _message, _address, _email]) {
      c.addListener(() => setState(() {}));
    }
  }

  Future<void> _upload(bool front) async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (x == null) return;
    setState(() => _uploading = true);
    try {
      final r = await Api.upload(front ? Endpoints.displayFront : Endpoints.displayBack, Session.uid, x.path);
      if (!mounted) return;
      if (Api.ok(r)) {
        final again = await Api.post(Endpoints.displayDetails, {'uID': Session.uid});
        setState(() {
          _front = '${again['Front_Img'] ?? _front}';
          _back = '${again['Back_Img'] ?? _back}';
        });
        toast(context, Api.msg(r, 'Image updated'));
      } else {
        toast(context, Api.msg(r), error: true);
      }
    } catch (_) {
      if (mounted) toast(context, 'Upload failed. Try again.', error: true);
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final r = await Api.post(Endpoints.displayUpdate, {
        'uID': Session.uid,
        'name': _name.text.trim(),
        'message': _message.text.trim(),
        'address': _address.text.trim(),
        'mobile': _mobile.text.trim(),
        'email': _email.text.trim(),
      });
      if (mounted) toast(context, Api.msg(r, Api.ok(r) ? 'Saved' : 'Couldn\'t save'), error: !Api.ok(r));
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  static const _labels = ['1 · Title', '2 · Front inner', 'Back inner', 'Last'];
  static const _captions = [
    ('Page 1 · Title page', '*Client name and time range are filled per report'),
    ('Page 2 · Front inner', 'Your page, placed right after the title'),
    ('Back inner', 'Your page, placed before the last page'),
    ('Last page', 'Your contact details close every report'),
  ];

  Widget _pageView(int i, {bool thumb = false}) {
    final r = BorderRadius.circular(thumb ? 8 : 12);
    Widget child;
    switch (i) {
      case 0:
        child = Image.asset('assets/images/report_title.png', fit: BoxFit.cover);
        break;
      case 1:
      case 2:
        final url = i == 1 ? _front : _back;
        child = url.isEmpty
            ? Container(
                color: const Color(0xFF0B1A3E),
                alignment: Alignment.center,
                child: thumb
                    ? const Icon(Icons.add_rounded, color: CkColors.textSecondary)
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(color: CkColors.orangeTint, borderRadius: BorderRadius.circular(18)),
                            child: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFFFB27A), size: 26),
                          ),
                          const SizedBox(height: 10),
                          Text('Upload ${i == 1 ? 'front' : 'back'} inner page', textAlign: TextAlign.center, style: CkText.h(15)),
                          const SizedBox(height: 6),
                          const Text('A full A4 portrait page', style: CkText.muted),
                        ]),
                      ),
              )
            : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined));
        break;
      default:
        // Same template and text positions as the software's last page
        // (styles.css .dd-t--last-*): the art is fixed, only text changes.
        child = LayoutBuilder(builder: (c, box) {
          final w = box.maxWidth, h = box.maxHeight;
          TextStyle st(double cqw, FontWeight fw, {double ls = 0, bool ph = false}) => GoogleFonts.poppins(
              fontSize: w * cqw / 100, fontWeight: fw, letterSpacing: w * cqw / 100 * ls,
              color: ph ? Colors.white54 : Colors.white, height: 1.25);
          Widget centred(double top, String v, String ph, TextStyle s) => Positioned(
                left: w * .19, right: w * .19, top: h * top - s.fontSize! * .7,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(v.isEmpty ? ph : v, maxLines: 1, style: v.isEmpty ? s.copyWith(color: Colors.white54) : s)),
              );
          Widget left(double top, String v, String ph, {int lines = 1}) {
            final s = st(2.6, FontWeight.w500);
            return Positioned(
              left: w * .334, width: w * .46, top: h * top - s.fontSize! * .65,
              child: Text(v.isEmpty ? ph : v, maxLines: lines, overflow: TextOverflow.ellipsis,
                  style: v.isEmpty ? s.copyWith(color: Colors.white54) : s),
            );
          }

          return Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/report_last.jpg', fit: BoxFit.fill),
            centred(.383, _name.text, 'Consultant Name', st(5.9, FontWeight.w700, ls: .07)),
            centred(.437, _message.text, 'Consultant Message', st(3.55, FontWeight.w500, ls: .07)),
            left(.538, _mobile.text, 'Display Number'),
            left(.585, _email.text, 'Display E-mail'),
            left(.638, _address.text, 'Display Address', lines: 2),
          ]);
        });
    }
    return ClipRRect(
      borderRadius: r,
      child: Container(
        decoration: BoxDecoration(borderRadius: r, border: Border.all(color: Colors.white.withOpacity(.25))),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cap = _captions[_page];
    return AccountFrame(
      title: 'Display details',
      action: _loading ? null : PrimaryButton('Save', loading: _busy, onTap: _save),
      children: _loading
          ? [const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)))]
          : [
              const Text('How you appear on every report you send.', style: CkText.muted),
              Glass(
                margin: const EdgeInsets.only(top: 10),
                radius: 26,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(children: [
                  SizedBox(
                    height: 380,
                    child: PageView.builder(
                      controller: _pc,
                      itemCount: 4,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (c, i) => AnimatedScale(
                        scale: i == _page ? 1 : .92,
                        duration: CkMotion.base,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: (i == 1 || i == 2) ? () => _upload(i == 1) : null,
                            child: AspectRatio(aspectRatio: 1 / 1.414, child: _pageView(i)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        4,
                        (i) => AnimatedContainer(
                              duration: CkMotion.base,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _page ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: i == _page ? CkColors.orangeSoft : Colors.white.withOpacity(.3), borderRadius: BorderRadius.circular(3)),
                            )),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cap.$1, style: CkText.h(16)),
                      Text(cap.$2, style: CkText.muted.copyWith(fontSize: 12)),
                      if (_page == 1 || _page == 2) ...[
                        const SizedBox(height: 10),
                        Pressable(
                          onTap: _uploading ? null : () => _upload(_page == 1),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: CkColors.orangeStroke)),
                            alignment: Alignment.center,
                            child: _uploading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text('${(_page == 1 ? _front : _back).isEmpty ? 'Choose' : 'Change'} ${_page == 1 ? 'front' : 'back'} inner image',
                                    style: const TextStyle(color: Color(0xFFFFB27A), fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 122,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for (var i = 0; i < 4; i++) ...[
                        if (i == 2)
                          const SizedBox(
                            width: 44,
                            height: 92,
                            child: Center(
                                child: Text('report\ncontent', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, color: CkColors.textMuted))),
                          ),
                        GestureDetector(
                          onTap: () => _pc.animateToPage(i, duration: CkMotion.slow, curve: CkMotion.ease),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(children: [
                              Container(
                                width: 64,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: i == _page ? CkColors.orangeSoft : Colors.transparent, width: 2),
                                ),
                                child: _pageView(i, thumb: true),
                              ),
                              const SizedBox(height: 5),
                              Text(_labels[i],
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: i == _page ? FontWeight.w800 : FontWeight.w500,
                                      color: i == _page ? const Color(0xFFF7A45E) : CkColors.textSecondary)),
                            ]),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ]),
              ),
              Glass(
                margin: const EdgeInsets.only(top: 12),
                radius: 24,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(children: [
                  Field('Display name', controller: _name),
                  Field('Mobile', controller: _mobile, keyboard: TextInputType.phone),
                  Field('Message', controller: _message),
                  Field('Address', controller: _address, maxLines: 2),
                  Field('Email', controller: _email, keyboard: TextInputType.emailAddress),
                ]),
              ),
            ],
    );
  }
}

// ───────────────────────── App details

class AppDetailsPage extends StatefulWidget {
  const AppDetailsPage({super.key});
  @override
  State<AppDetailsPage> createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage> {
  final _appName = TextEditingController();
  final _code = TextEditingController();
  final _desc = TextEditingController();
  String _icon = '';
  bool _loading = true, _busy = false, _uploading = false;

  @override
  void initState() {
    super.initState();
    Api.post(Endpoints.appDetails, {'uID': Session.uid}).then((r) {
      _appName.text = '${r['App_Name'] ?? ''}';
      _code.text = '${r['App_Code'] ?? ''}';
      _desc.text = '${r['Description'] ?? ''}';
      _icon = '${r['Icon'] ?? ''}';
      if (mounted) setState(() => _loading = false);
    }).catchError((_) {
      if (mounted) setState(() => _loading = false);
    });
    for (final c in [_appName, _desc]) {
      c.addListener(() => setState(() {}));
    }
  }

  Future<void> _uploadIcon() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 90);
    if (x == null) return;
    setState(() => _uploading = true);
    try {
      final r = await Api.upload(Endpoints.appIcon, Session.uid, x.path);
      if (!mounted) return;
      if (Api.ok(r)) {
        final again = await Api.post(Endpoints.appDetails, {'uID': Session.uid});
        setState(() => _icon = '${again['Icon'] ?? _icon}');
        toast(context, Api.msg(r, 'Icon updated'));
      } else {
        toast(context, Api.msg(r), error: true);
      }
    } catch (_) {
      if (mounted) toast(context, 'Upload failed. Try again.', error: true);
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final r = await Api.post(Endpoints.appUpdate, {'uID': Session.uid, 'description': _desc.text.trim()});
      if (mounted) toast(context, Api.msg(r, Api.ok(r) ? 'Saved' : 'Couldn\'t save'), error: !Api.ok(r));
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _iconBox(double s) => ClipRRect(
        borderRadius: BorderRadius.circular(s * .28),
        child: SizedBox(
          width: s,
          height: s,
          child: _icon.isEmpty
              ? Container(decoration: const BoxDecoration(gradient: CkColors.cta))
              : CachedNetworkImage(imageUrl: _icon, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(decoration: const BoxDecoration(gradient: CkColors.cta))),
        ),
      );

  @override
  Widget build(BuildContext context) => AccountFrame(
        title: 'App details',
        action: _loading ? null : PrimaryButton('Save', loading: _busy, onTap: _save),
        children: _loading
            ? [const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)))]
            : [
                const Text('What your clients see in their MyAcharyaji app.', style: CkText.muted),
                Glass(
                  margin: const EdgeInsets.only(top: 10),
                  radius: 26,
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      const Text('LIVE PREVIEW', style: CkText.label),
                      const Spacer(),
                      _iconBox(28),
                      const SizedBox(width: 8),
                      Text(_appName.text.isEmpty ? 'Your app' : _appName.text, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 14),
                    // phone frame with a simplified client-app home
                    Container(
                      width: 210,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1530),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(.3)),
                        boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 30, offset: Offset(0, 14))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Container(
                          height: 360,
                          color: const Color(0xFFF7F5FF),
                          child: Column(children: [
                            Container(
                              height: 64,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFC0569E)])),
                              alignment: Alignment.center,
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                _iconBox(26),
                                const SizedBox(width: 8),
                                Text(_appName.text.isEmpty ? 'Your app' : _appName.text,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                              ]),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFE3DDF5))),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    const Text('About your Acharyaji',
                                        style: TextStyle(color: Color(0xFF3B2A6B), fontWeight: FontWeight.w800, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Expanded(
                                      child: Text(_desc.text.isEmpty ? 'Your description appears here.' : _desc.text,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(color: Color(0xFF4B4466), fontSize: 11, height: 1.4)),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Updates as you type below', style: TextStyle(fontSize: 11.5, color: CkColors.textMuted)),
                  ]),
                ),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  radius: 24,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Field('App name', controller: _appName, readOnly: true),
                    Field('App code', controller: _code, readOnly: true),
                    Field('About you', controller: _desc, maxLines: 5, hint: 'Describe your practice for your clients…'),
                    const SizedBox(height: 14),
                    const Text('APP ICON', style: CkText.label),
                    const SizedBox(height: 8),
                    Row(children: [
                      _iconBox(56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Pressable(
                          onTap: _uploading ? null : _uploadIcon,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: CkColors.orangeStroke)),
                            alignment: Alignment.center,
                            child: _uploading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Change icon', style: TextStyle(color: Color(0xFFFFB27A), fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ]),
                    const Padding(
                        padding: EdgeInsets.only(top: 6), child: Text('JPG or PNG, square', style: TextStyle(fontSize: 11.5, color: CkColors.textMuted))),
                  ]),
                ),
              ],
      );
}

// ───────────────────────── Credits

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});
  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  late Future<Map<String, dynamic>> _f = Api.post(Endpoints.credits, {'uID': Session.uid});
  String _filter = 'All';

  @override
  Widget build(BuildContext context) => AccountFrame(
        title: 'Credit transactions',
        children: [
          LoadView<Map<String, dynamic>>(
            future: _f,
            onRetry: () => setState(() => _f = Api.post(Endpoints.credits, {'uID': Session.uid})),
            builder: (r) {
              final all = Api.list(r, ['list']);
              final l = _filter == 'All' ? all : all.where((e) => '${e['Type']}'.toLowerCase() == _filter.toLowerCase()).toList();
              final groups = <String, List<Map<String, dynamic>>>{};
              for (final e in l) {
                groups.putIfAbsent('${e['Date'] ?? ''}', () => []).add(e);
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Glass(
                  radius: 22,
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('AVAILABLE CREDIT', style: CkText.label),
                        Text('${r['Remaining_Credit'] ?? '—'}', style: CkText.h(26, color: const Color(0xFFF7A45E))),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 240,
                  child: Segmented<String>(
                      values: const ['All', 'Credit', 'Debit'], selected: _filter, height: 38, label: (v) => v, onChanged: (v) => setState(() => _filter = v)),
                ),
                if (l.isEmpty) const EmptyBox(icon: Icons.receipt_long_outlined, title: 'No transactions', body: 'Nothing to show yet.'),
                ...groups.entries.map((g) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.fromLTRB(4, 14, 4, 6), child: Text(g.key, style: CkText.label)),
                      Glass(
                        radius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: g.value.asMap().entries.map((e) {
                            final credit = '${e.value['Type']}'.toLowerCase() == 'credit';
                            final col = credit ? const Color(0xFF74E2B7) : const Color(0xFFFF8A8A);
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(border: e.key == 0 ? null : const Border(top: BorderSide(color: Color(0x14FFFFFF)))),
                              child: Row(children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(color: col.withOpacity(.15), borderRadius: BorderRadius.circular(11)),
                                  child: Icon(credit ? Icons.south_rounded : Icons.north_rounded, size: 16, color: col),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text('${e.value['Details'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
                                Text('${credit ? '+' : '−'}${e.value['Qty'] ?? ''}', style: TextStyle(fontWeight: FontWeight.w800, color: col)),
                              ]),
                            );
                          }).toList(),
                        ),
                      ),
                    ])),
              ]);
            },
          ),
        ],
      );
}

// ───────────────────────── Report history

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<Map<String, dynamic>> _f = Api.post(Endpoints.reportHistory, {'uID': Session.uid});
  String _q = '';

  @override
  Widget build(BuildContext context) => AccountFrame(
        title: 'Report history',
        children: [
          TextField(
            onChanged: (v) => setState(() => _q = v.toLowerCase()),
            decoration: const InputDecoration(hintText: 'Search client or report', prefixIcon: Icon(Icons.search_rounded)),
          ),
          LoadView<Map<String, dynamic>>(
            future: _f,
            onRetry: () => setState(() => _f = Api.post(Endpoints.reportHistory, {'uID': Session.uid})),
            builder: (r) {
              final l = Api.list(r, ['list'])
                  .where((e) => '${e['Name']} ${e['Type']}'.toLowerCase().contains(_q))
                  .toList();
              if (l.isEmpty) return const EmptyBox(icon: Icons.description_outlined, title: 'No reports', body: 'Reports you generate will show here.');
              return Column(
                children: l.map((e) {
                  final link = '${e['Download_Link'] ?? ''}';
                  final name = '${e['Name'] ?? ''}';
                  return Glass(
                    margin: const EdgeInsets.only(top: 10),
                    radius: 20,
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(gradient: CkColors.cta, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${e['Type'] ?? 'Report'}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text([name, '${e['Month'] ?? ''}', 'made ${e['Date'] ?? ''}'].where((x) => x.trim().isNotEmpty && x != 'made ').join(' · '),
                              style: CkText.muted.copyWith(fontSize: 11.5)),
                          if ('${e['Status'] ?? ''}'.isNotEmpty && link.isEmpty)
                            Text('${e['Status']}', style: const TextStyle(fontSize: 11, color: Color(0xFFFFD063))),
                        ]),
                      ),
                      if (link.isNotEmpty)
                        IconButton(
                          tooltip: 'Download',
                          onPressed: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
                          icon: const Icon(Icons.download_rounded, color: Color(0xFFFFB27A)),
                        ),
                    ]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      );
}

// ───────────────────────── Password

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});
  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _form = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  final _hide = [true, true, true];

  @override
  void initState() {
    super.initState();
    _new.addListener(() => setState(() {}));
  }

  int get _strength {
    final p = _new.text;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final r = await Api.post(Endpoints.changePassword, {'uID': Session.uid, 'oldpassword': _old.text, 'newpassword': _new.text});
      if (!mounted) return;
      toast(context, Api.msg(r, Api.ok(r) ? 'Password updated' : 'Couldn\'t update password'), error: !Api.ok(r));
      if (Api.ok(r)) Get.back();
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _pw(int i, String label, TextEditingController c, {String? Function(String?)? v}) => Field(label,
      controller: c,
      obscure: _hide[i],
      required: true,
      validator: v,
      formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      suffix: IconButton(
          onPressed: () => setState(() => _hide[i] = !_hide[i]),
          icon: Icon(_hide[i] ? Icons.visibility_outlined : Icons.visibility_off_outlined)));

  @override
  Widget build(BuildContext context) {
    const labels = ['Too short', 'Weak', 'Fair', 'Good', 'Strong'];
    return AccountFrame(
      title: 'Change password',
      action: PrimaryButton('Update password', loading: _busy, onTap: _save),
      children: [
        Glass(
          radius: 24,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _pw(0, 'Current password', _old),
              Builder(builder: (c) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _pw(1, 'New password', _new, v: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null),
                  const SizedBox(height: 8),
                  Row(
                      children: List.generate(
                          4,
                          (i) => Expanded(
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                      color: i < _strength ? CkColors.green : CkColors.glassFillStrong, borderRadius: BorderRadius.circular(2)),
                                ),
                              ))),
                  const SizedBox(height: 4),
                  Text(_new.text.isEmpty ? ' ' : labels[_strength], style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
                ]);
              }),
              _pw(2, 'Confirm new password', _confirm, v: (v) => v != _new.text ? 'Passwords don\'t match' : null),
            ]),
          ),
        ),
      ],
    );
  }
}
