import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/theme/text_theme.dart';

enum InputFieldType { normal, password, calendar }

class InputFieldWidget extends StatelessWidget {
  InputFieldWidget({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.label,
    this.prefix,
    this.suffix,
    this.bgColor,
    this.enable,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.minLines = 1,
    this.important = false,
    this.inset = false,
    this.border,
    this.style,
    this.inputStyle,
    this.onEditingComplete,
    this.textCapitalization = TextCapitalization.none,
    this.maxLengthEnforcement,
    this.counterText,
    this.fieldType = InputFieldType.normal,
    this.readOnly = false,
    this.onSelectDate,
    this.labelStyle,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hint;
  final String? label;
  final String? counterText;
  final Widget? prefix;
  final Widget? suffix;
  final Color? bgColor;
  final bool? enable;
  final bool important;
  final bool inset;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? minLines;
  final InputBorder? border;
  final TextStyle? style;
  final TextStyle? inputStyle;
  final TextStyle? labelStyle;
  final Function()? onEditingComplete;
  final TextCapitalization textCapitalization;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueNotifier<bool> isObscureNotifier = ValueNotifier<bool>(true);
  final InputFieldType fieldType;
  final bool readOnly;
  final Function()? onSelectDate;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != null
            ? Row(
                children: [
                  Text(label!, style: labelStyle ?? Typo.bodyM),
                  if (important)
                    Text(" *", style: TextStyle(color: context.colors.error)),
                ],
              )
            : const SizedBox(),
        const SizedBox(height: 4),
        ValueListenableBuilder(
            valueListenable: isObscureNotifier,
            builder: (context, isObscured, child) {
              return TextFormField(
                textCapitalization: textCapitalization,
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                style: inputStyle,
                obscureText:
                    fieldType == InputFieldType.password ? isObscured : false,
                readOnly: fieldType == InputFieldType.calendar || readOnly,
                enabled: enable ?? true,
                validator: validator,
                maxLength: maxLength,
                minLines: minLines,
                autofocus: false,
                onTap:
                    fieldType == InputFieldType.calendar ? onSelectDate : null,
                maxLines: minLines,
                buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
                onEditingComplete: onEditingComplete ??
                    () => FocusScope.of(context).nextFocus(),
                maxLengthEnforcement:
                    maxLengthEnforcement ?? MaxLengthEnforcement.none,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  counterText: counterText,
                  isDense: true,
                  filled: true,
                  prefixIcon: prefix,
                  suffixIcon: _buildSuffixIcon(isObscured),
                  hintText: hint,
                  fillColor: bgColor,
                  hintStyle: style,
                  errorMaxLines: 5,
                ),
                keyboardType: keyboardType,
                onChanged: onChanged,
                inputFormatters: inputFormatters,
              );
            }),
      ],
    );
  }

  // Xử lý hiển thị suffix icon tùy vào loại TextField
  Widget? _buildSuffixIcon(bool isObscured) {
    if (fieldType == InputFieldType.password) {
      return IconButton(
        icon: Icon(isObscured
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined),
        onPressed: () => isObscureNotifier.value = !isObscured,
      );
    }
    if (fieldType == InputFieldType.calendar) {
      return const Icon(Icons.calendar_today);
    }
    return suffix;
  }
}

class IconObscure extends StatelessWidget {
  const IconObscure({
    super.key,
    required this.onPressed,
    required this.isObscure,
  });

  final Function() onPressed;
  final bool isObscure;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isObscure ? Icons.visibility : Icons.visibility_off,
        color: context.colors.outline,
      ),
    );
  }
}
