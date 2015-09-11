//
//  LoginViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/30/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var metawearManager:MBLMetaWearManager!
    var bracelet:PFObject!
    var loginWithFacebookButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.metawearManager = MBLMetaWearManager.sharedManager()
        
        self.loginWithFacebookButton = UIButton(frame: CGRectZero)
        self.loginWithFacebookButton.translatesAutoresizingMaskIntoConstraints = false
        self.loginWithFacebookButton.layer.borderWidth = 1
        self.loginWithFacebookButton.layer.borderColor = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor.CGColor
        self.loginWithFacebookButton.layer.cornerRadius = 6
        self.loginWithFacebookButton.setTitle("Login with Facebook", forState: UIControlState.Normal)
        self.loginWithFacebookButton.setTitleColor((UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor, forState: UIControlState.Normal)
        self.loginWithFacebookButton.clipsToBounds = true
        self.loginWithFacebookButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.loginWithFacebookButton.titleLabel?.textColor = UIColor.whiteColor()
        self.loginWithFacebookButton.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightLight)
        self.loginWithFacebookButton.setBackgroundImage((UIApplication.sharedApplication().delegate as! AppDelegate)
            .imageWithColor(((UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor)!), forState: UIControlState.Highlighted)
        self.loginWithFacebookButton.addTarget(self, action: "loginWithFacebookButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.loginWithFacebookButton)
        
        let viewsDictionary = ["loginWithFacebookButton":self.loginWithFacebookButton]
        
        let horizontalConstraint = NSLayoutConstraint(item: self.loginWithFacebookButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|->=120-[loginWithFacebookButton(44)]->=200-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        let buttonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=0-[loginWithFacebookButton(>=280)]->=0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        self.view.addConstraint(horizontalConstraint)
        self.view.addConstraints(verticalConstraints)
        self.view.addConstraints(buttonHorizontalConstraints)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginWithFacebookButtonTapped(sender:UIButton){
        print("signup with facebook tapped")
        sender.enabled = false
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"], block: {(user:PFUser?, error:NSError?) -> Void in
            print(error)
            if let user = user {
                if user.isNew {
                    if (FBSDKAccessToken.currentAccessToken() != nil){
                        print("token not nil")
                        let parameters:NSMutableDictionary = NSMutableDictionary(dictionary: NSDictionary())
                        parameters.setValue("id,email,location,birthday,first_name,last_name,gender", forKey: "fields")
                        FBSDKGraphRequest(graphPath: "me", parameters: parameters as [NSObject : AnyObject], tokenString: FBSDKAccessToken.currentAccessToken().tokenString, version: "v2.0", HTTPMethod: "GET").startWithCompletionHandler({(connection, result, error) -> Void in
                            print("graph requested")
                            if (error == nil){
                                let user = result as! NSDictionary
                                PFUser.currentUser()!.email = user.objectForKey("email") as? String
                                let birthdayString:String = user.objectForKey("birthday") as! String
                                let dateFormatter = NSDateFormatter()
                                if (birthdayString.characters.count == 10){
                                    dateFormatter.dateFormat = "MM/dd/yyyy"
                                }
                                else if birthdayString.characters.count == 4{
                                    dateFormatter.dateFormat = "yyyy"
                                }
                                else if birthdayString.characters.count == 5{
                                    dateFormatter.dateFormat = "MM/dd"
                                }
                                let birthday:NSDate = dateFormatter.dateFromString(birthdayString)!
                                PFUser.currentUser()?["facebookId"] = user.objectForKey("id")
                                PFUser.currentUser()?["birthday"] = birthday
                                PFUser.currentUser()?["firstName"] = user.objectForKey("first_name")
                                PFUser.currentUser()?["lastName"] = user.objectForKey("last_name")
                                PFUser.currentUser()?["gender"] = user.objectForKey("gender")
                                let locationDictionary = user.objectForKey("location") as! NSDictionary
                                PFUser.currentUser()?["location"] = locationDictionary["name"]
                                PFUser.currentUser()?.saveInBackgroundWithBlock({(success, error) -> Void in
                                    if (success){
                                        self.performSegueWithIdentifier("loggedInWithoutBracelet", sender: self)
                                    }
                                    else{
                                        print(error)
                                        sender.enabled = true
                                    }
                                })
                            }
                        })
                    }
                    else{
                        print("token is nil")
                        
                    }
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                    PFInstallation.currentInstallation()["currentUser"] = PFUser.currentUser()
                    PFInstallation.currentInstallation().saveInBackgroundWithBlock({(success, error) -> Void in
                        print("current user saved to current installation")
                        // Check if logged-in user owns a bracelet
                        print(PFUser.currentUser()?["bracelet"])
                        if (PFUser.currentUser()?["bracelet"] == nil){
                            // User doesn't own a bracelet, show BID registration
                            self.performSegueWithIdentifier("loggedInWithoutBracelet", sender: self)
                        }
                        else{
                            // User owns a bracelet, show Feed
                            self.performSegueWithIdentifier("loggedIn", sender: self)
                            // FOLLOWING BLOCK ENABLES CHECK FOR CONNECTION TO REGISTERED METAWEAR DEVICE BEFORE PRESENTING CORE APP INTERFACE
                            //                        self.metawearManager.startScanForMetaWearsAllowDuplicates(true, handler: {(devices:[AnyObject]!) -> Void in
                            //                            for device in devices as! [MBLMetaWear]{
                            //                                device.connectWithHandler({(error) -> Void in
                            //
                            //                                    PFUser.currentUser()!["bracelet"]?.fetchInBackgroundWithBlock({(object, error) -> Void in
                            //                                        if (error == nil){
                            //                                            print(PFUser.currentUser())
                            //                                            print(PFUser.currentUser()!["bracelet"])
                            //                                            self.bracelet = object! as PFObject
                            //                                            if ((self.bracelet["serialNumber"] as! String) == device.deviceInfo.serialNumber){
                            //                                                device.rememberDevice()
                            //                                                self.performSegueWithIdentifier("loggedIn", sender: self)
                            //                                            }
                            //                                            else{
                            //                                                device.forgetDevice()
                            //                                                device.disconnectWithHandler({(error) -> Void in
                            //                                                    print("non-matching metawear disconnected")
                            //                                                })
                            //                                            }
                            //                                        }
                            //                                        else{
                            //                                            print(error)
                            //                                        }
                            //                                    })
                            //                                })
                            //                            }
                            //                        })
                        }
                        
                    })
                }
                
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        })
    }
}
