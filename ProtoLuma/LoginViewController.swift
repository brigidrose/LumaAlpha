//
//  LoginViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/30/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signupWithFB(sender: AnyObject) {
        print("signup with facebook tapped")
        (sender as! UIButton).enabled = false
        PFFacebookUtils.logInWithPermissions(["public_profile", "email"], block: {(user:PFUser?, error:NSError?) -> Void in
            print(error)
            if let user = user {
                if user.isNew {
                    if (PFFacebookUtils.session() != nil){
                        print("session not nil")
                        let parameters:NSMutableDictionary = NSMutableDictionary(dictionary: NSDictionary())
                        parameters.setValue("id,email,location,birthday,first_name,last_name,gender", forKey: "fields")
                        FBSDKGraphRequest(graphPath: "me", parameters: parameters as [NSObject : AnyObject], tokenString: PFFacebookUtils.session()?.accessTokenData.accessToken, version: "v2.0", HTTPMethod: "GET").startWithCompletionHandler({(connection, result, error) -> Void in
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
                                        (sender as! UIButton).enabled = true
                                    }
                                })
                            }
                        })
                    }
                    else{
                        print("token not nil")
                        
                    }
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                    // Check if logged-in user owns a bracelet
                    if (PFUser.currentUser()?["bracelet"] == nil){
                        // User doesn't own a bracelet, show BID registration
                        self.performSegueWithIdentifier("loggedInWithoutBracelet", sender: self)
                    }
                    else{
                        // User owns a bracelet, show Feed
                        self.performSegueWithIdentifier("loggedIn", sender: self)
                    }
                }

            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        })
    }
    

}
