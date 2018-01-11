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

class ViewController: UIViewController,MKMapViewDelegate, UIGestureRecognizerDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var pan2AR: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var pan2Menu: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var view4EdgePan: UIView!
    @IBOutlet weak var view4EdgePan2Menu: UIView!
    
    var centerMapOnUserLocation: Bool = true
    var destination : LocationAnnotationNode?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        mapView.isHidden = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 1
        mapView.showsPointsOfInterest = false
        //mapView.userTrackingMode = .follow
        
        let locationManager = CLLocationManager()
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: 22.309454, longitude: 114.262633)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 100)
//        let pinImage = UIImage(named: "pin")!
//        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinCoordinate
        annotation.title = "TKO"
        mapView.addAnnotation(annotation)
        destination = LocationAnnotationNode(location: pinLocation, image: UIImage(named: "pin")!)
        //        //centering the map

//        //getting user location
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        

//        var heading: CLLocationDirection?
//        var headingAccuracy: CLLocationDegrees?
//        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        locationManager.distanceFilter = kCLDistanceFilterNone
//        locationManager.headingFilter = kCLHeadingFilterNone
//        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.startUpdatingHeading()
//        locationManager.startUpdatingLocation()
//        locationManager.requestWhenInUseAuthorization()
        var userLocation = locationManager.location
        print(userLocation?.coordinate ?? -1)
       //let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//        mapView.addGestureRecognizer(longPress)
        
//        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//            let location = locations.last as! CLLocation
//
//            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            //let region = MKCoordinateRegionMakeWithDistance(center, 300, 300)
//
//            mapView.setCenter(center, animated: false)
//            print("changed location")
//        }

        
//        let adjustedRegion = mapView.regionThatFits(viewRegion)
//        mapView.setRegion(adjustedRegion, animated: true)
        
        //self.mapView.showsUserLocation = true;
        
        view.addSubview(mapView)
        
        //mapView.setRegion(viewRegion, animated: true)
        //view.addSubview(testText)
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)
        view.addSubview(view4EdgePan)
        view.addSubview(view4EdgePan2Menu)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 300, 300)
        mapView.setRegion(coordinateRegion, animated: true)
        //locationManager.stopUpdatingLocation()
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
//            let story = UIStoryboard(name: "Main", bundle: nil)
//            let arVC = story.instantiateViewController(withIdentifier: "ARVC")
//            arVC.loadViewIfNeeded()
            Hero.shared.defaultAnimation = .slide(direction: .right)
            performSegue(withIdentifier: "main2AR", sender: self)
            //testText.text = "test passed"
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
//    func mapView(_ mapView: MKMapView, didUpdate
//        userLocation: MKUserLocation) {
//        mapView.centerCoordinate = userLocation.location!.coordinate
//    }

}

