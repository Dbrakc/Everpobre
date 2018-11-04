//
//  CLLocation+Operations.swift
//  Everpobre
//
//  Created by David Braga  on 03/11/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import CoreLocation

extension CLLocation{
    static func getCenter(ofLocations locations: [CLLocation]) -> CLLocation{
        return  CLLocation(latitude: locations.map{$0.coordinate.latitude}.reduce(0, +) / Double(locations.count), longitude: locations.map{$0.coordinate.longitude}.reduce(0,+) / Double(locations.count))
    }
    
    func farthestPoint (ofLocations locations: [CLLocation])->CLLocation?{
        let location = locations.sorted { $0.distance(from: self)>$1.distance(from: self)}.first
        return location
    }
}
