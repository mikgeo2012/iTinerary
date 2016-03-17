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
import Contacts


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
    var address: String
    var coordinate: Point
    var mapCoordinate: CLLocationCoordinate2D?
    
    // Coordinates for map
    /*var mapCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))
    }*/
}


// MODEL: - A hotel/motel/airbnb

struct sleepLocation {
    
    // MARK: - Properties
    
    var name: String?
    var address: String?
    var nights: Int?
    var coordinate: Point
    var mapCoordinate: CLLocationCoordinate2D?
    
    // Coordinates for map
    /*var mapCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))
    }*/
}


// UTILITY: - Comparing sightseeing destinations

extension viewLocation: Equatable {}

func ==(lhs: viewLocation, rhs: viewLocation) -> Bool {
    let lhs_coord = lhs.coordinate
    let rhs_coord = rhs.coordinate
    return fabs(lhs_coord.lat - lhs_coord.lat) <= 0.1 && fabs(rhs_coord.long - rhs_coord.long) <= 0.1
}


// MODEL: - Annotations

class viewAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    
    init(title: String, description subtitle: String, address locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.subtitle = subtitle
        
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): locationName as AnyObject]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
}

class sleepAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    
    init(title: String, nights subtitle: String, address locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.subtitle = subtitle + " night(s)"
        self.coordinate = coordinate
        
        
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): locationName as AnyObject]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
}



// MODEL: - A stop along the travel route

class travelLocation {
    
    // MARK: - Properties
    
    var name: String
    var city: String?
    var state: String?
    var country: String?
    var coordinate: Point
    var mapCoordinate: CLLocationCoordinate2D
    
    // Coordinates for map
    /*var mapCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))
    }*/
    
    // Lists of sights and rest places at stop
    var viewLocations = [viewLocation]()
    var sleepLocations = [sleepLocation]()
    
    
    // MARK: - Initializors
    
    init(stopName name: String, coordinate: Point) {
        self.name = name
        self.coordinate = coordinate
        self.mapCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))
    }
    
    init(stopName name: String, mapCoordinate: CLLocationCoordinate2D) {
        self.name = name
        self.mapCoordinate = mapCoordinate
        self.coordinate = Point(mapCoordinate.latitude, mapCoordinate.longitude)
    }
    
    init(city: String, state: String? = nil, country: String, coordinate: Point) {
        self.city = city
        self.state = state
        self.country = country
        self.coordinate = coordinate
        
        if let state_name = state {
            self.name = "\(city), \(state_name) \(country)"
        } else {
            self.name = "\(city), \(country)"
        }
        
        self.mapCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))

    }
    
    
    // MARK: - Methods
    
    func addViewLocation(name: String, description: String, address: String? = nil, coordinate: Point) {
        let newViewLocation = viewLocation(name: name, description: description, address: address!,coordinate: coordinate, mapCoordinate: convertPointToMapCoord(coordinate))
        viewLocations.append(newViewLocation)
    }
    
    func addSleepLocation(name: String, address: String? = nil, nights: Int, coordinate: Point) {
        
        let newSleepLocation = sleepLocation(name: name, address: address, nights: nights, coordinate:coordinate, mapCoordinate: convertPointToMapCoord(coordinate))
        sleepLocations.append(newSleepLocation)
        
    }
    
    func convertPointToMapCoord(coordinate: Point) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate.lat), longitude: CLLocationDegrees(coordinate.long))
    }
    
    
}


