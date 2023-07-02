import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if FirebaseApp.app() == nil {
        let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        let firbaseOptions = FirebaseOptions(contentsOfFile: path!)
        FirebaseApp.configure(options: firbaseOptions!)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
