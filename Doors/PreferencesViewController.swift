//
//  PreferencesViewController.swift
//  Doors
//
//  Created by Aryan Vaswani on 12/12/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class PreferencesViewController: UIViewController, UITextFieldDelegate {
        
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var roomSegment: UISegmentedControl!
    
    let defaults = UserDefaults.standard
    
    let db = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        nameField.text = self.defaults.string(forKey: "userName")
        
        if let value = self.defaults.value(forKey: "roomChosen"){
            let selectedIndex = value as! Int
            roomSegment.selectedSegmentIndex = selectedIndex
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = self.view
        nameField.text = self.defaults.string(forKey: "userName")
        
        if self.defaults.string(forKey: "roomNumber") == nil {
            self.defaults.set("0013", forKey: "roomNumber")
        }
    }

    @IBAction func donePressed(_ sender: UITextField) {
        self.defaults.set(nameField.text, forKey: "userName")
        nameField.resignFirstResponder()
        
        let roomChoice = defaults.value(forKey: "roomChosen") ?? 1
        
        db.collection("users_table").document(defaults.string(forKey: "userName")!).setData([
            "name": defaults.string(forKey: "userName")!,
            "room": roomSegment.titleForSegment(at: roomChoice as! Int)!,
            "fcmToken": Messaging.messaging().fcmToken ?? 0
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.defaults.set(sender.selectedSegmentIndex, forKey: "roomChosen")
        let roomChoice = self.defaults.value(forKey: "roomChosen")
        self.defaults.set(roomSegment.titleForSegment(at: roomChoice as! Int)!, forKey: "roomNumber")
        db.collection("users_table").document(defaults.string(forKey: "userName") ?? "Temp").setData([
            "name": defaults.string(forKey: "userName")!,
            "room": roomSegment.titleForSegment(at: defaults.value(forKey: "roomChosen") as! Int)!,
            "fcmToken": Messaging.messaging().fcmToken ?? 0
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func getRoomNum() -> String{
        return self.defaults.string(forKey: "roomNumber")!
    }
}
