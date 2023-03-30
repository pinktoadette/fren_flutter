import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:get/get.dart';

class InviteContactScreen extends StatefulWidget {
  const InviteContactScreen({Key? key}) : super(key: key);

  @override
  InviteContactScreenState createState() => InviteContactScreenState();
}

class InviteContactScreenState extends State<InviteContactScreen> {
  late AppLocalizations _i18n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<List<Contact>> _fetchContacts() async {
    List<Contact> contacts = await ContactsService.getContacts();
    return contacts;
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
            leading: BackButton(
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                Get.back();
              },
            ),
            title: Text(_i18n.translate("invite_user"),
                style: Theme.of(context).textTheme.titleLarge)),
        body: FutureBuilder(
            future: _fetchContacts(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Frankloader());
              } else {
                return ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        leading: Text(
                            "${snapshot.data[index].givenName} ${snapshot.data[index].familyName}",
                            style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Text(
                          _i18n.translate("invite"),
                          style: Theme.of(context).textTheme.displaySmall,
                        ));
                  },
                );
              }
            }));
  }
}
