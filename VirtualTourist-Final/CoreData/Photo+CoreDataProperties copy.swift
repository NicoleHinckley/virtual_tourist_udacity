//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by E Nicole Hinckley on 3/26/18.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var downloadURL: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var pin: Pin?

}
