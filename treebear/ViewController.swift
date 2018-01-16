//
//  ViewController.swift
//  treebear
//
//  Created by Brandon Ng on 7/11/2017.
//  Copyright © 2017 Brandon Ng. All rights reserved.
//
import ARCL
import UIKit
import SceneKit
import MapKit
import Hero

class MKPointAnnotationWithID:MKPointAnnotation{
    let id: Int
    var markerTintColor: UIColor?
    
    init(id: Int, color: UIColor){
        self.id = id
        self.markerTintColor = color
    }
}

class ViewController: UIViewController,MKMapViewDelegate, UIGestureRecognizerDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var pan2AR: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var pan2Menu: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var view4EdgePan: UIView!
    @IBOutlet weak var view4EdgePan2Menu: UIView!
    
    var centerMapOnUserLocation: Bool = true
    var destination : LocationAnnotationNode?
    var locationManager:CLLocationManager!
    var centerMapBaseOnUserLocation: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        mapView.isHidden = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 1
        mapView.showsPointsOfInterest = false
        
        determineCurrentLocation()
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: 22.309454, longitude: 114.262633)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 100)
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = pinCoordinate
//        annotation.title = "TKO"
//        mapView.addAnnotation(annotation)
//        destination = LocationAnnotationNode(location: pinLocation, image: UIImage(named: "pin")!)
        
        let annotationWithID = MKPointAnnotationWithID(id: 15, color: .blue)
        annotationWithID.coordinate = pinCoordinate
        annotationWithID.title = "TKO"
        mapView.addAnnotation(annotationWithID)
        destination = LocationAnnotationNode(location: pinLocation, image: UIImage(named: "pin")!)
        
        view.addSubview(mapView)
        
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)
        view.addSubview(view4EdgePan)
        view.addSubview(view4EdgePan2Menu)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func swipeLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = pan2AR.translation(in: nil)
        let progress = CGFloat(translation.x / 2 / view.bounds.width)
        switch pan2AR.state {
        case .began:
            // begin the transition as normal
            Hero.shared.defaultAnimation = .slide(direction: .right)
            performSegue(withIdentifier: "main2AR", sender: self)
        case .ended:
            if progress + pan2AR.velocity(in: nil).x / view.bounds.width > 0.15 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        case .changed:
            Hero.shared.update(progress)
        default:
            _ = 1
        }
    }
    
    
    @IBAction func swipeRight(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = pan2Menu.translation(in: nil)
        let progress = CGFloat( -1 * translation.x / 2 / view.bounds.width)
        switch pan2Menu.state {
        case .began:
            // begin the transition as normal
            //            let story = UIStoryboard(name: "Main", bundle: nil)
            //            let arVC = story.instantiateViewController(withIdentifier: "ARVC")
            //            arVC.loadViewIfNeeded()
            Hero.shared.defaultAnimation = .slide(direction: .left)
            performSegue(withIdentifier: "main2Menu", sender: self)
        //testText.text = "test passed"
        case .ended:
            if progress + -1 * pan2Menu.velocity(in: nil).x / view.bounds.width > 0.15 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        case .changed:
            Hero.shared.update(progress)
        default:
            _ = 1
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "main2AR" && self.destination != nil {
            if let nextViewController = segue.destination as? ARViewController{
                nextViewController.destination = self.destination
            }
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        //when a annotation on click
        centerMapOnUserLocation = false
        centerMapWithLocationAndRange(Center: (view.annotation?.coordinate)!, Meters: 300)
        if ((view.tag) != 0)
        {
            print("User tapped on annotation: \(view.tag)")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if(annotation.isKind(of: MKUserLocation.self)) {
            return nil;
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? MKPointAnnotationWithID {
            annotationView?.markerTintColor = annotation.markerTintColor
            annotationView?.tag = annotation.id
        }
        
        annotationView?.animatesWhenAdded = true
        annotationView?.titleVisibility = .visible
        return annotationView
    }
    
    func centerMapWithLocationAndRange(Center: CLLocationCoordinate2D, Meters: Double){
        let region = MKCoordinateRegionMakeWithDistance(Center, Meters, Meters)
        
        mapView.setRegion(region, animated: true)
    }
    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        //manager.stopUpdatingLocation()
        
        if(centerMapOnUserLocation){
            centerMapWithLocationAndRange(Center:center, Meters:300)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

}

