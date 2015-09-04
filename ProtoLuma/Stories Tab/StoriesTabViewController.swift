//
//  StoriesTabViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/18/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class StoriesTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate{

    var charmsGalleryCollectionViewController:UICollectionViewController!
    var storiesTableViewController:UITableViewController!
    var userInfo:AnyObject!
    var savedDevices:[MBLMetaWear] = []
    var devices:[MBLMetaWear] = []
    var bracelet:MBLMetaWear!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let accountButton = UIBarButtonItem(image: UIImage(named: "AccountBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "accountButtonTapped:")
        let newStoryButton = UIBarButtonItem(image: UIImage(named: "NewStoryBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "newStoryButtonTapped:")
        
        self.navigationItem.rightBarButtonItem = newStoryButton
        self.navigationItem.leftBarButtonItem = accountButton
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        // currentUser exists
        if (PFUser.currentUser() != nil){
            self.layoutUIPostBraceletPairingANCS()
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
        
        self.charmsGalleryCollectionViewController = UICollectionViewController()
        self.addChildViewController(self.charmsGalleryCollectionViewController)
        self.charmsGalleryCollectionViewController.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.charmsGalleryCollectionViewController.collectionView!.translatesAutoresizingMaskIntoConstraints = false
        self.charmsGalleryCollectionViewController.collectionView!.delegate = self
        self.charmsGalleryCollectionViewController.collectionView!.dataSource = self
        self.charmsGalleryCollectionViewController.collectionView!.scrollsToTop = false
        self.charmsGalleryCollectionViewController.collectionView!.registerClass(CharmsGalleryCollectionViewCell.self, forCellWithReuseIdentifier: "CharmsGalleryCollectionViewCell")
        self.charmsGalleryCollectionViewController.collectionView!.directionalLockEnabled = true
        self.charmsGalleryCollectionViewController.collectionView!.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        self.charmsGalleryCollectionViewController.collectionView!.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.charmsGalleryCollectionViewController.collectionView!)
        
        self.storiesTableViewController = UITableViewController(style: UITableViewStyle.Plain)
        self.addChildViewController(self.storiesTableViewController)
        self.storiesTableViewController.tableView.frame = CGRectZero
        self.storiesTableViewController.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.storiesTableViewController.tableView.delegate = self
        self.storiesTableViewController.tableView.scrollsToTop = true
        self.storiesTableViewController.tableView.dataSource = self
        self.storiesTableViewController.tableView.estimatedRowHeight = 210
        self.storiesTableViewController.tableView.rowHeight = UITableViewAutomaticDimension
        self.storiesTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.storiesTableViewController.tableView.registerClass(StoriesTableViewCell.self, forCellReuseIdentifier: "StoriesTableViewCell")
        self.storiesTableViewController.tableView.registerClass(CharmTitleBlurbHeaderTableViewCell.self, forCellReuseIdentifier: "CharmTitleBlurbHeaderTableViewCell")
        self.view.addSubview(self.storiesTableViewController.tableView)
        
        self.storiesTableViewController.refreshControl = UIRefreshControl()
        self.storiesTableViewController.refreshControl!.addTarget(self, action: "loadNewStoriesForCharm:", forControlEvents: UIControlEvents.ValueChanged)
        
        let metricsDictionary = ["zero":0]
        let viewsDictionary = ["charmsGalleryCollectionView":self.charmsGalleryCollectionViewController.collectionView!, "storiesTableView":self.storiesTableViewController.tableView]
        
        let horizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[charmsGalleryCollectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        let verticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[charmsGalleryCollectionView(84)][storiesTableView]|", options: [NSLayoutFormatOptions.AlignAllLeft, NSLayoutFormatOptions.AlignAllRight], metrics: metricsDictionary, views: viewsDictionary)
        
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
        print("layoutUIPostBraceletPairingANCS")
    }
    
    
    
    // MARK: Collection View delegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CharmsGalleryCollectionViewCell", forIndexPath: indexPath)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    // MARK: Table View delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }
        else{
            return 6
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmTitleBlurbHeaderTableViewCell") as! CharmTitleBlurbHeaderTableViewCell
            cell.charmTitleLabel.text = "Charm Title"
            cell.charmBlurbLabel.text = "Charm blurb with authors and timestamp"
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("StoriesTableViewCell") as! StoriesTableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1){
            self.performSegueWithIdentifier("showStoryDetail", sender: self)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showAccount"){
//            let destinationVC = segue.destinationViewController.childViewControllers[0] as! AccountViewController
        }
    }
    
    
    
    // MARK: Navigation Methods
    func accountButtonTapped(sender:UIBarButtonItem){
        self.performSegueWithIdentifier("showAccount", sender: self)
    }
    
    func newStoryButtonTapped(sender:UIBarButtonItem){
        self.performSegueWithIdentifier("showNewStory", sender: self)
    }
    
    func loadNewStoriesForCharm(sender:UIRefreshControl){
        print("Load new stories for charm.")
        sender.endRefreshing()
    }
        

    
}
