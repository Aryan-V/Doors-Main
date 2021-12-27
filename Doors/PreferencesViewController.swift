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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            db.collection("users_table").document(defaults.string(forKey: "userName")!).setData([
                "name": defaults.string(forKey: "userName")!,
                "room": roomSegment.titleForSegment(at: defaults.value(forKey: "roomChosen") as! Int)!,
                "fcmToken": Messaging.messaging().fcmToken!
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameField.text = self.defaults.string(forKey: "userName")
    }

    @IBAction func donePressed(_ sender: UITextField) {
        self.defaults.set(nameField.text, forKey: "userName")
        nameField.resignFirstResponder()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.defaults.set(sender.selectedSegmentIndex, forKey: "roomChosen")
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
