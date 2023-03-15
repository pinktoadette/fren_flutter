import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lottie/lottie.dart';
import 'package:googleapis/docs/v1.dart';

///
/// need google verification, todo some future date
class ImportGoogleDriveWidget extends StatefulWidget {
  @override
  _ImportGoogleDriveWidgetState createState() => _ImportGoogleDriveWidgetState();
}

class _ImportGoogleDriveWidgetState extends State<ImportGoogleDriveWidget> {
  static const _pageSize = 20;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return  Card(
        child: SizedBox(
          height: 120,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _importIcons(
                            context,
                            path: 'assets/images/imports/google_docs.png',
                            title: 'Docs'
                        ),
                        _importIcons(
                            context,
                            path: 'assets/images/imports/google_sheets.png',
                            title: 'Sheets'
                        ),
                        _importIcons(
                            context,
                            path: 'assets/images/imports/pdf.png',
                            title: 'PDF'
                        ),
                      ],
                    ))
              ]),
        )
    );
  }

  void _importGoogleDocs() {

  }

  Future<void> _importGoogleSheet() async{
    var scope = await GoogleSignIn().scopes;
    if (scope.isEmpty) {
      signIntoGoogle();
    }
    print (scope);
  }

  void _readPDF() {

  }


  Future<void> signIntoGoogle () async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/documents.readonly',
        'https://www.googleapis.com/auth/spreadsheets.readonly'
      ],
    );

    await _googleSignIn.signIn();
  }

  Widget _importIcons(BuildContext context, {required String path, required String title}) {

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
                      switch(title) {
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