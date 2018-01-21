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

class ARViewController: UIViewController, UIGestureRecognizerDelegate, SceneLocationViewDelegate{
    

    @IBOutlet weak var loadingGIF: UIActivityIndicatorView!
    
    @IBOutlet weak var pan2Main: UIScreenEdgePanGestureRecognizer!
    var sceneLocationView = SceneLocationView()
    var destination : LocationAnnotationNode?
    var locationNodes : [LocationAnnotationNode] = []
    var polylines : [MKPolyline] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneLocationView.locationDelegate = self
        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: destination!)
        view.addSubview(sceneLocationView)
        for location in locationNodes{
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: location)
        }
        print(polylines)
        sceneLocationView.addPolylines(polylines)
        sceneLocationView.run()
        
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sceneLocationView.pause()
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

}
