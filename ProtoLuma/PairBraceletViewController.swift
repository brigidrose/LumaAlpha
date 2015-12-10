//
//  PairBraceletViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/4/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class PairBraceletViewController: UIViewController {

    var pairBraceletView:UIView!
    var pairBraceletButton:UIButton!
    var setupANCSButton:UIButton!
    var pairBraceletLabel:UILabel!
    var skipPairingLabel:UILabel!
    var skipPairingButton:UIButton!
    var braceletSerialNumber:String!
    var bracelet:MBLMetaWear!
    var metawearManager:MBLMetaWearManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.metawearManager = MBLMetaWearManager.sharedManager()
        
        self.pairBraceletView = TPKeyboardAvoidingScrollView(frame: self.view.frame)
        self.view.addSubview(self.pairBraceletView)
        
        let globalTintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor
        
        self.pairBraceletLabel = UILabel(frame: CGRectZero)
        self.pairBraceletLabel.translatesAutoresizingMaskIntoConstraints = false
        self.pairBraceletLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)
        self.pairBraceletLabel.textColor = UIColor.blackColor()
        self.pairBraceletLabel.textAlignment = NSTextAlignment.Center
        self.pairBraceletLabel.numberOfLines = 1
        self.pairBraceletLabel.text = "Please pair your Luma Bracelet with your iPhone."
        self.pairBraceletView.addSubview(self.pairBraceletLabel)
        
        self.pairBraceletButton = UIButton(frame: CGRectZero)
        self.pairBraceletButton.translatesAutoresizingMaskIntoConstraints = false
        self.pairBraceletButton.layer.borderWidth = 1
        self.pairBraceletButton.layer.borderColor = globalTintColor!.CGColor
        self.pairBraceletButton.layer.cornerRadius = 6
        self.pairBraceletButton.setTitle("Pair Bracelet", forState: UIControlState.Normal)
        self.pairBraceletButton.setTitleColor(globalTintColor, forState: UIControlState.Normal)
        self.pairBraceletButton.clipsToBounds = true
        self.pairBraceletButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.pairBraceletButton.titleLabel?.textColor = UIColor.whiteColor()
        self.pairBraceletButton.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightLight)
        self.pairBraceletButton.setBackgroundImage((UIApplication.sharedApplication().delegate as! AppDelegate)
            .imageWithColor(((UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor)!), forState: UIControlState.Highlighted)
        self.pairBraceletButton.addTarget(self, action: "pairBraceletButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.pairBraceletView.addSubview(self.pairBraceletButton)
        
        self.skipPairingButton = UIButton(frame: CGRectZero)
        self.skipPairingButton.translatesAutoresizingMaskIntoConstraints = false
        self.skipPairingButton.layer.borderWidth = 1
        self.skipPairingButton.layer.borderColor = globalTintColor!.CGColor
        self.skipPairingButton.layer.cornerRadius = 6
        self.skipPairingButton.setTitle("Skip For Now", forState: UIControlState.Normal)
        self.skipPairingButton.setTitleColor(globalTintColor, forState: UIControlState.Normal)
        self.skipPairingButton.clipsToBounds = true
        self.skipPairingButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.skipPairingButton.titleLabel?.textColor = UIColor.whiteColor()
        self.skipPairingButton.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightLight)
        self.skipPairingButton.setBackgroundImage((UIApplication.sharedApplication().delegate as! AppDelegate)
            .imageWithColor(((UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor)!), forState: UIControlState.Highlighted)
        self.skipPairingButton.addTarget(self, action: "skipPairingButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.pairBraceletView.addSubview(self.skipPairingButton)

        
        
        
        let viewsDictionary = ["pairBraceletLabel":self.pairBraceletLabel, "pairBraceletButton":self.pairBraceletButton, "skipPairingButton":self.skipPairingButton]
        
        let horizontalConstraint = NSLayoutConstraint(item: self.pairBraceletLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.pairBraceletView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|->=120-[pairBraceletLabel]-12-[pairBraceletButton(44)]-24-[skipPairingButton]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        let verticalConstraintsForButtons = NSLayoutConstraint.constraintsWithVisualFormat("V:[pairBraceletButton(44)]-24-[skipPairingButton(44)]", options: [NSLayoutFormatOptions.AlignAllLeft, NSLayoutFormatOptions.AlignAllRight], metrics: nil, views: viewsDictionary)

        let buttonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=0-[pairBraceletButton(>=280)]->=0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        self.pairBraceletView.addConstraint(horizontalConstraint)
        self.pairBraceletView.addConstraints(verticalConstraints)
        self.pairBraceletView.addConstraints(verticalConstraintsForButtons)
        self.pairBraceletView.addConstraints(buttonHorizontalConstraints)
        
        
        // button tapped to pair Bracelet
        // get user's Bracelet PFObject

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func skipPairingButtonTapped(sender:UIButton){
        self.performSegueWithIdentifier("RegisteredAndPaired", sender: self)
    }
    
    func pairBraceletButtonTapped(sender:UIButton){
        print("pairBraceletButton tapped")
        self.pairBraceletButton.enabled = false
        print(self.braceletSerialNumber)
        self.connectToBraceletOfSerialNumber(self.braceletSerialNumber)
    }
    

    func pairAndSetupANCS(){
        print("Pairing now!")

        self.bracelet.setConfiguration(BraceletSettings(), handler: {(error) -> Void in
            if(error != nil){
                print("pairing error")
                print(error)
            }else{
                print("bracelet configured")
                self.bracelet.rememberDevice()
                self.performSegueWithIdentifier("RegisteredAndPaired", sender: self)
            }
        })
    }
    
    // MARK: MetaWearManager Methods
    func connectToBraceletOfSerialNumber(serialNumber:String){
        self.bracelet = nil;
        print("connect to bracelet of serialnumber \(serialNumber)")
        self.metawearManager.retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!) -> Void in
            if (devices.count > 0){
                print("devices.count is greater than 0")
                for device in devices as! [MBLMetaWear]{
                    device.forgetDevice();
                }
            }
            print("forgot all.  scanning for new now.")
            self.metawearManager.startScanForMetaWearsAllowDuplicates(false, handler: {(devices:[AnyObject]!) -> Void in
                print("scanned for metawear")
                for device in devices as! [MBLMetaWear]{
                    // Loop connect to all devices and drop connection until matches bracelet on file, needs solution where ble advertises serialNumber
                    if (device.state == MBLConnectionState.Connected){
                        print("already connected to new bracelet")
                        self.bracelet = device
                        self.pairAndSetupANCS()
                    }
                    else{
                        device.connectWithHandler({(error) -> Void in
                            print("Connected")
                            if (error == nil){
                                print("connected to \(device.deviceInfo.serialNumber)")
                                if (device.deviceInfo.serialNumber == self.braceletSerialNumber){
                                    self.bracelet = device
                                    self.pairAndSetupANCS()
                                }
                                self.pairBraceletButton.enabled = true
                            }
                            else{
                                print(error)
                                self.pairBraceletButton.enabled = true
                            }
                        })
                    }
                }
            })

            
        })
        
    
    }

}
