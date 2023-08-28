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

        let args = CommandLine.arguments
                
        // Initialize a variable to store the environment ("env" or "flavor").
        var environment: String? = "dev"
        let plistFileName = "GoogleService-Info"
        
        // Find the "flavor" argument and extract the environment value from terminal args.
        for arg in args {
            if arg.hasPrefix("--dart-define=flavor=") {
                let parts = arg.components(separatedBy: "=")
                if parts.count == 2 {
                    environment = parts[1]
                    print("Environment: \(environment!)")
                    break // You can exit the loop since you found the value
                }
            }
        }
        
        // If environment is not set from terminal args, check the scheme-specific setting.
        let processInfo = ProcessInfo.processInfo
        for arg in processInfo.arguments {
            if arg.hasPrefix("--dart-define=") {
                let parts = arg.components(separatedBy: "=")
                if parts.count == 3 && parts[0] == "--dart-define" {
                    environment = parts[2]
                    print("Environment: \(environment!)")
                    // Use environment to determine your configuration dynamically
                    break // You can exit the loop since you found the value
                }
            }
        }
        
        
        print("After loop, Environment: \(environment!)")

    
        if let path = Bundle.main.path(forResource: "env/" + environment! + "/" + plistFileName, ofType: "plist") {
            let firbaseOptions = FirebaseOptions(contentsOfFile: path)
            FirebaseApp.configure(options: firbaseOptions!)
        } else {
            // Handle the case where the plist file doesn't exist
            print("Plist file not found.")
            exit(0)
        }
        
    }
      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
