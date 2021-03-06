//
//  AppDelegate.swift
//  Casper
//
//  Created by Ben Navetta on 10/31/15.
//  Copyright © 2015 Casper. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AlarmManagerDelegate {

    var window: UIWindow?
    
    var currentProofCallback: (Bool -> ())?
    
    // really terrible hack, but AppDelegate is where notifications go to, and it can't reliably get at the current
    // view controller for a segue
    static var currentViewController: UIViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        AlarmManager.sharedInstance.configureNotifications(application)
        AlarmManager.sharedInstance.delegate = self
        
        if let launchOptions = launchOptions, notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] {
            print("Launched from notification: \(notification)")
        }
       
//        let alarm = Alarm(time: NSDate(timeIntervalSinceNow: 20*60), warmupTime: 20)
//        AlarmManager.sharedInstance.schedule(alarm)
        
        return true
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        print("Handling \(identifier) for \(notification)")
        if let identifier = identifier {
            AlarmManager.sharedInstance.handleAction(identifier, notification: notification)
        }
        completionHandler()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("Got local notification: \(notification)")
        if let category = notification.category {
            // hacks
            if category == "done" {
                AlarmManager.sharedInstance.handleAction("complete", notification: notification)
            }
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func alarmDidComplete(alarm: Alarm, proofCallback: Bool -> ()) {
//        if let currentVC = window?.rootViewController {
//            currentProofCallback = proofCallback
////            currentVC.performSegueWithIdentifier("wakeUp", sender: alarm)
//            let storyboard = UIStoryboard(name: "UI", bundle: nil)
//            let wakeupVC = storyboard.instantiateViewControllerWithIdentifier("wakeupVC") as! WakeupViewController
//            wakeupVC.alarm = alarm
//            currentVC.presentViewController(wakeupVC, animated: true, completion: nil)
//        }
        currentProofCallback = proofCallback
        AppDelegate.currentViewController?.performSegueWithIdentifier("wakeUp", sender: alarm)
    }
    
    func proofCompleted(success: Bool) {
        currentProofCallback?(success)
        if success && !(AppDelegate.currentViewController is ViewController) {
            AppDelegate.currentViewController?.performSegueWithIdentifier("goHome", sender: nil)
        }
    }
}

