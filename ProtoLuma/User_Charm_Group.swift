//
//  User_Charm_Group.swift
//  ProtoLuma
//
//  Created by Chris on 1/8/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import Foundation

class User_Charm_Group: PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "User_Charm_Group"
    }
    
    @NSManaged var charmGroup: Charm_Group
    @NSManaged var user: User
    
    
}