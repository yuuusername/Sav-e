//
//  LocationAnnotation.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 7/6/2022.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var supermarket: String?
    var distance: Double?
    
    init(title: String, subtitle: String, supermarket: String, lat: Double, long: Double, distance: Double!) {
        self.title = title
        if supermarket == "w" {
            self.subtitle = "Woolworths Open: \(subtitle)"
        } else {
            self.subtitle = "IGA Open: \(subtitle)"
        }
        self.supermarket = supermarket
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.distance = distance
    }
}
