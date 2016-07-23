

class StudentCourseHelper{
    static var _defaultHelper: StudentCourseHelper?
    static var defaultHelper: StudentCourseHelper!{
        get{
            if StudentCourseHelper._defaultHelper == nil{
                StudentCourseHelper._defaultHelper = StudentCourseHelper()
            }
            return StudentCourseHelper._defaultHelper
        }
    }
    
    var checkInToken = ""
    var autoTakePhoto = false
    static func drop(){
        _defaultHelper = nil
    }
    func getAsksForLeave(course: StudentCourse, completionHandler: ResponseMessageHandler) {
        let auth = StudentAuthenticationHelper.defaultHelper
        auth.getResponse(RequestType.GET_ASKS_FOR_LEAVE, method: .GET, argsOrBody: [:], courseIdRequired: true){
            error, json in
            course.asks = []
            if error == nil{
                for ask_dict in json["pending_asks"].arrayValue{
                    let ask = AskForLeave(json: ask_dict)
                    course.asks.append(ask)
                }
                for ask_dict in json["approved_asks"].arrayValue{
                    let ask = AskForLeave(json: ask_dict)
                    course.asks.append(ask)
                }
                for ask_dict in json["disapproved_asks"].arrayValue{
                    let ask = AskForLeave(json: ask_dict)
                    course.asks.append(ask)
                }
            }
            completionHandler(error: error)
            
        }
    }
    
    func askForLeave(ask: AskForLeave, course: StudentCourse, completionHandler: ResponseMessageHandler){
        let auth = StudentAuthenticationHelper.defaultHelper
        var dict = ask.toDict()
        dict["course_id"] = course.courseId
        auth.getResponse(RequestType.ASK_FOR_LEAVE, method: .POST, argsOrBody: dict, courseIdRequired: true){
            error, json in
            if error == nil{
                ask.askId = json["ask_id"].stringValue
                ask.status = AskForLeaveStatus.PENDING
                ask.createdAt = json["created_at"].stringValue
                ask.viewdAt = ""
                course.asks.insert(ask, atIndex: 0)
            }
            completionHandler(error: error)
        }
    }
    func deleteAskForLeave(ask: AskForLeave, course: StudentCourse, completionHandler: ResponseMessageHandler){
        let auth = StudentAuthenticationHelper.defaultHelper
        auth.getResponse(RequestType.DELETE_ASK_FOR_LEAVE, method: .GET, argsOrBody: ["ask_id": ask.askId], courseIdRequired: true){
            error, json in
            if error == nil{
                course.asks.removeAtIndex(course.asks.indexOf({$0 === ask})!)
            }
            completionHandler(error: error)
        }
    }

    func getAbsenceList(course: StudentCourse, completionHandler: ResponseMessageHandler){
        let auth = StudentAuthenticationHelper.defaultHelper
        auth.getResponse(RequestType.GET_MY_ABSENCE_LIST, method: .GET, argsOrBody: ["course_id": course.courseId]){
            error, json in
            course.absenceList = []
            if error == nil{
                for absence in json["absence"].arrayValue{
                    course.absenceList.append(absence.rawValue as! [String: Int])
                }
            }
            completionHandler(error: error)
        }
    }
    
    func getCheckInToken(qrCode: String, completionHandler: ResponseMessageHandler){
        let auth = StudentAuthenticationHelper.defaultHelper
        auth.getResponse(RequestType.VERIFY_QR_CODE, method: .GET, argsOrBody: ["code": qrCode]){
            [unowned self]
            error, json in
            if error == nil{
                self.checkInToken = json["check_in_token"].stringValue
            }
            else{
                self.checkInToken = ""
            }
            completionHandler(error: error)
        }
    }

    func checkIn(course: StudentCourse, img: UIImage, completionHandler: ResponseHandler){
        let auth = StudentAuthenticationHelper.defaultHelper
        auth.postImage(RequestType.CHECK_IN, image: img, courseIdRequired: true, checkInToken: self.checkInToken){
            [unowned self]
            error, json in
            if error == nil{
                self.checkInToken = ""
            }
            completionHandler(error: error, json: json)
        }
    }
   
    
       
}