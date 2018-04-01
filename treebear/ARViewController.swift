//
//  ARViewController.swift
//  treebear
//
//  Created by Brandon Ng on 28/11/2017.
//  Copyright © 2017 Brandon Ng. All rights reserved.
//

import UIKit
import ARCL
import Hero
import MapKit
import SceneKit

class LocationAnnotationNodeWithDetails:LocationAnnotationNode{
    var	id: Int
    var title: String
    var excerpt: String
    var bgcolor: UIColor
    
    init(id:Int, title:String, excerpt: String, color: UIColor, location: CLLocation, image: UIImage){
        self.id = id
        self.title = title
        self.excerpt = excerpt
        self.bgcolor = color
        
        super.init(location: location, image: image, altitudeType: .sameAltitudeAsUser)
    }
    
    init(annotation:MKPointAnnotationWithID, image: UIImage, altitude: Double){
        self.id = annotation.id
        self.title = annotation.title!
        self.excerpt = annotation.subtitle!
        self.bgcolor = annotation.markerTintColor!
        
        super.init(location: CLLocation(coordinate: annotation.coordinate, altitude: altitude), image: image, altitudeType: .sameAltitudeAsUser)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ARViewController: UIViewController, UIGestureRecognizerDelegate, SceneLocationViewDelegate{
    

    @IBOutlet weak var loadingGIF: UIActivityIndicatorView!
    @IBOutlet weak var pan2Main: UIScreenEdgePanGestureRecognizer!
    
    var sceneLocationView = SceneLocationView()
    var destination : MKPointAnnotationWithID?
    var locationNodes : [LocationAnnotationNodeWithDetails] = []
    var polylines : [MKPolyline] = []
    var selectedObject: LocationAnnotationNodeWithDetails?
    var postTimer: Timer?
    
    //For Location Node (the view is hiding in the back)
    @IBOutlet weak var locationLabel: UIView!
    @IBOutlet weak var POIExcerpt: UILabel!
    @IBOutlet weak var POIName: UILabel!
    
    let colors = ExtenedColors()
    let helper = Helpers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingGIF.startAnimating()

        sceneLocationView.locationDelegate = self
        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        //sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: destination!)
        sceneLocationView.run()
//        debugLocations()
        view.addSubview(sceneLocationView)
//        for location in locationNodes{
//            location.scaleRelativeToDistance = true
//            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: location)
//        }
        if(destination != nil){
            let altitude = sceneLocationView.currentLocation()?.altitude ?? 100
            let desImage = getImageForLocation(title: (destination?.title)!, excerpt: (destination?.subtitle)!, color: colors.destColor["dark"]!)
            let destinationNode = LocationAnnotationNodeWithDetails(annotation: destination!, image: desImage, altitude: altitude)
            destinationNode.scaleRelativeToDistance = false
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: destinationNode)
            sceneLocationView.addPolylines(polylines)
        }
        //sceneLocationView.run()
        
        //handle tap on ar obj
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneLocationView.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sceneLocationView.run()
        postTimer?.invalidate()
        postTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTooltips), userInfo: nil, repeats: true)
        loadingGIF.stopAnimating()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SCNNodePressed" && self.selectedObject != nil {
            if let nextViewController = segue.destination as? POIViewController{
                nextViewController.bgColor = (selectedObject?.bgcolor)!
                nextViewController.thisPOITitle = selectedObject?.title
                nextViewController.thisPOIExcerpt = selectedObject?.excerpt
                nextViewController.thisPOIId = selectedObject?.id
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sceneLocationView.pause()
        postTimer?.invalidate()
        postTimer = nil
    }
    

    @IBAction func swipeRight(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = pan2Main.translation(in: nil)
        let progress = CGFloat(-1 * translation.x / 2 / sceneLocationView.bounds.width)
        switch pan2Main.state {
        case .began:
            Hero.shared.defaultAnimation = .slide(direction: .left)
            hero_dismissViewController()
        case .ended:
            if progress / 2 + -1 * pan2Main.velocity(in: nil).x / sceneLocationView.bounds.width > 0.3 {
                sceneLocationView.pause()
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
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: sceneLocationView)
        
        if let tappedObject = virtualObject(at: touchLocation) {
            // Select a new object.
            selectedObject = existingObjectContainingNode(tappedObject)
            print("User tapped on annotation: \(selectedObject?.id ?? -1)")
            print("Point altitude = \(selectedObject?.location.altitude ?? -1)")
            print("User altitude = \(sceneLocationView.currentLocation()?.altitude ?? -1)")
            Hero.shared.defaultAnimation = .push(direction: .up)
            if(selectedObject?.id != nil){
                performSegue(withIdentifier: "SCNNodePressed", sender: self)
            }
        } else {
            // nothing selected
            print("pressed on nothing")
        }
    }
    
    func virtualObject(at point: CGPoint) -> SCNNode? {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = sceneLocationView.hitTest(point, options: hitTestOptions)
        
        return hitTestResults.first?.node
    }
    
    func existingObjectContainingNode(_ node: SCNNode) -> LocationAnnotationNodeWithDetails? {
        if let virtualObjectRoot = node as? LocationAnnotationNodeWithDetails {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `VirtualObject`.
        return existingObjectContainingNode(parent)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
    func debugLocations(){
        let altitude = sceneLocationView.currentLocation()?.altitude
        let color = [UIColor(red: 0.0039, green: 0.3412, blue: 0.6078, alpha: 1.0) /* #01579b */,
            UIColor(red: 0.749, green: 0.2118, blue: 0.0471, alpha: 1.0) /* #bf360c */,
            UIColor(red: 0.1922, green: 0.1059, blue: 0.5725, alpha: 1.0) /* #311b92 */,
            UIColor(red: 0.149, green: 0.1961, blue: 0.2196, alpha: 1.0) /* #263238 */]
        locationNodes.append(LocationAnnotationNodeWithDetails(id: 1, title: "Turkey", excerpt: "RedBird", color: color[0], location: CLLocation(coordinate: CLLocationCoordinate2D(latitude: 22.3375005, longitude: 114.2629677), altitude: altitude ?? 100), image: getImageForLocation(title: "Turkey", excerpt: "RedBird", color: color[0])))
        locationNodes.append(LocationAnnotationNodeWithDetails(id: 2, title: "Libra", excerpt: "ry", color: color[1], location: CLLocation(coordinate: CLLocationCoordinate2D(latitude: 22.338009, longitude: 114.2641432), altitude: altitude ?? 100), image: getImageForLocation(title: "Libra", excerpt: "ry", color: color[1])))
        locationNodes.append(LocationAnnotationNodeWithDetails(id: 2, title: "Mushroom", excerpt: "jump", color: color[2], location: CLLocation(coordinate: CLLocationCoordinate2D(latitude: 22.337493, longitude: 114.264215), altitude: altitude ?? 100), image: getImageForLocation(title: "Mushroom", excerpt: "jump", color: color[2])))
        locationNodes.append(LocationAnnotationNodeWithDetails(id: 2, title: "Concourse", excerpt: "long", color: color[3], location: CLLocation(coordinate: CLLocationCoordinate2D(latitude: 22.337258, longitude: 114.263797), altitude: altitude ?? 100), image: getImageForLocation(title: "Concourse", excerpt: "long", color: color[3])))
    }
    
    func getImageForLocation(title:String, excerpt: String, color: UIColor) -> UIImage{
        locationLabel.backgroundColor = color
        POIName.text = title
        POIName.textColor = .white
        POIName.lineBreakMode = .byTruncatingTail
        POIName.sizeToFit()
        locationLabel.frame.size.width = POIName.frame.size.width + 32
        POIExcerpt.text = excerpt
        POIExcerpt.lineBreakMode = .byWordWrapping
        POIExcerpt.textColor = .white
        return locationLabel.asImage()
    }
    
    @objc func updateTooltips(){
        helper.postRequest(args: ["action": "get",
                                  "type": "poi",
                                  "range": "100",
                                  "lat": "\(self.sceneLocationView.currentLocation()?.coordinate.latitude ?? 0.0)",
                                  "long": "\(self.sceneLocationView.currentLocation()?.coordinate.longitude ?? 0.0)"]){
                                    (_json) in
                                    for index in stride(from:(self.locationNodes.count-1), through: 0, by: -1){
                                        let node = self.locationNodes[index]
                                        var needToRemove = true
                                        for poi in _json["POIS"].arrayValue{
                                            if(poi["id"].intValue == node.id){
                                                needToRemove = false
                                                break
                                            }
                                        }
                                        if (needToRemove){
                                            DispatchQueue.main.async {
                                                self.sceneLocationView.removeLocationNode(locationNode: node)
                                                self.locationNodes.remove(at: index)
                                            }
                                        }
                                    }
                                    for poi in _json["POIS"].arrayValue{
                                        var needToAdd = true
                                        for node in self.locationNodes{
                                            if(node.id == poi["id"].intValue){
                                                needToAdd = false
                                                break
                                            }
                                        }
                                        if(needToAdd){
                                            DispatchQueue.main.async {
                                                //create the obj
                                                let id = poi["id"].intValue
                                                let title = poi["title"].stringValue
                                                let excerpt = poi["excerpt"].stringValue
                                                let color = self.colors.noTripColor["dark"]!
                                                let coordinate = CLLocationCoordinate2D(latitude: poi["latitude"].doubleValue, longitude: poi["longitude"].doubleValue)
                                                let altitude = poi["altitude"].doubleValue
                                                let node = LocationAnnotationNodeWithDetails(id: id, title: title, excerpt: excerpt, color: color, location: CLLocation(coordinate: coordinate, altitude: altitude), image: self.getImageForLocation(title: title, excerpt: excerpt, color: color))
                                                node.scaleRelativeToDistance = true
                                                self.locationNodes.append(node)
                                                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: node)
                                            }
                                        }
                                    }
        }
    }
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}



