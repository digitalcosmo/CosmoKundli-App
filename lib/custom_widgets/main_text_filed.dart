import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../ui/ck_theme.dart';

class MainTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController textEditingController;
  final dynamic validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final EdgeInsets? contentPadding;
  final IconButton? suffix;
  final String? lableText;
  final TextStyle? lableTextStyle;
  final TextStyle? hintTextStyle;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final Function(String)? onChanged;
  final bool isEnabled;
  final bool readOnly;

  const MainTextField({
    super.key,
    required this.hintText,
    required this.textEditingController,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
    this.maxLines = 1,
    this.contentPadding,
    this.suffix,
    this.lableText,
    this.lableTextStyle,
    this.hintTextStyle,
    this.onSubmitted,
    this.onChanged,
    this.onTap,
    this.isEnabled = true,
    this.readOnly = false,
  });

  @override
  State<MainTextField> createState() => _MainTextFieldState();
}

class _MainTextFieldState extends State<MainTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: widget.onSubmitted,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onChanged: widget.onChanged,
      controller: widget.textEditingController,
      validator: widget.validator,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      onTap: widget.onTap,
      enabled: widget.isEnabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      style: const TextStyle(color: CkColors.text, fontSize: 14),
      cursorColor: CkColors.orangeSoft,
      decoration: InputDecoration(
        labelText: widget.lableText,
        labelStyle: widget.lableTextStyle,
        hintStyle: widget.hintTextStyle,
        suffixIcon: widget.suffix,
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        counterText: '',
        hintText: widget.hintText,
      ),
    );
  }
}
