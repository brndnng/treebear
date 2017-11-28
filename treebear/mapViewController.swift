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
class mapViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet var pan2AR: UIScreenEdgePanGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.isHidden = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 1
        view.addSubview(mapView)
//        pan2AR = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(switch2AR(gestureRecognizer:)))
        view.addGestureRecognizer(pan2AR)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func switch2AR(gestureRecognizer:UIScreenEdgePanGestureRecognizer){
        switch pan2AR.state {
        case .began:
            //hero_replaceViewController(with:arViewController)
            performSegue(withIdentifier: "ToAR", sender: self)
        default:
            break
        }
    }


}

