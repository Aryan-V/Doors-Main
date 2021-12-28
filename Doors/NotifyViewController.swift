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
    
    let nf = NumberFormatter()
        
    private let database = Firestore.firestore()
    private var reference: CollectionReference?
    private var messageListener: ListenerRegistration?
    
//    let messageClient = MessageClient()
    
    deinit {
      messageListener?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listenToMessages()
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
//        messageClient.delegate = self
//        messageClient.setupNetworkCommunication()
//        messageClient.joinChat()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayWelcomeName()
    }
    
    private func listenToMessages() {
      reference = database.collection("channels/doors/thread")
        messageListener = reference?
          .addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            guard let snapshot = querySnapshot else {
              print("""
                Error listening for channel updates: \
                \(error?.localizedDescription ?? "No error")
                """)
              return
            }

            snapshot.documentChanges.forEach { change in
              self.handleDocumentChange(change)
            }
          }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
      guard let message = Message(document: change.document) else {
        return
      }

      switch change.type {
      case .added:
          sendNotificationDoor(message: message.content)
      default:
        break
      }
    }
    
    private func save(_ message: Message) {
      reference?.addDocument(data: message.representation) { [weak self] error in
//        guard let self = self else { return }
        if let error = error {
          print("Error sending message: \(error.localizedDescription)")
          return
        }
      }
    }

    
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
        
        let testMessage = Message(user: defaults.string(forKey: "userName")!, content: self.defaults.string(forKey: "userName")! + " is at the Nabeel door.")
        
        save(testMessage)
        
        let sender = PushNotificationSender()
//
//        sender.sendPushNotification(to: "07edd4c7326685895b2956e1ea99bc2480e41f1695a79836bd5585f0a16fbf2d", title: "Nabeel Door", body: "Sent with device token")
        
        sender.sendPushNotification(to: "cCLv9YA9ekztlMaX2bmbZe:APA91bE1YHnZmN_FCSpepHPEwHkBFvLnXSh6HkB3E78bcxAx3d3WhpJvng6slBF-2t7HZeQlvQQx2CudS_-RBP_JlA2IuKobJAOx5R-RVK20QcIT8i3H6nBv68H7h-7iBWNyRZaobjcT", title: "Doors", body: defaults.string(forKey: "userName")! + " is at the Nabeel Door.")
        
        print(self.defaults.string(forKey: "userName")! + " is at the Nabeel door.")
    }
    
    @IBAction func larDoorPressed(_ sender: Any) {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        
//        messageClient.send(message: self.defaults.string(forKey: "userName")! + " is at the LAR door.")
        
        let testMessage = Message(user: defaults.string(forKey: "userName")!, content: self.defaults.string(forKey: "userName")! + " is at the LAR door.")
        
        save(testMessage)
        
        let sender = PushNotificationSender()
        
        var fcm = ""
        
        let usersRef = Firestore.firestore().collection("users_table").document("Oju")
        
        usersRef.getDocument { (document, error) in
            if let document = document, document.exists {
                fcm = document.get("fcmToken") as! String
                sender.sendPushNotification(to: fcm, title: "Doors", body: self.defaults.string(forKey: "userName")! + " is at the LAR Door.")
                print((document.get("name") as! String) + "'s FCM Token: " + (fcm))
            } else {
                print("Document does not exist")
            }
        }

        print(self.defaults.string(forKey: "userName")! + " is at the LAR door.")
    }
    
    @IBAction func larElevatorPressed(_ sender: Any) {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        
//        messageClient.send(message: self.defaults.string(forKey: "userName")! + " is at the LAR elevator.")
        
        let testMessage = Message(user: defaults.string(forKey: "userName")!, content: self.defaults.string(forKey: "userName")! + " is at the LAR elevator.")
        
        save(testMessage)
        
        let sender = PushNotificationSender()
        
        sender.sendPushNotification(to: "cCLv9YA9ekztlMaX2bmbZe:APA91bE1YHnZmN_FCSpepHPEwHkBFvLnXSh6HkB3E78bcxAx3d3WhpJvng6slBF-2t7HZeQlvQQx2CudS_-RBP_JlA2IuKobJAOx5R-RVK20QcIT8i3H6nBv68H7h-7iBWNyRZaobjcT", title: "Doors", body: defaults.string(forKey: "userName")! + " is at the LAR Elevator.")

        print(self.defaults.string(forKey: "userName")! + " is at the LAR elevator.")
    }
    
    @IBAction func subinDoorPressed(_ sender: Any) {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        
//        messageClient.send(message: self.defaults.string(forKey: "userName")! + " is at the Subin door.")
        
        let testMessage = Message(user: defaults.string(forKey: "userName")!, content: self.defaults.string(forKey: "userName")! + " is at the Subin door.")
        
        save(testMessage)
        
        let sender = PushNotificationSender()

        sender.sendPushNotification(to: "cCLv9YA9ekztlMaX2bmbZe:APA91bE1YHnZmN_FCSpepHPEwHkBFvLnXSh6HkB3E78bcxAx3d3WhpJvng6slBF-2t7HZeQlvQQx2CudS_-RBP_JlA2IuKobJAOx5R-RVK20QcIT8i3H6nBv68H7h-7iBWNyRZaobjcT", title: "Doors", body: defaults.string(forKey: "userName")! + " is at the Subin Door.")

        print(self.defaults.string(forKey: "userName")! + " is at the Subin door.")
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
                
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
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.impactOccurred()
        if sendDNDNotification.titleLabel!.text == "Send Do Not Disturb to Roommates" {
            sendDNDNotification.setTitle("Cancel", for: .normal)
            sendDNDNotification.tintColor = UIColor.systemRed
        } else if sendDNDNotification.titleLabel!.text == "Cancel" {
            sendDNDNotification.setTitle("Send Do Not Disturb to Roommates", for: .normal)
            sendDNDNotification.tintColor = UIColor.systemBlue
        }
        
        self.defaults.set(sendDNDNotification.titleLabel!.text, forKey: "notifButton")
    }
    
    func sendNotificationDoor(message: String) {
        print("RECEIVED: " + message)
        //OJU
        //tryna get token from firestore usertable now
        /*let sender = PushNotificationSender()
        sender.sendPushNotification(to: "token", title: "Doors", body: message)*/
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
        self.user = data["senderName"] as! String
        self.content = data["content"] as! String
    }
}

//extension NotifyViewController: MessageClientDelegate {
//  func received(message: String) {
//    sendNotificationDoor(message: message)
//  }
//}
