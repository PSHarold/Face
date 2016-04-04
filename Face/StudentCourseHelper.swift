

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
    
//    func getNotifications(course: StudentCourse, page: Int, completionHandler: (error: CError?) -> Void){
//        assert(page >= 1)
//       
//            StudentAuthenticationHelper.defaultHelper.getResponse(RequestType.GET_NOTIFICAIONS, method: . postBody: ["course_id":course.courseId,"sub_id":course.subId, "page": page]){
//                (error, json) in
//                if error == nil{
//                    course.notifications = [Notification]()
//                    for (_, n) in json["notifications"]{
//                        let notification = Notification(json: n)
//                        notification.courseName = course.name
//                        course.notifications.append(notification)
//                    }
//                }
//                completionHandler(error: error)
//            }
//        
//    }
    
    
    
    
}