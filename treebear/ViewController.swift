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
    var locationNodes = [LocationAnnotationNode]()
    var polylines = [MKPolyline]()
    fileprivate var coordinatesInPress = [CLLocationCoordinate2D]()
    
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
        
        
//        let annotationWithID = MKPointAnnotationWithID(id: 15, color: .blue)
//        annotationWithID.coordinate = pinCoordinate
//        annotationWithID.title = "TKO"
//        mapView.addAnnotation(annotationWithID)
        destination = LocationAnnotationNode(location: pinLocation, image: UIImage(named: "pin")!)
        addPOI(id: 1500, color: .blue,coordinate: pinCoordinate)
        view.addSubview(mapView)
        
        // Long press to add POI
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPress)
        
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)
        view.addSubview(view4EdgePan)
        view.addSubview(view4EdgePan2Menu)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        determineCurrentLocation()
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
                nextViewController.locationNodes = self.locationNodes
                nextViewController.polylines = self.polylines
            }
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        //when a annotation on click
        centerMapOnUserLocation = false
        centerMapWithLocationAndRange(Center: (view.annotation?.coordinate)!, Meters: 300)
        if(view.annotation?.isKind(of: MKUserLocation.self))!{
            centerMapOnUserLocation = true
        }
        if ((view.tag) != 0)
        {
            print("User tapped on annotation: \(view.tag)")
            mapView.removeOverlays(mapView.overlays)
            self.polylines.removeAll()
            self.getDirections(start: (locationManager.location?.coordinate)!,end: (view.annotation?.coordinate)!){(route) in
                self.addPolyline(polyline: route.polyline)
                print("Distance: ",route.distance)
                print("Estimated travel time: ",route.expectedTravelTime)
//                var boundingbox = route.polyline.boundingMapRect
//                boundingbox.size.height += Double(mapView.bounds.height)
//                boundingbox.size.width += Double(mapView.bounds.width)
//                self.mapView.setVisibleMapRect(boundingbox, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views{
            if(view.annotation?.isKind(of: MKUserLocation.self))!{
                view.canShowCallout = false
            }
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineWidth = 5
            renderer.strokeColor = .blue
            renderer.fillColor = .blue
            return renderer
            
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
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
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
        //print("Long Press")
        
        switch recognizer.state {
        case .possible: break
        case .began:    coordinatesInPress = [coordinate]
                        //print(coordinatesInPress)
        case .changed:  coordinatesInPress.append(coordinate)
                        //print(coordinatesInPress)
        case .ended:    flushCoordinates()
        case .cancelled, .failed: coordinatesInPress = []
        }
    }
    private func flushCoordinates() {
        print (coordinatesInPress.count)
        print("ended long press")
        if(coordinatesInPress.count == 0){
            print("nothing")
            return
        }
        else if (coordinatesInPress.count < 10){
            addPOI(id: locationNodes.count + 1, coordinate: coordinatesInPress.first!)
//            print("add point")
//            let annotation = MKPointAnnotationWithID(id:locationNodes.count + 1, color: .green)
//            let coordinate = coordinatesInPress.first!
//            annotation.coordinate = coordinate
//            annotation.title = "Dropped Location"
//            let location = CLLocation(coordinate: coordinate, altitude: 100)
//            locationNodes.append(LocationAnnotationNode(location: location, image: UIImage(named: "pin")!))
//            //print(locationNodes)
//            mapView.addAnnotation(annotation)
            //addPOI(id: locationNodes.count + 1, coordinate: coordinatesInPress.first!)
        }
        else{
            let polyline = MKPolyline(coordinates: coordinatesInPress, count: coordinatesInPress.count)
            addPolyline(polyline: polyline)
        }

        
    }
    func getDirections(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, completion:@escaping (MKRoute) -> Void){
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end, addressDictionary: nil))
        //request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            completion(unwrappedResponse.routes[0])
        }
    
    }
    func addPOI(id: Int, color: UIColor = .green, coordinate: CLLocationCoordinate2D, title: String = "Dropped Pin", altitude: Double = 100, image: UIImage = UIImage(named: "pin")!){
        print("add point ",id)
        let annotation = MKPointAnnotationWithID(id: id, color: color)
        annotation.coordinate = coordinate
        annotation.title = title
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        locationNodes.append(LocationAnnotationNode(location: location, image: image))
        mapView.addAnnotation(annotation)
    }
    func addPolyline(polyline: MKPolyline){
        mapView.add(polyline)
        polylines.append(polyline)
    }
}

