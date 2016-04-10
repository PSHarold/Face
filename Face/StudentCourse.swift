
//
//  StudentCourse.swift
//  AdvancedClassStudent
//
//  Created by Harold on 15/9/6.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import Foundation
import SwiftyJSON

enum AskForLeaveStatus: Int {
    case PENDING = 0
    case APPROVED = 1
    case DISAPPROVED = 2
}

class AskForLeave{
    
    var courseId: String!
    var askId: String!
    var reason: String!
    var statusInt: Int!
    var status: AskForLeaveStatus!
    var weekNo: Int!
    var dayNo: Int!
    var periodNo: Int!
    var createdAt: String!
    var viewdAt: String!
    init(json: JSON){
        self.courseId = json["course_id"].stringValue
        self.askId = json["ask_id"].stringValue
        self.reason = json["reason"].stringValue
        self.statusInt = json["status"].intValue
        self.status = AskForLeaveStatus(rawValue: self.statusInt)
        self.dayNo = json["day_no"].intValue
        self.periodNo = json["period_no"].intValue
        self.weekNo = json["week_no"].intValue
        self.createdAt = json["created_at"].stringValue
        self.viewdAt = json["viewed_at"].stringValue
    }
    init(){
        
    }
    
    func toDict() -> [String: AnyObject]{
        return ["reason": self.reason, "week_no": self.weekNo, "day_no": self.dayNo, "period_no": self.periodNo]
    }
}



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
    var courseId: String
    var studentIdList = [String]()
    var name:String
    var absenceList: [[String: Int]]!
    var timesAndRooms:TimesAndRooms
    var asks = [AskForLeave]()
    var unreadNotifications = [Notification]()
    var notifications = [Notification]()
    var notificationsAcquired = false
    init(json:JSON, preview:Bool = true){
        self.name = json["course_name"].stringValue
        self.courseId = json["course_id"].stringValue
      
        self.timesAndRooms = TimesAndRooms(json: json["times"])
        for (_, n) in json["unread_ntfcs"]{
            let notification = Notification(json: n)
            notification.courseName = self.name
            self.unreadNotifications.append(notification)
        }
        
        
    } 
}