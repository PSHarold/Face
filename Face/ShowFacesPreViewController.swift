//
//  ShowFacesPreViewController.swift
//  Face
//
//  Created by Harold on 16/4/4.
//  Copyright © 2016年 Harold. All rights reserved.
//

import UIKit

class ShowFacesPreViewController: UIViewController {
    weak var faceHelper = FaceHelper.defaultHelper
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
 
    
 
    @IBAction func getFaces(sender: AnyObject) {
        self.showHudWithText("正在加载")
        self.faceHelper!.getFaceImages{
            [unowned self]
            error in
            if let error = error{
                self.showError(error)
            }
            else{
                self.hideHud()
                self.performSegueWithIdentifier("ShowFaces", sender: self)
            }
            
        }
    }

}
