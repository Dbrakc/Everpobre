//
//  Note+CoreDataProperties.swift
//  Everpobre
//
//  Created by David Braga  on 24/10/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var lastSeenDate: NSDate?
    @NSManaged public var tags: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var coordinates: Coodinates?
    @NSManaged public var notebook: Notebook?

}
