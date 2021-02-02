//
//  AppDelegate.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import Realm
import IQKeyboardManagerSwift
import Firebase
import Purchases

var uiRealm = try! Realm()
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
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
        var packagesAvailableForPurchase = [Purchases.Package]()
        Purchases.shared.offerings {  (offerings, error) in
            if let offerings = offerings {
                let offer = offerings.current
                let packages = offer?.availablePackages
                guard packages != nil else {
                    return
                }
                for i in 0...packages!.count - 1 {
                    let package = packages![i]
                    packagesAvailableForPurchase.append(package)
                }
            }
        }
        print(packagesAvailableForPurchase)
        for package in packagesAvailableForPurchase {
            Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
                if purchaserInfo?.entitlements.all["premium"]?.isActive == true {
                    print("your mother")
                    UserDefaults.standard.setValue(true, forKey: "isPro")
                    return
                } else {
                    print("setting to false")
                    UserDefaults.standard.setValue(false, forKey: "isPro")
                }
            }
        }
        window?.rootViewController = UINavigationController(rootViewController: controller )

        window?.makeKeyAndVisible()
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

