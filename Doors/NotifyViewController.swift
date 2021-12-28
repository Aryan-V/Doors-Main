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
    
    // all outlets for storyboard objects
    @IBOutlet weak var nabeelDoorButton: UIButton!
    @IBOutlet weak var larDoorButton: UIButton!
    @IBOutlet weak var larElevatorButton: UIButton!
    @IBOutlet weak var subinDoorButton: UIButton!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var sendDNDNotification: UIButton!
        
    // initializing class-wide properties
    let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    let prefview = PreferencesViewController()
    let nf = NumberFormatter()
    let feedbackGenerator = UIImpactFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // using firebase authentication to anonymously authenticate user
        Auth.auth().signInAnonymously()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            // display welcome message upon first use of application
            self.displayWelcomeName()
            
            // set up slider values and label text based on saved preferences from defaults
            self.durationSlider.value = (Float(self.defaults.string(forKey: "minutesDND") ?? "0")! / 120)
            let minutes = self.defaults.integer(forKey: "minutesDND")
            
            // ensuring that minute instead of minutes is printed for 1 minute
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
        // prepare haptics
        self.feedbackGenerator.prepare()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // instantiate preferencesviewcontroller so its variables/methods can be accessed
        _ = self.storyboard?.instantiateViewController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // display welcome message upon first use of application (depending on whether load or appear runs first)
        self.displayWelcomeName()
    }
    
    // displays initial welcome message with preferences view controller to set name and room
    func displayWelcomeName() {
        // access userdefaults property whether name has been inputed (to ensure following alert displays only once
        let nameInput = self.defaults.string(forKey: "nameInput")
        
        // confirm whether welcome alert has already been shown
        if (nameInput == nil || nameInput == "") {
            // init UIALertController with title and message
            let welcomeAlert = UIAlertController(title: "Welcome to Doors!", message: "After you've set your preferences, swipe down the screen and begin using Doors!", preferredStyle: .alert)
            
            // include singluar continue action to dismiss alert and present empty preferences view controller to add name/room
            let continueAction = UIAlertAction(title: "Set Preferences", style: .default) { _ in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let preferencesViewController = storyBoard.instantiateViewController(withIdentifier: "PreferencesViewController")
                self.present(preferencesViewController, animated: true, completion: nil)
            }
            
            // complete set up of NotifyView objects
            self.sendDNDNotification.setTitle("Send Do Not Disturb to Roommates", for: .normal)
            self.sendDNDNotification.tintColor = UIColor.systemBlue
            
            self.defaults.set(self.sendDNDNotification.titleLabel!.text, forKey: "notifButton")
            
            welcomeAlert.addAction(continueAction)
            welcomeAlert.overrideUserInterfaceStyle = .dark
            
            //present alert
            self.present(welcomeAlert, animated: true, completion: nil)
            
            // set shown for defaults value so alert never appears again
            self.defaults.set("shown", forKey: "nameInput")
        }
    }
    
    // action for if nabeel door button is pressed
    @IBAction func nabeelDoorPressed(_ sender: Any) {
        // haptics
        self.feedbackGenerator.impactOccurred()
        
        // calls notification function to send to all members of designated room
        sendNotificationDoor(door: "0013", doorName: "Nabeel Door.")
    }
    
    // action for if lar door button is pressed
    @IBAction func larDoorPressed(_ sender: Any) {
        // haptics
        self.feedbackGenerator.impactOccurred()
        
        // calls notification function to send to all members of designated room
        sendNotificationDoor(door: "0013", doorName: "LAR Door.")
    }
    
    // action for if lar elevator button is pressed
    @IBAction func larElevatorPressed(_ sender: Any) {
        // haptics
        self.feedbackGenerator.impactOccurred()
        
        // calls notification function to send to all members of designated rooms
        sendNotificationDoor(door: "4498", doorName: "LAR Elevator.")
        sendNotificationDoor(door: "4496", doorName: "LAR Elevator.")
    }
    
    // action for if subin door button is pressed
    @IBAction func subinDoorPressed(_ sender: Any) {
        // haptics
        self.feedbackGenerator.impactOccurred()
        
        // calls notification function to send to all members of designated room
        sendNotificationDoor(door: "1132", doorName: "Subin Door.")
    }
    
    // action for if dnd slider value has changed
    @IBAction func sliderChanged(_ sender: Any) {
        // max value is 2 hours, minutes calculated below
        let minutes = 120 * durationSlider.value
        
        // ensuring that minute instead of minutes is printed for 1 minute
        if nf.string(from: NSNumber(value: minutes))! == "1" {
            minutesLabel.text = nf.string(from: NSNumber(value: minutes))! + " Minute"
        } else {
            minutesLabel.text = nf.string(from: NSNumber(value: minutes))! + " Minutes"
        }
        
        // minutes value saved to defaults for future loads
        self.defaults.set(nf.string(from: NSNumber(value: minutes)), forKey: "minutesDND")
    }
    
    // action for if send DND notif to roommates button is pressed
    @IBAction func sendDNDNotificationPressed(_ sender: Any) {
        // initializing properties in scope of function
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let prefview = storyboard.instantiateViewController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
        let sender = PushNotificationSender()
        var timer = Timer()
        
        // haptics
        self.feedbackGenerator.impactOccurred()
        // if button is currently set to send notif
        if sendDNDNotification.titleLabel!.text == "Send Do Not Disturb to Roommates" {
            // change button characteristics to cancel style
            sendDNDNotification.setTitle("Cancel", for: .normal)
            sendDNDNotification.tintColor = UIColor.systemRed
            
            // compute necessary values to display return time
            let timeNeededMins = (durationSlider.value * 120)
            let startDate = Date()
            let calendar = Calendar.current
            let date = calendar.date(byAdding: .minute, value: Int(timeNeededMins), to: startDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            // begin timer
            let timeNeededSecs = timeNeededMins*60
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeNeededSecs), target: self, selector: #selector(timerComplete), userInfo: nil, repeats: false)
            print(dateFormatter.string(from: date!))
            
            // access user table in firestore
            db.collection("users_table").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // for each document
                    for document in querySnapshot!.documents {
                        // if the document (stored user) has the same room number as user and not the same name (not self)
                        if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
                            // ensuring that minute instead of minutes is printed for 1 minute
                            if self.nf.string(from: NSNumber(value: timeNeededMins))! == "1" {
                                sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " needs the room for " + self.nf.string(from: NSNumber(value: timeNeededMins))! + " minute. Come back at " + dateFormatter.string(from: date!) + ".")
                            } else {
                                sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " needs the room for " + self.nf.string(from: NSNumber(value: timeNeededMins))! + " minutes. Come back at " + dateFormatter.string(from: date!) + ".")
                            }
                            print("sent dnd notif")
                        }
                        
                    }
                }
            }
            // if button is currently set to cancel notif
        } else if sendDNDNotification.titleLabel!.text == "Cancel" {
            // change button characteristics to send style
            sendDNDNotification.setTitle("Send Do Not Disturb to Roommates", for: .normal)
            sendDNDNotification.tintColor = UIColor.systemBlue
            // access all users
            db.collection("users_table").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // iterate through all users
                    for document in querySnapshot!.documents {
                        // if room matches self room and name ensures not self
                        if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
                            sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is done with the room.")
                            print("sent cancel notif")
                        }
                        
                    }
                }
            }
            
            // timer is cancelled
            timer.invalidate()
        }
        
        // save button status in user defaults for future loads
        self.defaults.set(sendDNDNotification.titleLabel!.text, forKey: "notifButton")
    }
    
    // function for when timer completes
    @objc func timerComplete() {
        if sendDNDNotification.titleLabel!.text == "Cancel" {
            // change button characteristics to send style
            sendDNDNotification.setTitle("Send Do Not Disturb to Roommates", for: .normal)
            sendDNDNotification.tintColor = UIColor.systemBlue
        }
    }
    
    // door button pressed notification sender function
    func sendNotificationDoor(door: String, doorName: String) {
        let sender = PushNotificationSender()
        
        // access table of users in firestore
        db.collection("users_table").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // for each user
                for document in querySnapshot!.documents {
                    // if room is same as input room (door location) and not self via name
                    // already called twice for lar elevator so no need for special case
                    if (document.get("room") as! String) == door && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) {
                        // send notif via stored fcm token
                        sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is at the " + doorName)
                    }
                }
            }
        }
    }
    
    // notification processing function
    func process(_ notification: UNNotification) {
        // gather data from user notification
        let userInfo = notification.request.content.userInfo
        let senderFcm = userInfo["user"]
        let sender = PushNotificationSender()
        
        // extract body from notification
        if let aps = userInfo["aps"] as? [String:Any],
           let alertDict = aps["alert"] as? [String:String] {
            print("received notification body:", alertDict["body"]!)
            
            // derive components of body (similar to .split in java)
            let dict = alertDict["body"]!.components(separatedBy: " ")
            
            // create alert with two actions for away and coming, both with two notifs sent, one to roommates and the other to sender of original at door notif
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
            
            // only show this alert if it says someone is at door/elevator
            if alertDict["body"]!.components(separatedBy: " ")[dict.count - 1].contains("or.") {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        print("Sender FCM: " + (senderFcm as! String))
        
    }
    
    // function sends alert notifications to roommates regarding whether someone is going to get the door or not
    private func sendAlertNotif(senderFcm: String, comingOrAway: String, personDoor: String) {
        // ensure prefview objects can be accessed
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let prefview = storyboard.instantiateViewController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
        let sender = PushNotificationSender()
        
        let dict = personDoor.components(separatedBy: " ")
        let name = dict[0]
        let elevator = dict[dict.count-1]
        var isElevator = false
        
        if elevator == "Elevator." {
            isElevator = true
        }
        
        // access user table
        db.collection("users_table").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // if user is coming to door
                if comingOrAway == "coming" {
                    for document in querySnapshot!.documents {
                        // sent to roommates and not self via name
                        // NEED SPECIAL CASE FOR LAR ELEVATOR
                        if isElevator {
                            if prefview.getRoomNum() == "4496" {
                                if ((document.get("room") as! String) == prefview.getRoomNum() || (document.get("room") as! String) == "4498") && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) && (document.get("fcmToken") as! String) != senderFcm {
                                    sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is getting " + name + ". Please open " + name + "'s arrival notification and choose away at the alert.")
                                }
                            } else {
                                if ((document.get("room") as! String) == prefview.getRoomNum() || (document.get("room") as! String) == "4496") && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) && (document.get("fcmToken") as! String) != senderFcm {
                                    sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is getting " + name + ". Please open " + name + "'s arrival notification and choose away at the alert.")
                                }
                            }
                        } else {
                            if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) && (document.get("fcmToken") as! String) != senderFcm {
                                sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is getting " + name + ". Please open " + name + "'s arrival notification and choose away at the alert.")
                            }
                        }
                    }
                    
                    // if user is not coming to door
                } else if comingOrAway == "away" {
                    for document in querySnapshot!.documents {
                        // sent to roommates and not self via name
                        // NEED SPECIAL CASE FOR LAR ELEVATOR
                        if isElevator {
                            if prefview.getRoomNum() == "4496" {
                                if ((document.get("room") as! String) == prefview.getRoomNum() || (document.get("room") as! String) == "4498") && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) && (document.get("fcmToken") as! String) != senderFcm {
                                    sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " cannot get " + name + ".")
                                }
                            } else {
                                if ((document.get("room") as! String) == prefview.getRoomNum() || (document.get("room") as! String) == "4496") && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) && (document.get("fcmToken") as! String) != senderFcm {
                                    sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " cannot get " + name + ".")
                                }
                            }
                        } else {
                            if (document.get("room") as! String) == prefview.getRoomNum() && ((document.get("name") as! String) != self.defaults.string(forKey: "userName")) && (document.get("fcmToken") as! String) != senderFcm {
                                sender.sendPushNotification(to: document.get("fcmToken") as! String, title: "Doors", body: self.defaults.string(forKey: "userName")! + " cannot get " + name + ".")
                            }
                        }
                    }
                }
            }
        }
    }
}
