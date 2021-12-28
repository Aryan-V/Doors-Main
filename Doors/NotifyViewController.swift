//
//  NotifyViewController.swift
//  Doors
//
//  Created by Aryan Vaswani on 12/12/21.
//

import UserNotifications
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class NotifyViewController: UIViewController {
    
    @IBOutlet weak var nabeelDoorButton: UIButton!
    @IBOutlet weak var larDoorButton: UIButton!
    @IBOutlet weak var larElevatorButton: UIButton!
    @IBOutlet weak var subinDoorButton: UIButton!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var sendDNDNotification: UIButton!
    
        
    let defaults = UserDefaults.standard
        
    let db = Firestore.firestore()
    
    let prefview = PreferencesViewController()
    
//    var prefview = storyboard?.instantiateViewController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
    
    let nf = NumberFormatter()
        
//    private let database = Firestore.firestore()
//    private var reference: CollectionReference?
//    private var messageListener: ListenerRegistration?
    
//    let messageClient = MessageClient()
    
//    deinit {
//      messageListener?.remove()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        listenToMessages()
        Auth.auth().signInAnonymously()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.displayWelcomeName()
            self.durationSlider.value = (Float(self.defaults.string(forKey: "minutesDND") ?? "0")! / 120)
            let minutes = self.defaults.integer(forKey: "minutesDND")
            
            if self.nf.string(from: NSNumber(value: minutes))! == "1" {
                self.minutesLabel.text = self.nf.string(from: NSNumber(value: minutes))! + " Minute"
            } else {
                self.minutesLabel.text = self.nf.string(from: NSNumber(value: minutes))! + " Minutes"
            }
            
            self.defaults.set(self.sendDNDNotification.titleLabel!.text, forKey: "notifButton")
            
            self.defaults.set(self.nf.string(from: NSNumber(value: minutes)), forKey: "minutesDND")
        }
        
        loadView()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        messageClient.stopMessageClient()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var prefview = self.storyboard?.instantiateViewController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
//        messageClient.delegate = self
//        messageClient.setupNetworkCommunication()
//        messageClient.joinChat()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayWelcomeName()
    }
    
//    private func listenToMessages() {
//      reference = database.collection("channels/doors/thread")
//        messageListener = reference?
//          .addSnapshotListener { [weak self] querySnapshot, error in
//            guard let self = self else { return }
//            guard let snapshot = querySnapshot else {
//              print("""
//                Error listening for channel updates: \
//                \(error?.localizedDescription ?? "No error")
//                """)
//              return
//            }
//
//            snapshot.documentChanges.forEach { change in
//              self.handleDocumentChange(change)
//            }
//          }
//    }
    
