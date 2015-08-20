//
//  StoriesTabViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/18/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class StoriesTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var charmsGalleryCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        self.charmsGalleryCollectionView.delegate = self
        self.charmsGalleryCollectionView.dataSource = self
        self.charmsGalleryCollectionView.registerClass(CharmsGalleryCollectionViewCell.self, forCellWithReuseIdentifier: "charmsGalleryCell")
        
        self.storiesCollectionView.delegate = self
        self.storiesCollectionView.dataSource = self
//        self.storiesCollectionView.collectionViewLayout = StoriesCollectionViewFlowLayout()
        let layout = self.storiesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 32, 180)

        self.storiesCollectionView.registerClass(StoriesCollectionViewCell.self, forCellWithReuseIdentifier: "storiesCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.charmsGalleryCollectionView){
            return 6
        }
        else{
            return 30
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (collectionView == self.charmsGalleryCollectionView){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("charmsGalleryCell", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.redColor()
            return cell
        }
        else if (collectionView == self.storiesCollectionView){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("storiesCell", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.greenColor()
            return cell
        }
        return UICollectionViewCell()
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
