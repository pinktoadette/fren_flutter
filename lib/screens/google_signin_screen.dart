// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:fren_app/dialogs/progress_dialog.dart';
// import 'package:fren_app/helpers/app_localizations.dart';
// import 'package:fren_app/models/user_model.dart';
// import 'package:fren_app/screens/blocked_account_screen.dart';
// import 'package:fren_app/screens/home_screen.dart';
// import 'package:fren_app/screens/sign_up_screen.dart';
// import 'package:fren_app/screens/update_location_sceen.dart';
// import 'package:fren_app/screens/verification_code_screen.dart';
// import 'package:fren_app/widgets/default_button.dart';
// import 'package:fren_app/widgets/show_scaffold_msg.dart';
// import 'package:fren_app/widgets/svg_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'package:google_sign_in/google_sign_in.dart';
//
// GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: <String>[
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//     'https://www.google.com/calendar/feeds.readonly'
//   ],
// );
//
// class GoogleSignIn extends StatefulWidget {
//   const GoogleSignIn({Key? key}) : super(key: key);
//
//   @override
//   State createState() => GoogleSignIn();
// }
//
// class _GoogleSignInButtonScreenState extends State<GoogleSignIn> {
//   GoogleSignInAccount? _currentUser;
//   String _contactText = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//       setState(() {
//         _currentUser = account;
//       });
//       if (_currentUser != null) {
//         _handleGetContact(_currentUser!);
//       }
//     });
//     _googleSignIn.signInSilently();
//   }
//
//   Future<void> _handleGetContact(GoogleSignInAccount user) async {
//     setState(() {
//       _contactText = 'Loading contact info...';
//     });
//     final http.Response response = await http.get(
//       Uri.parse('https://people.googleapis.com/v1/people/me/connections'
//           '?requestMask.includeField=person.names'),
//       headers: await user.authHeaders,
//     );
//     if (response.statusCode != 200) {
//       setState(() {
//         _contactText = 'People API gave a ${response.statusCode} '
//             'response. Check logs for details.';
//       });
//       print('People API ${response.statusCode} response: ${response.body}');
//       return;
//     }
//     final Map<String, dynamic> data =
//     json.decode(response.body) as Map<String, dynamic>;
//     final String? namedContact = _pickFirstNamedContact(data);
//     setState(() {
//       if (namedContact != null) {
//         _contactText = 'I see you know $namedContact!';
//       } else {
//         _contactText = 'No contacts to display.';
//       }
//     });
//   }
//
//   String? _pickFirstNamedContact(Map<String, dynamic> data) {
//     final List<dynamic>? connections = data['connections'] as List<dynamic>?;
//     final Map<String, dynamic>? contact = connections?.firstWhere(
//           (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
//       orElse: () => null,
//     ) as Map<String, dynamic>?;
//     if (contact != null) {
//       final List<dynamic> names = contact['names'] as List<dynamic>;
//       final Map<String, dynamic>? name = names.firstWhere(
//             (dynamic name) =>
//         (name as Map<Object?, dynamic>)['displayName'] != null,
//         orElse: () => null,
//       ) as Map<String, dynamic>?;
//       if (name != null) {
//         return name['displayName'] as String?;
//       }
//     }
//     return null;
//   }
//
//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//     } catch (error) {
//       print(error);
//     }
//   }
//
//   Future<void> _handleSignOut() => _googleSignIn.disconnect();
//
//   Widget _buildBody() {
//     final GoogleSignInAccount? user = _currentUser;
//     if (user != null) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           ListTile(
//             leading: GoogleUserCircleAvatar(
//               identity: user,
//             ),
//             title: Text(user.displayName ?? ''),
//             subtitle: Text(user.email),
//           ),
//           const Text('Signed in successfully.'),
//           Text(_contactText),
//           ElevatedButton(
//             onPressed: _handleSignOut,
//             child: const Text('SIGN OUT'),
//           ),
//           ElevatedButton(
//             child: const Text('REFRESH'),
//             onPressed: () => _handleGetContact(user),
//           ),
//         ],
//       );
//     } else {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           const Text('You are not currently signed in.'),
//           ElevatedButton(
//             onPressed: _handleSignIn,
//             child: const Text('SIGN IN'),
//           ),
//         ],
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Google Sign In'),
//         ),
//         body: ConstrainedBox(
//           constraints: const BoxConstraints.expand(),
//           child: _buildBody(),
//         ));
//   }
// }
