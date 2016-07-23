//
//  LoginHelper.swift
//  AdvancedClassTeacher
//
//  Created by Harold on 15/9/2.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class StudentAuthenticationHelper{
    
    
    
    static var _defaultHelper:StudentAuthenticationHelper?
    
   
    
    var tokenRetryCount = 0
    let MAX_TOKEN_RETRY_COUNT = 3
    var me: Student!
    var emailToVerify: String?
    var userIdToReset: String?
    var userId = ""
    var password = ""
    var token = ""
    var tempRequestType: RequestType!
    var tempMethod: Alamofire.Method!
    var tempArgsOrBody: [String: AnyObject]!
    var tempHeaders: [String:String]!
    var originalHandler: ResponseHandler!
    var originalImageHandler: ResponseImageHandler!
    var currentWeekNo: Int!
    var currentDayNo: Int!
    static var defaultHelper:StudentAuthenticationHelper{
        get{
            if _defaultHelper == nil{
                _defaultHelper = StudentAuthenticationHelper()
            }
            return _defaultHelper!
        }
    }
    
    static func drop(){
        _defaultHelper = nil
    }
    
  
    
    
    
    func getResponse(requestType: RequestType, method: Alamofire.Method, argsOrBody:[String: AnyObject], tokenNotRequired: Bool = false, courseIdRequired: Bool = false, completionHandler: ResponseHandler){
        let encoding: ParameterEncoding = method == .POST ? .JSON : .URL
        let request = getRequestFor(requestType, method: method, argsOrBody: argsOrBody, headers: nil, encoding: encoding, token: (tokenNotRequired ? nil : self.token), courseId: (courseIdRequired ? StudentCourse.currentCourse.courseId : nil))
        request.responseJSON(){
            [unowned self]
            (_,_,result) in
            switch result{
            case .Success(let data):
                let json = JSON(data)
                let code = json["error_code"].intValue
                if code == CError.TOKEN_EXPIRED.rawValue{
                    self.tempArgsOrBody=argsOrBody
                    self.tempRequestType=requestType
                    self.originalHandler=completionHandler
                    self.originalImageHandler=nil
                    self.getTokenBackground()
                    return
                }
                else if code > 0{
                    completionHandler(error: CError(rawValue: code), json: json)
                }
                else{
                    completionHandler(error: nil, json: json)
                }
                
            case .Failure:
                completionHandler(error: CError.NETWORK_ERROR, json: nil)
            }
        }
        
    }
    
    
    func getResponseImage(requestType: RequestType, method: Alamofire.Method, argsOrBody:[String: AnyObject], courseIdRequired: Bool = false, completionHandler: ResponseImageHandler){
        var argsOrBody = argsOrBody
        argsOrBody["token"] = self.token
        if courseIdRequired{
            let course = StudentCourse.currentCourse
            argsOrBody["course_id"] = course.courseId
           
        }
        let encoding: ParameterEncoding = method == .POST ? .JSON : .URL
        let request = getRequestFor(requestType, method: method, argsOrBody: argsOrBody, headers: nil, encoding: encoding)
        request.responseData(){
            [unowned self]
            (_,_,result) in
            switch result{
            case .Success(let data):
                let json = JSON(data)
                let code = json["error_code"].intValue
                if code == CError.TOKEN_EXPIRED.rawValue{
                    self.tempArgsOrBody=argsOrBody
                    self.tempRequestType=requestType
                    self.originalHandler = nil
                    self.originalImageHandler=completionHandler
                    self.getTokenBackground()
                    return
                }
                else if code > 0{
                    completionHandler(error: CError(rawValue: code), image: nil)
                }
                else{
                    completionHandler(error: nil, image: UIImage(data: data))
                }
                
            case .Failure:
                completionHandler(error: CError.NETWORK_ERROR, image: nil)
            }
        }

    }
    

    func postImage(requestType: RequestType, image: UIImage, courseIdRequired: Bool = false, checkInToken: String = "", completionHandler: ResponseHandler){
        Alamofire.upload(.POST, BASE_URL+requestType.rawValue+"?token=\(self.token)"+(courseIdRequired ? "&course_id=\(StudentCourse.currentCourse.courseId)" : "")+(checkInToken == "" ? "" : "&check_in_token=\(checkInToken)"),
            headers: nil,
            multipartFormData: {
                multipartFormData in
                
                // import image to request

                if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                    multipartFormData.appendBodyPart(data: imageData, name: "file", fileName: "myImage.png", mimeType: "image/png")
                }
                
            },
            encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { _, _, result in
                        switch result{
                        case .Success(let data):
                            let json = JSON(data)
                            let code = json["error_code"].intValue
                            if code == CError.TOKEN_EXPIRED.rawValue{
                                self.getTokenBackground()
                                return
                            }
                            else if code > 0{
                                completionHandler(error: CError(rawValue: code), json: nil)
                            }
                            else{
                                completionHandler(error: nil, json: json)
                            }
                            
                        case .Failure:
                            completionHandler(error: CError.NETWORK_ERROR, json: nil)
                        }

                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
        
        


    func getTokenBackground(){
        let request = getRequestFor(.GET_TOKEN_ONLY, method: .POST, argsOrBody: ["user_id": self.userId, "password": self.password, "role": ROLE_FOR_STUDENT], headers: nil)
        request.responseJSON(){
            [unowned self]
            _,_,result in
            switch result{
            case .Success(let data):
                let json = JSON(data)
                let code = json["error_code"].intValue
                if code > 0{
                    if self.tokenRetryCount == self.MAX_TOKEN_RETRY_COUNT{
                        self.tokenRetryCount = 0
                        self.originalHandler(error: CError(rawValue: code), json: nil)
                    }
                    else{
                        self.getTokenBackground()
                    }
                }
                else{
                    self.token = json["token"].stringValue
                    if self.originalHandler == nil{
                        self.getResponseImage(self.tempRequestType, method: self.tempMethod, argsOrBody: self.tempArgsOrBody, completionHandler: self.originalImageHandler)
                    }
                    else{
                        self.getResponse(self.tempRequestType, method: self.tempMethod, argsOrBody: self.tempArgsOrBody, completionHandler: self.originalHandler)
                    }
                    
                }
            case .Failure(_, _):
                self.originalHandler(error: CError.NETWORK_ERROR, json: nil)
            }
        }
        
    }

    

    func login(userId:String, password: String, completionHandler: (error: CError?, json: JSON?) -> Void){
        self.userId = userId
        self.password = password
        getResponse(RequestType.LOGIN, method: .POST, argsOrBody: ["user_id":userId, "password": password, "role": 2], tokenNotRequired: true){
            [unowned self]
            (error,json) in            
            if error != nil{
                completionHandler(error: error, json: json)
            }
            else{
                self.token = json["token"].stringValue
                self.me = Student(json: json["user"])
                self.currentWeekNo = json["week_no"].intValue
                self.currentDayNo = json["day_no"].intValue
                completionHandler(error: nil, json: json)
            }
            
        }
    }
    
    
    func readNewStatusAsks(completionHandler: ResponseMessageHandler){
        self.getResponse(RequestType.READ_NEW_STATUS_ASKS, method: .GET, argsOrBody: [:]){
            error, json in
            if error == nil{
                self.me.newStatusAsks = []
            }
            completionHandler(error: error)
        }
    }
    
    func modifyPassword(oldPassword: String, newPassword: String, completionHandler: ResponseMessageHandler){
        self.getResponse(RequestType.MODIFY_PASSWORD, method: .GET, argsOrBody: ["old_pwd": oldPassword, "new_pwd": newPassword]){
            error, json in
            completionHandler(error: error)
        }
    }

    func getEmail(completionHandler: ResponseMessageHandler) {
        self.getResponse(RequestType.GET_EMAIL, method: .GET, argsOrBody: [:]){
            [unowned self]
            error, json in
            if error == nil{
                self.me.email = json["email"].stringValue
                self.me.emailActivated = json["activated"].boolValue
            }
            completionHandler(error: error)
        }
    }
    
    func modifyEmail(newEmail: String, completionHandler: ResponseMessageHandler){
        self.getResponse(RequestType.MODIFY_EMAIL, method: .GET, argsOrBody: ["email": newEmail]){
            error, json in
            completionHandler(error: error)
        }
        
    }
    
    func requestToResetPassword(userId: String, completionHandler: ResponseMessageHandler){
        self.userIdToReset = userId
        self.getResponse(RequestType.RESET_PASSWORD_GET_EMAIL, method: .GET, argsOrBody: ["user_id": userId, "role": ROLE_FOR_STUDENT], tokenNotRequired: false){
            [unowned self]
            error, json in
            if error == nil{
                self.emailToVerify = json["email"].stringValue
            }
            completionHandler(error: error)
        }
    }
    
    func resetPasswordConfirmEmail(email: String, completionHandler: ResponseMessageHandler){
        self.getResponse(RequestType.RESET_PASSWORD_CONFIRM_EMAIL, method: .GET, argsOrBody: ["user_id": self.userIdToReset!, "role": ROLE_FOR_STUDENT, "email": email], tokenNotRequired: false){
            error, json in
            completionHandler(error: error)
        }
    }
    
    private init(){
        
    }
    

    
    
    
    
}