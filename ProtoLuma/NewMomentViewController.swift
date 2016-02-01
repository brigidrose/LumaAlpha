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
    
    var ghostTextField:UITextField!
    
    var charmGroupSelectView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Moment"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "closeButtonTapped")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Done, target: self, action: "sendButtonTapped:")
        self.tableViewController = UITableViewController()
        self.addChildViewController(self.tableViewController)
        self.tableViewController.tableView = TPKeyboardAvoidingTableView(frame: CGRectZero)
        self.tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewController.tableView.delegate = self
        self.tableViewController.tableView.dataSource = self
        self.tableViewController.tableView.registerClass(CharmGroupSelectionTableViewCell.self, forCellReuseIdentifier: "CharmGroupSelectionTableViewCell")
        self.tableViewController.tableView.contentInset.top = 53
        self.tableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(self.tableViewController.tableView)
        
        let topConstraint = NSLayoutConstraint(item: self.tableViewController.tableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.topLayoutGuide, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.tableViewController.tableView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self.tableViewController.tableView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        
        self.view.addConstraint(topConstraint)
        self.view.addConstraint(bottomConstraint)
        self.view.addConstraint(widthConstraint)
        
        self.toolBarBottom = UIToolbar(frame: CGRectZero)
        self.toolBarBottom.translatesAutoresizingMaskIntoConstraints = false
        let mediaToolBarItem = UIBarButtonItem(image: UIImage(named: "NewStoryBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "mediaButtonTapped")
        let lockToolBarItem = UIBarButtonItem(image: UIImage(named: "NewStoryBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "lockButtonTapped")
        self.toolBarBottom.items = [mediaToolBarItem, lockToolBarItem]
        self.view.addSubview(self.toolBarBottom)
        
        let toolBarBottomPinConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let toolBarBottomHeightConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44)
        let toolBarBottomWidthConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        
        self.view.addConstraint(toolBarBottomPinConstraint)
        self.view.addConstraint(toolBarBottomHeightConstraint)
        self.view.addConstraint(toolBarBottomWidthConstraint)
        
        self.ghostTextField = UITextField()
        self.ghostTextField.hidden = true
        self.view.addSubview(self.ghostTextField)
        
        self.toolBarBottom.removeFromSuperview()
        self.ghostTextField.becomeFirstResponder()
        
        self.charmGroupSelectView = UIView(frame: CGRectZero)
        self.charmGroupSelectView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.charmGroupSelectView)
        
        let charmSelectViewsDictionary = ["charmGroupSelectView":self.charmGroupSelectView]
        
        let hConstraintsHeader = NSLayoutConstraint.constraintsWithVisualFormat("H:|[charmGroupSelectView]|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: charmSelectViewsDictionary)
        self.view.addConstraints(hConstraintsHeader)

        let vConstraintHeader = NSLayoutConstraint(item: self.charmGroupSelectView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(vConstraintHeader)
        
        let charmGroupSelectButton = UIButton(frame: CGRectZero)
        charmGroupSelectButton.translatesAutoresizingMaskIntoConstraints = false
        charmGroupSelectButton.backgroundColor = UIColor(white: 1, alpha: 1)
        charmGroupSelectButton.addTarget(self, action: "charmGroupSelectButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        charmGroupSelectView.addSubview(charmGroupSelectButton)


        let charmImagePreviewImageView = UIImageView(frame: CGRectZero)
        charmImagePreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        charmImagePreviewImageView.contentMode = UIViewContentMode.ScaleAspectFit
        charmImagePreviewImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        charmGroupSelectButton.addSubview(charmImagePreviewImageView)

        let charmGroupTitleLabel = UILabel(frame: CGRectZero)
        charmGroupTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        charmGroupTitleLabel.text = "Charm Group Title Label"
        charmGroupTitleLabel.textAlignment = NSTextAlignment.Left
        charmGroupTitleLabel.numberOfLines = 1
        charmGroupSelectButton.addSubview(charmGroupTitleLabel)

        let separatorView = UIView(frame: CGRectZero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor(white: 0.8, alpha: 1)
        charmGroupSelectButton.addSubview(separatorView)

        let viewsDictionary = ["charmGroupSelectButton":charmGroupSelectButton, "charmImagePreviewImageView":charmImagePreviewImageView, "charmGroupTitleLabel":charmGroupTitleLabel, "separatorView":separatorView]
        let metricsDictionary = ["topPadding":15, "bottomPadding":20, "sidePadding":7.5]
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[charmGroupSelectButton]|", options: NSLayoutFormatOptions(rawValue:0), metrics: metricsDictionary, views: viewsDictionary)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[charmGroupSelectButton]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        
        self.charmGroupSelectView.addConstraints(hConstraints)
        self.charmGroupSelectView.addConstraints(vConstraints)
        
        let buttonHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-sidePadding-[charmImagePreviewImageView(32)]-10-[charmGroupTitleLabel]-sidePadding-|", options: [NSLayoutFormatOptions.AlignAllTop, NSLayoutFormatOptions.AlignAllBottom], metrics: metricsDictionary, views: viewsDictionary)
        charmGroupSelectButton.addConstraints(buttonHConstraints)
        
        let separatorHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[separatorView]|", options: NSLayoutFormatOptions(rawValue:0), metrics: metricsDictionary, views: viewsDictionary)
        charmGroupSelectButton.addConstraints(separatorHConstraints)
        
        let buttonVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[charmImagePreviewImageView(32)]-10-[separatorView(1)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        charmGroupSelectButton.addConstraints(buttonVConstraints)

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            print("moment section")
            if indexPath.row == 0{
            }
        default:
            print("default case")
        }
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.grayColor()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 + storyUnits.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeButtonTapped(){
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendButtonTapped(sender:UIBarButtonItem){
        sender.enabled = false
        self.createMomentFromForm()
    }
    
    func createMomentFromForm(){
        self.saveMoment()
    }
    
    func saveMoment(){
        // if successful
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView:UIView{
        get{
            return self.toolBarBottom
        }
    }
    
    func charmGroupSelectButtonTapped(sender:UIButton){
        print("charmGroupSelectButtonTapped")
        // Push to charmGroupSelect TVC
        // self.navigationController?.pushViewController(UIViewController(), animated: true)
    }

    func mediaButtonTapped(){
        print("media button tapped")
        // Present Modal Media Picker
    }
    
    func lockButtonTapped(){
        print("lock button tapped")
        // Present Modal Lock Options
    }
}