//    private func handleDocumentChange(_ change: DocumentChange) {
//      guard let message = Message(document: change.document) else {
//        return
//      }
//
//      switch change.type {
//      case .added:
//          sendNotificationDoor(message: message.content)
//      default:
//        break
//      }
//    }
//
//    private func save(_ message: Message) {
//      reference?.addDocument(data: message.representation) { [weak self] error in
////        guard let self = self else { return }
//        if let error = error {
//          print("Error sending message: \(error.localizedDescription)")
//          return
//        }
//      }
//    }

    
    func displayWelcomeName() {
        let nameInput = self.defaults.string(forKey: "nameInput")
        
//        var cont = false
        
        if (nameInput == nil || nameInput == "") {
            let welcomeAlert = UIAlertController(title: "Welcome to Doors!", message: "After you've set your preferences, swipe down the screen and begin using Doors!", preferredStyle: .alert)

            let continueAction = UIAlertAction(title: "Set Preferences", style: .default) { [weak welcomeAlert] _ in
//                guard let textFields = welcomeAlert?.textFields else { return }
//
//                if let nameText = textFields[0].text {
//                    self.defaults.set(nameText, forKey: "userName")
//                }
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let preferencesViewController = storyBoard.instantiateViewController(withIdentifier: "PreferencesViewController")
                self.present(preferencesViewController, animated: true, completion: nil)
            }
            
            self.sendDNDNotification.setTitle("Send Do Not Disturb to Roommates", for: .normal)
            self.sendDNDNotification.tintColor = UIColor.systemBlue
            
            self.defaults.set(self.sendDNDNotification.titleLabel!.text, forKey: "notifButton")

            welcomeAlert.addAction(continueAction)
            welcomeAlert.overrideUserInterfaceStyle = .dark
            self.present(welcomeAlert, animated: true, completion: nil)
            self.defaults.set("shown", forKey: "nameInput")
        }
    }
    
    
    @IBAction func nabeelDoorPressed(_ sender: Any) {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        
//        messageClient.send(message: self.defaults.string(forKey: "userName")! + " is at the Nabeel door.")
        
//        let testMessage = Message(user: defaults.string(forKey: "userName")!, content: self.defaults.string(forKey: "userName")! + " is at the Nabeel door.")
        
//        save(testMessage)
//
//        sender.sendPushNotification(to: "07edd4c7326685895b2956e1ea99bc2480e41f1695a79836bd5585f0a16fbf2d", title: "Nabeel Door", body: "Sent with device token")
        
        sendNotificationDoor(door: "0013", doorName: "Nabeel Door.")
    }
    
    @IBAction func larDoorPressed(_ sender: Any) {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        
//        messageClient.send(message: self.defaults.string(forKey: "userName")! + " is at the LAR door.")
        
//        let testMessage = Message(user: defaults.string(forKey: "userName")!, content: self.defaults.string(forKey: "userName")! + " is at the LAR door.")
//
//        save(testMessage)
        
        sendNotificationDoor(door: "0013", doorName: "LAR Door.")
    }
    
    @IBAction func larElevatorPressed(_ sender: Any) {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        
//        messageClient.send(message: self.defaults.string(forKey: "userName")! + " is at the LAR elevator.")
        
//        let testMessage = Message(user: defaults.string(forKey: "userName")!, content: self.defaults.string(forKey: "userName")! + " is at the LAR elevator.")
//
//        save(testMessage)
        
        sendNotificationDoor(door: "4498", doorName: "LAR Elevator.")
        sendNotificationDoor(door: "4496", doorName: "LAR Elevator.")
    }
    
    @IBAction func subinDoorPressed(_ sender: Any) {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        
//        messageClient.send(message: self.defaults.string(forKey: "userName")! + " is at the Subin door.")
        
//        let testMessage = Message(user: defaults.string(forKey: "userName")!, content: self.defaults.string(forKey: "userName")! + " is at the Subin door.")
//
//        save(testMessage)
//
        sendNotificationDoor(door: "1132", doorName: "Subin Door.")
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
//        let feedbackGenerator = UISelectionFeedbackGenerator()
//        feedbackGenerator.selectionChanged()
                
        // max value is 2 hours
        let minutes = 120 * durationSlider.value
        if nf.string(from: NSNumber(value: minutes))! == "1" {
            minutesLabel.text = nf.string(from: NSNumber(value: minutes))! + " Minute"
        } else {
            minutesLabel.text = nf.string(from: NSNumber(value: minutes))! + " Minutes"
        }
        
        self.defaults.set(nf.string(from: NSNumber(value: minutes)), forKey: "minutesDND")
    }
    
    @IBAction func sendDNDNotificationPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let prefview = storyboard.instantiateViewController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
        
        var timer = Timer()
        
        let sender = PushNotificationSender()
                
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        if sendDNDNotification.titleLabel!.text == "Send Do Not Disturb to Roommates" {
            sendDNDNotification.setTitle("Cancel", for: .normal)
            sendDNDNotification.tintColor = UIColor.systemRed
            let timeNeededMins = (durationSlider.value * 120)
            let timeNeededSecs = timeNeededMins*60
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeNeededSecs), target: self, selector: #selector(sendCompletionNotif), userInfo: nil, repeats: false)
            
            db.collection("users_table").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
                            if self.nf.string(from: NSNumber(value: timeNeededMins))! == "1" {
                                sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " needs the room for " + self.nf.string(from: NSNumber(value: timeNeededMins))! + " minute.")
                            } else {
                                sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " needs the room for " + self.nf.string(from: NSNumber(value: timeNeededMins))! + " minutes.")
                            }
                            print("sent dnd notif")
                        }
                        
                    }
                }
            }
            
        } else if sendDNDNotification.titleLabel!.text == "Cancel" {
            sendDNDNotification.setTitle("Send Do Not Disturb to Roommates", for: .normal)
            sendDNDNotification.tintColor = UIColor.systemBlue
            db.collection("users_table").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
                            sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is done with the room.")
                            print("sent cancel notif")
                        }
                        
                    }
                }
            }
            timer.invalidate()
        }
        
        self.defaults.set(sendDNDNotification.titleLabel!.text, forKey: "notifButton")
    }
    
    @objc func sendCompletionNotif() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let prefview = storyboard.instantiateViewController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
        let sender = PushNotificationSender()
                
        db.collection("users_table").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
                        sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is done with the room.")
                        print("sent timer completion notif")
                    }
                    
                }
            }
        }
        
        if sendDNDNotification.titleLabel!.text == "Cancel" {
            sendDNDNotification.setTitle("Send Do Not Disturb to Roommates", for: .normal)
            sendDNDNotification.tintColor = UIColor.systemBlue
        }
        
        self.defaults.set(sendDNDNotification.titleLabel!.text, forKey: "notifButton")
    }
    
    func sendNotificationDoor(door: String, doorName: String) {
        let sender = PushNotificationSender()
                
        db.collection("users_table").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if (document.get("room") as! String) == door && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
                            sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is at the " + doorName)
                        }
