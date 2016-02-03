//
//  CharmManager.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 2/2/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmManager {

    static let sharedManager = CharmManager()
    var charms = [Charm]()
    
    private init() {
        self.loadCharms()
    }
    
    
    func loadCharms(){
        let queryForCharms = PFQuery(className: "Charm")
        queryForCharms.whereKey("owner", equalTo: PFUser.currentUser()!)
        queryForCharms.includeKey("charmGroup")
        queryForCharms.whereKeyExists("charmGroup")
        
        queryForCharms.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if error == nil{
                self.charms = objects as! [Charm]
                print("\(self.charms.count) charms retrieved")
                
                //reset scheduled moments flags
                for charm in self.charms {
                    charm.hasScheduledMoments = false
                }
                
                PFCloud.callFunctionInBackground("getCharmGroupsWithScheduledMomentInfo", withParameters: nil) { (response, error) -> Void in
                    if error == nil{
                        print("charmGroupsWithLockedStories moments response: \(response)")
                        if response!["charms"] != nil {
                            let charmGroupsWithScheduledMoments = response!["charmGroupsWithLockedStories"] as! [Charm_Group]
                            for charmGroup in charmGroupsWithScheduledMoments {
                                for charm in self.charms {
                                    if charm.charmGroup!.objectId == charmGroup.objectId {
                                        charm.hasScheduledMoments = true
                                    }
                                }
                            }
                            print("has charms: \(self.charms)")
                        }
                    }else{
                        print(error)
                        ParseErrorHandlingController.handleParseError(error)
                    }
                    
                }
                
//                self.populateCharmsAndEnableBarItems();
                
                //load all profile photos in the background
//                self.loadProfilePhotos()
                
                
            }else{
                print(error)
                ParseErrorHandlingController.handleParseError(error)
            }
        })

    }
}
