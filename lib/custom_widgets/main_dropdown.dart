import 'package:flutter/material.dart';
import '../ui/ck_theme.dart';

class MainDropDown extends StatelessWidget {
  final String hintText;
  final String? dropdownValue;
  final String? value;
  final List<String> dropdownItems;
  final IconData? icon;
  final Function(dynamic) onChanged;
  final dynamic validator;

  const MainDropDown({
    super.key,
    required this.dropdownItems,
    required this.onChanged,
    this.value,
    this.dropdownValue,
    required this.hintText,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: value,
              hint: Text(
                dropdownValue == '' ? hintText : dropdownValue ?? '',
                style: const TextStyle(color: CkColors.textMuted),
              ),
              style: const TextStyle(color: CkColors.text, fontSize: 14),
              dropdownColor: CkColors.navySheet,
              borderRadius: BorderRadius.circular(16),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: CkColors.textSecondary),
              decoration: InputDecoration(
                prefixIcon: icon != null
                    ? Icon(icon, color: CkColors.orangeSoft)
                    : null,
              ),
              isExpanded: true,
              validator: validator,
              items: dropdownItems.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
