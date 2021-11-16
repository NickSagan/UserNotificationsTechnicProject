//
//  ViewController.swift
//  Scheduling notifications:
//
//  Created by Nick Sagan on 16.11.2021.
//
import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()

        // ask permission to send notifications
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Granted")
            } else {
                print("Denied")
            }
        }
    }


    @objc func scheduleLocal() {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // We can cancel pending notifications – i.e., notifications you have scheduled that have yet to be delivered because their trigger hasn’t been met
        
        let content = UNMutableNotificationContent() // This has lots of properties that customize the way the alert looks and works
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese"
        
        //categoryIdentifier is a text string that identifies a type of alert
        content.categoryIdentifier = "alarm" // You can also attach custom actions by specifying the categoryIdentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // To attach custom data to the notification
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // This one is just easier to test
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self // meaning that any alert-based messages that get sent will be routed to our view controller to be handled
        
        // Don't forget to make the ViewController class conform to UNUserNotificationCenterDelegate
        
        // UNNotificationAction creates an individual button for the user to tap
        let show = UNNotificationAction(identifier: "show", title: "Tell me more", options: .foreground)
        // UNNotificationCategory groups multiple buttons together under a single identifier
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // This is triggered on our view controller because we’re the center’s delegate, so it’s down to us to decide how to handle the notification.
        
        let userInfo = response.notification.request.content.userInfo
        //We attached some customer data to the userInfo property of the notification content, and this is where it gets handed back – here we can link the notification to whatever app content it relates to.
        
        if let customData = userInfo["customData"] as! String? {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier: print("Default identifier") // that gets sent when the user swiped on the notification to unlock their device and launch the app
            case "show": print("Show more information") // the user tapped our "show more info…" button
            default: break
            }
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
}
