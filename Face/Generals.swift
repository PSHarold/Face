//
//  Globals.swift
//  AdvancedClassStudent
//
//  Created by Harold on 16/2/20.
//  Copyright © 2016年 Harold. All rights reserved.
//


import Foundation
import SwiftyJSON
import Alamofire
import UIKit
var alamofireManager: Alamofire.Manager!
let BASE_URL = TARGET_IPHONE_SIMULATOR == 0 ? "http://192.168.155.2:5000" : "http://localhost:5000"
//let BASE_URL = "http://localhost:5000"
let ROLE_FOR_TEACHER = 1
let ROLE_FOR_STUDENT = 2



typealias ResponseHandler = (error: CError?, json: JSON!) -> Void
typealias ResponseMessageHandler = (error: CError?) -> Void
typealias ResponseImageHandler = (error: CError?, image: UIImage!) -> Void
enum RequestType: String{
    
    case REGISTER = "/user/register/student"
    case SCHOOLS_INFO = "/user/register/getSchools"
    case MAJORS_INFO = "/user/register/getMajors"
    case DEPARTMENTS_INFO = "/user/register/getDepartments"
    case LOGIN = "/user/login"
    case GET_TOKEN_ONLY = "/user/login/getToken"
    case GET_NOTIFICAIONS = "/course/notification/getNotifications"
    case GET_FACES = "/user/get_faces"
    case GET_FACE_IMAGE = "/user/get_face_img"
    case ADD_FACE = "/user/add_face"
    case TEST_FACE = "/user/test_face"
    case DELETE_FACE = "/user/delete_face"
    case GET_ASKS_FOR_LEAVE = "/course/my_asks_for_leave"
    case ASK_FOR_LEAVE = "/course/ask_for_leave"
    case READ_NEW_STATUS_ASKS = "/course/read_new_status_ask"
    case DELETE_ASK_FOR_LEAVE = "/course/delete_ask_for_leave"
    case GET_MY_ABSENCE_LIST = "/course/get_my_absence_list"
    case CHECK_IF_CAN_CHECK_IN = "/course/check_if_can_check_in"
    case CHECK_IN = "/course/check_in"
    case VERIFY_QR_CODE = "/course/verify_qr_code"
    case MODIFY_PASSWORD = "/user/modify_password"
    case GET_EMAIL = "/user/get_email"
    case MODIFY_EMAIL = "/user/modify_email"
    case RESET_PASSWORD_GET_EMAIL = "/user/reset_password_get_email"
    case RESET_PASSWORD_CONFIRM_EMAIL = "/user/reset_password"
    
}
func getRequestFor(requestType:RequestType, method:Alamofire.Method, argsOrBody:[String: AnyObject]?, headers:[String:String]?, token: String? = nil, courseId: String? = nil, encoding: ParameterEncoding = .JSON) -> Request{
    if token == nil{
        return alamofireManager.request(method, BASE_URL + requestType.rawValue, parameters: argsOrBody, encoding: encoding, headers: headers)
    }
    else{
        return alamofireManager.request(method, BASE_URL + requestType.rawValue + (token == nil ? "" : "?token="+token!) + (courseId == nil ? "" : "&course_id="+courseId!), parameters: argsOrBody, encoding: encoding, headers: headers)

    }
    
}


let hud = MBProgressHUD()
extension UIViewController{
    
    
    
    
    
    func showHudWithText(text:String, mode:MBProgressHUDMode = .Indeterminate, hideAfter:NSTimeInterval=1.0){
        hud.removeFromSuperViewOnHide = true
        hud.labelText = text
        hud.mode = mode
        
        if let _ = self as? UITableViewController{
            if !self.parentViewController!.view.subviews.contains(hud){
                self.parentViewController!.view.addSubview(hud)
            }
        }
        else{
            if !self.view.subviews.contains(hud){
                self.view.addSubview(hud)
            }
        }
        
        if mode == .Indeterminate{
            hud.show(true)
        }
        else{
            hud.show(true)
            hud.hide(true, afterDelay: hideAfter)
        }
    }
    
    func showError(error: CError, hideAfter: NSTimeInterval=1.5){
        self.showHudWithText(error.description, mode: .Text, hideAfter: hideAfter)
    }
    
    func hideHud(){
        hud.hide(true)
    }
    
}

extension Int{
    func toTimeString(showFull: Bool = false) -> String{
        if self < 0{
            return ""
        }
        let hours = self / 3600
        let minutes = (self - hours * 3600) / 60
        let seconds = self % 60
        if showFull{
            return "\(hours)小时\(minutes)分钟\(seconds)秒"
        }
        let hs = hours != 0 ? "\(hours)小时" : ""
        let ms = minutes != 0 ? "\(minutes)分钟" : ""
        return hs + ms + "\(seconds)秒"
    }
    
    func toTimeComponents() -> (Int, Int, Int){
        if self <= 0{
            return (0, 0, 0)
        }
        let hours = self / 3600
        let minutes = (self - hours * 3600) / 60
        let seconds = self % 60
        return (hours, minutes, seconds)
    }
}

extension String{
    func toNSDate() -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.dateFromString(self)
    }
    
}

extension NSDate{
    func toString() -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.stringFromDate(self)
    }
    
}

extension Double {
    func toPercentageString() -> String{
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        // you can set the minimum fraction digits to 0
        formatter.minimumFractionDigits = 0
        // and set the maximum fraction digits to 1
        formatter.maximumFractionDigits = 2
        return "\(formatter.stringFromNumber(self*100) ?? "0")%"
    }
}

extension Array {
    subscript (safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}

extension UIImage{
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImageOrientation.Up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        if ( self.imageOrientation == UIImageOrientation.Down || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Left || self.imageOrientation == UIImageOrientation.LeftMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Right || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if ( self.imageOrientation == UIImageOrientation.UpMirrored || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if ( self.imageOrientation == UIImageOrientation.LeftMirrored || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height),
                                                      CGImageGetBitsPerComponent(self.CGImage), 0,
                                                      CGImageGetColorSpace(self.CGImage),
                                                      CGImageGetBitmapInfo(self.CGImage).rawValue)!;
        
        CGContextConcatCTM(ctx, transform)
        
        if ( self.imageOrientation == UIImageOrientation.Left ||
            self.imageOrientation == UIImageOrientation.LeftMirrored ||
            self.imageOrientation == UIImageOrientation.Right ||
            self.imageOrientation == UIImageOrientation.RightMirrored ) {
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage)
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(CGImage: CGBitmapContextCreateImage(ctx)!)
    }
}

