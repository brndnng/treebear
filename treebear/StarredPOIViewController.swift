//
//  StarredPOIViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 29/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import MapKit
import Hero

class StarredPOIViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet var edgePanBack: UIScreenEdgePanGestureRecognizer!
    
    let helper = Helpers()
    let colors = ExtenedColors()
    var serverResponse: JSON?
    
    let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //table height fix
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        
        alert.view.tintColor = .black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        present(alert, animated: true, completion: nil)
        helper.postRequest(args: ["action": "get",
                                  "type": "starred"], completionHandler: insertDataToView)
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
    
    //table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(serverResponse == nil){
            return 0
        }else{
            return serverResponse!["num_POI"].int!
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Starred Points of Interest"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "starPOICell", for: indexPath)
        
        if(serverResponse != nil){
            // Configure the cell...
            cell.textLabel?.text = serverResponse!["POIS"][indexPath.row]["title"].string
            cell.detailTextLabel?.text = serverResponse!["POIS"][indexPath.row]["excerpt"].string
            cell.tag = serverResponse!["POIS"][indexPath.row]["id"].int!
            
            
        }
        
        return cell
    }
    
    //table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = tableView.cellForRow(at: indexPath)?.tag
        for annotation in mapView.annotations{
            if let annoationWithId = annotation as? MKPointAnnotationWithID{
                if(selectedId == annoationWithId.id){
                    mapView.selectAnnotation(annotation, animated: true)
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedId = tableView.cellForRow(at: indexPath)?.tag
        for annotation in mapView.annotations{
            if let annoationWithId = annotation as? MKPointAnnotationWithID{
                if(selectedId == annoationWithId.id){
                    mapView.deselectAnnotation(annotation, animated: true)
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            helper.postRequest(args: ["action": "set",
                                      "type": "unstar",
                                      "POIId": "\(tableView.cellForRow(at: indexPath)!.tag)"]){
                                        (_json) in
                                        if(_json["status"].string == "success"){
                                            var tempArray = self.serverResponse!["POIS"].arrayValue
                                            tempArray.remove(at: indexPath.row)
                                            self.serverResponse!["POIS"] = JSON(tempArray)
                                            self.serverResponse!["num_POI"] = JSON(self.serverResponse!["num_POI"].intValue - 1)
                                            DispatchQueue.main.async {
                                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                                for annotation in self.mapView.annotations {
                                                    if let annotationWithId = annotation as? MKPointAnnotationWithID {
                                                        if (annotationWithId.id == tableView.cellForRow(at: indexPath)!.tag){
                                                            self.mapView.removeAnnotation(annotation)
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                        }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
            annotationView?.markerTintColor = self.colors.noTripColor["dark"]
            annotationView?.tag = annotation.id
        }else{
            return nil
        }
        
        annotationView?.animatesWhenAdded = true
        annotationView?.titleVisibility = .visible
        annotationView?.subtitleVisibility = .hidden
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (mapView.region.span.latitudeDelta * 111 < 1000){
            var region = mapView.region
            region.center = (view.annotation?.coordinate)!
            mapView.setRegion(region, animated: true)
        }else{
            let region = MKCoordinateRegionMakeWithDistance((view.annotation?.coordinate)!, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func insertDataToView(_json: JSON){
        self.serverResponse = _json
        DispatchQueue.main.async {
            for i in 0...(_json["num_POI"].int! - 1) {
                //add point to map
                let annotation = MKPointAnnotationWithID(id: _json["POIS"][i]["id"].int!, color: self.colors.noTripColor["dark"]!, excerpt: "")
                annotation.coordinate = CLLocationCoordinate2D(latitude: _json["POIS"][i]["latitude"].double!, longitude: _json["POIS"][i]["longitude"].double!)
                annotation.title = _json["POIS"][i]["title"].string
                self.mapView.addAnnotation(annotation)
            }
            
            //tell map to show all poi
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            //tell table to reload
            self.tableView.reloadData()
            //detemine can the table scroll
            if(self.tableView.contentSize.height < self.tableView.frame.height){
                self.tableView.isScrollEnabled = false
            }else{
                self.tableView.isScrollEnabled = true
            }
            //dismiss loading overlay
            self.alert.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func swipeLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = edgePanBack.translation(in: nil)
        let progress = CGFloat(translation.x / 2 / view.bounds.width)
        switch edgePanBack.state {
        case .began:
            // begin the transition as normal
            Hero.shared.defaultAnimation = .pull(direction: .right)
            hero_dismissViewController()
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
    
    @IBAction func toggleTableEdit(_ sender: UIBarButtonItem){
        if(tableView.isEditing){
            sender.title = "Edit"
            tableView.isEditing = false
        }else{
            sender.title = "Done"
            tableView.isEditing = true
        }
    }

}
