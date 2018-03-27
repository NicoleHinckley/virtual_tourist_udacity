//
//  CoreDataService.swift
//  VirtualTourist-Final
//
//  Created by E Nicole Hinckley on 3/26/18.
//  Copyright © 2018 E Nicole Hinckley. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {
    
    static let shared = CoreDataService(modelName: "VirtualTourist_Final")
   
    let persistantContainer : NSPersistentContainer
   
    var viewContext : NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    init(modelName : String ) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    func load(completion : (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (description, error) in
            guard error == nil else {
              fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
}
}
