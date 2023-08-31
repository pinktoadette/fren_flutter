import 'dart:async';

import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';

class SearchMachiField extends StatefulWidget {
  final Function(String value) onInputChanged;

  const SearchMachiField({
    Key? key,
    required this.onInputChanged,
  }) : super(key: key);

  @override
  State<SearchMachiField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchMachiField> {
  final TextEditingController _searchController = TextEditingController();
  late AppLocalizations _i18n;
  late double _width;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    _width = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(10),
      width: _width,
      child: TextField(
        controller: _searchController,
        onChanged: (pattern) async {
          if (pattern.length >= 3) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(seconds: 2), () {
              widget.onInputChanged(pattern);
            });
          }
        },
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
          ),
          hintText: _i18n.translate("search"),
        ),
      ),
    );
  }
}
