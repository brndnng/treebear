//
//  ViewController.swift
//  treebear
//
//  Created by Brandon Ng on 7/11/2017.
//  Copyright © 2017 Brandon Ng. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.isHidden = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 1
        view.addSubview(mapView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

