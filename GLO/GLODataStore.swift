//
//  GLODataStore.swift
//  GLO
//
//  Created by Stephen Looney on 8/18/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit
import CoreData

class GLODataStore: NSObject {
    
    static let sharedInstance = GLODataStore()
    
    var context:NSManagedObjectContext!
    var model:NSManagedObjectModel!
    
    var currentOutings:[OutingObject] = []
    
    
    override init() {
        print ("GLO Datastore Swift Singleton Reporting for Duty")
        
        model = NSManagedObjectModel.mergedModelFromBundles(nil)
        
        super.init()
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let path = self.itemArchivePath()
        print("Archive path: ", path)
        let storeURL = NSURL.fileURLWithPath(path)
        
        print("StoreURL: ", storeURL)
        
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options:nil)
        } catch {
            print(error)
            fatalError("error adding persistent store")
        }
        
        // Create the managed object context
        context = NSManagedObjectContext.init(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        // The managed object context can manage undo, but we don't neet it
        context.undoManager = nil
        
        // Add in a fetch request template that I can call elsewhere in the class
        
        self.loadCurrentOutings()
    }
    
    func itemArchivePath() -> String {
        var documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentDirectory:String = documentDirectories[documentDirectories.endIndex - 1]
        print("Document Directory", documentDirectory)
        
        if (Platform.isSimulator) {
            print("Running in the simulator")
            return documentDirectory.stringByAppendingString("store.sqlite")
        } else {
            print("Running on a device");
            return documentDirectory.stringByAppendingString("/store.sqlite")
        }

    }
    
    
    func createOuting() -> (OutingObject) {
        
        
        let outing = NSEntityDescription.insertNewObjectForEntityForName("OutingObject", inManagedObjectContext: context) as? OutingObject
        
        print("Yeeehaw CoreData here we come!")
        
        
        outing!.dateCreated = NSDate.timeIntervalSinceReferenceDate()
        outing!.outingID = NSUUID.init().UUIDString
        currentOutings.append(outing!)
        
        return outing!
    }
    
    
    func loadCurrentOutings() {
        
        if (currentOutings.count == 0) {
            let request = NSFetchRequest.init()
            let e = model.entitiesByName["OutingObject"]
            request.entity = e
            
            let sd = NSSortDescriptor.init(key: "curfew", ascending: false)
            request.sortDescriptors = [sd]
            var result = []
            
            do {
                result = try context.executeFetchRequest(request)
            } catch {
                fatalError("Failed loading all objects because I don't know.")
            }
            
            currentOutings = result as! [OutingObject]
            print("All outings result HERE GUYZ: ", currentOutings)
        }
        
    }
    
    
    func saveChanges() -> (Bool) {
        
        do {
            try context.save()
        } catch {
            print(error)
            fatalError("Failure to save context: \(error)")
        }
        return true
    }

}

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
