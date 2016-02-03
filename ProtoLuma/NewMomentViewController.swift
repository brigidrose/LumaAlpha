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

class NewMomentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, CTAssetsPickerControllerDelegate, UIScrollViewDelegate{

    var tableViewController:UITableViewController!
    var toolBarBottom:UIToolbar!
    var storyUnits = NSMutableArray()
    
    var charmGroupSelectView:UIView!
    
    var mediaAssets:[PHAsset] = []
    var mediaDescriptions:[String] = []
    var imageAssets:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Moment"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "closeButtonTapped")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Done, target: self, action: "sendButtonTapped:")
        self.tableViewController = UITableViewController()
        self.addChildViewController(self.tableViewController)
        self.tableViewController.tableView = TPKeyboardAvoidingTableView(frame: CGRectZero)
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
        let mediaToolBarItem = UIBarButtonItem(image: UIImage(named: "NewStoryBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "mediaButtonTapped")
        let lockToolBarItem = UIBarButtonItem(image: UIImage(named: "NewStoryBarButtonIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "lockButtonTapped")
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
        charmImagePreviewImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        charmGroupSelectButton.addSubview(charmImagePreviewImageView)

        let charmGroupTitleLabel = UILabel(frame: CGRectZero)
        charmGroupTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        charmGroupTitleLabel.text = "Charm Group Title Label"
        charmGroupTitleLabel.textAlignment = NSTextAlignment.Left
        charmGroupTitleLabel.numberOfLines = 1
        charmGroupSelectButton.addSubview(charmGroupTitleLabel)

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

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.becomeFirstResponder()
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
                cell.textView.placeholder = "Description (Optional)"
                cell.textView.delegate = self
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("MomentMediaTableViewCell") as! MomentMediaTableViewCell

//            cell.mediaCaptionTextView.delegate = self
            (((cell.mediaCaptionTextView.inputAccessoryView as! UIToolbar).items!)[1].target = self)
            (((cell.mediaCaptionTextView.inputAccessoryView as! UIToolbar).items!)[1].action = "textViewDoneButtonTapped:")
            cell.mediaCaptionTextView.placeholder = "Description (Optional)"
            cell.mediaCaptionTextView.text = self.mediaDescriptions[indexPath.row]
//            cell.mediaCaptionTextView.delegate = self
            cell.mediaPreviewImageView.backgroundColor = nil
          
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

            if (self.imageAssets.count > indexPath.row){
                cell.mediaPreviewImageView.image = self.imageAssets.objectAtIndex(indexPath.row) as? UIImage
            }
            else{
                manager.requestImageForAsset(asset, targetSize: CGSizeMake(1200, 1200), contentMode: PHImageContentMode.Default, options: options, resultHandler:{(image:UIImage?, info:[NSObject:AnyObject]?) -> Void in
                    // this result handler is called on the main thread for asynchronous requests
                    self.imageAssets.insertObject(image!, atIndex: indexPath.row)
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                })
            }
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
    
    func sendButtonTapped(sender:UIBarButtonItem){
        sender.enabled = false
        self.createMomentFromForm()
    }
    
    func createMomentFromForm(){
        self.saveMoment()
    }
    
    func saveMoment(){
        // if successful
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    

    
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
            print("yoooo")
            (self.tableViewController.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TextViewTableViewCell).textView.becomeFirstResponder()
        }
        return false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
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
        presentingVC.tableViewController.tableView.reloadData()
        picker.dismissViewControllerAnimated(true, completion: {
            print(presentingVC.mediaAssets)
        })
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
        if scrollView == self.tableViewController.tableView{
            self.view.endEditing(true)
        }
    }
    
    func textViewDoneButtonTapped(sender:UIBarButtonItem){
        print("done button tapped")
        self.view.endEditing(true)   
    }
    
    func lockButtonTapped(){
        print("lock button tapped")
        // Present Modal Lock Options
    }
}
