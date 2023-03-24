import 'dart:async';

import 'package:fren_app/datas/user.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:fren_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';

import 'package:fren_app/widgets/rounded_top.dart';

class UpdateLocationScreen extends StatefulWidget {
  final bool isSignUpProcess;
  const UpdateLocationScreen({Key? key, this.isSignUpProcess = true})
      : super(key: key);

  @override
  _UpdateLocationScreenState createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> {
  // Variables
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  final AppHelper _appHelper = AppHelper();

  /// Navigate to next page
  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  // Show timeout exception message on get device's location
  void _showTimeoutErrorMessage(BuildContext context) async {
    // Hide progress dialog
    await _pr.hide();
    // Get error message
    final String message = _i18n
            .translate("we_are_unable_to_get_your_device_current_location") +
        ", " +
        _i18n.translate(
            "please_make_sure_to_enable_location_services_on_your_device_and_try_again");
    // Show error messag
    errorDialog(context, message: message);
  }

  // Show fail error message on get device's location
  void _showFailErrorMessage(BuildContext context) async {
    // Hide progress dialog
    await _pr.hide();
    // Get error message
    final String message =
        _i18n.translate("we_are_unable_to_get_your_device_current_location") +
            ", " +
            _i18n.translate("please_skip_and_try_again_later_in_app_settings");
    // Show error messag
    errorDialog(context, message: message);
  }

  /// Get location permission
  Future<void> _getLocationPermission(BuildContext context) async {
    // Show loading progress
    _pr.show(_i18n.translate('processing'));

    /// Check location permission
    await _appHelper.checkLocationPermission(onGpsDisabled: () async {
      // Hide progress dialog
      await _pr.hide();
      // Show error message
      errorDialog(context,
          message: _i18n.translate(
              "we_were_unable_to_get_your_current_location_please_enable_gps_to_continue"));
    }, onDenied: () async {
      // Hide progress dialog
      await _pr.hide();
      // Show error message
      errorDialog(context,
          message: _i18n.translate("location_permissions_are_denied"));
    }, onGranted: () async {
      //
      // Get User current location
      //
      await _appHelper.getUserCurrentLocation(
          onSuccess: (Position position) async {
        // Debug
        debugPrint("User Position result: $position");
        // Get user readable address
        final Placemark place = await _appHelper.getUserAddress(
            position.latitude, position.longitude);

        // Debug placemark address
        debugPrint("User Address result: $place");

        // Get locality
        String? locality;
        // Check locality
        if (place.locality == '') {
          locality = place.administrativeArea;
        } else {
          locality = place.locality;
        }

        String userId = UserModel().getFirebaseUser!.uid;
        // Update User location
        await _appHelper.updateUserLocation(
            userId: userId, // widget.userId
            latitude: position.latitude,
            longitude: position.longitude,
            country: place.country.toString(),
            locality: locality.toString());

        // Hide progress dialog
        await _pr.hide();
        User user = await UserModel().getUserObject(userId);

        // Show success message
        successDialog(context,
            message: '${_i18n.translate("location_updated_successfully")}\n\n'
                '${place.country}, $locality', positiveAction: () {
          // Check
          if (user.isFrankInitiated == false) {
            _getFrankie();
          } else if (widget.isSignUpProcess) {
            // Go to home screen
            _nextScreen(const HomeScreen());
          } else {
            // Close dialog
            Navigator.of(context).pop();
            // Close current screen
            Navigator.of(context).pop();
          }
        });
      }, onTimeoutException: (exception) async {
        // Show timeout error message
        _showTimeoutErrorMessage(context);
      }, onFail: (error) {
        // Show fail error message
        _showFailErrorMessage(context);
      });
      // End
    });
  }

  void _getFrankie() async {
    _nextScreen(const BotChatScreen());
  }

  @override
  Widget build(BuildContext context) {
    // Init
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const RoundedTop(),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Text(_i18n.translate('enable_location'),
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.left),
                    ),
                    // Title description
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Text(
                          _i18n.translate(
                              'the_app_needs_your_permission_to_access_your_device_current_location'),
                          textAlign: TextAlign.left),
                    ),
                    // Location icon
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: screenHeight * 0.05),
                      child: Icon(Iconsax.location,
                          size: 100, color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: screenHeight * 0.2),

                    // Get current location button
                    ElevatedButton(
                        child: Text(_i18n.translate('GET_LOCATION')),
                        onPressed: () async {
                          // Get location permission
                          _getLocationPermission(context);
                        })
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
