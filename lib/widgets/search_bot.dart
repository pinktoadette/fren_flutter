import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fren_app/api/machi/search_api.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:iconsax/iconsax.dart';

class SearchMachiWidget extends StatefulWidget {
  const SearchMachiWidget({Key? key}) : super(key: key);

  @override
  _SearchMachiState createState() => _SearchMachiState();
}

class _SearchMachiState extends State<SearchMachiWidget> {
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
                  hintText: _i18n.translate("search_machi"),
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            suggestionsCallback: (pattern) async {
              return await _searchApi.searchMachi(pattern);
            },
            itemBuilder: (context, dynamic suggestion) {
              Bot bot = Bot.fromDocument(suggestion);
              return ListTile(
                leading: AvatarInitials(
                  userId: bot.botId,
                  username: bot.name,
                  photoUrl: bot.profilePhoto ?? "",
                  radius: 20,
                ),
                title: Text(suggestion['name']!),
                subtitle: Text(
                  'Model Type: ${suggestion['modelType']}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            },
            onSuggestionSelected: (dynamic suggestion) {
              Bot bot = Bot.fromDocument(suggestion);
              _showBotInfo(bot);
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

  void _showBotInfo(Bot bot) {
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 400 / height,
            child: BotProfileCard(
              bot: bot,
              showPurchase: true,
            ));
      },
    );
  }
}
