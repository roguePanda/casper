//
//  AlarmManager.swift
//  Casper
//
//  Created by Ben Navetta on 10/31/15.
//  Copyright © 2015 Casper. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    let timeBefore: Int // how many minutes before to start sending notifications
    let interval: Int // time between notifications, in minutes
    let soundName: String
}

struct Alarm {
    let time: NSDate
    let warmupTime: Int // minutes before alarm time to start waking up
}

class AlarmManager {
    static let sharedInstance = AlarmManager()
    
    private static let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }();
    
    private func createNotifications(alert: Alert, alarm: Alarm) {
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        let startTime = calendar.dateByAddingUnit(.Minute, value: -alert.timeBefore, toDate: alarm.time, options: .MatchStrictly)!
        for schedule in notificationSchedules(startTime, interval: alert.interval) {
            if schedule.fireDate.compare(NSDate()) == .OrderedAscending {
                // Don't schedule notifications that would be in the past
                continue;
            }
            
            print("Notification scheduled at \(AlarmManager.dateFormatter.stringFromDate(schedule.fireDate))")
            
            let notification = UILocalNotification()
            notification.fireDate = schedule.fireDate
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.alertTitle = "Wake Up"
            notification.alertBody = "Casper wants you to get up!"
            notification.category = "ALARM"
            notification.soundName = alert.soundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    func schedule(alarm: Alarm) {
        for timeBefore in distances(Double(alarm.warmupTime)) {
            let minutesBefore = -Int(round(timeBefore/60))
            let alert = Alert(timeBefore: minutesBefore, interval: 1, soundName: UILocalNotificationDefaultSoundName)
            createNotifications(alert, alarm: alarm)
        }
    }
}