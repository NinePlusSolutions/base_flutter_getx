import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/extension/context_ext.dart';

class EmptyWidget extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? description;
  const EmptyWidget({
    this.icon,
    this.title,
    this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.folder_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title ?? 'Empty Data',
            style: context.title.copyWith(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description ?? 'No data available.',
            style: context.body.copyWith(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
