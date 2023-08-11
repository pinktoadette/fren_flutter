import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

///
/// need google verification, todo some future date
class ImportGoogleDriveWidget extends StatefulWidget {
  const ImportGoogleDriveWidget({super.key});

  @override
  State<ImportGoogleDriveWidget> createState() =>
      _ImportGoogleDriveWidgetState();
}

class _ImportGoogleDriveWidgetState extends State<ImportGoogleDriveWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: SizedBox(
      height: 120,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _importIcons(context,
                    path: 'assets/images/imports/google_docs.png',
                    title: 'Docs'),
                _importIcons(context,
                    path: 'assets/images/imports/google_sheets.png',
                    title: 'Sheets'),
                _importIcons(context,
                    path: 'assets/images/imports/pdf.png', title: 'PDF'),
              ],
            ))
          ]),
    ));
  }

  void _importGoogleDocs() {}

  Future<void> _importGoogleSheet() async {
    var scope = GoogleSignIn().scopes;
    if (scope.isEmpty) {
      signIntoGoogle();
    }
  }

  void _readPDF() {}

  Future<void> signIntoGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/documents.readonly',
        'https://www.googleapis.com/auth/spreadsheets.readonly'
      ],
    );

    await googleSignIn.signIn();
  }

  Widget _importIcons(BuildContext context,
      {required String path, required String title}) {
    return Column(
      // alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Card(
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: InkWell(
                  onTap: () {
                    switch (title) {
                      case 'Docs':
                        _importGoogleDocs();
                        break;
                      case 'Sheets':
                        _importGoogleSheet();
                        break;
                      case 'PDF':
                        _readPDF();
                        break;
                    }
                  }, // Handle your callback
                  child: Image.asset(path),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
