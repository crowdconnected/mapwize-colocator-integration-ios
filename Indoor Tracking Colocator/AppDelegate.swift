//
//  AppDelegate.swift
//  Indoor Tracking Colocator
//
//  Created by Mobile Developer on 13/09/2019.
//  Copyright © 2019 Mobile Developer. All rights reserved.
//

import UIKit
import CCLocation

let kCCApiKey = "fdrgm64d"
let kCCUrlString = "staging.colocator.net:443/socket"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        CCLocation.sharedInstance.start(apiKey: kCCApiKey, urlString: kCCUrlString)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { authorized, error in }
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // For CCLocation messaging feature, send device token to the library as an alias
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        CCLocation.sharedInstance.addAlias(key: "apns_user_id", value: tokenString)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // CCLocation can send Silent Push Notifications to wake up the library when needed; check the source of the SPN and pass it to the library
        if userInfo["source"] as? String == "colocator" {
            CCLocation.sharedInstance.receivedSilentNotification(userInfo: userInfo, clientKey: kCCApiKey) { isNewData in
                if isNewData {
                    completionHandler(.newData)
                } else {
                    completionHandler(.noData)
                }
            }
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // At background refresh, the CCLocation library should be notified to update its state
        CCLocation.sharedInstance.updateLibraryBasedOnClientStatus(clientKey: kCCApiKey) { success in
            if success {
                completionHandler(.newData)
            } else {
                completionHandler(.noData)
            }
        }
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

