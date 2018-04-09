//
//  SearchTableViewCell.swift
//  treebear
//
//  Created by Brandon Ng on 1/4/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import MapKit

class SearchTableViewCell: UITableViewCell {
    var id: Int?
    var excerpt: String?
    var coordinates: CLLocationCoordinate2D?
    var asso_trip: JSON?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
