//
//  TripDetailsViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 27/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import MapKit
import Hero

class TripDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var panEdgeBack: UIView!
    @IBOutlet var edgePanBack: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var buffer: UIView!
    
    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var tripExcerpt: UILabel!
    @IBOutlet weak var descriptionCard: UIView!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var POICard: UIView!
    @IBOutlet weak var POIMapView: MKMapView!
    @IBOutlet weak var POITableView: UITableView!
    @IBOutlet weak var POITableHeight: NSLayoutConstraint!

    
    var tripId: Int?
    var poiTable: [Int: JSON] = [:]
    var poiSequence: [Int] = []
    var from: String?
    var serverResponse: JSON?
    var navigationBar: UINavigationBar?
    var firstLoad = true
    var onGoingTrip = false
    var POIDetails: [String: Bool]?
    
    let helper = Helpers()
    let colors = ExtenedColors()
    let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add a loading overlay
        let onGoing = UserDefaults.standard.array(forKey: "tripsInProgress") as! [Int]
        var bgColor = colors.noTripColor["dark"]
        if let index = onGoing.index(of: tripId!){
            bgColor = colors.tripColor[index]["dark"]
            onGoingTrip = true
            var TripDetails = UserDefaults.standard.dictionary(forKey: "tripsDetails")!["\(tripId!)"] as? [String: Any]
            POIDetails = TripDetails!["POIS"] as? [String: Bool]
        }
        contentView.backgroundColor = bgColor
        scrollView.backgroundColor = bgColor
        alert.view.tintColor = .black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        POITableView.delegate = self
        POITableView.dataSource = self
        
        POIMapView.delegate = self
        
        //table height fix
        self.POITableView.estimatedRowHeight = 0;
        self.POITableView.estimatedSectionHeaderHeight = 0;
        self.POITableView.estimatedSectionFooterHeight = 0;
        
        //add uiview to table footer
        POITableView.tableFooterView = UIView()
        
        view.addSubview(panEdgeBack)
        
        if(from! == "ViewController" && navigationBar == nil){
            navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: 1000, height: 200))
            navigationBar?.barTintColor = .white
            view.addSubview(navigationBar!)
        }
        
        var rightButton: UIBarButtonItem?
        //logic need to set suitable title or not render the button
        let tripsInProgress:[Int] = UserDefaults.standard.array(forKey: "tripsInProgress") as! [Int]
        let finishedTrips:[Int] = UserDefaults.standard.array(forKey: "finishedTrips") as! [Int]
        if(tripsInProgress.index(of: tripId!) != nil){
            rightButton = UIBarButtonItem(title: "Drop", style: .plain, target: self, action: #selector(rightButtonTapped))
        } else if(finishedTrips.index(of: tripId!) == nil){
            rightButton = UIBarButtonItem(title: "Enroll", style: .plain, target: self, action: #selector(rightButtonTapped))
            if(tripsInProgress.index(of: -1) == nil){
                rightButton?.isEnabled = false
            }
        }
        rightButton?.possibleTitles = ["Enroll", "Drop"]
    
        if(from! == "ViewController"){
            let navigationItem = UINavigationItem(title: "Trip Details")
            if(rightButton != nil){
                navigationItem.rightBarButtonItem = rightButton
            }
            navigationBar?.items = [navigationItem]
            
        }else if(from! == "TripsTableViewController"){
            if(rightButton != nil){
                navigationItem.rightBarButtonItem = rightButton
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(tripId != nil && firstLoad){
            helper.postRequest(args: ["action": "get",
                                      "type": "trip",
                                      "tripId": "\(tripId!)"], completionHandler: insertDataToLayout)
        }
        navigationBar?.frame.size.width = view.frame.width
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func insertDataToLayout(_json: JSON){
        serverResponse = _json
        let json = _json
        DispatchQueue.main.async {
            //all this in main thread
            self.tripName.text = json["title"].string
            self.tripExcerpt.text = json["excerpt"].string
            self.tripName.textColor = .white
            self.tripName.backgroundColor = .clear
            self.tripExcerpt.textColor = .white
            self.tripExcerpt.backgroundColor = .clear
            
            self.descriptionCard.layer.cornerRadius = 5
            self.details.text = json["info"].string
            self.details.sizeToFit()
            self.details.textColor = .black
            self.details.backgroundColor = .clear
            
            self.POICard.layer.cornerRadius = 5
            
            for (_, poiId):(String, JSON) in json["POI_sequence"]{
                self.poiSequence.append(poiId.int!)
            }
            
            for (_, poi):(String, JSON) in json["POIS"] {
                //adding points to mapView
                var color = self.colors.noTripColor["dark"]!
                if(self.onGoingTrip){
                    if let finished = self.POIDetails!["\(poi["id"].intValue)"]{
                        if(finished){
                            color = self.colors.destColor["dark"]!
                        }
                    }
                }
                let annotation = MKPointAnnotationWithID(id: poi["id"].int!, color: color, excerpt: "")
                annotation.coordinate = CLLocationCoordinate2D(latitude: poi["latitude"].double!, longitude: poi["longitude"].double!)
                annotation.title = poi["title"].string
                self.POIMapView.addAnnotation(annotation)
                //adding points to tableView
                self.poiTable[poi["id"].int!] = poi
            }
            
            //tell the table to reload
            self.POITableView.reloadData()
            
            // set map area
            self.POIMapView.showAnnotations(self.POIMapView.annotations, animated: true)
            //draw route
            if(self.poiSequence.count > 1){
                for i in 1..<(self.poiSequence.count){
                    let start = CLLocationCoordinate2D(latitude: self.poiTable[self.poiSequence[i-1]]!["latitude"].double!, longitude: self.poiTable[self.poiSequence[i-1]]!["longitude"].double!)
                    let end = CLLocationCoordinate2D(latitude: self.poiTable[self.poiSequence[i]]!["latitude"].double!, longitude: self.poiTable[self.poiSequence[i]]!["longitude"].double!)
                    self.getDirections(start: start, end: end){
                        (route) in
                        
                        var startLocation: CLLocation = CLLocation()
                        var endLocation: CLLocation = CLLocation()
                        
                        if(!route.isEqual(MKRoute())){
                            //getting the endpoints of the polyline
                            for step in route.steps as [MKRouteStep] {
                                let pointCount = step.polyline.pointCount
                                
                                let cArray = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: pointCount)
                                
                                step.polyline.getCoordinates(cArray, range: NSMakeRange(0, pointCount))
                                
                                startLocation = CLLocation(coordinate: cArray[0], altitude: 0)
                                endLocation = CLLocation(coordinate: cArray[pointCount-1], altitude: 0)
                                
                                cArray.deallocate(capacity: pointCount)
                            }
                        }
                        
                        //if either endpoints of the polyline is too far from the poi, draw a stright line instead
                        if(route.isEqual(MKRoute()) ||
                            startLocation.distance(from: CLLocation(coordinate: start, altitude: 0)) > 100 ||
                            endLocation.distance(from: CLLocation(coordinate: start, altitude: 0)) > 100){
                            let strightLine = [start, end]
                            let strightPolyline = MKPolyline(coordinates: strightLine, count: 2)
                            self.POIMapView.add(strightPolyline)
                        }else{
                            self.POIMapView.add(route.polyline)
                        }
                    }
                }
            }
            
            //set tableView height
            self.POITableHeight.constant = self.POITableView.contentSize.height
            self.POITableView.setNeedsLayout()
            
            //reset scrollView content size
            self.contentView.layoutIfNeeded()
            self.scrollView.contentSize = self.contentView.frame.size
            
            //dismiss the loading overlay
            self.alert.dismiss(animated: true, completion: nil)
            Hero.shared.defaultAnimation = .pull(direction: .right)
            
            self.firstLoad = false
        }
    }
    
    //tableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !poiTable.isEmpty{
            return poiTable.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "poiCell", for: indexPath)
        if !poiTable.isEmpty{
            // Configure the cell...
            let thisRowId = poiSequence[indexPath.row]
            if(self.onGoingTrip){
                if let finished = self.POIDetails!["\(thisRowId)"]{
                    if(finished){
                        cell.backgroundColor = self.colors.destColor["dark"]
                        cell.textLabel?.textColor = .white
                        cell.detailTextLabel?.textColor = .white
                    }
                }
            }
            cell.textLabel?.text = poiTable[thisRowId]!["title"].string
            cell.detailTextLabel?.text = poiTable[thisRowId]!["excerpt"].string
            //cell.tag = thisRowId
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = tableView.cellForRow(at: indexPath)?.tag
        for annotation in POIMapView.annotations{
            if let annotationWithId = annotation as? MKPointAnnotationWithID{
                if annotationWithId.id == selectedId{
                    POIMapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //map view delegate
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
    
    func getDirections(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, completion:@escaping (MKRoute) -> Void){
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end, addressDictionary: nil))
        //request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else {
                print("Direction not found")
                completion(MKRoute())
                return }
            print("Have direction")
            completion(unwrappedResponse.routes[0])
        }
    }

    //edge pan
    @IBAction func swipeLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = edgePanBack.translation(in: nil)
        let progress = CGFloat(translation.x / 2 / view.bounds.width)
        switch edgePanBack.state {
        case .began:
            // begin the transition as normal
            Hero.shared.defaultAnimation = .pull(direction: .right)
            if(from == "TripsTableViewController"){
                navigationController?.popViewController(animated: true)
            }else if(from == "ViewController"){
                hero_dismissViewController()
            }
        case .ended:
            if progress + edgePanBack.velocity(in: nil).x / view.bounds.width > 0.3 {
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
    
    //Right button item tapped
    
    @objc func rightButtonTapped(sender: UIBarButtonItem){
        if(sender.title == "Enroll"){
            //cehck availible slot and is currently enrolled
            var tripsInProgress = UserDefaults.standard.array(forKey: "tripsInProgress") as! [Int]
            if let indexOfTrip = tripsInProgress.index(of: -1){
                if(tripsInProgress.index(of: tripId!) == nil){
                    //tell the server
                    helper.postRequest(args: ["type": "tripStart",
                                              "action": "set",
                                              "tripId": "\(self.tripId!)"]){
                                                (_json) in
                                                if(_json["status"].string == "success"){
                                                    // add to userDefault
                                                    tripsInProgress[indexOfTrip] = self.serverResponse!["id"].intValue
                                                    UserDefaults.standard.set(tripsInProgress, forKey: "tripsInProgress")
                                                    //add to trip details
                                                    var pois:[String: Bool] = [:]
                                                    for poi in self.serverResponse!["POI_sequence"].arrayValue{
                                                        pois["\(poi.intValue)"] = false
                                                    }
                                                    let tripDetails: [String : Any] = ["name": self.serverResponse!["title"].stringValue,
                                                                      "excerpt": self.serverResponse!["excerpt"].stringValue,
                                                                      "pic_url": self.serverResponse!["picURL"].stringValue,
                                                                      "POIS": pois]
                                                    var tripsDetails = UserDefaults.standard.dictionary(forKey: "tripsDetails")
                                                    tripsDetails!["\(self.serverResponse!["id"].intValue)"] = tripDetails
                                                    UserDefaults.standard.set(tripsDetails, forKey: "tripsDetails")

                                                    //change the button title
                                                    DispatchQueue.main.async{
                                                        sender.title = "Drop"
                                                        //change bg color
                                                        let bgColor = self.colors.tripColor[indexOfTrip]["dark"]
                                                        self.scrollView.backgroundColor = bgColor
                                                        self.contentView.backgroundColor = bgColor
                                                        //toast
                                                        self.showToast(message: self.serverResponse!["title"].stringValue  + " Enrolled")
                                                    }
                                                }
                    }
                }
            }
        }else if(sender.title == "Drop"){
            //cehck in enrolled list or not
            var tripsInProgress = UserDefaults.standard.array(forKey: "tripsInProgress") as! [Int]
            if let indexOfTrip = tripsInProgress.index(of: tripId!){
                //tell the server
                helper.postRequest(args: ["type": "tripDel",
                                          "action": "set",
                                          "tripId": "\(self.tripId!)"]){
                                            (_json) in
                                            if(_json["status"].string == "success"){
                                                // remove from userDefault
                                                tripsInProgress[indexOfTrip] = -1
                                                UserDefaults.standard.set(tripsInProgress, forKey: "tripsInProgress")
                                                //remove from trip details
                                                var tripsDetail = UserDefaults.standard.dictionary(forKey: "tripsDetails")
                                                tripsDetail?.removeValue(forKey: "\(self.tripId!)")
                                                UserDefaults.standard.set(tripsDetail, forKey: "tripsDetails")
                                                //change the button title
                                                DispatchQueue.main.async{
                                                    sender.title = "Enroll"
                                                    //change bg color
                                                    self.contentView.backgroundColor = self.colors.noTripColor["dark"]
                                                    self.scrollView.backgroundColor = self.colors.noTripColor["dark"]
                                                    //toast
                                                    self.showToast(message: self.serverResponse!["title"].stringValue  + " Dropped")
                                                }
                                            }
                }
            }
        }
    }
}
