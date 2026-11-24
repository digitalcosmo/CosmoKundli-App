import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';

/// Dialling code and the length of a national mobile number (digits only,
/// without the leading 0 / trunk prefix).
class Country {
  final String iso;
  final String name;
  final String code;
  final int min;
  final int max;
  const Country(this.iso, this.name, this.code, this.min, [int? max]) : max = max ?? min;
  String get label => '$iso +$code';
  String get lengthText => min == max ? '$min digits' : '$min–$max digits';
}

const kCountries = <Country>[
  Country('IN', 'India', '91', 10),
  Country('US', 'United States', '1', 10),
  Country('CA', 'Canada', '1', 10),
  Country('GB', 'United Kingdom', '44', 10),
  Country('AE', 'United Arab Emirates', '971', 9),
  Country('AU', 'Australia', '61', 9),
  Country('NZ', 'New Zealand', '64', 8, 10),
  Country('SG', 'Singapore', '65', 8),
  Country('MY', 'Malaysia', '60', 9, 10),
  Country('NP', 'Nepal', '977', 10),
  Country('BD', 'Bangladesh', '880', 10),
  Country('LK', 'Sri Lanka', '94', 9),
  Country('PK', 'Pakistan', '92', 10),
  Country('SA', 'Saudi Arabia', '966', 9),
  Country('QA', 'Qatar', '974', 8),
  Country('KW', 'Kuwait', '965', 8),
  Country('OM', 'Oman', '968', 8),
  Country('BH', 'Bahrain', '973', 8),
  Country('ZA', 'South Africa', '27', 9),
  Country('KE', 'Kenya', '254', 9),
  Country('NG', 'Nigeria', '234', 10),
  Country('DE', 'Germany', '49', 10, 11),
  Country('FR', 'France', '33', 9),
  Country('IT', 'Italy', '39', 9, 10),
  Country('ES', 'Spain', '34', 9),
  Country('NL', 'Netherlands', '31', 9),
  Country('IE', 'Ireland', '353', 9),
  Country('CH', 'Switzerland', '41', 9),
  Country('HK', 'Hong Kong', '852', 8),
  Country('JP', 'Japan', '81', 10),
  Country('TH', 'Thailand', '66', 9),
  Country('ID', 'Indonesia', '62', 9, 12),
  Country('PH', 'Philippines', '63', 10),
  Country('MU', 'Mauritius', '230', 8),
  Country('FJ', 'Fiji', '679', 7),
];

Country countryByCode(String? code) {
  final c = (code ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  return kCountries.firstWhere((e) => e.code == c, orElse: () => kCountries.first);
}

/// Splits "+919876543210" / "919876543210" / "9876543210" into country + number.
(Country, String) splitPhone(String raw, {Country? fallback}) {
  final d = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (d.startsWith('+')) {
    final digits = d.substring(1);
    final sorted = [...kCountries]..sort((a, b) => b.code.length.compareTo(a.code.length));
    for (final c in sorted) {
      if (digits.startsWith(c.code) && digits.length - c.code.length >= c.min) {
        return (c, digits.substring(c.code.length));
      }
    }
  }
  return (fallback ?? kCountries.first, d.replaceAll('+', ''));
}

String? validatePhone(Country c, String number, {bool required = true}) {
  final n = number.replaceAll(RegExp(r'[^0-9]'), '');
  if (n.isEmpty) return required ? 'Enter a mobile number' : null;
  if (n.length < c.min || n.length > c.max) return '${c.name} numbers are ${c.lengthText}';
  return null;
}

Future<Country?> pickCountry(BuildContext context, Country current) => showModalBottomSheet<Country>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (c) => _CountrySheet(current),
    );

class _CountrySheet extends StatefulWidget {
  final Country current;
  const _CountrySheet(this.current);
  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final q = _q.toLowerCase();
    final list = kCountries.where((c) => q.isEmpty || c.name.toLowerCase().contains(q) || c.code.contains(q) || c.iso.toLowerCase().contains(q)).toList();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .7,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0x4DFFFFFF), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Text('Country code', style: CkText.h(18)),
            const SizedBox(height: 10),
            TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _q = v),
              decoration: const InputDecoration(hintText: 'Search country or code', prefixIcon: Icon(Icons.search_rounded)),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  final sel = c.iso == widget.current.iso;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pop(context, c),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                      child: Row(children: [
                        SizedBox(width: 34, child: Text(c.iso, style: CkText.mono(12.5, color: CkColors.labelMono))),
                        Expanded(child: Text(c.name, style: const TextStyle(fontSize: 14.5))),
                        Text('+${c.code}', style: CkText.mono(13.5, color: sel ? CkColors.cyan : CkColors.text)),
                        if (sel) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_rounded, size: 18, color: CkColors.cyan)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Country code button + number field with a live length check.
class PhoneField extends StatelessWidget {
  final Country country;
  final ValueChanged<Country> onCountry;
  final TextEditingController controller;
  final String label;
  final bool required;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  const PhoneField({
    this.focusNode,
    super.key,
    required this.country,
    required this.onCountry,
    required this.controller,
    this.label = 'Mobile number',
    this.required = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 112,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CODE', style: CkText.label),
            const SizedBox(height: 6),
            Pressable(
              onTap: () async {
                final c = await pickCountry(context, country);
                if (c != null) onCountry(c);
              },
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: CkColors.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CkColors.panelStroke),
                ),
                child: Row(children: [
                  Expanded(child: Text(country.label, style: CkText.mono(13.5))),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: CkColors.labelMono),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(), style: CkText.label),
            const SizedBox(height: 6),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (c, v, _) {
                final n = v.text.replaceAll(RegExp(r'[^0-9]'), '').length;
                final ok = n >= country.min && n <= country.max;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(country.max)],
                  onChanged: onChanged,
                  validator: (t) => validatePhone(country, t ?? '', required: required),
                  style: CkText.mono(15),
                  decoration: InputDecoration(
                    hintText: country.lengthText,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Center(
                        widthFactor: 1,
                        child: Text('$n/${country.max}',
                            style: CkText.mono(11, color: n == 0 ? CkColors.labelMono : ok ? const Color(0xFF5EE38A) : const Color(0xFFFFC46B))),
                      ),
                    ),
                  ),
                );
              },
            ),
          ]),
        ),
      ]);
}
