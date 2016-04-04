
//
//  StudentCourse.swift
//  AdvancedClassStudent
//
//  Created by Harold on 15/9/6.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import Foundation
import SwiftyJSON

class Notification {
    var title:String!
    var content:String!
    var onTop: Bool!
    var createdOn:String!
    var createdOnTimeData:NSDate!
    var notificationId:String!
    var courseName = ""
    init(json:JSON){
        self.title = json["title"].stringValue
        self.content = json["content"].stringValue
        self.onTop = json["on_top"].boolValue
        self.notificationId = json["ntfc_id"].stringValue
        self.createdOn = json["created_on"].stringValue
        
    }
   
}

class StudentCourse {
    static var currentCourse: StudentCourse!
    
    var studentIdList = [String]()
    var name:String
    var courseId:String
    var subId:String
    var teachers = [Teacher]()
    var timesAndRooms:TimesAndRooms
    var unreadNotifications = [Notification]()
    var notifications = [Notification]()
    var notificationsAcquired = false
    init(json:JSON, preview:Bool = true){
        self.name = json["course_name"].stringValue
        self.courseId = json["course_id"].stringValue
        self.subId = json["sub_id"].stringValue
        self.timesAndRooms = TimesAndRooms(json: json["times"])
        for (_, n) in json["unread_ntfcs"]{
            let notification = Notification(json: n)
            notification.courseName = self.name
            self.unreadNotifications.append(notification)
        }
    } 
}