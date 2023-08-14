import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:machi_app/helpers/app_localizations.dart';

class CategoryDropdownWidget extends StatefulWidget {
  final Function(dynamic data) notifyParent;
  final String? selectedCategory;
  const CategoryDropdownWidget(
      {super.key, required this.notifyParent, this.selectedCategory});

  @override
  State<CategoryDropdownWidget> createState() => _CategoryDropdownWidgetState();
}

class _CategoryDropdownWidgetState extends State<CategoryDropdownWidget> {
  List<String> _category = [];
  late String _selectedCategory;
  late AppLocalizations _i18n;

  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getCategory() async {
    if (!mounted) {
      return;
    }
    String cat = await rootBundle.loadString('assets/json/category.json');
    List<String> category = List.from(jsonDecode(cat) as List<dynamic>);
    setState(() {
      _category = category;
      _selectedCategory = widget.selectedCategory ?? category[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Row(children: [
      Text(
        _i18n.translate("publish_confirm_category"),
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(
        width: 30,
      ),
      _category.isNotEmpty
          ? Expanded(
              child: DropdownButton<String>(
                  iconSize: 0.0,
                  value: _selectedCategory,
                  elevation: 16,
                  underline: Container(
                    height: 1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    widget.notifyParent(value);
                  },
                  items:
                      _category.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center),
                    );
                  }).toList()))
          : const SizedBox.shrink()
    ]);
  }
}
