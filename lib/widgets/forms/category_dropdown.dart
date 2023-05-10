import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/chat/typing_indicator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart' show rootBundle;

class CategoryDropdownWidget extends StatefulWidget {
  final Function(dynamic data) notifyParent;
  final String? selectedCategory;
  const CategoryDropdownWidget(
      {super.key, required this.notifyParent, this.selectedCategory});

  @override
  _CategoryDropdownWidgetState createState() => _CategoryDropdownWidgetState();
}

class _CategoryDropdownWidgetState extends State<CategoryDropdownWidget> {
  late AppLocalizations _i18n;
  late List<String> _category;
  String _selectedCategory = "Crime";

  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  void _getCategory() async {
    String _cat = await rootBundle.loadString('assets/json/interest.json');
    List<String> category = List.from(jsonDecode(_cat) as List<dynamic>);
    setState(() {
      _category = category;
      _selectedCategory = category[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(
        "Category",
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(
        width: 10,
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
                    widget.notifyParent({"selection": value});
                  },
                  items:
                      _category.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()))
          : const SizedBox.shrink()
    ]);
  }
}
