//
//  StoriesTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 12/18/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import ParseUI
import MBProgressHUD

class StoryTableViewCell : UITableViewCell {
    
    @IBOutlet var creatorPhoto: UIImageView!
    @IBOutlet var HImageStack: UIStackView!
    @IBOutlet var title: UILabel!
    @IBOutlet var storyDesc: UILabel!
    
    var story:Story!
    var storyUnits:[Story_Unit]!
    
    func loadItem(title title: String, description: String?, creatorPhoto: UIImage?, storyUnits: [PFObject]) {
        self.title.text = title
        
        self.storyDesc.text = description
        
        self.creatorPhoto.image = creatorPhoto
        
        self.storyUnits = storyUnits as! [Story_Unit]
        
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
    var stories:[Story] = []
    var storiesStoryUnits:[[Story_Unit]] = []
    var profileImages = [String: UIImage]()
    var lockedStoriesCount:Int32 = 0
    var scheduledMomentsButton:UIBarButtonItem!
    let titleButtonLabel = UILabel()
    var selectedRow:NSIndexPath?
    var indexPathOfStoryViewed:NSIndexPath!
    
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
        self.navigationItem.title = "\(charm.charmGroup!.name)"
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
            let story = self.stories[indexPath.row]
            let sender = story.sender
            var image:UIImage? = nil
            if(self.profileImages[sender.facebookId] != nil){
                image = self.profileImages[sender.facebookId]
            }
            cell.loadItem(title: story["title"] as! String, description:  story["description"] as? String, creatorPhoto: image, storyUnits: self.storiesStoryUnits[indexPath.row])
            cell.story = story
            //add longpress gesture recognizer as edit gesture for now
            let gr = UILongPressGestureRecognizer(target: self, action: "editStory:")
            cell.addGestureRecognizer(gr)
        }
        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            print("delete row at \(indexPath.row)")
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit", handler: { (action, indexPath) -> Void in
            print("Edit \(indexPath.row)")
            let alertVC = UIAlertController(title: "Edit Moment", message: "Stay tuned—to be enabled with an upcoming app update!", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertVC.addAction(cancelAction)
            self.presentViewController(alertVC, animated: true, completion: nil)
            
        })
        editAction.backgroundColor = UIColor(red:1, green:0.58, blue:0, alpha:1)
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Delete", handler: { (action, indexPath) -> Void in
            print("Delete \(indexPath.row)")
            self.deleteStory(indexPath.row)
        })
        deleteAction.backgroundColor = UIColor(red:1, green:0.23, blue:0.19, alpha:1)
        return [deleteAction,editAction]

    }
    
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        print("tapped row \(indexPath.row)")
        selectedRow = indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPathOfStoryViewed = indexPath
        self.performSegueWithIdentifier("showStoryDetail", sender: self)
    }
    

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
        else if segue.identifier == "showStoryDetail"{
            let storyDetailVC = segue.destinationViewController as! StoryDetailViewController
            storyDetailVC.story = self.stories[self.indexPathOfStoryViewed.row]
            storyDetailVC.storyUnits = self.storiesStoryUnits[self.indexPathOfStoryViewed.row]
            PFAnalytics.trackEvent("storyOpened", dimensions: ["userId": PFUser.currentUser()!.objectId!, "storyId": self.stories[self.indexPathOfStoryViewed.row].objectId!])
        }
    }
    
    func editStory(sender: UIGestureRecognizer){
        print("edit story pressed")
        if sender.state == UIGestureRecognizerState.Ended {
        
            guard let rowIndex = selectedRow?.row else {
                print("Could not get row index from selected row in edit story handler")
                return
            }
            
            let story = self.stories[rowIndex]
            
            let nstvc = NewStoryTabViewController()
            nstvc.shouldResetSelectedCharm = false
            nstvc.storyUnits = self.storiesStoryUnits[rowIndex]
            nstvc.forCharm = self.charm
            nstvc.momentTitle?.textField.text = story.title
            nstvc.momentDesc?.textView.text = story["description"] as! String
            self.navigationController?.pushViewController(nstvc, animated: true)
        }
        
    }

    func deleteStory(storyRowNum:Int){
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.labelText = "Deleting..."
        let story = stories[storyRowNum]
        print("story to delete is \(story["title"] as? String)")
        let storyUnits = self.storiesStoryUnits[storyRowNum]
        for storyUnit in storyUnits{
            storyUnit.deleteEventually()
        }
        self.storiesStoryUnits.removeAtIndex(storyRowNum)
        story.deleteEventually()
        self.stories.removeAtIndex(storyRowNum)
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
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
                self.stories = objects as! [Story]
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
                            self.storiesStoryUnits[self.stories.indexOf(story)!] = storyUnits as! [Story_Unit]
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
