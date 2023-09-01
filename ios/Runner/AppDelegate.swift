import Firebase
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    // Initialize Firebase when the app launches.
    private func initializeFirebase(completion: @escaping () -> Void) {
        if FirebaseApp.app() == nil {
            var environment: String? = "prod"
            let plistFileName = "GoogleService-Info"
            
            let processInfo = ProcessInfo.processInfo
            for arg in processInfo.arguments {
                if arg.hasPrefix("--dart-define=") {
                  print("Has flavors: \(processInfo)")
                    let parts = arg.components(separatedBy: "=")
                    if parts.count == 3 && parts[0] == "--dart-define" {
                        environment = parts[2]
                        print("Processing Info Environment: \(environment!)")
                        break
                    }
                }
                /// @todo Probably not the right way, but spending too much time and running out of ideas on getting env
                let components = arg.components(separatedBy: "/")
                if let lastComponent = components.last {
                    let parts = lastComponent.components(separatedBy: " ")
                    if let runnerWord = parts.last, runnerWord == "dev" || runnerWord == "prod"  || runnerWord == "uat" {
                        print("Extracted Env: \(runnerWord)")
                        environment = runnerWord
                        break // Stop processing after the first matching argument
                    }
                }
            }

            print("============================= Environment: \(environment!) =============================")

            if let path = Bundle.main.path(forResource: "env/" + environment! + "/" + plistFileName, ofType: "plist") {
                print("Path: \(path)")
              
                if let firebaseOptions = FirebaseOptions(contentsOfFile: path) {
                    FirebaseApp.configure(options: firebaseOptions)
                    // Call the completion handler after Firebase is configured
                    completion()
                } else {
                    fatalError("Unable to configure Firebase with provided options.")
                }
            } else {
                print("Plist file not found.")
                exit(0)
            }
        } else {
            // Call the completion handler if Firebase is already configured
            completion()
        }
    }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print(">>>>>>> InitializeFirebase <<<<<<<<< ")

        // Call initializeFirebase with a completion handler
        initializeFirebase {
            // This code block will be executed after Firebase is configured
            print(">>>>>>> GeneratedPluginRegistrant<<<<<<< ")
            GeneratedPluginRegistrant.register(with: self)
            print(">>>>>>> after init firebase <<<<<<<")
        }

        return true
    }
}
