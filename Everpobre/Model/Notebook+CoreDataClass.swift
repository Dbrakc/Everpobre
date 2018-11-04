//
//  Notebook+CoreDataClass.swift
//  Everpobre
//
//  Created by David Braga  on 24/10/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

@objc(Notebook)
public class Notebook: NSManagedObject {
    
    var center : CLLocation {
        return  CLLocation.getCenter(ofLocations: getArrayOfLocations())
    }
    
    var radius : CLLocationDistance? {
        let locations = getArrayOfLocations()
        guard let farthestPoint = self.center.farthestPoint(ofLocations: locations) else { return nil }
        return CLLocationDistance(exactly: 1.5 * self.center.distance(from: farthestPoint))
    }
    
    private func getArrayOfLocations () -> [CLLocation]{
        return ((self.notes?.array as? [Note]) ?? []).map{$0.coordinates?.wrapedInCLLocation()}.compactMap{return $0}
    }

}
