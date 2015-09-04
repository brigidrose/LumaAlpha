//
//  StoriesTabViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/18/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class StoriesTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate{

    var charmsGalleryCollectionView:UICollectionView!
    var storiesTableView:UITableView!
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
        self.charmsGalleryCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.charmsGalleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.charmsGalleryCollectionView.delegate = self
        self.charmsGalleryCollectionView.dataSource = self
        self.charmsGalleryCollectionView.registerClass(CharmsGalleryCollectionViewCell.self, forCellWithReuseIdentifier: "CharmsGalleryCollectionViewCell")
        self.charmsGalleryCollectionView.directionalLockEnabled = true
        self.charmsGalleryCollectionView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        self.charmsGalleryCollectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.charmsGalleryCollectionView)
        
        self.storiesTableView = UITableView(frame: CGRectZero)
        self.storiesTableView.translatesAutoresizingMaskIntoConstraints = false
        self.storiesTableView.delegate = self
        self.storiesTableView.dataSource = self
        self.storiesTableView.estimatedRowHeight = 210
        self.storiesTableView.rowHeight = UITableViewAutomaticDimension
        self.storiesTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.storiesTableView.registerClass(StoriesTableViewCell.self, forCellReuseIdentifier: "StoriesTableViewCell")
        self.storiesTableView.registerClass(CharmTitleBlurbHeaderTableViewCell.self, forCellReuseIdentifier: "CharmTitleBlurbHeaderTableViewCell")
        self.view.addSubview(self.storiesTableView)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "loadNewStoriesForCharm:", forControlEvents: UIControlEvents.ValueChanged)
        self.storiesTableView.addSubview(refreshControl)
        
        let metricsDictionary = ["zero":0]
        let viewsDictionary = ["charmsGalleryCollectionView":self.charmsGalleryCollectionView, "storiesTableView":self.storiesTableView]
        
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
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! AccountViewController
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
