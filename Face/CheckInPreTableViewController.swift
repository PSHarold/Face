//
//  CheckInPreViewController.swift
//  Face
//
//  Created by Harold on 16/4/10.
//  Copyright © 2016年 Harold. All rights reserved.
//

import UIKit

class CheckInPreViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var checkInButton: UIView!
    var timer: NSTimer!
    var remainingSeconds = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkInButton.layer.masksToBounds = true
        self.checkInButton.layer.cornerRadius = 10.0
        self.checkInButton.layer.borderWidth = 0.3
        self.checkInButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CheckInPreViewController.checkIfCanCheckIn)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let courseHelper = StudentCourseHelper.defaultHelper
        if courseHelper.autoTakePhoto{
            courseHelper.autoTakePhoto = false
            self.takePhoto()
        }
    }
    
    func checkIfCanCheckIn(){
        self.showHudWithText("正在加载")
        let auth = StudentAuthenticationHelper.defaultHelper
        auth.getResponse(RequestType.CHECK_IF_CAN_CHECK_IN, method: .GET, argsOrBody: [:], courseIdRequired: true){
            [unowned self]
            error, json in
            if let error = error{
                switch error{
                case .CHECKING_IN_NOT_AVAILABLE:
                    self.remainingSeconds = json["remaining_secs"].intValue
                    if self.timer == nil{
                        self.timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(CheckInPreViewController.tick), userInfo: nil, repeats: true)
                        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
                    }
                case .COURSE_ALREADY_OVER:
                    self.promptLabel.text = "课程已结束，无法签到"
                case .COURSE_ALREADY_BEGUN:
                    fallthrough
                case .YOU_ARE_TOO_LATE:
                    self.promptLabel.text = "课程已开始，无法签到"
                case .ALREADY_CHECKED_IN:
                    self.promptLabel.text = "已签到"
                case .COURSE_IS_NOT_ON_TODAY:
                    self.promptLabel.text = "今天没有这门课"
                default:
                    break
                }
                self.showError(error)

            }
            else{
                self.promptLabel.text = "已开放"
                self.hideHud()
                self.performSegueWithIdentifier("TakeQRCode", sender: self)
            }
            
        }
    }
    
    
    
    func takePhoto() {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        imagePicker.cameraDevice = .Front
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var img = info[UIImagePickerControllerOriginalImage] as! UIImage
        img = img.fixOrientation()
        self.showHudWithText("正在上传")
        let courseHelper = StudentCourseHelper.defaultHelper
        courseHelper.checkIn(StudentCourse.currentCourse, img: img){
            [unowned self]
            error, json in
            if let error = error{
                switch error{
                case .CHECKING_IN_NOT_AVAILABLE:
                    if self.timer == nil{
                        self.remainingSeconds = json["remaining_secs"].intValue
                        self.timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(CheckInPreViewController.tick), userInfo: nil, repeats: true)
                        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
                    }
                case .COURSE_ALREADY_OVER:
                    self.promptLabel.text = "课程已结束，无法签到"
                case .COURSE_ALREADY_BEGUN:
                    fallthrough
                case .YOU_ARE_TOO_LATE:
                    self.promptLabel.text = "课程已开始，无法签到"
                case .ALREADY_CHECKED_IN:
                    self.promptLabel.text = "已签到"
                default:
                    break
                }
                if error == CError.FACE_DOES_NOT_MATCH{
                    self.hideHud()
                    let alert = UIAlertController(title: nil, message: "脸部信息不匹配！请尝试在照片管理中添加更多照片来提升识别准确率。", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    self.showError(error)
                }
                
            }
            else{
                self.hideHud()
                let alert = UIAlertController(title: nil, message: "签到成功！", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.promptLabel.text = "已签到"
            }

        }
    }

    
    
    
    func tick(){
        self.remainingSeconds -= 1
        if self.remainingSeconds <= 0{
            self.timer.invalidate()
            self.promptLabel.text = "已开放"
        }
        else{
            self.promptLabel.text = self.remainingSeconds.toTimeString()
        }
    }
    
}