//                        if (document.get("room") as! String) == door {
//                            sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is at the " + doorName)
//                        }
                    }
                }
            }
    }
    
    func process(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        let senderFcm = userInfo["user"]
        
        let sender = PushNotificationSender()
        
        if let aps = userInfo["aps"] as? [String:Any],
           let alertDict = aps["alert"] as? [String:String] {
            print("body :", alertDict["body"]!)
            
            let dict = alertDict["body"]!.components(separatedBy: " ")
            let name = dict[0]
            
            let alert = UIAlertController(title: "Attention", message: alertDict["body"], preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Away", style: UIAlertAction.Style.destructive, handler: { action in
                self.sendAlertNotif(senderFcm: senderFcm as! String, comingOrAway: "away", personDoor: alertDict["body"]!)
                sender.sendPushNotification(to: senderFcm as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " cannot come get you.")
            }))
            alert.addAction(UIAlertAction(title: "Coming", style: UIAlertAction.Style.default, handler: { action in
                self.sendAlertNotif(senderFcm: senderFcm as! String, comingOrAway: "coming", personDoor: alertDict["body"]!)
                sender.sendPushNotification(to: senderFcm as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is coming to get you.")
            }))
            alert.overrideUserInterfaceStyle = .dark
            
            print(alertDict["body"]!.components(separatedBy: " ")[dict.count - 1])
            
            // only show this alert if it says someone is at door/elevator
            if alertDict["body"]!.components(separatedBy: " ")[dict.count - 1].contains("or.") {
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        
        print("Sender FCM: " + (senderFcm as! String))
        
    }
    
    private func sendAlertNotif(senderFcm: String, comingOrAway: String, personDoor: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let prefview = storyboard.instantiateViewController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
        let sender = PushNotificationSender()
        
        let name = personDoor.components(separatedBy: " ")[0]
                        
        db.collection("users_table").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if comingOrAway == "coming" {
                    for document in querySnapshot!.documents {
//                        if (document.get("room") as! String) == door && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
//                            sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is at the " + doorName)
//                        }
                        
                       
                        if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) && (document.get("fcmToken") as! String) != senderFcm {
                                sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is getting " + name + ".")
                            }
                        }
                        
                    } else if comingOrAway == "away" {
                        for document in querySnapshot!.documents {
    //                        if (document.get("room") as! String) == door && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
    //                            sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is at the " + doorName)
    //                        }
                            
                           
                            if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) && (document.get("fcmToken") as! String) != senderFcm {
                                    sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " cannot get " + name + ".")
                                }
                            }
                    }
                }
            }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

struct Message {
    let user: String!
    var content: String!
    
    var representation: [String: Any] {
      var rep: [String: Any] = [
        "senderName": user!,
        "content": content!
      ]

      return rep
    }
    
    init(user: String, content: String) {
        self.user = user
      self.content = content
    }
    
    init?(document: QueryDocumentSnapshot) {
      let data = document.data()
        self.user = (data["senderName"] as! String)
        self.content = (data["content"] as! String)
    }
}

//extension NotifyViewController: MessageClientDelegate {
//  func received(message: String) {
//    sendNotificationDoor(message: message)
//  }
//}
