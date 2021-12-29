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
    
    // all outlets for storyboard objects
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var roomSegment: UISegmentedControl!
    
    // global variables
    let defaults = UserDefaults.standard
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set up storyboard objects
        nameField.text = self.defaults.string(forKey: "userName")
        
        if let value = self.defaults.value(forKey: "roomChosen"){
            let selectedIndex = value as! Int
            roomSegment.selectedSegmentIndex = selectedIndex
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = self.view
        nameField.text = self.defaults.string(forKey: "userName")
        
        // if nil, let default be 0013
        if self.defaults.string(forKey: "roomNumber") == nil {
            self.defaults.set("0013", forKey: "roomNumber")
        }
    }

    // if name editing is complete
    @IBAction func donePressed(_ sender: UITextField) {
        // save username to defaults
        self.defaults.set(nameField.text, forKey: "userName")
        // dismiss keyboard
        nameField.resignFirstResponder()
        // provide default value for room chosen
        let roomChoice = defaults.value(forKey: "roomChosen") ?? 1
        // access usertable for given user by name and update all fields
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
    
    // if room number selection changed
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        // reset defaults value for key roomChosen
        self.defaults.set(sender.selectedSegmentIndex, forKey: "roomChosen")
        // acess value and set segment title for key roomNumber
        let roomChoice = self.defaults.value(forKey: "roomChosen")
        self.defaults.set(roomSegment.titleForSegment(at: roomChoice as! Int)!, forKey: "roomNumber")
        // access usertable for given user by name and update all fields
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
    
    // return room number from defaults
    func getRoomNum() -> String{
        return self.defaults.string(forKey: "roomNumber")!
    }
}
