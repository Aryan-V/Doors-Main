//
//  InterfaceController.swift
//  Watch Doors WatchKit Extension
//
//  Created by Aryan Vaswani on 12/28/21.
//

import WatchKit
import Foundation
import WatchConnectivity
//import FirebaseMessaging

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var nabeelDoorButton: WKInterfaceButton!
    @IBOutlet weak var larDoorButton: WKInterfaceButton!
    @IBOutlet weak var larElevatorDoor: WKInterfaceButton!
    @IBOutlet weak var subinDoorButton: WKInterfaceButton!
    
//    let notif = NotifyViewController()

    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func nabeelDoorPressedWatch() {
        WKInterfaceDevice().play(.click)
        sendPhoneNotifData(door: "0013", doorName: "Nabeel Door.")
    }
    
    @IBAction func larDoorPressedWatch() {
        WKInterfaceDevice().play(.click)
        sendPhoneNotifData(door: "0013", doorName: "LAR Door.")
    }
    
    @IBAction func larElevatorPressedWatch() {
        WKInterfaceDevice().play(.click)
        sendPhoneNotifData(door: "4498", doorName: "LAR Elevator.")
        sendPhoneNotifData(door: "4496", doorName: "LAR Elevator.")
    }
    
    @IBAction func subinDoorPressedWatch() {
        WKInterfaceDevice().play(.click)
        sendPhoneNotifData(door: "1132", doorName: "Subin Door.")
    }
    
    func sendPhoneNotifData(door: String, doorName: String) {
        // send a message to the watch if it's reachable
        if (WCSession.default.isReachable) {
            // this is a meaningless message, but it's enough for our purposes
            let message = ["door": door, "doorName": doorName]
            WCSession.default.sendMessage(message, replyHandler: nil)
            print("MESSAGE SENT TO PHONE WITH: \(door) \(doorName)")
        } else {
            print("PHONE UNREACHABLE")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }
}
