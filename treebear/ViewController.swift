//
//  ViewController.swift
//  treebear
//
//  Created by Brandon Ng on 7/11/2017.
//  Copyright © 2017 Brandon Ng. All rights reserved.
//

import UIKit
import MapKit
import Hero

class ViewController: UIViewController,MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var pan2AR: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var view4EdgePan: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.isHidden = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 1
        mapView.showsPointsOfInterest = false
//        //getting user location
//        let userLocation: CLLocationCoordinate2D?
//        //centering the map
//        let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation!, 100, 100);
//        let adjustedRegion = mapView.regionThatFits(viewRegion)
//        mapView.setRegion(adjustedRegion, animated: true)
        self.mapView.showsUserLocation = true;
        view.addSubview(mapView)
        //view.addSubview(testText)
        view.addSubview(view4EdgePan)
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
            if progress+ pan2AR.velocity(in: nil).x / view.bounds.width > 0.15 {
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
    
}

