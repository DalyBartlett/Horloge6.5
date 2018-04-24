//
//  Alarm.swift
//  Alarm
//
//  Created by Lasha Efremidze on 1/13/17.
//  Copyright © 2017 More Voltage. All rights reserved.
//

import UserNotifications

@available(iOS 10.0, *)
private let UNC = UNUserNotificationCenter.current()

enum AlarmType: String {
    case am, pm, day
    
    private var dateComponents: DateComponents {
        switch self {
        case .am:
            var components = DateComponents()
            components.hour = 4
            components.minute = 20
            return components
        case .pm:
            var components = DateComponents()
            components.hour = 16
            components.minute = 20
            return components
        case .day:
            var components = DateComponents()
            components.month = 4
            components.day = 20
            return components
        }
    }
    
    func schedule(completionHandler: ((Error?) -> Void)? = nil) {
        if #available(iOS 10.0, *) {
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    UNC.add(title: "", body: Constants.defaultTitle, identifier: rawValue, trigger: trigger, withCompletionHandler: completionHandler)
        } else {
            // Fallback on earlier versions
        }

    }
    
    func unschedule() {
        if #available(iOS 10.0, *) {
            UNC.removePendingNotificationRequests(withIdentifiers: [rawValue])
        } else {
            // Fallback on earlier versions
        }
    }
    
    func isScheduled(completionHandler: @escaping (Bool) -> Void) {
        if #available(iOS 10.0, *) {
            UNC.getPendingNotificationRequests { requests in DispatchQueue.main.async { completionHandler(!requests.filter { $0.identifier == self.rawValue }.isEmpty) } }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct Alarm {
    
    static func start(completionHandler: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 10.0, *) {
            UNC.requestAuthorization(options: [.sound, .alert, .carPlay], completionHandler: completionHandler)
        } else {
            // Fallback on earlier versions
        }
    }
    
    static func reset() {
        if #available(iOS 10.0, *) {
            UNC.removeAllPendingNotificationRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    
//    static func test(completionHandler: ((Error?) -> Void)? = nil) {
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        UNC.add(title: "", body: Constants.defaultTitle, identifier: "test", trigger: trigger, withCompletionHandler: completionHandler)
//    }
    
}

@available(iOS 10.0, *)
private extension UNUserNotificationCenter {
    
    func add(title: String, body: String, identifier: String, trigger: UNNotificationTrigger?, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default()
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        add(request, withCompletionHandler: completionHandler)
    }
    
}
