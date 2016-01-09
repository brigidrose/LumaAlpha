//
//  SetCharmGroupViewController.swift
//  ProtoLuma
//
//  Created by Chris on 1/5/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

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
        let charmGroup = Charm_Group()
        charmGroup.name = charmGroupName.text!
        charmGroup.saveInBackgroundWithBlock { (saved, error) -> Void in
            if error == nil {
                self.charm.charmGroup = charmGroup
                self.charm.saveInBackgroundWithBlock({ (saved, error) -> Void in
                    if error == nil {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        self.tabBarController?.selectedIndex = 0
                        print("tab bar index: \(self.tabBarController?.selectedIndex)")
                    }else{
                        print(error)
                    }
                })
            }else{
                print(error)
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
