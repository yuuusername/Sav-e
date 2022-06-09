//
//  MapViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 7/6/2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        // Check if location permission is granted
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Where map should focus on
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "locationSegue") {
            let destination = segue.destination as! LocationsTableViewController
            destination.mapViewController = self
        }
    }

}
