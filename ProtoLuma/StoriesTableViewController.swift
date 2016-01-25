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
    
    func loadItem(title title: String, description: String, creatorPhoto: UIImage?, storyUnits: [PFObject]) {
        self.title.text = title
        self.storyDesc.text = description
        
        self.creatorPhoto.image = creatorPhoto
        
        for sv in self.HImageStack.arrangedSubviews{
            self.HImageStack.removeArrangedSubview(sv)
            sv.removeFromSuperview()
        }
        
        for unit in storyUnits as! [Story_Unit]{
            let imageView = PFImageView(frame: CGRectMake(0,0,100,100))
            imageView.contentMode = .ScaleAspectFit
            imageView.file = unit.file
            imageView.loadInBackground({ (image, error) -> Void in
                if error == nil {
                    self.HImageStack.addArrangedSubview(imageView)
                    self.HImageStack.layoutIfNeeded()
                }else{
                    print(error)
                    ParseErrorHandlingController.handleParseError(error)
                }
            })
        }

    }
}

class StoriesTableViewController: UITableViewController {

    var charm:Charm!
    var stories:[PFObject] = []
    var storiesStoryUnits:[[PFObject]] = []
    var profileImages = [String: UIImage]()
    var lockedStoriesCount:Int32 = 0
    var scheduledMomentsButton:UIBarButtonItem!
    let titleButtonLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("storiesTableViewController viewDidLoad")
        
        let nib = UINib(nibName: "StoryTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "StoryCell")
        scheduledMomentsButton = UIBarButtonItem(image: UIImage(named: "Balloons"), style: UIBarButtonItemStyle.Plain, target: self, action: "scheduledMomentsTapped:")
        
        
        
        titleButtonLabel.frame = CGRectMake(0, 0, 70, 44);
        titleButtonLabel.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "titleTapped:")
        titleButtonLabel.addGestureRecognizer(tap)
        self.navigationItem.titleView = titleButtonLabel
        
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        loadStoriesForCharmViewed()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.navigationItem.title = "\(charm.charmGroup.name) >"
        titleButtonLabel.text = "\(charm.charmGroup!.name) >"
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        loadStoriesForCharmViewed()
    }
    
    func titleTapped(sender: AnyObject){
        print("charm title tapped. go to charm settings")
        self.performSegueWithIdentifier("charmSettingsFromFeed", sender: self)
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
        if storiesStoryUnits[indexPath.row].count > 0{
            return 175
        }
        return 88
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("getting cell at \(indexPath.row).  stories count is \(stories.count) and storiesStoryUnits count is \(storiesStoryUnits.count)")
        let cell = tableView.dequeueReusableCellWithIdentifier("StoryCell") as! StoryTableViewCell
        if indexPath.row < self.stories.count && indexPath.row < self.storiesStoryUnits.count{
            let story = self.stories[indexPath.row] as! Story
            let sender = story.sender
            var image:UIImage? = nil
            if(self.profileImages[sender.facebookId] != nil){
                image = self.profileImages[sender.facebookId]
            }
            cell.loadItem(title: story["title"] as! String, description:  story["description"] as! String, creatorPhoto: image, storyUnits: self.storiesStoryUnits[indexPath.row])
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
        if segue.identifier == "showScheduledMoments" {
            let destinationVC = segue.destinationViewController as! ScheduledMomentsTableViewController
            destinationVC.lockedStoriesCount = self.lockedStoriesCount
        }else if segue.identifier == "charmSettingsFromFeed" {
            let dvc = segue.destinationViewController as! CharmSettingsTableViewController
            dvc.charm = charm
        }
    }


    
    func loadStoriesForCharmViewed(){
        print("Loading stories for charm group named \(self.charm.charmGroup!.name)")
        self.refreshControl?.beginRefreshing()
        
        var queryForStoriesForCharmViewed = PFQuery(className: "Story")
        queryForStoriesForCharmViewed.whereKey("charmGroup", equalTo: self.charm.charmGroup!)
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
                ParseErrorHandlingController.handleParseError(error)
            }
        })
        
        queryForStoriesForCharmViewed = PFQuery(className: "Story")
        queryForStoriesForCharmViewed.whereKey("charmGroup", equalTo: self.charm["charmGroup"])
        queryForStoriesForCharmViewed.whereKey("unlocked", equalTo: true)
        queryForStoriesForCharmViewed.includeKey("sender")
        queryForStoriesForCharmViewed.orderByDescending("createdAt")
        queryForStoriesForCharmViewed.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if (error == nil){
                self.stories = objects!
                self.storiesStoryUnits = Array(count: self.stories.count, repeatedValue: [])
                // load storiesStoryUnits
                var storiesStoryUnitsFoundCount = 0
                print("found \(self.stories.count) stories for charm")
                if self.stories.count > 0{
                    for story in self.stories{
                        let storyRelation = story.relationForKey("storyUnits")
                        let queryForStoryStoryUnits:PFQuery = storyRelation.query()
                        queryForStoryStoryUnits.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
                            let storyUnits = objects!
                            print("got \(storyUnits.count) story units")
                            self.storiesStoryUnits[self.stories.indexOf(story)!] = storyUnits
                            storiesStoryUnitsFoundCount++
                            print("on \(storiesStoryUnitsFoundCount) of \(self.stories.count) story unit batches to be retrieved")
                            if (storiesStoryUnitsFoundCount == self.stories.count){
                                print("done loading story units")
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
                ParseErrorHandlingController.handleParseError(error)
            }
        })
    }

}
