//
//  AppDelegate.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    static let CATEGORY_IDENTIFIER = "edu.monash.fit3178.sav-e.category"
    
    var notificationsEnabled = false

    var databaseController: DatabaseProtocol?
    var woolworthsItems: [ItemData] = []
    var compItemData: ItemData?
    var addedItem: Product?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = CoreDataController()
        // Set up local notifications given if notifications are enabled/ else ask
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { notificationSettings in
            if notificationSettings.authorizationStatus == .notDetermined {
                
                notificationCenter.requestAuthorization(options: [.alert]) { granted, error in
                    self.notificationsEnabled = granted
                    if granted {
                        self.setupNotifications()
                    }
                }
            }
            else if notificationSettings.authorizationStatus == .authorized {
                self.notificationsEnabled = true
                self.setupNotifications()
            }
        }
        return true
    }
    
    func setupNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        // Set up the category
        let appCategory = UNNotificationCategory(identifier: AppDelegate.CATEGORY_IDENTIFIER, actions: [], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the category just created with the notification centre
        notificationCenter.setNotificationCategories([appCategory])
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

    // MARK: UNUserNotificationCenterDelegate methods

    // Function required when registering as a delegate. We can process notifications if they are in the foreground!
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Print some information to console saying we have recieved the notification
        // We could do some automatic processing here if we didnt want the user's response
        print("Notification triggered while app running")
        
        // By default iOS will silence a notification if the application is in the foreground. We can over-ride this with the following
        completionHandler([.banner])
    }
}

