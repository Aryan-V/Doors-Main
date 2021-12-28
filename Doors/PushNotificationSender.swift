//
//  PushNotificationSender.swift
//  Doors
//
//  Created by ojaswee c on 12/26/21.
//

import UIKit
import Firebase
import FirebaseMessaging

//OJU
class PushNotificationSender {
    
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA3aOe1Tw:APA91bH31i9GjMd1dyiz51t5nL6e7tcxrgMELBRj55EXFlaYtXBf1GF3ecTBuVhl67zyi2RitdZ9EmHouoH0LPpvrftJGQDsqGRV2BPpqc_1E6dHBkGnLtpWNAVErqcWsCrstsknIF1g", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
