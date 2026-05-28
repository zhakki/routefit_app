import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Read the API key directly from the .env file
    if let path = Bundle.main.path(forResource: "flutter_assets/.env", ofType: nil) {
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            for line in lines {
                let parts = line.components(separatedBy: "=")
                if parts.count == 2 && parts[0].trimmingCharacters(in: .whitespaces) == "GOOGLE_MAPS_API_KEY" {
                    let key = parts[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                    GMSServices.provideAPIKey(key)
                }
            }
        } catch {
            print("Error reading .env file: \(error)")
        }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
