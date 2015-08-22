//
//  ProtoLumaTabBarViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class ProtoLumaTabBarViewController: UITabBarController{

    var newTab:UIViewController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        let charmsTabBarItem:UITabBarItem = UITabBarItem(title: "Charms", image: UIImage(named: "CharmsTabBarIcon"), tag: 1)
//        let newStoryTabBarItem:UITabBarItem = UITabBarItem(title: "New", image: UIImage(named: "NewStoryTabBarIcon"), tag: 2)
//        let accountTabBarItem:UITabBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "AccountTabBarIcon"), tag: 3)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (tabBar.items?.indexOf(item) == 1){
            self.performSegueWithIdentifier("showNewStoryModal", sender: self)
//            self.presentViewController(NewStoryTabViewController(), animated: true, completion: nil)

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
