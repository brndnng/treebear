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
    let excerpt: String
    
    init(id: Int, color: UIColor, excerpt: String){
        self.id = id
        self.markerTintColor = color
        self.excerpt = excerpt
    }
}

class ViewController: UIViewController,MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {


    @IBOutlet weak var pan2AR: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var pan2Menu: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var panUpPOI: UIPanGestureRecognizer!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var view4EdgePan: UIView!
    @IBOutlet weak var view4EdgePan2Menu: UIView!
    @IBOutlet weak var POIView: UIView!
    @IBOutlet weak var POINameLabel: UILabel!
    @IBOutlet weak var POIExcerpt: UILabel!
    @IBOutlet weak var ARNav: UIButton!
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var searchTableHeight: NSLayoutConstraint!
    
    var centerMapOnUserLocation: Bool = true
    //var destination : LocationAnnotationNodeWithDetails?
    var searchActive : Bool = false
    var locationManager:CLLocationManager!
    var centerMapBaseOnUserLocation: Bool = true
    var locationNodes = [LocationAnnotationNode]()
    var addedPOI = [MKAnnotation]()
    var polylines = [MKPolyline]()
    var filteredSearchedItems = [SearchItem]()
    var SearchedItems = [SearchItem]()
    var responseFromServer: JSON?
    fileprivate var coordinatesInPress = [CLLocationCoordinate2D]()
    
