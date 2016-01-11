//
//  Story_Unit.swift
//  ProtoLuma
//
//  Created by Chris on 1/10/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import Foundation

class Story_Unit: PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Story_Unit"
    }
    
    @NSManaged var file: PFFile?
    
}