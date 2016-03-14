//
//  Stop.swift
//  iTinerary
//
//  Created by Mikhail George on 3/13/16.
//  Copyright © 2016 Mikhail George. All rights reserved.
//

import Foundation
import UIKit
import MapKit


// MODEL: - A Point on earth

struct Point {
    
    // MARK: - Properties
    
    var lat: Double
    var long: Double
    
    init(_ lat: Double, _ long: Double) {
        self.lat = lat
        self.long = long
    }
}


// MODEL: - A sightseeing destination

struct viewLocation {
    
    // MARK: - Properties
    
    var name: String
    var description: String
    var coordinate: Point
    
    // Coordinates for map
    var mapCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))
    }
}


// MODEL: - A hotel/motel/airbnb

struct sleepLocation {
    
    // MARK: - Properties
    
    var name: String?
    var address: String?
    var nights: Int?
    var coordinate: Point
    
    // Coordinates for map
    var mapCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))
    }
}


// UTILITY: - Comparing sightseeing destinations

extension viewLocation: Equatable {}

func ==(lhs: viewLocation, rhs: viewLocation) -> Bool {
    let lhs_coord = lhs.coordinate
    let rhs_coord = rhs.coordinate
    return fabs(lhs_coord.lat - lhs_coord.lat) <= 0.1 && fabs(rhs_coord.long - rhs_coord.long) <= 0.1
}



// MODEL: - A stop along the travel route

class travelLocation {
    
    // MARK: - Properties
    
    var order: Int
    var name: String
    var city: String?
    var state: String?
    var country: String?
    var coordinate: Point
    
    // Coordinates for map
    var mapCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))
    }
    
    // Lists of sights and rest places at stop
    var viewLocations = [viewLocation]()
    var sleepLocations = [sleepLocation]()
    
    
    // MARK: - Initializors
    
    init(stopName name: String, coordinate: Point, travelIndex order: Int) {
        self.name = name
        self.coordinate = coordinate
        self.order = order
    }
    
    init(city: String, state: String? = nil, country: String, coordinate: Point, travelIndex order: Int) {
        self.city = city
        self.state = state
        self.country = country
        self.coordinate = coordinate
        self.order = order
        
        if let state_name = state {
            self.name = "\(city), \(state_name) \(country)"
        } else {
            self.name = "\(city), \(country)"
        }
        
        
    }
    
    
    // MARK: - Methods
    
    func addViewLocation(name: String, description: String, coordinate: Point) -> Bool {
        let newViewLocation = viewLocation(name: name, description: description, coordinate: coordinate)
        
        if !(viewLocations.contains{$0==newViewLocation}) {
            viewLocations.append(newViewLocation)
            return true
        } else {
            return false
        }
    }
    
    func addSleepLocation(name: String, address: String? = nil, nights: Int, coordinate: Point) -> Bool {
        
        let newSleepLocation = sleepLocation(name: name, address: address, nights: nights, coordinate:coordinate)
        sleepLocations.append(newSleepLocation)
        return true
    }
    
    
}


