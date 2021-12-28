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
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if isBeingDismissed {
//
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameField.text = self.defaults.string(forKey: "userName")
    }

    @IBAction func donePressed(_ sender: UITextField) {
        self.defaults.set(nameField.text, forKey: "userName")
        nameField.resignFirstResponder()
        
        let roomChoice = defaults.value(forKey: "roomChosen") ?? 1
        
        db.collection("users_table").document(defaults.string(forKey: "userName")!).setData([
            "name": defaults.string(forKey: "userName")!,
            "room": roomSegment.titleForSegment(at: roomChoice as! Int)!,
            "fcmToken": Messaging.messaging().token
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
        db.collection("users_table").document(defaults.string(forKey: "userName")!).setData([
            "name": defaults.string(forKey: "userName")!,
            "room": roomSegment.titleForSegment(at: defaults.value(forKey: "roomChosen") as! Int)!,
            "fcmToken": Messaging.messaging().token
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
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
