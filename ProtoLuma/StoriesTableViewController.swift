//
//  StoriesTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 12/18/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import ParseUI

class StoryTableViewCell : UITableViewCell {
    
    @IBOutlet var creatorPhoto: UIImageView!
    @IBOutlet var HImageStack: UIStackView!
    @IBOutlet var title: UILabel!
    @IBOutlet var storyDesc: UILabel!
    
    func loadItem(title title: String, description: String, creatorPhoto: UIImage, storyUnits: [PFObject]) {
        self.title.text = title
        self.storyDesc.text = description
        
        self.creatorPhoto.image = creatorPhoto
        
        for sv in self.HImageStack.arrangedSubviews{
            self.HImageStack.removeArrangedSubview(sv)
            sv.removeFromSuperview()
        }
        
        for unit in storyUnits{
            let imageView = PFImageView(frame: CGRectZero)
            imageView.contentMode = .ScaleAspectFit
            imageView.file = unit["file"] as? PFFile
            imageView.loadInBackground({ (image, error) -> Void in
                self.HImageStack.addArrangedSubview(imageView)
                self.HImageStack.layoutIfNeeded()
            })
        }

    }
}

class StoriesTableViewController: UITableViewController {

    var charm:PFObject!
    var stories:[PFObject] = []
    var storiesStoryUnits:[[PFObject]] = []
    var profileImages = [String: UIImage]()
    var lockedStoriesCount:Int32 = 0
    var scheduledMomentsButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "StoryTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "StoryCell")
        scheduledMomentsButton = UIBarButtonItem(image: UIImage(named: "CharmsBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "scheduledMomentsTapped:")
        
        loadStoriesForCharmViewed()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scheduledMomentsTapped(sender:UIBarButtonItem){
        self.performSegueWithIdentifier("showScheduledMoments", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stories.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 175
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoryCell") as! StoryTableViewCell
        if indexPath.row < self.stories.count && indexPath.row < self.storiesStoryUnits.count{
            let story = self.stories[indexPath.row]
            let sender = story["sender"] as! PFObject
            cell.loadItem(title: story["title"] as! String, description:  story["description"] as! String, creatorPhoto: self.profileImages[sender["facebookId"] as! String]!, storyUnits: self.storiesStoryUnits[indexPath.row])
        }
        // Configure the cell...

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showScheduledMoments"){
            let destinationVC = segue.destinationViewController as! ScheduledMomentsTableViewController
            destinationVC.lockedStoriesCount = self.lockedStoriesCount
        }
    }


    
    func loadStoriesForCharmViewed(){
        self.refreshControl?.beginRefreshing()
        
        var queryForStoriesForCharmViewed = PFQuery(className: "Story")
        queryForStoriesForCharmViewed.whereKey("charmGroup", equalTo: self.charm["charmGroup"])
        queryForStoriesForCharmViewed.whereKey("unlocked", equalTo: false)
        queryForStoriesForCharmViewed.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
            if(error == nil){
                self.lockedStoriesCount = count
                if self.lockedStoriesCount > 0{
                    self.navigationItem.rightBarButtonItem = self.scheduledMomentsButton
                }else{
                    self.navigationItem.rightBarButtonItem = nil
                }
            }else{
                print(error)
                (UIApplication.sharedApplication().delegate as! AppDelegate).displayNoInternetErrorMessage()
            }
        })
        
        queryForStoriesForCharmViewed = PFQuery(className: "Story")
        queryForStoriesForCharmViewed.whereKey("charmGroup", equalTo: self.charm["charmGroup"])
        queryForStoriesForCharmViewed.whereKey("unlocked", equalTo: true)
        queryForStoriesForCharmViewed.orderByDescending("createdAt")
        queryForStoriesForCharmViewed.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if (error == nil){
                self.stories = objects!
                self.storiesStoryUnits = Array(count: self.stories.count, repeatedValue: [])
                // load storiesStoryUnits
                var storiesStoryUnitsFoundCount = 0
                if self.stories.count > 0{
                    for story in self.stories{
                        let storyRelation = story.relationForKey("storyUnits")
                        let queryForStoryStoryUnits:PFQuery = storyRelation.query()!
                        queryForStoryStoryUnits.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
                            self.storiesStoryUnits[self.stories.indexOf(story)!] = objects!
                            storiesStoryUnitsFoundCount++
                            if (storiesStoryUnitsFoundCount == self.stories.count){
                                //done loading story units
                                self.refreshControl?.endRefreshing()
                                self.tableView.reloadData()
                            }
                        })
                    }
                }else{
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
            else{
                print(error)
                (UIApplication.sharedApplication().delegate as! AppDelegate).displayNoInternetErrorMessage()
            }
        })
    }

}
