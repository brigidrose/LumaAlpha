//
//  NewMomentViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 1/28/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import CTAssetsPickerController
import MBProgressHUD

class NewMomentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, CTAssetsPickerControllerDelegate, UIScrollViewDelegate{

    var tableViewController:UITableViewController!
    var toolBarBottom:UIToolbar!
    var storyUnits = NSMutableArray()
    
    var charmGroupSelectView:UIView!
    var charmGroupTitleLabel:UILabel!
    
    var mediaAssets:[PHAsset] = []
    var mediaDescriptions:[String] = []
    var imageDictionary:[NSIndexPath:UIImage] = [NSIndexPath:UIImage]()
    
    var activeField: UITextView?
    var oldContentInset:UIEdgeInsets!
    
    var forCharm:Charm!
    var momentTitle:String = ""
    var momentDescription:String!
    var unlockParameterType:String!
    var unlockTime:NSDate!
    var unlockLocation:PFGeoPoint!
    var unlockLocationPlacemark:CLPlacemark!
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var keyboardShown:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Moment"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "closeButtonTapped")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Done, target: self, action: "sendButtonTapped:")
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.tableViewController = UITableViewController()
        self.addChildViewController(self.tableViewController)
        self.tableViewController.tableView = UITableView(frame: CGRectZero)
        self.tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewController.tableView.delegate = self
        self.tableViewController.tableView.dataSource = self
        self.tableViewController.tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldTableViewCell")
        self.tableViewController.tableView.registerClass(TextViewTableViewCell.self, forCellReuseIdentifier: "TextViewTableViewCell")
        self.tableViewController.tableView.registerClass(MomentMediaTableViewCell.self, forCellReuseIdentifier: "MomentMediaTableViewCell")
        self.tableViewController.tableView.contentInset.top = 53
        self.tableViewController.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableViewController.tableView.estimatedRowHeight = 88
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
        let mediaToolBarItem = UIBarButtonItem(image: UIImage(named: "mediaUploadBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "mediaButtonTapped")
        let lockToolBarItem = UIBarButtonItem(image: UIImage(named: "lockBarButtonItemIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "lockButtonTapped")
        self.toolBarBottom.tintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor
        self.toolBarBottom.items = [mediaToolBarItem, lockToolBarItem]
        self.view.addSubview(self.toolBarBottom)
        
        let toolBarBottomPinConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let toolBarBottomHeightConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44)
        let toolBarBottomWidthConstraint = NSLayoutConstraint(item: self.toolBarBottom, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        
        self.view.addConstraint(toolBarBottomPinConstraint)
        self.view.addConstraint(toolBarBottomHeightConstraint)
        self.view.addConstraint(toolBarBottomWidthConstraint)
                
        self.toolBarBottom.removeFromSuperview()
        
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
        charmImagePreviewImageView.image = UIImage(named: "CharmsBarButtonIcon")
        charmGroupSelectButton.addSubview(charmImagePreviewImageView)

        self.charmGroupTitleLabel = UILabel(frame: CGRectZero)
        self.charmGroupTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.charmGroupTitleLabel.text = "Tap to Select Charm"
        self.charmGroupTitleLabel.textAlignment = NSTextAlignment.Left
        self.charmGroupTitleLabel.numberOfLines = 1
        charmGroupSelectButton.addSubview(self.charmGroupTitleLabel)

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

        self.registerForKeyboardNotifications()
        
    }
    
    func sendButtonTapped(sender:UIBarButtonItem){
        //special treatment for description since PFAnalytics can't handle nils
        var descriptionLength = 0
        if self.momentDescription != nil {
            descriptionLength = self.momentDescription.characters.count
        }
        var analyticsDimensions = [
            "attachmentCount": String(self.mediaAssets.count),
            "userId": PFUser.currentUser()!.objectId!,
            "titleLength": String(self.momentTitle.characters.count),
            "descriptionLength": String(descriptionLength),
            "unlockType": "None"
        ]
        
        
        print("Send button tapped")
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.labelText = "Sending..."
        //        self.navigationItem.leftBarButtonItem?.enabled = false
        //        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem?.enabled = false
        let story = PFObject(className: "Story")
        story["title"] = self.momentTitle
        if self.momentDescription != nil {
            story["description"] = self.momentDescription
        }
        story["sender"] = PFUser.currentUser()
        story["charmGroup"] = self.forCharm["charmGroup"]
        if (self.unlockParameterType != nil){
            analyticsDimensions["unlockType"] = self.unlockParameterType
            print("unlock parameter type is not nil")
            story["unlockType"] = self.unlockParameterType
            if (self.unlockParameterType == "time"){
                story["unlockTime"] = self.unlockTime
            }
            else{
                story["unlockLocation"] = self.unlockLocation
            }
            story["unlocked"] = false
        }
        else{
            story["unlocked"] = true
        }
        story["readStatus"] = false
        PFAnalytics.trackEvent("sentNewMoment", dimensions:analyticsDimensions)
        print("Creating image manager")
        let manager = PHImageManager.defaultManager()
        let storyUnitsRelation:PFRelation = story.relationForKey("storyUnits")
        var savedCount = 0
        if (self.mediaAssets.count > 0){
            for mediaAsset in self.mediaAssets{
                print("Finding media asset")
                print(mediaAsset)
                let options = PHImageRequestOptions()
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                options.synchronous = false
                options.networkAccessAllowed = true
                options.progressHandler = {(progress, error, stop, info) -> Void in
                    print(progress)
                }
                manager.requestImageForAsset(mediaAsset, targetSize: CGSizeMake(1200, 1200), contentMode: PHImageContentMode.Default, options: options, resultHandler:{(image:UIImage?, info:[NSObject:AnyObject]?) -> Void in
                    let storyUnit = PFObject(className: "Story_Unit")
                    let sizedImage = self.RBResizeImage(image!, targetSize: CGSizeMake(1200, 1200))
                    storyUnit["file"] = PFFile(data: UIImagePNGRepresentation(sizedImage)!)
                    storyUnit["description"] = self.mediaDescriptions[self.mediaAssets.indexOf(mediaAsset)!]
                    storyUnit.saveInBackgroundWithBlock({(success, error) -> Void in
                        if (error == nil){
                            print("\(storyUnit) saved!")
                            savedCount++
                            storyUnitsRelation.addObject(storyUnit)
                            if (savedCount == self.mediaAssets.count){
                                story.saveInBackgroundWithBlock({(success, error) -> Void in
                                    if (error == nil){
                                        // load charms into the new story controller
                                        //                                        let barViewControllers = self.tabBarController?.viewControllers
                                        //                                        let stvc = barViewControllers![0].childViewControllers[0] as! StoriesTabViewController
                                        //                                        stvc.indexOfCharmViewed = self.charms.indexOf(self.forCharm)
                                        //                                        stvc.loadStoriesForCharmViewed()
                                        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                                        self.tabBarController?.selectedIndex = 0
                                        self.appDelegate.collectionController.navigateToCharmMoments(self.forCharm.objectId!)
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                        //                                            self.appDelegate.collectionController.navigationController?.popToRootViewControllerAnimated(true)
                                    }
                                    else{
                                        print(error)
                                        self.navigationItem.rightBarButtonItem?.enabled = true
                                        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                                        ParseErrorHandlingController.handleParseError(error)
                                    }
                                })
                            }
                        }
                        else{
                            print(error)
                            self.tabBarController?.navigationItem.rightBarButtonItem?.enabled = true
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                            ParseErrorHandlingController.handleParseError(error)
                        }
                    })
                })
            }
        }else{
            story.saveInBackgroundWithBlock({(success, error) -> Void in
                if (error == nil){
                    //                    (self.parentViewController?.presentingViewController?.childViewControllers[0] as! StoriesTabViewController).indexOfCharmViewed = self.charms.indexOf(self.forCharm)
                    //                    (self.parentViewController?.presentingViewController?.childViewControllers[0] as! StoriesTabViewController).loadStoriesForCharmViewed()
                    //                    self.dismissViewControllerAnimated(true, completion: nil)
                    //                    let barViewControllers = self.tabBarController?.viewControllers
                    //                    let stvc = barViewControllers![0] as! StoriesTabViewController
                    //                    stvc.indexOfCharmViewed = self.charms.indexOf(self.forCharm)
                    //                    stvc.loadStoriesForCharmViewed()
                    progressHUD.progress = 1
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                    self.tabBarController?.selectedIndex = 0
                    self.appDelegate.collectionController.navigateToCharmMoments(self.forCharm.objectId!)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else{
                    print(error)
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                    self.tabBarController?.navigationItem.rightBarButtonItem?.enabled = true
                    ParseErrorHandlingController.handleParseError(error)
                }
                
            })
            
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.becomeFirstResponder()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell") as! TextFieldTableViewCell
                cell.textField.placeholder = "Title"
                cell.textField.delegate = self
                return cell
            }
            if indexPath.row == 1{
                let cell = tableView.dequeueReusableCellWithIdentifier("TextViewTableViewCell") as! TextViewTableViewCell
                cell.textView.placeholder = "Description"
                cell.textView.delegate = self
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("MomentMediaTableViewCell") as! MomentMediaTableViewCell

            cell.mediaCaptionTextView.delegate = self
            cell.mediaCaptionTextView.placeholder = "Description"
            cell.mediaCaptionTextView.text = self.mediaDescriptions[indexPath.row]
            cell.mediaPreviewImageView.backgroundColor = nil
            cell.mediaCaptionTextView.returnKeyType = UIReturnKeyType.Done
          
            let manager = PHImageManager.defaultManager()
            
            if cell.tag != 0 {
                manager.cancelImageRequest(PHImageRequestID(cell.tag))
            }
            
            let asset = self.mediaAssets[indexPath.row]
            let options = PHImageRequestOptions()
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
            options.synchronous = false
            options.networkAccessAllowed = true
            options.progressHandler = {(progress, error, stop, info) -> Void in
                print(progress)
            }
            
            if self.imageDictionary.keys.contains(indexPath){
                cell.mediaPreviewImageView.image = self.imageDictionary[indexPath]
            }
            else{
                manager.requestImageForAsset(asset, targetSize: CGSizeMake(1200, 1200), contentMode: PHImageContentMode.Default, options: options, resultHandler:{(image:UIImage?, info:[NSObject:AnyObject]?) -> Void in
                    // this result handler is called on the main thread for asynchronous requests
                    self.imageDictionary.updateValue(image!, forKey: indexPath)
                    if self.tableViewController.tableView.visibleCells.contains(cell){
                        self.tableViewController.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                })
            }
//            if (self.imageAssets.count > indexPath.row){
//                cell.mediaPreviewImageView.image = self.imageAssets.objectAtIndex(indexPath.row) as? UIImage
//            }
//            else{
//                manager.requestImageForAsset(asset, targetSize: CGSizeMake(1200, 1200), contentMode: PHImageContentMode.Default, options: options, resultHandler:{(image:UIImage?, info:[NSObject:AnyObject]?) -> Void in
//                    // this result handler is called on the main thread for asynchronous requests
//                    self.imageAssets.insertObject(image!, atIndex: indexPath.row)
//                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//                })
//            }

            cell.layoutSubviews()
            return cell
        default:
            print("default case")
        }
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.grayColor()
        return cell
    }
    
    func doneButtonTapped(sender:UIBarButtonItem){
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        let indexPathForTextView:NSIndexPath = self.indexPathForCellContainingView(textView, inTableView: self.tableViewController.tableView)!
        print(indexPathForTextView)
        if (indexPathForTextView.section == 1){
            self.activeField = textView //only set activeField for section 1
            print("indexPathForTextView of activeField is \(indexPathForTextView)")
        }
    }
    
    func indexPathForCellContainingView(view: UIView, inTableView tableView:UITableView) -> NSIndexPath? {
        let viewCenterRelativeToTableview = tableView.convertPoint(CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)), fromView:view)
        return tableView.indexPathForRowAtPoint(viewCenterRelativeToTableview)
    }

    
    func textViewDidEndEditing(textView: UITextView) {
        let indexPathForTextView:NSIndexPath = self.indexPathForCellContainingView(textView, inTableView: self.tableViewController.tableView)!
        print(indexPathForTextView)
        if (indexPathForTextView.section == 1){
            self.mediaDescriptions[indexPathForTextView.row] = textView.text
            print(self.mediaDescriptions)
        }
        else{
            // == 1
            // This would be the moment desc
            self.momentDescription = textView.text
        }
        self.activeField = nil
        print("moment description is \(self.momentDescription)")
    }
    
    func textViewDidChange(textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            self.tableViewController.tableView.beginUpdates()
            self.tableViewController.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }


    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }
        else{
            return self.mediaAssets.count
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeButtonTapped(){
        self.view.endEditing(true)
        self.view.addSubview(self.toolBarBottom)
        self.toolBarBottom.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    func sendButtonTapped(sender:UIBarButtonItem){
//        sender.enabled = false
//        self.createMomentFromForm()
//    }
//    
//    func createMomentFromForm(){
//        self.saveMoment()
//    }
//    
//    func saveMoment(){
//        // if successful
//        self.navigationItem.rightBarButtonItem?.enabled = true
//    }
    

    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView:UIView{
        get{
            return self.toolBarBottom
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if ((textField.superview?.superview?.isKindOfClass(TextFieldTableViewCell)) != nil){
            if self.momentTitle != "" && self.forCharm != nil{
                self.navigationItem.rightBarButtonItem!.enabled = true
            }
            else{
                self.navigationItem.rightBarButtonItem!.enabled = false
            }
            (self.tableViewController.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TextViewTableViewCell).textView.becomeFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if self.indexPathForCellContainingView(textField, inTableView: self.tableViewController.tableView) == NSIndexPath(forRow: 0, inSection: 0){
            // textField is moment title
            if (textField.text != ""){
                self.momentTitle = textField.text!
            }
            if self.momentTitle != "" && self.forCharm != nil{
                self.navigationItem.rightBarButtonItem!.enabled = true
            }
            else{
                self.navigationItem.rightBarButtonItem!.enabled = false
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textFieldRange:NSRange = NSMakeRange(0, textField.text!.characters.count)
        if (NSEqualRanges(range, textFieldRange) && string.characters.count == 0) {
            print("just became empty")
            self.momentTitle = ""
        }
        else{
            self.momentTitle = textField.text! + string
        }
        if self.momentTitle != "" && self.forCharm != nil{
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else{
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            if ((textView.superview?.isKindOfClass(TextViewTableViewCell)) != nil){
                print("text view responded")
                textView.resignFirstResponder()
                return false
            }
            return false
        }
        else{
            return true
        }
    }
    
    func charmGroupSelectButtonTapped(sender:UIButton){
        print("charmGroupSelectButtonTapped")
        // Push to charmGroupSelect TVC
         self.performSegueWithIdentifier("showCharmGroupPicker", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCharmGroupPicker"{
            ((segue.destinationViewController as! UINavigationController).childViewControllers[0] as! CharmGroupPickerTableViewController).charms = (UIApplication.sharedApplication().delegate as! AppDelegate).charmManager.charms
            ((segue.destinationViewController as! UINavigationController).childViewControllers[0] as! CharmGroupPickerTableViewController).momentComposerVC = self
        }
    }

    func mediaButtonTapped(){
        print("media button tapped")
        // Present Modal Media Picker
        
        print("addMediaButtonTapped")
        PHPhotoLibrary.requestAuthorization({(status) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                // code here
                let picker:CTAssetsPickerController = CTAssetsPickerController()
                picker.defaultAssetCollection = PHAssetCollectionSubtype.SmartAlbumUserLibrary

                // create options for fetching photo only
                let fetchOptions:PHFetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
                // assign options
                picker.assetsFetchOptions = fetchOptions;
                picker.view.tintColor = UIColor(red:0.95, green:0.09, blue:0.25, alpha:1)
                
                // to present picker as a form sheet in iPad
                picker.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                picker.selectedAssets = NSMutableArray(array: self.mediaAssets)
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            })
        })

    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        print(assets)
        let presentingVC = self //(picker.presentingViewController?.childViewControllers[0] as! NewStoryTabViewController)
        presentingVC.mediaAssets.appendContentsOf(assets as! [PHAsset])
        presentingVC.mediaDescriptions.appendContentsOf(Array(count: assets.count, repeatedValue: ""))
        presentingVC.tableViewController.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
        picker.dismissViewControllerAnimated(true, completion: {
            print(presentingVC.mediaAssets)
//            presentingVC.imageAssets = NSMutableArray(capacity: picker.selectedAssets.count)
        })
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, shouldSelectAsset asset: PHAsset!) -> Bool {
        if picker.selectedAssets.count < 15{
            return true
        }
        else{
            let alertVC = UIAlertController(title: "Upload Maximum Reached", message: "You can add up to 15 photos to each moment.", preferredStyle: UIAlertControllerStyle.Alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            picker.presentViewController(alertVC, animated: true, completion: nil)
            return false
        }
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        oldContentInset = self.tableViewController.tableView.contentInset
        if activeField != nil {
            let info = aNotification.userInfo as! [String: AnyObject],
            kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size,
            contentInsets = UIEdgeInsets(top: 53 + 64, left: 0, bottom: kbSize.height, right: 0)
            
            self.tableViewController.tableView.contentInset = contentInsets
            self.tableViewController.tableView.scrollIndicatorInsets = contentInsets
            
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            var aRect = self.view.frame
            aRect.size.height -= kbSize.height
            let indexPathForTextView:NSIndexPath = self.indexPathForCellContainingView(activeField!, inTableView: self.tableViewController.tableView)!
            self.tableViewController.tableView.scrollToRowAtIndexPath(indexPathForTextView, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        self.keyboardShown = true
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        //        let contentInsets = UIEdgeInsetsZero
        print("keyboard will hide")
        self.tableViewController.tableView.contentInset = oldContentInset
        self.tableViewController.tableView.scrollIndicatorInsets = oldContentInset
    }

    
    // Code by @hcatlin
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    // end code by @hcatlin

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView == self.tableViewController.tableView) && self.keyboardShown{
            print("hide keyboard")
            self.view.endEditing(true)
            self.keyboardShown = false
        }
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        if (scrollView == self.tableViewController.tableView){
            return true
        }
        else{
            return false
        }
    }
    
    func textViewDoneButtonTapped(sender:UIBarButtonItem){
        print("done button tapped")
        self.view.endEditing(true)   
    }
    
    func lockButtonTapped(){
        print("lock button tapped")
        // Present Modal Lock Options
        let lockNC = UINavigationController(rootViewController: LockMomentViewController())
        self.presentViewController(lockNC, animated: true, completion: nil)
    }
}
