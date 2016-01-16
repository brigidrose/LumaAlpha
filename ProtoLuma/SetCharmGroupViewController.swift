//
//  SetCharmGroupViewController.swift
//  ProtoLuma
//
//  Created by Chris on 1/5/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit
import MBProgressHUD

class SetCharmGroupViewController: UIViewController {

    @IBOutlet var charmGroupName: UITextField!
    var charm:Charm!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createCharmGroupPressed(sender: AnyObject) {
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.labelText = "Saving..."
        let charmGroup = Charm_Group()
        charmGroup.name = charmGroupName.text!
        charmGroup.saveInBackgroundWithBlock { (saved, error) -> Void in
            if error == nil {
                self.charm.charmGroup = charmGroup
                self.charm.saveInBackgroundWithBlock({ (saved, error) -> Void in
                    if error == nil {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        (UIApplication.sharedApplication().delegate as! AppDelegate).tabBarController.selectedIndex = 0
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    }else{
                        print(error)
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        ParseErrorHandlingController.handleParseError(error)
                    }
                })
            }else{
                print(error)
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                ParseErrorHandlingController.handleParseError(error)
            }
        }
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
