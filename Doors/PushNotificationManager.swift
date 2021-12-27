//
//  PushNotificationManager.swift
//  Doors
//
//  Created by ojaswee c on 12/26/21.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    //OJU
    //error: with remoteMessaging and next func
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users_table").document(userID)
            usersRef.setData(["fcmToken": token], merge: true)
        }
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        print(remoteMessage.description)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
}
