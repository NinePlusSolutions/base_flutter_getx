import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/constants/theme.dart';
import 'package:flutter_getx_boilerplate/shared/extension/context_ext.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final Widget? icon;
  final TextStyle? labelStyle;
  final ButtonStyle? style;
  final bool enabled;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.style,
    this.labelStyle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = labelStyle ?? _getTextStyle(context);
    final child = ElevatedButton.icon(
      style: style ?? _getButtonStyle(context),
      onPressed: onPressed,
      icon: icon != null
          ? IconTheme(data: IconThemeData(color: textStyle.color), child: icon!)
          : null,
      label: Text(
        text,
        style: textStyle,
      ),
    );

    if (enabled) {
      return child;
    } else {
      return IgnorePointer(
        ignoring: true,
        child: Opacity(opacity: 0.8, child: child),
      );
    }
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (type) {
      case ButtonType.outline:
        return ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(kComponentHeight),
          side: BorderSide(
            color: context.colors.primary,
            width: 1,
          ),
        );
      case ButtonType.text:
        return ElevatedButton.styleFrom(
          elevation: 0,
        );

      default:
        return ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          minimumSize: const Size.fromHeight(kComponentHeight),
          side: BorderSide(
            color: context.colors.primary,
            width: 1,
          ),
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return TextStyle(
          color: context.colors.surface,
        );

      default:
        return TextStyle(
          color: context.colors.primary,
        );
    }
  }
}

enum ButtonType { primary, outline, text }
