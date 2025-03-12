import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/extension/context_ext.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/input/input_field.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({
    super.key,
    this.useSearch = false,
    this.controller,
    this.showLoading = true,
    this.onChanged,
    this.canClear = true,
    this.onClear,
    this.onFieldSubmitted,
    this.autofocus,
    this.trailing,
    this.hintText,
    this.focusNode,
    this.fillColor,
    this.hintStyle,
  });

  final bool useSearch;
  final bool showLoading;
  final bool canClear;
  final bool? autofocus;
  final Function()? onClear;
  final Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController? controller;
  final Widget? trailing;
  final String? hintText;
  final FocusNode? focusNode;
  final Color? fillColor;
  final TextStyle? hintStyle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 36,
        child: TextFormField(
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          controller: controller,
          maxLines: 1,
          autofocus: autofocus ?? false,
          // style: context.body.copyWith(
          //   color: context.mutedText,
          // ),
          focusNode: focusNode,
          cursorHeight: 36 * 0.5,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            suffixIcon: _getSuffix(),
            // suffixIcon: ,
            filled: true,
            prefixIcon: SizedBox(
              width: 20,
              height: 20,
              child: Center(
                child: Icon(Icons.search),
              ),
            ),
            fillColor: fillColor ?? context.colors.background,
            contentPadding: EdgeInsets.zero,
            hintText: hintText ?? 'Tìm kiếm...',
            hintStyle: hintStyle,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _getSuffix() {
    if (showLoading) {
      return const SizedBox(
          height: 24,
          width: 24,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
          ));
    }

    if (canClear) {
      return trailing ??
          GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: onClear,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Center(
                // child: SvgPicture.asset(
                //   ImageConstant.iconCloseEditMessage,
                //   color: ColorConstants.grey6C757D,
                //   width: 20,
                //   height: 20,
                // ),
                child: Icon(
                  Icons.close,
                  size: 20,
                ),
              ),
            ),
          );
    }

    return null;
  }
}

///@Example
///
///```dart
// / ISearchWidget(
// /   useSearch: true,
// /   controller: controller.searchController,
// /   showLoading: false,
// /   onClear: () {
// /     controller.searchController.clear();
// /     controller.searchResults.value = [];
// /     controller.isCheckOnChange.value = false;
// /   },
// /   onChanged: controller.onChangedSearch,
// /   onSearch: (value) async {
// /     await controller.searchMessage(value ?? '');
// /   },
// /   screenName: 'channel_page',
// / ),
///```
class SearchInputWidget extends StatefulWidget {
  const SearchInputWidget({
    super.key,
    this.useSearch = false,
    this.controller,
    this.showLoading = true,
    this.onChanged,
    this.canClear = true,
    this.onClear,
    this.onFieldSubmitted,
    this.autofocus,
    this.trailing,
    this.onSearch,
    this.fillColor,
    required this.screenName,
  });

  final bool useSearch;
  final bool showLoading;
  final bool canClear;
  final bool? autofocus;
  final Function()? onClear;
  final Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController? controller;
  final Widget? trailing;
  final Color? fillColor;
  final String screenName;
  final Future<void> Function(String?)? onSearch;

  @override
  State<SearchInputWidget> createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  bool _searching = false;
  bool _showClear = false;
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final _searchDebounce = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_listener);
  }

  _listener() {
    if (mounted) {
      setState(() {
        _showClear = _controller.text.isNotEmpty ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputFieldWidget(
      controller: _controller,
      hint: 'Search...',
      suffix: _buildSufix(),
      prefix: widget.useSearch ? const Icon(Icons.search_sharp) : null,
      onChanged: (value) {
        widget.onChanged?.call(value);
        EasyDebounce.debounce(
          widget.screenName,
          _searchDebounce,
          () => _searchRequest(value),
        );
      },
    );
  }

  _buildSufix() {
    if (_searching) {
      return const SizedBox(
          height: 24,
          width: 24,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
          ));
    }

    if (_showClear) {
      return GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          _controller.clear();
          widget.onClear?.call();
        },
        child: const SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Icon(
              Icons.close,
              size: 20,
            ),
          ),
        ),
      );
    }

    return null;
  }

  _searchRequest(String? value) async {
    if (mounted) {
      setState(() {
        _searching = true;
      });
    }

    try {
      await widget.onSearch?.call(value);
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  Future<void> search(String? value) async {}

  @override
  void dispose() {
    EasyDebounce.cancel(widget.screenName);
    _controller.removeListener(_listener);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
