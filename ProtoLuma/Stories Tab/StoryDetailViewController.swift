//
//  StoryDetailViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class StoryDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var story:PFObject!
    var storyUnitsTableViewController:UITableViewController!
    var storyUnitsTableView:UITableView!
    var storyUnits:[PFObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Moment"
        
        self.storyUnitsTableViewController = UITableViewController()
        self.storyUnitsTableViewController.tableView = self.storyUnitsTableView
        self.addChildViewController(self.storyUnitsTableViewController)
        self.storyUnitsTableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Plain)
        self.storyUnitsTableView.backgroundColor = UIColor(white: 0.92, alpha: 1)
        self.storyUnitsTableView.delegate = self
        self.storyUnitsTableView.dataSource = self
        self.storyUnitsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.storyUnitsTableView.rowHeight = UITableViewAutomaticDimension
        self.storyUnitsTableView.registerClass(CharmTitleBlurbHeaderTableViewCell.self, forCellReuseIdentifier: "CharmTitleBlurbHeaderTableViewCell")
        self.storyUnitsTableView.registerClass(MomentMediaTableViewCell.self, forCellReuseIdentifier: "MomentMediaTableViewCell")
        self.view = self.storyUnitsTableView
        self.loadStoryUnits()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmTitleBlurbHeaderTableViewCell") as! CharmTitleBlurbHeaderTableViewCell
            cell.charmTitleLabel.text = story["title"] as? String
            cell.charmBlurbLabel.text = story["description"] as? String
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("MomentMediaTableViewCell") as! MomentMediaTableViewCell
            cell.mediaPreviewImageView.file = self.storyUnits[indexPath.row]["file"] as? PFFile
            cell.mediaPreviewImageView.loadInBackground()
            cell.mediaCaptionTextView.text = self.storyUnits[indexPath.row]["description"] as? String
            cell.mediaCaptionTextView.userInteractionEnabled = false
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 1
        }
        else{
            return self.storyUnits.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 80
        }
        else{
            return 450
        }
    }
    
    func loadStoryUnits(){
        let storyUnitsRelation = self.story.relationForKey("storyUnits")
        let queryForStoryUnits = storyUnitsRelation.query()
        queryForStoryUnits.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            self.storyUnits = objects!
            self.storyUnitsTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.None)
        })
    }

}
