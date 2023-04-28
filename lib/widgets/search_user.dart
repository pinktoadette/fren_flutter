import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fren_app/api/machi/search_api.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/user/profile_screen.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBarWidget> {
  final _searchApi = SearchApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: TypeAheadField(
            minCharsForSuggestions: 3,
            textFieldConfiguration: TextFieldConfiguration(
              autofocus: false,
              decoration: InputDecoration(
                  icon: const Icon(Iconsax.search_normal),
                  border: InputBorder.none,
                  hintText: _i18n.translate("search_user"),
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            suggestionsCallback: (pattern) async {
              return await _searchApi.searchUser(pattern);
            },
            itemBuilder: (context, dynamic suggestion) {
              User user = User.fromDocument(suggestion);
              return ListTile(
                leading: AvatarInitials(
                  userId: user.userId,
                  username: user.username,
                  photoUrl: user.userProfilePhoto,
                  radius: 20,
                ),
                title: Text(suggestion['fullname']!),
                subtitle: Text('@${suggestion['username']}'),
              );
            },
            onSuggestionSelected: (dynamic suggestion) {
              User user = User.fromDocument(suggestion);
              Get.to(() => ProfileScreen(user: user));
            },
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              elevation: 8.0,
              color: Theme.of(context).cardColor,
            ),
            noItemsFoundBuilder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(5),
                child: Text(_i18n.translate('search_not_found')),
              );
            }));
  }
}
