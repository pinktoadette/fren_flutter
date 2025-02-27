import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/plugins/otp_screen/otp_screen.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/screens/first_time/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:iconsax/iconsax.dart';

class VerificationCodeScreen extends StatefulWidget {
  // Variables
  final String verificationId;

  // Constructor
  const VerificationCodeScreen({
    Key? key,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  // Variables
  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  /// Navigate to next page
  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  /// logic to validate otp return [null] when success else error [String]
  Future<String?> validateOtp(String otp) async {
    /// Handle entered verification code here
    ///
    /// Show progress dialog
    _pr.show(_i18n.translate("processing"));

    await UserModel().signInWithOTP(
        verificationId: widget.verificationId,
        otp: otp,
        checkUserAccount: () {
          /// Auth user account
          UserModel().authUserAccount(
              // updateLocationScreen: () =>
              //     _nextScreen(const UpdateLocationScreen()),
              homeScreen: () => _nextScreen(const HomeScreen()),
              signUpScreen: () => _nextScreen(const SignUpScreen()));
        },
        onError: () async {
          // Hide dialog
          await _pr.hide();
        });

    // Hide progress dialog
    await _pr.hide();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return OtpScreen.withGradientBackground(
      topColor: Theme.of(context).primaryColor,
      bottomColor: Theme.of(context).primaryColor.withOpacity(.7),
      otpLength: 6,
      validateOtp: validateOtp,
      routeCallback: (context) {},
      icon: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: Icon(Iconsax.mobile, color: Theme.of(context).primaryColor),
      ),
      title: _i18n.translate("verification_code"),
      subTitle: _i18n.translate("please_enter_the_sms_code_sent"),
    );
  }
}
