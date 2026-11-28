import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
import '../core/countries.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import '../values/app_constants.dart';
import 'client_shell.dart';

/// Birth details collected for a person (used by New/Edit client and Melapak).
class BirthInput {
  DateTime? date;
  TimeOfDay? time;
  int seconds = 0;
  String place = '';
  String lat = '';
  String lng = '';
  String utc = '';

  bool get complete => date != null && time != null && place.isNotEmpty && lat.isNotEmpty && lng.isNotEmpty;
}

/// Reusable "When" + "Where" block.
class BirthFields extends StatefulWidget {
  final BirthInput value;
  final VoidCallback? onChanged;
  const BirthFields({super.key, required this.value, this.onChanged});
  @override
  State<BirthFields> createState() => _BirthFieldsState();
}

class _BirthFieldsState extends State<BirthFields> {
  late final TextEditingController _place = TextEditingController(text: widget.value.place);

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          flex: 7,
          child: _picker('Date of birth', v.date == null ? 'Select date' : DateFormat('dd-MM-yyyy').format(v.date!), Icons.calendar_today_outlined,
              () async {
            final d = await showDatePicker(
                context: context,
                initialDate: v.date ?? DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                initialEntryMode: DatePickerEntryMode.calendarOnly);
            if (d != null) setState(() => v.date = d);
            widget.onChanged?.call();
          }),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: _picker('Time', v.time == null ? 'Select' : v.time!.format(context), Icons.schedule_rounded, () async {
            final t = await showTimePicker(
                context: context,
                initialTime: v.time ?? const TimeOfDay(hour: 12, minute: 0),
                builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: false), child: child!));
            if (t != null) setState(() => v.time = t);
            widget.onChanged?.call();
          }),
        ),
      ]),
      const SizedBox(height: 12),
      Text(upper('Birth place'), style: CkText.label),
      const SizedBox(height: 6),
      AddressAutocompleteTextFormField(
        mapsApiKey: AppConstants.googleMapApiKey,
        controller: _place,
        types: const [AutoCompleteType.cities],
        style: const TextStyle(color: CkColors.text, fontSize: 15),
        decoration: const InputDecoration(hintText: 'Start typing a city…', prefixIcon: Icon(Icons.place_outlined, size: 19)),
        elevation: 12,
        suggestionsOverlayDecoration: BoxDecoration(
          color: const Color(0xFF1C4590),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x598CBEFF)),
          boxShadow: const [BoxShadow(color: Color(0x8C020820), blurRadius: 30, offset: Offset(0, 14))],
        ),
        hoverColor: CkColors.cyanTint,
        selectionColor: CkColors.cyanTint,
        buildItem: (sg, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0x1A8CBEFF)))),
          child: Row(children: [
            const Icon(Icons.place_outlined, size: 16, color: CkColors.cyan),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: sg.mainText ?? sg.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if ((sg.secondaryText ?? '').isNotEmpty) TextSpan(text: ', ${sg.secondaryText}', style: const TextStyle(color: CkColors.textSecondary)),
                ]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, color: CkColors.text),
              ),
            ),
          ]),
        ),
        onSuggestionClick: (p) {
          setState(() {
            v.place = [p.city, p.state, p.country].where((e) => e != null && e.isNotEmpty).join(', ');
            if (v.place.isEmpty) v.place = p.formattedAddress ?? _place.text;
            v.lat = p.lat?.toString() ?? '';
            v.lng = p.lng?.toString() ?? '';
            v.utc = p.utcOffset?.toString() ?? '';
          });
          widget.onChanged?.call();
        },
        onSuggestionClickGetTextToUseForControl: (p) =>
            [p.city, p.state, p.country].where((e) => e != null && e.isNotEmpty).join(', '),
      ),
      const SizedBox(height: 10),
      Row(children: [
        _coord('Latitude', v.lat),
        const SizedBox(width: 8),
        _coord('Longitude', v.lng),
        const SizedBox(width: 8),
        _coord('UTC offset (min)', v.utc),
      ]),
      const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text('Filled in from the place you pick.', style: TextStyle(fontSize: 11.5, color: CkColors.textMuted)),
      ),
    ]);
  }

  Widget _picker(String label, String value, IconData icon, VoidCallback onTap) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(upper(label), style: CkText.label),
          const SizedBox(height: 6),
          Pressable(
            onTap: onTap,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: CkColors.field, borderRadius: BorderRadius.circular(12), border: Border.all(color: CkColors.panelStroke)),
              child: Row(children: [
                Icon(icon, size: 17, color: CkColors.labelMono),
                const SizedBox(width: 8),
                Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.mono(14))),
              ]),
            ),
          ),
        ],
      );

  Widget _coord(String label, String v) => Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          decoration: BoxDecoration(color: CkColors.field, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(upper(label), maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.label),
            const SizedBox(height: 2),
            Text(v.isEmpty ? '—' : (v.length > 8 ? v.substring(0, 8) : v), style: CkText.mono(12.5)),
          ]),
        ),
      );
}

