import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fren_app/api/machi/search.dart';
import 'package:fren_app/api/machi/user_api.dart';
import 'package:fren_app/datas/user.dart';
import 'package:iconsax/iconsax.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBarWidget> {
  final _searchApi = SearchApi();
  static const List<User> _userOptions = <User>[];

  static String _displayStringForOption(User option) =>
      "${option.userFullname} @${option.username}";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: TypeAheadField(
          minCharsForSuggestions: 3,
          textFieldConfiguration: TextFieldConfiguration(
            autofocus: false,
            style: DefaultTextStyle.of(context)
                .style
                .copyWith(fontStyle: FontStyle.italic),
            decoration: const InputDecoration(
                icon: Icon(Iconsax.search_normal),
                border: InputBorder.none,
                hintText: 'Search user'),
          ),
          suggestionsCallback: (pattern) async {
            return await _searchApi.searchUserAndBots(pattern);
          },
          itemBuilder: (context, dynamic suggestion) {
            return ListTile(
              leading: const Icon(Iconsax.user_add),
              title: Text(suggestion['fullname']!),
              subtitle: Text('\@${suggestion['username']}'),
            );
          },
          onSuggestionSelected: (dynamic suggestion) {
            // Navigator.of(context)
            //     .push<void>(MaterialPageRoute(builder: (context) => ProductPage(product: suggestion)));
          },
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            elevation: 8.0,
            color: Theme.of(context).cardColor,
          ),
        ));
  }
}
