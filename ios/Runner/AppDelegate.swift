import UIKit
import Flutter
import GoogleMaps
import Firebase
import FirebaseMessaging
import moengage_flutter
import MoEngageSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyApwzJ3YNRak3lBXmJSz9DVg2g4S7eMqzo")
      
    
    if #available(iOS 13.0, *) {
        let sdkConfig: MoEngageSDKConfig
        #if PRODUCTION
            sdkConfig = MoEngageSDKConfig(withAppID: "1KR2IE6HRPJ2FOZ5ONSIJGRW")
            sdkConfig.moeDataCenter = .data_center_03
        #else
            sdkConfig = MoEngageSDKConfig(withAppID: "JF1EZI4GYP8PXZICEYSJI6NT")
            sdkConfig.moeDataCenter = .data_center_01
        #endif
        sdkConfig.enableLogs = true
      MoEngageInitializer.sharedInstance.initializeDefaultInstance(sdkConfig, launchOptions: launchOptions)
      }

    GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("Token: \(deviceToken)")
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}
