//
//  ErrorHandler.swift
//  AdvancedClassStudent
//
//  Created by Harold on 16/2/20.
//  Copyright © 2016年 Harold. All rights reserved.
//

import Foundation
import SwiftyJSON

enum CError: Int {
    case NETWORK_ERROR
    case NEED_TO_LOGIN_AGAIN
    case UNKNOWN_INTERNAL_ERROR = 500
    case FACE_API_ERROR = 600
    case FORBIDDEN = 601
    case WRONG_PASSWORD = 602
    case ALREADY_LOGGED_IN = 603
    case BAD_TOKEN = 604
    case TOKEN_EXPIRED = 605
    case ONLY_ACCEPT_JSON = 606
    case FIELD_MISSING = 607
    case WRONG_FIELD_TYPE = 609
    case UNKNOWN_FIELD = 608
    case ARGUMENT_MISSING = 610
    case BAD_IMAGE = 620
    
    case FACE_TRAINING_NOT_DONE = 621
    case IMAGE_CONTAINS_NO_FACE = 622
    case EMAIL_NOT_ACTIVATED = 650
    case WRONG_EMAIL_ADDRESS = 651
    case RESOURCE_NOT_FOUND = 700
    case USER_NOT_FOUND = 701
    case SUB_COURSE_NOT_FOUND = 703
    case ASK_FOR_LEAVE_NOT_FOUND = 720
    
    
    case CHECKING_IN_NOT_AVAILABLE = 901
    case COURSE_ALREADY_BEGUN = 907
    case COURSE_IS_NOT_ON_TODAY = 908
    
    case COURSE_ALREADY_OVER = 909
    case COURSE_NOT_BEGUN = 910
    case YOU_ARE_TOO_LATE = 911
    case YOU_DO_NOT_HAVE_THIS_COURSE = 921
    case BAD_QR_CODE = 922
    case QR_CODE_EXPIRED = 923
    case ASK_FOR_LEAVE_HAS_BEEN_APPROVED = 950
    case ASK_FOR_LEAVE_HAS_BEEN_DISAPPROVED = 951
    case ASK_FOR_LEAVE_STILL_PENDING = 952
    case ALREADY_CHECKED_IN = 953
    case FACE_DOES_NOT_MATCH = 954
    
    
    
    var description: String{
        switch self{
        case .NETWORK_ERROR:
            return "网络错误！"

        case .UNKNOWN_INTERNAL_ERROR:
            return "服务器错误"
        case .FACE_API_ERROR:
            return "人脸识别服务器错误"
        case .FORBIDDEN:
            return "无权限！"
        case .WRONG_PASSWORD:
            return "密码错误！"
        case .ALREADY_LOGGED_IN:
            return "请不要重复登录！"
            
        case .RESOURCE_NOT_FOUND:
            return ""
        case .USER_NOT_FOUND:
            return "用户不存在！"
        case .SUB_COURSE_NOT_FOUND:
            return "找不到此讲台！"
        case .EMAIL_NOT_ACTIVATED:
            return "请先验证邮箱！"
        case .WRONG_EMAIL_ADDRESS:
            return "错误的邮箱地址！"
           
        case .CHECKING_IN_NOT_AVAILABLE:
            return "签到还没有开放！"
        case .COURSE_ALREADY_BEGUN:
            return "已经上课了！"
        case .COURSE_IS_NOT_ON_TODAY:
            return "今天没有这门课！"
        case .COURSE_ALREADY_OVER:
            return "今天这节课已经结束了！"
        case .COURSE_NOT_BEGUN:
            return "这节课还没有开始！"
        case .YOU_ARE_TOO_LATE:
            return "你迟到太久！"
        case .YOU_DO_NOT_HAVE_THIS_COURSE:
            return "你没有权限查看这个课程！"
        case .IMAGE_CONTAINS_NO_FACE:
            return "图片中找不到人脸！"
        case .ASK_FOR_LEAVE_STILL_PENDING:
            return "已提交过此时间段的请假！"
        case .ASK_FOR_LEAVE_HAS_BEEN_APPROVED:
            return "请假已经被批准了！"
        case .ALREADY_CHECKED_IN:
            return "已经签过到了！"
        case .BAD_QR_CODE:
            return "错误的二维码！"
        case .QR_CODE_EXPIRED:
            return "二维码过期！请重新扫描！"
        case .FACE_DOES_NOT_MATCH:
            return "脸部信息不匹配！"
        default:
            return "未知错误"
        }
        
    }
}


func parseJSON(json:JSON) -> CError?{
    return CError(rawValue: json["error_code"].intValue)
}



