//
//  MyInformation.swift
//  AdvancedClassStudent
//
//  Created by Harold on 15/9/6.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import Foundation
import SwiftyJSON
class Student {
    var studentId:String
    var gender: Bool
    var name:String
    var email: String!
    var emailActivated: Bool!
    var className:String
    var tel:String
    var majorName:String
    var courses = [StudentCourse]()
    var courseDict = [String:StudentCourse]()
    var unreadNotifications = [Notification]()
    var newStatusAsks = [AskForLeave]()
    var genderString:String{
        get{
            if self.gender{
                return "男"
            }
            return "女"
        }
    }
    init(json:JSON){
        self.studentId = json["student_id"].stringValue
        if self.studentId == ""{
            self.studentId = json["user_id"].stringValue
        }
        self.gender = json["gender"].boolValue
        self.name = json["name"].stringValue
        self.className = json["class_name"].stringValue
        self.tel = json["tel"].stringValue
        self.majorName = json["major_name"].stringValue
        let courses = json["courses"].arrayValue
        for course_json in courses{
            let course = StudentCourse(json: course_json, preview: true)
            self.courses.append(course)
            self.courseDict[course.courseId] = course
        }
        
        for askDict in json["new_status_asks"].arrayValue{
            self.newStatusAsks.append(AskForLeave(json: askDict))
        }
        
       self.courses.sortInPlace({$0.asks.count > $1.asks.count})
    }
}