//
//  Note+CoreDataClass.swift
//  Everpobre
//
//  Created by Charles Moncada on 09/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Note)
public class Note: NSManagedObject {

}

extension Note {

	func csv() -> String {
		let exportedTitle = title ?? "Sin Titulo"
		let exportedText = text ?? ""
        let exportedLatitude = coordinates?.latitude.description ?? ""
        let exportedLongitude = coordinates?.longitude.description ?? ""
        let exportedTags = tags ?? ""
		let exportedCreationDate = (creationDate as Date?)?.customStringLabel() ?? "ND"

        //hago el separator del csv por punto y coma para evitar que la
        //coma del formato de la fecha de problema en su exportación
        return "\(exportedCreationDate);\(exportedTitle);\(exportedText);\(exportedTags);\(exportedLatitude);\(exportedLongitude)\n"
	}
    
}

extension Note : MKAnnotation{
    public var coordinate: CLLocationCoordinate2D {
        guard let notesCoordinates = self.coordinates  else{
            return CLLocationCoordinate2D()
        }
        return notesCoordinates.wrapedInCLLocation().coordinate 
    }
    
    
}

extension Note {
    enum Tag : String {
        case Personal
        case Todo
        case Info
        case Otros
    }
}
