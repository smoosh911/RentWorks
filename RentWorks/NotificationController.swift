//
//  NotificationController.swift
//  RentWorks
//
//  Created by Michael Perry on 1/6/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol NotificationControllerDelegate {
    func recievedNotification(message: String, toUser: String, fromUser: String, forProperty: String)
}

class NotificationController {
    
    public static func sendNotificationToUser(message: String, toUser: String, fromUser: String, forProperty: String) {
        var notification: [String: String] = [:]
        notification["toUser"] = toUser
        notification["fromUser"] = fromUser
        notification["forProperty"] = forProperty
        notification["message"] = message
        
        let timestamp = Date().timeIntervalSince1970
        
        let uniqueId = UUID().uuidString
        
        let seperator = "%~20~%"
        
        let id = "\(Int(timestamp))" + seperator + uniqueId
        
        FirebaseController.notificationsRef.child(id).setValue(notification)
    }
}
