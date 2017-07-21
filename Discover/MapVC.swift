//
//  MapVC.swift
//  Discover
//
//  Created by Trevor Rose on 7/20/17.
//  Copyright © 2017 Trevor Rose. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapVC: UIViewController, CLLocationManagerDelegate {

    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    let uid = Auth.auth().currentUser?.uid
    var currentLocation: CLLocation? = nil
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
           print("Services not enabled")
        }
        
        geoFireRef = Database.database().reference().child("userLocations")
        geoFire = GeoFire(firebaseRef: geoFireRef)
    }
    func setLocation(forLocation location: CLLocation) {
        geoFire.setLocation(location, forKey: uid)
    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
                mapView.setRegion(viewRegion, animated: false)
                
                let center = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
                // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
                let circleQuery = geoFire.query(at: center, withRadius: 0.6)
                
                _ = circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                    print("Key '\(key)' entered the search area and is at location '\(location)'")
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    self.mapView.addAnnotation(annotation)
                })
                
                geoFire.setLocation(userLocation, forKey: uid)
            }
        }
    }
}
