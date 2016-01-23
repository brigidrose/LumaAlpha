//
//  BraceletSettings.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/3/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class BraceletSettings: NSObject, MBLRestorable {

    var notifications:NSMutableArray!
    
    override init() {
        super.init()
        self.notifications = NSMutableArray()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.notifications = aDecoder.decodeObjectForKey("notifications") as! NSMutableArray
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.notifications, forKey: "notifications")
    }
    
    func runOnDeviceBoot(device: MBLMetaWear) {


        let event5:MBLEvent = device.ancs!.eventWithCategoryIds(MBLANCSCategoryID.Any, eventIds: MBLANCSEventID.NotificationAdded, eventFlags: MBLANCSEventFlag.Any, attributeId: MBLANCSNotificationAttributeID.AppIdentifier, attributeData: "com.lumalegacy.Luma")
        event5.programCommandsToRunOnEventAsync({
            device.led?.flashLEDColorAsync(UIColor.blueColor(), withIntensity: 1.0, numberOfFlashes: 3)
            device.hapticBuzzer?.startHapticWithDutyCycleAsync(255, pulseWidth: 500, completion: nil)
//            let length:UInt8 = 7; // Specific to your NeoPixel stand
//            let color:MBLColorOrdering = MBLColorOrdering.GRB; // Specific to your NeoPixel stand
//            let speed:MBLStrandSpeed = MBLStrandSpeed.Slow; // Specific to your NeoPixel stand
//            
//            let strand:MBLNeopixelStrand = device.neopixel.strandWithColor(color, speed: speed, pin: 0, length: length);
//            
//            
//            for(var i:UInt8 = 0; i < 100; i++){
//                strand.setPixel(i % length, color: UIColor.redColor())
//                strand.turnStrandOff()
//            }
        })

        
        let event2:MBLEvent = device.mechanicalSwitch!.switchUpdateEvent
        event2.programCommandsToRunOnEventAsync({
            device.led?.flashLEDColorAsync(UIColor.redColor(), withIntensity: 1.0, numberOfFlashes: 3)
        })
    }
    
}
