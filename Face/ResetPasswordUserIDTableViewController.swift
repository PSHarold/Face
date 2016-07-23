//
//  ResetPasswordUserIDTableViewController.swift
//  Face
//
//  Created by Harold on 16/4/22.
//  Copyright © 2016年 Harold. All rights reserved.
//

import UIKit

class ResetPasswordUserIDTableViewController: UITableViewController {
    
    @IBOutlet weak var userIdTextField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1{
            self.showHudWithText("正在提交")
            StudentAuthenticationHelper.defaultHelper.requestToResetPassword(self.userIdTextField.text!){
                [unowned self]
                error in
                if let error = error{
                    self.showError(error)
                }
                else{
                    self.hideHud()
                    self.performSegueWithIdentifier("ConfirmEmail", sender: self)
                }
                
            }
        }
    }



}
