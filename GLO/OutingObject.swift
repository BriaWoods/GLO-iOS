//
//  OutingObject.swift
//  GLO
//
//  Created by Stephen Looney on 8/18/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit
import CoreData

class OutingObject: NSManagedObject {
    
    @NSManaged var name:               String
    @NSManaged var outingID:           String
    @NSManaged var dateCreated:        NSTimeInterval
    
    @NSManaged var curfew:             NSTimeInterval
    @NSManaged var curfewTimeInterval: NSTimeInterval
    @NSManaged var outingCreator:      String
    
    @NSManaged var destinationLat:     NSNumber
    @NSManaged var destinationLon:     NSNumber
    
    // memberArray will not be necessary, because the real (updated) one I want is going to be on the server)
    //@NSManaged var memberArray:[String:Member] = [:]

}
