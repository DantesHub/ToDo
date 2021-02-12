//
//  AppDelegate.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import RealmSwift
import Realm
import IQKeyboardManagerSwift
import Firebase
import Purchases
import AppsFlyerLib

var uiRealm = try! Realm()
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let lastOpened = (UserDefaults.standard.string(forKey: "lastOpened"))
        let controller = MainViewController()
        if lastOpened != nil {
            mainIsRoot = false
        } else {
            mainIsRoot = true
        }
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        UserDefaults.standard.register(defaults: [
            "notif": true,
        ])
        FirebaseApp.configure()
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: "AHheigtCZwIDDNXLWGlcpEHQzgvcVjaA")
        
        AppsFlyerLib.shared().appsFlyerDevKey = "SkMD73YhAgsMxoC8vPrALn"
             AppsFlyerLib.shared().appleAppID = "1547261918"
             AppsFlyerLib.shared().delegate = self
             AppsFlyerLib.shared().isDebug = true
             // iOS 10 or later
//             if #available(iOS 10, *) {
//                 UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
//                 application.registerForRemoteNotifications()
//             }
        
        window?.rootViewController = UINavigationController(rootViewController: controller )
        window?.makeKeyAndVisible()
        sendLaunch()
        return true
    }
    @objc func sendLaunch() {
       AppsFlyerLib.shared().start()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
         AppsFlyerLib.shared().handlePushNotification(userInfo)
     }
     // Open Deeplinks
     // Open URI-scheme for iOS 8 and below
     private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
         AppsFlyerLib.shared().continue(userActivity, restorationHandler: restorationHandler)
         return true
        
     }
     // Open URI-scheme for iOS 9 and above
     func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
         AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
         return true
     }
     // Report Push Notification attribution data for re-engagements
     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
         AppsFlyerLib.shared().handleOpen(url, options: options)
         return true
     }
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         AppsFlyerLib.shared().handlePushNotification(userInfo)
     }
     // Reports app open from deep link for iOS 10 or later
     func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
         AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
         return true
     }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentCloudKitContainer(name: "Todo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

//MARK: AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate{
    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        print("onConversionDataSuccess data:")
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                    let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
                is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    //Handle Deep Link
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}
