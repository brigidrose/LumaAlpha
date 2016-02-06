//
//  LockMomentViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 2/4/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class LockMomentViewController: UIViewController {

    var tableViewController:UITableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Lock Moment"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donelButtonTapped")

        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableViewController = UITableViewController()
        self.addChildViewController(self.tableViewController)
        
        self.tableViewController.tableView = UITableView(frame: CGRectZero)
        self.tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableViewController.tableView)
        
        let viewsDictionary = ["tableView":self.tableViewController.tableView]
        let tbvHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let tbvVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)

        self.view.addConstraints(tbvHConstraints)
        self.view.addConstraints(tbvVConstraints)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func donelButtonTapped(){
    
    }


}
