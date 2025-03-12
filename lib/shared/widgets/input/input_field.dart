import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';

class InputFieldWidget extends StatelessWidget {
  const InputFieldWidget({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.label,
    this.prefix,
    this.suffix,
    this.bgColor,
    this.isHideContent,
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
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hint;
  final String? label;
  final String? counterText;
  final Widget? prefix;
  final Widget? suffix;
  final Color? bgColor;
  final bool? isHideContent;
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
  final Function()? onEditingComplete;
  final TextCapitalization textCapitalization;
  final MaxLengthEnforcement? maxLengthEnforcement;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != null
            ? Row(
                children: [
                  Text(label!, style: context.label.copyWith()),
                  if (important)
                    Text(" *",
                        style: context.label
                            .copyWith(color: context.colors.error)),
                ],
              )
            : const SizedBox(),
        const SizedBox(height: 4),
        TextFormField(
          textCapitalization: textCapitalization,
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          style: inputStyle,
          obscureText: isHideContent ?? false,
          enabled: enable ?? true,
          validator: validator,
          maxLength: maxLength,
          minLines: minLines,
          autofocus: false,
          maxLines: minLines,
          buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) =>
              null,
          onEditingComplete:
              onEditingComplete ?? () => FocusScope.of(context).nextFocus(),
          maxLengthEnforcement:
              maxLengthEnforcement ?? MaxLengthEnforcement.none,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            counterText: counterText,
            isDense: true,
            filled: true,
            prefixIcon: prefix,
            suffixIcon: suffix,
            hintText: hint,
            fillColor: bgColor,
            hintStyle: style,
            errorMaxLines: 5,
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
        ),
      ],
    );
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
