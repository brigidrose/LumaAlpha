//
//  NewMomentViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 1/28/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class NewMomentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableViewController:UITableViewController!
    var toolBarBottom:UIToolbar!
    var storyUnits = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewController = UITableViewController()
        self.addChildViewController(self.tableViewController)
        self.tableViewController.tableView = TPKeyboardAvoidingTableView(frame: self.view.frame)
        self.tableViewController.tableView.delegate = self
        self.tableViewController.tableView.dataSource = self
        self.view.addSubview(self.tableViewController.tableView)
        
        self.toolBarBottom = UIToolbar(frame: CGRectZero)
        self.toolBarBottom.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.toolBarBottom)
        
        let toolBarBottomPinConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let toolBarBottomHeightConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
        let toolBarBottomWidthConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        
        self.view.addConstraint(toolBarBottomPinConstraint)
        self.view.addConstraint(toolBarBottomHeightConstraint)
        self.view.addConstraint(toolBarBottomWidthConstraint)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + storyUnits.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
