//
//  Coodinates+CoreDataClass.swift
//  Everpobre
//
//  Created by David Braga  on 24/10/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

@objc(Coodinates)
public class Coodinates: NSManagedObject {
    func wrapedInCLLocation () -> CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    
    

}
