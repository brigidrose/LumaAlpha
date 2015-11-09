//
//  StoriesTabViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/18/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class StoriesTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate{

    var accountButton:UIBarButtonItem!
    var newStoryButton:UIBarButtonItem!
    
    // To be reimplemented with UIStackView
    var charmsGalleryCollectionViewController:UICollectionViewController!
    
    var storiesTableViewController:UITableViewController!
    var userInfo:AnyObject!
    var bracelet:MBLMetaWear!
    var charms:[PFObject] = []
    var indexOfCharmViewed:Int!
    var stories:[PFObject] = []
    var storiesStoryUnits:[[PFObject]] = []
    var lockedStories:[PFObject] = []
    var lockedStoriesStoryUnits:[[PFObject]] = []
    var indexPathOfStoryViewed:NSIndexPath!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountButton = UIBarButtonItem(image: UIImage(named: "AccountBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "accountButtonTapped:")
        self.newStoryButton = UIBarButtonItem(image: UIImage(named: "NewStoryBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "newStoryButtonTapped:")
        self.newStoryButton.enabled = false
        
        self.navigationItem.rightBarButtonItem = newStoryButton
        self.navigationItem.leftBarButtonItem = accountButton
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        // currentUser exists
        if (PFUser.currentUser() != nil){
            MBLMetaWearManager.sharedManager().retrieveSavedMetaWearsWithHandler({(devices) -> Void in
                if ((devices as! [MBLMetaWear]).count > 0){
                    self.layoutUIPostBraceletPairingANCS()
                    self.loadCharms()
                }
                else{
                    if (PFUser.currentUser()!["bracelet"] != nil){
                        self.layoutUIPostBraceletPairingANCS()
                        self.loadCharms()
                    }
                    else{
                        self.performSegueWithIdentifier("showLoggedInWithoutBracelet", sender: self)
                    }
                }
            })
        }
        else{
            self.performSegueWithIdentifier("showLogin", sender: self)
        }

    }

    override func viewWillAppear(animated: Bool) {
        // Check self.bracelet state to display disconnected alert if so
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Layout after Bracelet connection
    func layoutUIPostBraceletPairingANCS(){
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.sectionInset = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
        layout.minimumLineSpacing = 28
        
        
        self.storiesTableViewController = UITableViewController(style: UITableViewStyle.Plain)
        self.addChildViewController(self.storiesTableViewController)
        self.storiesTableViewController.tableView.frame = CGRectZero
        self.storiesTableViewController.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.storiesTableViewController.tableView.delegate = self
        self.storiesTableViewController.tableView.scrollsToTop = true
        self.storiesTableViewController.tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        self.storiesTableViewController.tableView.dataSource = self
        self.storiesTableViewController.tableView.estimatedRowHeight = 210
        self.storiesTableViewController.tableView.rowHeight = UITableViewAutomaticDimension
        self.storiesTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.storiesTableViewController.tableView.contentInset.top = 148
        self.storiesTableViewController.tableView.registerClass(StoriesTableViewCell.self, forCellReuseIdentifier: "StoriesTableViewCell")
        self.storiesTableViewController.tableView.registerClass(CharmTitleBlurbHeaderTableViewCell.self, forCellReuseIdentifier: "CharmTitleBlurbHeaderTableViewCell")
        self.view.addSubview(self.storiesTableViewController.tableView)
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, 84)
//        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(visualEffectView)

        
        self.storiesTableViewController.refreshControl = UIRefreshControl()
        self.storiesTableViewController.refreshControl!.addTarget(self, action: "loadNewStoriesForCharm:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.charmsGalleryCollectionViewController = UICollectionViewController()
        self.addChildViewController(self.charmsGalleryCollectionViewController)
        self.charmsGalleryCollectionViewController.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)

        self.charmsGalleryCollectionViewController.collectionView!.translatesAutoresizingMaskIntoConstraints = false
        self.charmsGalleryCollectionViewController.collectionView!.delegate = self
        self.charmsGalleryCollectionViewController.collectionView!.dataSource = self
        self.charmsGalleryCollectionViewController.collectionView!.scrollsToTop = false
        self.charmsGalleryCollectionViewController.collectionView!.alwaysBounceHorizontal = true
        self.charmsGalleryCollectionViewController.collectionView!.registerClass(CharmsGalleryCollectionViewCell.self, forCellWithReuseIdentifier: "CharmsGalleryCollectionViewCell")
        self.charmsGalleryCollectionViewController.collectionView!.directionalLockEnabled = true
        self.charmsGalleryCollectionViewController.collectionView!.backgroundColor = UIColor(white: 1, alpha: 0.7)
        self.charmsGalleryCollectionViewController.collectionView!.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.charmsGalleryCollectionViewController.collectionView!)

        
        let metricsDictionary = ["zero":0]
        let viewsDictionary = ["charmsGalleryCollectionView":self.charmsGalleryCollectionViewController.collectionView!, "storiesTableView":self.storiesTableViewController.tableView]
        
        let storiesTableViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[storiesTableView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        let storiesTableViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[storiesTableView]|", options: NSLayoutFormatOptions(rawValue: 0)  , metrics: nil, views: viewsDictionary)

        let horizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[charmsGalleryCollectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        let verticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[charmsGalleryCollectionView(84)]", options: [NSLayoutFormatOptions.AlignAllLeft, NSLayoutFormatOptions.AlignAllRight], metrics: metricsDictionary, views: viewsDictionary)

        self.view.addConstraints(storiesTableViewConstraintsVertical)
        self.view.addConstraints(storiesTableViewConstraintsHorizontal)
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)

//        print("layoutUIPostBraceletPairingANCS")
    }
    
    
    
    // MARK: Collection View delegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.charmsGalleryCollectionViewController.collectionView){
            return self.charms.count
        }
        else{
            let indexPathOfCollectionView = self.indexPathForCellContainingView(collectionView, inTableView: self.storiesTableViewController.tableView)
//            print(indexPathOfCollectionView)
            
            if (indexPathOfCollectionView?.section == 0){
                if (self.lockedStoriesStoryUnits[(indexPathOfCollectionView?.row)!].count != 0){
                    return self.lockedStoriesStoryUnits[(indexPathOfCollectionView?.row)!].count
                }
            }
            else if (indexPathOfCollectionView?.section == 2){
                if (self.storiesStoryUnits[(indexPathOfCollectionView?.row)!].count != 0){
                    return self.storiesStoryUnits[(indexPathOfCollectionView?.row)!].count
                }
            }
            else{
                return 0
            }
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (collectionView == self.charmsGalleryCollectionViewController.collectionView){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CharmsGalleryCollectionViewCell", forIndexPath: indexPath) as! CharmsGalleryCollectionViewCell
            if (self.indexOfCharmViewed != nil){
                if (indexPath.row == self.indexOfCharmViewed){
                    cell.contentView.alpha = 1
                    cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                }
                else{
                    cell.contentView.alpha = 0.5
                    cell.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.1)
                }
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImagePreviewCollectionViewCell", forIndexPath: indexPath) as! ImagePreviewCollectionViewCell
            let indexPathOfCollectionView = self.indexPathForCellContainingView(collectionView, inTableView: self.storiesTableViewController.tableView)
            var storyUnits:[PFObject]!
            if (indexPathOfCollectionView?.section == 0){
                storyUnits = self.lockedStoriesStoryUnits[(indexPathOfCollectionView?.row)!]
            }
            else if (indexPathOfCollectionView?.section == 2){
                storyUnits = self.storiesStoryUnits[(indexPathOfCollectionView?.row)!]
            }
            if (storyUnits != nil){
                if (indexPath.item < storyUnits.count){
                    cell.imagePreviewImageView.file = storyUnits[indexPath.row]["file"] as? PFFile
                    cell.imagePreviewImageView.loadInBackground()
                }
            }
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView == self.charmsGalleryCollectionViewController.collectionView){
            self.indexOfCharmViewed = indexPath.row
            self.loadStoriesForCharmViewed()
        }
        else{
        
        }
    }

    
    
    
    // MARK: Table View delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            case 0:
                return self.lockedStories.count
            case 1:
                if (self.indexOfCharmViewed != nil){
                    return 1
                }
                else{
                    return 0
                }
            case 2:
                return self.stories.count
            default:
                return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("StoriesTableViewCell") as! StoriesTableViewCell
            cell.storyTitleLabel.text = self.lockedStories[indexPath.row]["title"] as? String
            cell.storySummaryLabel.text = self.lockedStories[indexPath.row]["description"] as? String
//            cell.storyUnits = self.lockedStoriesStoryUnits[indexPath.row]
//            print(self.lockedStoriesStoryUnits[indexPath.row])
            cell.storyImagePreviewCollectionView.delegate = self
            cell.storyImagePreviewCollectionView.dataSource = self
            cell.storyImagePreviewCollectionView.reloadData()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmTitleBlurbHeaderTableViewCell") as! CharmTitleBlurbHeaderTableViewCell
            let charm = self.charms[self.indexOfCharmViewed]
//            let charmOwner = charm["owner"] as? PFUser
            let charmGifter = charm["gifter"] as? PFUser
            if (charmGifter != nil){
//                let charmOwnerFirstName = charmOwner?["firstName"] as! String
//                let charmOwnerLastName = charmOwner?["lastName"] as! String
                let charmGifterFirstName = charmGifter?["firstName"] as! String
                let charmGifterLastName = charmGifter?["lastName"] as! String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let updatedString = "\(dateFormatter.stringFromDate(charm.updatedAt!))"
                cell.charmTitleLabel.text = charm["name"] as? String
                if (charmGifter == PFUser.currentUser()!){
                    cell.charmBlurbLabel.text = "Gifted charm"
                }
                else{
                    cell.charmBlurbLabel.text = "Gifted by \(charmGifterFirstName) \(charmGifterLastName.characters.first!). on \(updatedString)"

                }
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("StoriesTableViewCell") as! StoriesTableViewCell
            cell.storyTitleLabel.text = self.stories[indexPath.row]["title"] as? String
            cell.storySummaryLabel.text = self.stories[indexPath.row]["description"] as? String
//            cell.storyUnits = self.storiesStoryUnits[indexPath.row]
            cell.storyImagePreviewCollectionView.delegate = self
            cell.storyImagePreviewCollectionView.dataSource = self
            cell.storyImagePreviewCollectionView.reloadData()
//            print(self.storiesStoryUnits[indexPath.row])
            return cell
        default: return UITableViewCell()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section != 1 && indexPath.section != 0){
            self.indexPathOfStoryViewed = indexPath
            self.performSegueWithIdentifier("showStoryDetail", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showAccount"){
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! AccountViewController
            destinationVC.charms = self.charms
        }
        else if (segue.identifier == "showNewMoment"){
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! NewStoryTabViewController
            destinationVC.charms = self.charms
        }
        else if (segue.identifier == "showStoryDetail"){
            let destinationVC = segue.destinationViewController as! StoryDetailViewController
            if (self.indexPathOfStoryViewed.section == 0){
                destinationVC.story = self.lockedStories[indexPathOfStoryViewed.row]
            }
            else if (self.indexPathOfStoryViewed.section == 2){
                destinationVC.story = self.stories[indexPathOfStoryViewed.row]
            }
        }
    }
    
    
    
    
    // MARK: Navigation Methods
    func accountButtonTapped(sender:UIBarButtonItem){
        print("account button tapped")
        self.performSegueWithIdentifier("showAccount", sender: self)
    }
    
    func newStoryButtonTapped(sender:UIBarButtonItem){
        self.performSegueWithIdentifier("showNewMoment", sender: self)
    }
    
    func loadNewStoriesForCharm(sender:UIRefreshControl){
        print("Load new stories for charm.")
        self.loadStoriesForCharmViewed()
    }
        
    func loadCharms(){
        let queryForCharmsOwned = PFQuery(className: "Charm")
        queryForCharmsOwned.whereKey("owners", equalTo: PFUser.currentUser()!)
        let queryForCharmsGifted = PFQuery(className: "Charm")
        queryForCharmsGifted.whereKey("gifter", equalTo: PFUser.currentUser()!)
        let queryForCharms = PFQuery.orQueryWithSubqueries([queryForCharmsOwned, queryForCharmsGifted])
//        queryForCharms.includeKey("owners")
        queryForCharms.includeKey("gifter")
        queryForCharms.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            self.charms = objects!
//            print("charms loaded")
            self.charmsGalleryCollectionViewController.collectionView?.reloadSections(NSIndexSet(index: 0))
            if (self.charms.count > 0){
                self.newStoryButton.enabled = true
                if (self.indexOfCharmViewed == nil){
                    self.indexOfCharmViewed = 0
                }
                self.loadStoriesForCharmViewed()
            }
        })
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        var story:PFObject!
//        print("lockedStories count is \(self.lockedStories.count)")
//        print("stories count is \(self.stories.count)")
//        print("indexPath row is \(indexPath.row) and section is \(indexPath.section)")
        if (indexPath.section == 0 && self.lockedStories.count != 0 && (self.lockedStoriesStoryUnits[indexPath.row]).count == 0){
            story = self.lockedStories[indexPath.row]
        }
        else if(indexPath.section == 2 && self.stories.count != 0 && (self.storiesStoryUnits[indexPath.row]).count == 0){
            story = self.stories[indexPath.row]
        }

        

        if (story != nil){
            // fetch and provide cell with storyUnit array
//            print("story is not nil")
            let relation = story.relationForKey("storyUnits")
            let queryForStoryUnits = relation.query()
            queryForStoryUnits?.limit = 3
            queryForStoryUnits?.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
//                print(objects as! [PFObject])
                if (story["unlocked"] as! Bool){
                    if(indexPath.row < self.storiesStoryUnits.count){
                        self.storiesStoryUnits[indexPath.row] = objects!
                    }
                }
                else{
                    self.lockedStoriesStoryUnits[indexPath.row] = objects!
                }
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            })
        }
    }
    
    func loadStoriesForCharmViewed(){
        self.storiesTableViewController.refreshControl?.beginRefreshing()
        let queryForStoriesForCharmViewed = PFQuery(className: "Story")
        queryForStoriesForCharmViewed.whereKey("forCharm", equalTo: self.charms[self.indexOfCharmViewed])
        queryForStoriesForCharmViewed.whereKey("unlocked", equalTo: true)
        queryForStoriesForCharmViewed.orderByDescending("createdAt")
        queryForStoriesForCharmViewed.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if (error == nil){
                self.stories = objects!
                self.storiesStoryUnits = Array(count: self.stories.count, repeatedValue: [])
                let queryForLockedStoriesForCharmViewed = PFQuery(className: "Story")
                queryForLockedStoriesForCharmViewed.whereKey("forCharm", equalTo: self.charms[self.indexOfCharmViewed])
                queryForLockedStoriesForCharmViewed.whereKey("unlocked", equalTo: false)
                queryForLockedStoriesForCharmViewed.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
                    self.lockedStories = objects!
                    self.lockedStoriesStoryUnits = Array(count: self.lockedStories.count, repeatedValue: [])
                    self.storiesTableViewController.refreshControl?.endRefreshing()
                    self.storiesTableViewController.tableView.reloadData()
//                    self.storiesTableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                    self.charmsGalleryCollectionViewController.collectionView?.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 1)))
                    // load lockedStoriesStoryUnits
                    var lockedStoriesStoryUnitsFoundCount = 0
                    for lockedStory in self.lockedStories{
                        let lockedStoryRelation = lockedStory.relationForKey("storyUnits")
                        let queryForLockedStoryStoryUnits:PFQuery = lockedStoryRelation.query()!
                        queryForLockedStoryStoryUnits.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
                            self.lockedStoriesStoryUnits[self.lockedStories.indexOf(lockedStory)!] = objects!
                            lockedStoriesStoryUnitsFoundCount++
                            if (lockedStoriesStoryUnitsFoundCount == self.lockedStories.count){
                                // load storiesStoryUnits
                                var storiesStoryUnitsFoundCount = 0
                                for story in self.stories{
                                    let storyRelation = story.relationForKey("storyUnits")
                                    let queryForStoryStoryUnits:PFQuery = storyRelation.query()!
                                    queryForStoryStoryUnits.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
                                        self.storiesStoryUnits[self.stories.indexOf(story)!] = objects!
                                        storiesStoryUnitsFoundCount++
                                        if (storiesStoryUnitsFoundCount == self.stories.count){
                                            // load storiesStoryUnits
//                                            self.storiesTableViewController.refreshControl?.endRefreshing()
//                                            self.storiesTableViewController.tableView.reloadData()
                                            self.storiesTableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
//                                            self.charmsGalleryCollectionViewController.collectionView?.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 1)))
                                        }
                                    })
                                }
                            }
                        })
                    }
                })
            }
            else{
                print(error)
            }
        })
        
    }

    func indexPathForCellContainingView(view: UIView, inTableView tableView:UITableView) -> NSIndexPath? {
        let viewCenterRelativeToTableview = tableView.convertPoint(CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)), fromView:view)
        return tableView.indexPathForRowAtPoint(viewCenterRelativeToTableview)
    }

    
    
}
