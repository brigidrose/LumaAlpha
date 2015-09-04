//
//  PairBraceletViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/4/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class PairBraceletViewController: UIViewController {

    var pairBraceletView:UIView!
    var pairBraceletButton:UIButton!
    var setupANCSButton:UIButton!
    var pairBraceletLabel:UILabel!
    var braceletSerialNumber:String!
    var bracelet:MBLMetaWear!
    var metawearManager:MBLMetaWearManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.metawearManager = MBLMetaWearManager.sharedManager()
        
        self.pairBraceletView = TPKeyboardAvoidingScrollView(frame: self.view.frame)
        self.view.addSubview(self.pairBraceletView)
        
        self.pairBraceletLabel = UILabel(frame: CGRectZero)
        self.pairBraceletLabel.translatesAutoresizingMaskIntoConstraints = false
        self.pairBraceletLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)
        self.pairBraceletLabel.textColor = UIColor(red:0.83, green:0.75, blue:0.63, alpha:1)
        self.pairBraceletLabel.textAlignment = NSTextAlignment.Center
        self.pairBraceletLabel.numberOfLines = 1
        self.pairBraceletLabel.text = "Please pair your Luma Bracelet with your iPhone."
        self.pairBraceletView.addSubview(self.pairBraceletLabel)
        
        self.pairBraceletButton = UIButton(frame: CGRectZero)
        self.pairBraceletButton.translatesAutoresizingMaskIntoConstraints = false
        self.pairBraceletButton.layer.borderWidth = 1
        self.pairBraceletButton.layer.borderColor = UIColor(red:0.83, green:0.75, blue:0.63, alpha:1).CGColor
        self.pairBraceletButton.layer.cornerRadius = 6
        self.pairBraceletButton.setTitle("Pair Bracelet", forState: UIControlState.Normal)
        self.pairBraceletButton.setTitleColor(UIColor(red:0.83, green:0.75, blue:0.63, alpha:1), forState: UIControlState.Normal)
        self.pairBraceletButton.titleLabel?.textColor = UIColor.whiteColor()
        self.pairBraceletButton.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightLight)
        self.pairBraceletButton.addTarget(self, action: "pairBraceletButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.pairBraceletView.addSubview(self.pairBraceletButton)
        
        let viewsDictionary = ["pairBraceletLabel":self.pairBraceletLabel, "pairBraceletButton":self.pairBraceletButton]
        
        let horizontalConstraint = NSLayoutConstraint(item: self.pairBraceletLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.pairBraceletView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|->=120-[pairBraceletLabel]-12-[pairBraceletButton(40)]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        let buttonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=0-[pairBraceletButton(>=280)]->=0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        self.pairBraceletView.addConstraint(horizontalConstraint)
        self.pairBraceletView.addConstraints(verticalConstraints)
        self.pairBraceletView.addConstraints(buttonHorizontalConstraints)
        
        
        // button tapped to pair Bracelet
        // get user's Bracelet PFObject

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pairBraceletButtonTapped(sender:UIButton){
        print("pairBraceletButton tapped")
        self.connectToBraceletOfSerialNumber(self.braceletSerialNumber)
    }
    

    func pairAndSetupANCS(){
        print(self.bracelet.state.rawValue)
        self.bracelet.connectWithHandler({(error) -> Void in
            if (error == nil){
                self.bracelet.setConfiguration(BraceletSettings(), handler: {(error) -> Void in
                    print("bracelet configured")
                    self.bracelet.rememberDevice()
                    self.performSegueWithIdentifier("RegisteredAndPaired", sender: self)
                })
            }
            else{
                print(error)
            }
        })
    }
    
    // MARK: MetaWearManager Methods
    func connectToBraceletOfSerialNumber(serialNumber:String){
        self.metawearManager.retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!) -> Void in
            if (devices.count > 0){
                self.bracelet = devices[0] as! MBLMetaWear
            }
            else{
                self.metawearManager.startScanForMetaWearsAllowDuplicates(false, handler: {(devices:[AnyObject]!) -> Void in
                    print(devices.count)
                    for device in devices as! [MBLMetaWear]{
                        // Loop connect to all devices and drop connection until matches bracelet on file, needs solution where ble advertises serialNumber
                        print(device)
                        if (device.state == MBLConnectionState.Connected){
                            print("already connected to new bracelet")
                        }
                        else{
                            self.bracelet = device
                            self.pairAndSetupANCS()
                            //                    device.connectWithHandler({(error) -> Void in
                            //                        print("Connected")
                            //                        if (error == nil){
                            //                            print("connected to \(device)")
                            //                            if (device.deviceInfo.serialNumber == self.braceletSerialNumber){
                            //                                self.bracelet = device
                            //                                self.pairAndSetupANCS()
                            //                                self.bracelet.rememberDevice()
                            //                            }
                            //                        }
                            //                        else{
                            //                            print(error)
                            //                        }
                            //                    })
                        }
                    }
                })
            }
        })
    }
    


}