    var pressedAnnotation: MKPointAnnotationWithID? //selected annotation
    var selectedAsDestination: MKPointAnnotationWithID? // only set when user request ar navigation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // set up table view
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.isHidden = true
        searchTableView.allowsSelection = true
        searchTableView.backgroundColor = UIColor(white: 1,alpha:0.5)
        searchBar.delegate = self
        searchBar.placeholder = "Search POI/Trips"
        searchBar.showsCancelButton = false
        searchBar.enablesReturnKeyAutomatically = true
//        searchTableView.
        // set up keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide
            , object: nil)
        

        definesPresentationContext = true
        
       //post test
        let helpers = Helpers()
        helpers.postRequest(args:["type":"user",
                                  "action":"set"], completionHandler: printResponse)
        
        view.sendSubview(toBack: POIView)
        mapView.isHidden = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 1
        mapView.showsPointsOfInterest = false
        
        determineCurrentLocation()
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: 22.309454, longitude: 114.262633)
        //let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 100)
        
        
        //JSON first load
        addPOI(id: 1500, color: .blue,coordinate: pinCoordinate, title: "TKO", subtitle: "Shopping Center?")
        view.addSubview(mapView)
        // Tap to close keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tap)
        // Long press to add POI
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPress)
        
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)
        view.addSubview(view4EdgePan)
        view.addSubview(view4EdgePan2Menu)
        view.addSubview(searchTableView)
        // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        
        // make your class the delegate of the pan gesture
        panGesture.delegate = self
        
        // add the gesture to the mapView
        mapView.addGestureRecognizer(panGesture)
        
        // adding seperate line for btn
        let lineView = UIView(frame: CGRect(x: -16, y: 0, width: 1, height: ARNav.frame.size.height))
        lineView.backgroundColor = .white
        ARNav.addSubview(lineView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        determineCurrentLocation()
        selectedAsDestination = nil
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
            if progress + pan2AR.velocity(in: nil).x / view.bounds.width > 0.3 {
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
    
    @IBAction func requestedOnARNav(_ sender: UIButton) {
        selectedAsDestination = pressedAnnotation
        Hero.shared.defaultAnimation = .slide(direction: .right)
        performSegue(withIdentifier: "main2AR", sender: self)
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
            if progress + -1 * pan2Menu.velocity(in: nil).x / view.bounds.width > 0.3 {
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
    
    @IBAction func POIPanUP(_ sender: UIPanGestureRecognizer) {
        let translation = panUpPOI.translation(in: nil)
        let progress = CGFloat( -1 * translation.y / 2 / view.bounds.height)

        switch panUpPOI.state {
        case .began:
            // begin the transition as normal
            Hero.shared.defaultAnimation = .push(direction: .up)
            performSegue(withIdentifier: "annotationPressed", sender: self)
        //testText.text = "test passed"
        case .ended:
            if progress + -1 * panUpPOI.velocity(in: nil).y / view.bounds.height > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        default:
            Hero.shared.update(progress)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didDragMap(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            // do something here
            centerMapOnUserLocation = false
            for annotation in mapView.annotations{
                if(annotation.isKind(of: MKUserLocation.self)){
                    mapView.deselectAnnotation(annotation, animated: true)
                    break
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "main2AR" && self.selectedAsDestination != nil {
            if let nextViewController = segue.destination as? ARViewController{
                nextViewController.destination = self.selectedAsDestination
                //nextViewController.locationNodes = self.locationNodes
                nextViewController.polylines = self.polylines
            }
        }else if segue.identifier == "annotationPressed" && self.pressedAnnotation != nil{
            if let nextViewController = segue.destination as? POIViewController{
                nextViewController.bgColor = (self.pressedAnnotation?.markerTintColor)!
                nextViewController.thisPOITitle = self.pressedAnnotation?.title
                nextViewController.thisPOIExcerpt = self.pressedAnnotation?.title
                nextViewController.thisPOIId = self.pressedAnnotation?.id
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
        if ((view.tag) != 0) {
            print("User tapped on annotation: \(view.tag)")
            //mapView.removeOverlays(mapView.overlays)
            self.polylines.removeAll()
            self.getDirections(start: (locationManager.location?.coordinate)!,end: (view.annotation?.coordinate)!){(route) in
                self.addPolyline(polyline: route.polyline)
                print("Distance: ",route.distance)
                print("Estimated travel time: ",route.expectedTravelTime)
//                var boundingbox = route.polyline.boundingMapRect
//                boundingbox.size.height += Double(mapView.bounds.height)
//                boundingbox.size.width += Double(mapView.bounds.width)
//                self.mapView.setVisibleMapRect(boundingbox, animated: true)
                if (self.polylines.isEmpty){
                    // disable the button
                    self.ARNav.isEnabled = false
                }else{
                    self.ARNav.isEnabled = true
                }
            }
            pressedAnnotation = view.annotation as? MKPointAnnotationWithID
            showViewALittleBit()
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        POIView.alpha = 0
        mapView.removeOverlays(mapView.overlays)
        polylines = []
        pressedAnnotation = nil
        selectedAsDestination = nil
        print("did deselect")
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views{
            if(view.annotation?.isKind(of: MKUserLocation.self))!{
                view.canShowCallout = false
            }else{
                if let markerAnnotationView = view as? MKMarkerAnnotationView {
                    markerAnnotationView.titleVisibility = .visible
                    markerAnnotationView.subtitleVisibility = .hidden
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if(annotation.isKind(of: MKUserLocation.self)) {
            return nil;
        }
        
        var annotationView: MKMarkerAnnotationView?
        
        if let annotation = annotation as? MKPointAnnotationWithID {
        
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: String(annotation.id)) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.id))
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.markerTintColor = annotation.markerTintColor
            annotationView?.tag = annotation.id
        }else{
            return nil
        }
        
        annotationView?.animatesWhenAdded = true
        annotationView?.titleVisibility = .visible
        annotationView?.subtitleVisibility = .hidden
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // load JSON
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
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
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
            print("gor dir")
            completion(unwrappedResponse.routes[0])
        }
    
    }
    func addPOI(id: Int, color: UIColor = .green, coordinate: CLLocationCoordinate2D, title: String = "Dropped Pin", subtitle: String = "", altitude: Double = 100, image: UIImage = UIImage(named: "pin")!){
        print("add point ",id)
        let annotation = MKPointAnnotationWithID(id: id, color: color, excerpt: subtitle)
        annotation.coordinate = coordinate
        annotation.title = title
        //annotation.subtitle = subtitle
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        locationNodes.append(LocationAnnotationNode(location: location, image: image))
        addedPOI.append(annotation)
        mapView.addAnnotation(annotation)
    }
    func addPOIandSelect(id: Int, color: UIColor = .green, coordinate: CLLocationCoordinate2D, title: String = "Dropped Pin", subtitle: String = "", altitude: Double = 100, image: UIImage = UIImage(named: "pin")!){
        print("add point ",id)
        let annotation = MKPointAnnotationWithID(id: id, color: color, excerpt: subtitle)
        annotation.coordinate = coordinate
        annotation.title = title
        //annotation.subtitle = subtitle
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        locationNodes.append(LocationAnnotationNode(location: location, image: image))
        addedPOI.append(annotation)
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    func addPolyline(polyline: MKPolyline){
        mapView.add(polyline)
        polylines.append(polyline)
    }
    
    func showViewALittleBit(){
        POIView.backgroundColor = pressedAnnotation?.markerTintColor
        POINameLabel.text = pressedAnnotation?.title
        POIExcerpt.text = pressedAnnotation?.subtitle
        print("check polyline")
        if (polylines.isEmpty){
            // disable the button
            ARNav.isEnabled = false
        }else{
            ARNav.isEnabled = true
        }
        POIView.alpha = 1
        view.insertSubview(POIView, aboveSubview: searchBar)
        print("should be brought")
    }
    
    func printResponse(_json : JSON){
        print(_json)
    }
    func createSearchItemsFromResponse(_json : JSON){
//        SearchedItems.removeAll()
//        self.responseFromServer = _json["trips"]
        let trips = _json["trips"]["trip"].array
        let POIS = _json["POIS"]["POI"].array
        DispatchQueue.main.async {
            self.SearchedItems.removeAll()
            for trip in trips!{
                //            print(trip)
                self.SearchedItems.append(SearchItem(type: "trip", title: trip["title"].stringValue, id: trip["id"].intValue, excerpt: trip["excerpt"].stringValue, coordinates: CLLocationCoordinate2D(latitude: -1, longitude: -1)))
//                print("Searched: ",self.SearchedItems)
            }
            for POI in POIS!{
                self.SearchedItems.append(SearchItem(type: "POI", title: POI["title"].stringValue, id: POI["id"].intValue, excerpt: POI["excerpt"].stringValue,coordinates: CLLocationCoordinate2D(latitude: POI["latitude"].doubleValue,longitude: POI["longitude"].doubleValue)))
            }
            print(self.SearchedItems)
            self.searchTableView.reloadData()
//            if(self.searchTableView.contentSize.height > self.view.frame.height){
//                self.searchTableView.isScrollEnabled = true
//            }else{
//                self.searchTableView.isScrollEnabled = false
//            }
        }
    }
    
    //search functions
//    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        let helpers = Helpers()
//        print("Searching for: ",searchText)
//        helpers.postRequest(args:["type":"search",
//                                  "action":"get","key":searchText], completionHandler: printResponse)
//        filteredSearchedItems = SearchedItems.filter({( item : SearchItem) -> Bool in
//            return item.title.lowercased().contains(searchText.lowercased())
//        })
//    }
    //tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Numofitems:",SearchedItems.count)
        return SearchedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "SearchedItemsCell", for: indexPath) as! SearchTableViewCell// ?? SearchTableViewCell(style: .default, reuseIdentifier: "SearchedItemsCells")  //else { fatalError("The dequeued cell is not an instance of SearchTableViewCell.") }

        let item: SearchItem
            //        if isFiltering() {
        item = SearchedItems[indexPath.row]
            //        } else {
            //        item = SearchedItems[indexPath.row]
        print("Item",item)
            //        }
        cell.backgroundColor = UIColor.clear
        cell.textLabel!.text = item.title
        cell.detailTextLabel!.text = item.type
        cell.id = item.id
        cell.excerpt = item.excerpt
        cell.coordinates = item.coordinates
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell {
            let pressed_cell_id = cell.id
            if (cell.detailTextLabel!.text == "POI"){
                view.endEditing(true)
                searchBar.text = ""
                searchTableView.isHidden = true
                searchTableView.reloadData()
                addPOIandSelect(id: cell.id!, coordinate: cell.coordinates!, title: cell.textLabel!.text!,subtitle:cell.excerpt!)
                
            }
                // TODO: case when selected cell is a trip
            else if (cell.detailTextLabel!.text == "trip"){
                
            }
            view.endEditing(true)
        }

        
    }
    // searchBar functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty){
            searchTableView.isHidden = true
            SearchedItems.removeAll()
            view.endEditing(true)
        }
        else{
        searchTableView.isHidden = false
        let helpers = Helpers()
        print("Searching for: ",searchText)
        helpers.postRequest(args:["type":"search",
                                  "action":"get","key":searchText],completionHandler: createSearchItemsFromResponse)
        print("Searched:",SearchedItems)
        filteredSearchedItems = SearchedItems.filter({( item : SearchItem) -> Bool in
            return item.title.lowercased().contains(searchText.lowercased())
        })
        }
        self.searchTableView.reloadData()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        view.endEditing(true)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        searchTableView.isHidden = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchActive = false;
        SearchedItems.removeAll();
        view.endEditing(true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchActive = false;
        view.endEditing(true)
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
//                self.searchTableView.frame.origin.y = 20
                self.searchTableHeight.constant -= keyboardSize.height
//                self.view.bringSubview(toFront: searchBar)
//                self.searchTableView.frame = CGRect(x: self.searchTableView.frame.origin.x, y: self.searchTableView.frame.origin.y, width: self.searchTableView.frame.size.width, height: self.searchTableView.frame.height-keyboardSize.height)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
                self.searchTableHeight.constant += keyboardSize.height
            }
        }
    }
}


//extension ViewController: UISearchResultsUpdating {
//    // MARK: - UISearchResultsUpdating Delegate
//    func updateSearchResults(for searchController: UISearchController) {
//        print(searchController.searchBar.text!)
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
//}

