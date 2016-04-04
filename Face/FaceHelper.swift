//
//  FaceHelper.swift
//  Face
//
//  Created by Harold on 16/4/4.
//  Copyright © 2016年 Harold. All rights reserved.
//

import Foundation
class FaceHelper{
    static var _defaultHelper: FaceHelper?
    static var defaultHelper: FaceHelper{
        if _defaultHelper == nil{
            _defaultHelper = FaceHelper()
        }
        return _defaultHelper!
    }
    var faceIds = [String]()
    var faceImages = [String: FaceImage]()
    var faceAcquiredCount = 0
    
    weak var authHelper = StudentAuthenticationHelper.defaultHelper
    
    func getFaceIds(completionHandler: ResponseMessageHandler){
        self.faceIds = []
        self.faceAcquiredCount = 0
        self.authHelper!.getResponse(RequestType.GET_FACES, method: .GET, argsOrBody: [:]){
            (error, json) in
            if error == nil{
                for (_, id) in json["faces"]{
                    self.faceIds.append(id.stringValue)
                }
            }
            completionHandler(error: error)
        }
    }
    
    
    
    
    func getFaceImages(completionHandler: ResponseMessageHandler){
        self.getFaceIds{
            error in
            if error == nil{
                if self.faceIds.count == 0{
                    completionHandler(error: nil)
                }
                for faceId in self.faceIds{
                    self.getFaceImage(faceId){
                        [unowned self]
                        error in
                        if error == nil{
                            self.faceAcquiredCount += 1
                            if self.faceAcquiredCount == self.faceIds.count{
                                self.faceAcquiredCount == 0
                                completionHandler(error: nil)
                            }
                        }
                        else{
                            completionHandler(error: error)
                        }
                    }
                }

            }
            else{
                completionHandler(error: error)
            }
        }
    }
    
    func getFaceImage(faceId: String, completionHandler: ResponseMessageHandler){
        self.authHelper!.getResponseImage(RequestType.GET_FACE_IMAGE, method: .GET, argsOrBody: ["face_id": faceId]){
            [unowned self]
            error, img in
            if error == nil{
                self.faceImages[faceId] = FaceImage(faceId: faceId, image: img)
            }
            completionHandler(error: error)
        }
    }
    
    
    
    func addFace(faceImage: UIImage, completionHandler: ResponseMessageHandler){
        self.authHelper!.postImage(RequestType.ADD_FACE, image: faceImage){
            [unowned self]
            error, json in
            if error == nil{
                let faceId = json["face_id"].stringValue
                self.faceIds.append(faceId)
                self.faceImages[faceId] = FaceImage(faceId: faceId, image: faceImage)
            }
            completionHandler(error: error)
        }
    }
    
    func deleteFace(faceId: String, completionHandler: ResponseMessageHandler){
        self.authHelper!.getResponse(RequestType.DELETE_FACE, method: .GET, argsOrBody: ["face_id": faceId]){
            [unowned self]
            error, json in
            if error == nil{
                if let index = self.faceIds.indexOf(faceId){
                    self.faceIds.removeAtIndex(index)
                }
                self.faceImages.removeValueForKey(faceId)                
            }
            completionHandler(error: error)
        }
    }
    
    func testFace(faceImage: UIImage, completionHandler: (CError?, Bool!) -> Void) {
        self.authHelper!.postImage(RequestType.TEST_FACE, image: faceImage){
            error, json in
            if error == nil{
                let result = json["is_same_person"].boolValue
                completionHandler(nil, result)
                return
            }
            completionHandler(error, nil)
        }
    }
    
    
}