class ClientFormPage extends StatefulWidget {
  final String? editId;
  const ClientFormPage({super.key, this.editId});
  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _middle = TextEditingController();
  final _last = TextEditingController();
  final _mobile = TextEditingController();
  Country _country = kCountries.first;
  String? _gender; // no default: must be chosen
  bool _personalOpen = true;
  final BirthInput _birth = BirthInput();
  bool _loading = false, _busy = false;
  Key _birthKey = UniqueKey();

  bool get _edit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (_edit) _load();
    _mobile.addListener(() {
      if (_mobile.text.length == _country.max && _gender != null) _maybeCollapse();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await Api.post(Endpoints.memberDetails, {'mID': widget.editId});
      _first.text = (r['first_name'] ?? '').toString();
      _middle.text = (r['middle_name'] ?? '').toString().trim();
      _last.text = (r['surname'] ?? '').toString();
      _mobile.text = (r['mobile'] ?? '').toString();
      _country = countryByCode((r['country_code'] ?? '91').toString());
      final g = (r['gender'] ?? '').toString().toLowerCase();
      _gender = g.startsWith('f') ? 'Female' : g.startsWith('m') ? 'Male' : null;
      _personalOpen = !_personalDone;
      final dob = (r['dob'] ?? '').toString();
      for (final f in ['yyyy-MM-dd', 'dd-MM-yyyy', 'dd/MM/yyyy']) {
        try {
          _birth.date = DateFormat(f).parseStrict(dob);
          break;
        } catch (_) {}
      }
      final h = int.tryParse('${r['btime_hrs']}') ?? 0, m = int.tryParse('${r['btime_min']}') ?? 0;
      _birth.time = TimeOfDay(hour: h, minute: m);
      _birth.seconds = int.tryParse('${r['btime_sec']}') ?? 0;
      _birth.place = (r['birth_place'] ?? '').toString();
      _birth.lat = (r['latitude'] ?? '').toString();
      _birth.lng = (r['longitude'] ?? '').toString();
      _birth.utc = (r['timm_diff'] ?? '').toString();
      _birthKey = UniqueKey();
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t load client details', error: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  bool get _personalDone =>
      _first.text.trim().isNotEmpty &&
      _last.text.trim().isNotEmpty &&
      _gender != null &&
      validatePhone(_country, _mobile.text) == null;

  void _maybeCollapse() {
    if (_personalDone && _personalOpen) {
      FocusScope.of(context).unfocus();
      setState(() => _personalOpen = false);
    }
  }

  Future<void> _save({bool open = false}) async {
    if (_gender == null) {
      setState(() => _personalOpen = true);
      return toast(context, 'Select gender', error: true);
    }
    if (!_personalOpen && !_personalDone) setState(() => _personalOpen = true);
    if (!_form.currentState!.validate()) return;
    if (!_birth.complete) return toast(context, 'Add date, time and birth place', error: true);
    setState(() => _busy = true);
    final data = {
      'uID': Session.uid,
      if (_edit) 'mID': widget.editId,
      'first_name': _first.text.trim(),
      'middle_name': _middle.text.trim(),
      'surname': _last.text.trim(),
      'country_code': _country.code,
      'mobile': _mobile.text.trim(),
      'gender': _gender!,
      'dob': DateFormat('yyyy-MM-dd').format(_birth.date!),
      'btime_hrs': _birth.time!.hour.toString().padLeft(2, '0'),
      'btime_min': _birth.time!.minute.toString().padLeft(2, '0'),
      'btime_sec': _birth.seconds.toString().padLeft(2, '0'),
      'birth_place': _birth.place,
      'latitude': _birth.lat,
      'longitude': _birth.lng,
      'timm_diff': _birth.utc,
    };
    try {
      final r = await Api.post(_edit ? Endpoints.memberUpdate : Endpoints.memberAdd, data);
      if (!mounted) return;
      if (Api.ok(r)) {
        toast(context, Api.msg(r, _edit ? 'Client updated' : 'Client added'));
        final mid = (r['mID'] ?? widget.editId ?? '').toString();
        final name = [_first.text, _middle.text, _last.text].where((e) => e.trim().isNotEmpty).join(' ');
        final c = Client(
          mId: mid,
          name: name,
          gender: _gender!,
          dobRaw: DateFormat('dd-MM-yyyy HH:mm:ss')
              .format(DateTime(_birth.date!.year, _birth.date!.month, _birth.date!.day, _birth.time!.hour, _birth.time!.minute)),
          city: _birth.place.split(',').first,
        );
        if (_edit && Session.client.value?.mId == mid) Session.client.value = c;
        Get.back(result: c);
        if (open && mid.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 250));
          Session.open(c);
          Get.to(() => const ClientShell());
        }
      } else {
        toast(context, Api.msg(r), error: true);
      }
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t save. Check your connection.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _section(String title, IconData icon, List<Widget> children) => Glass(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 17, color: CkColors.cyan),
            const SizedBox(width: 8),
            Text(title, style: CkText.h(15.5)),
          ]),
          ...children,
        ]),
      );

  Widget _genderPick() => Row(children: [
        for (final g in const ['Female', 'Male']) ...[
          if (g == 'Male') const SizedBox(width: 10),
          Expanded(
            child: Pressable(
              onTap: () {
                setState(() => _gender = g);
                Future.delayed(const Duration(milliseconds: 220), () {
                  if (mounted) _maybeCollapse();
                });
              },
              child: AnimatedContainer(
                duration: CkMotion.fast,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _gender == g ? CkColors.cyanTint : CkColors.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gender == g ? CkColors.cyanStroke : CkColors.panelStroke),
                ),
                child: Text(g, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: _gender == g ? Colors.white : CkColors.textSecondary)),
              ),
            ),
          ),
        ],
      ]);

  Widget _personalSummary() => Pressable(
        scale: .985,
        onTap: () => setState(() => _personalOpen = true),
        child: Glass(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Row(children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x2E5EE38A),
                border: Border.all(color: const Color(0x995EE38A)),
              ),
              child: const Icon(Icons.check_rounded, size: 15, color: Color(0xFF5EE38A)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Personal details', style: CkText.h(15.5)),
                const SizedBox(height: 3),
                Text(
                  [
                    [_first.text, _middle.text, _last.text].where((e) => e.trim().isNotEmpty).join(' '),
                    _gender ?? '',
                    '+${_country.code} ${_mobile.text}',
                  ].join(' · ').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CkText.label.copyWith(fontSize: 10.5),
                ),
              ]),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: CkColors.labelMono),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Row(children: [
              CircleBtn(Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: () => Get.back()),
              const SizedBox(width: 12),
              Text(_edit ? 'Edit client' : 'New client', style: CkText.h(22)),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Padding(padding: EdgeInsets.all(16), child: SkeletonList(rows: 6, leading: false))
                : Form(
                    key: _form,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      children: [
                        AnimatedSize(
                          duration: CkMotion.base,
                          curve: CkMotion.ease,
                          alignment: Alignment.topCenter,
                          child: _personalOpen
                              ? _section('Personal details', Icons.person_outline_rounded, [
                                  Field('First name', controller: _first, required: true),
                                  Row(children: [
                                    Expanded(child: Field('Middle name', controller: _middle)),
                                    const SizedBox(width: 10),
                                    Expanded(child: Field('Surname', controller: _last, required: true)),
                                  ]),
                                  const SizedBox(height: 12),
                                  PhoneField(
                                    country: _country,
                                    controller: _mobile,
                                    onCountry: (c) => setState(() => _country = c),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('GENDER · REQUIRED', style: CkText.label),
                                  const SizedBox(height: 6),
                                  _genderPick(),
                                ])
                              : _personalSummary(),
                        ),
                        _section('Birth details', Icons.event_outlined, [
                          const SizedBox(height: 10),
                          BirthFields(key: _birthKey, value: _birth, onChanged: () => setState(() {})),
                        ]),
                      ],
                    ),
                  ),
          ),
        ]),
      ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Row(children: [
                  if (!_edit) ...[
                    Expanded(child: GhostButton('Save', onTap: _busy ? null : () => _save())),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                      flex: 2,
                      child: PrimaryButton(_edit ? 'Save changes' : 'Save & open workspace',
                          loading: _busy, onTap: () => _save(open: !_edit))),
                ]),
              ),
            ),
    );
  }
}

