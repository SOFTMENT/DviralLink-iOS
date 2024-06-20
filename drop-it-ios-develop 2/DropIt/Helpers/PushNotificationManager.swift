//
//  PushNotificationManager.swift
//  DropIt
//
//  Created by User on 8/11/21.
//

import Firebase
import Foundation

class PushNotificationManager {
    
    static let shared = PushNotificationManager()
    private init() { }
    
    func registerPushNotifications() {
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            MoyaManager().requestNotifications(token) { responseCode in
                switch responseCode {
                case 200:
                    print("The request was sent successfully")
                default:
                    print("Error")
                }
            }
          }
        }
    }
}
