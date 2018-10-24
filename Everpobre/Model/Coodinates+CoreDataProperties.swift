//
//  Coodinates+CoreDataProperties.swift
//  Everpobre
//
//  Created by David Braga  on 24/10/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//
//

import Foundation
import CoreData


extension Coodinates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coodinates> {
        return NSFetchRequest<Coodinates>(entityName: "Coodinates")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension Coodinates {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}
