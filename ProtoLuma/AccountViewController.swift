//
//  AccountViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var accountTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneButtonTapped:")
        self.navigationItem.leftBarButtonItem = doneButton
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Done, target: self, action: "logoutButtonTapped:")
        self.navigationItem.rightBarButtonItem = logoutButton

        self.navigationItem.title = "Account"
        
        self.accountTableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        self.accountTableView.translatesAutoresizingMaskIntoConstraints = false
        self.accountTableView.estimatedRowHeight = 50
        self.accountTableView.rowHeight = UITableViewAutomaticDimension
        self.accountTableView.delegate = self
        self.accountTableView.dataSource = self
        self.accountTableView.registerClass(ButtonWithPromptTableViewCell.self, forCellReuseIdentifier:
            "ButtonWithPromptTableViewCell")
        self.accountTableView.registerClass(CharmWithSubtitleTableViewCell.self, forCellReuseIdentifier: "CharmWithSubtitleTableViewCell")
        self.accountTableView.contentInset.top = 64
        self.accountTableView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.accountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(self.accountTableView)

        
        let viewsDictionary = ["accountTableView":self.accountTableView]
        let horizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[accountTableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|[accountTableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
            cell.promptLabel.text = "Have a new Luma Bracelet or Charm?"
            cell.button.setTitle("Begin Setup", forState: UIControlState.Normal)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
            cell.charmTitle.text = "Charm Title"
            cell.charmSubtitle.text = "Charm Subtitle"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
            cell.charmTitle.text = "Charm Title"
            cell.charmSubtitle.text = "Charm Subtitle"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
            cell.promptLabel.text = "Want a fresh start? Reset and erase all content."
            cell.button.setTitle("Reset All Charms", forState: UIControlState.Normal)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 3
        case 3:
            return 1
        default:
            return Int(0)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section{
        case 1:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "5 Charms Connected"
            return headerView
        case 2:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "3 Charms Disconnected"
            return headerView
        default:
            return UIView()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 || section == 3){
            return 0
        }
        else{
            return 40
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func doneButtonTapped(sender:UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logoutButtonTapped(sender:UIBarButtonItem){
        print("Logout button tapped")
    }
}
