//
//  StudentCourseTableViewController.swift
//  AdvancedClassStudent
//
//  Created by Harold on 15/9/7.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import UIKit

class StudentCourseTableViewController: UITableViewController {
    
    let courseHelper = StudentCourseHelper.defaultHelper
    let authHelper = StudentAuthenticationHelper.defaultHelper
    var first = true
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController!.interactivePopGestureRecognizer?.enabled = false  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !self.first{
            return
        }
        if StudentAuthenticationHelper.me.newStatusAsks.count != 0{
            self.performSegueWithIdentifier("ShowNewStatusAsks", sender: self)
            self.first = false
        }
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.authHelper.me.courses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let course = self.authHelper.me.courses[indexPath.row]
        cell.textLabel?.text = course.name
        let count = course.asks.count
        cell.detailTextLabel?.text = count == 0 ? "" : "\(count)"
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        StudentCourse.currentCourse = self.authHelper.me.courses[indexPath.row]
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("enterMain", sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowNotifications"{
            
        }
    }
}
