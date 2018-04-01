//
//  TripTableViewCell.swift
//  treebear
//
//  Created by Ricky Cheng on 16/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit

class TripsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tripPic: UIImageView!
    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var tripExcerpt: UILabel!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var barView: UIView!
    
    @IBOutlet weak var progressPercentage: UILabel!
    
    var id: Int?
    var barColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        //self.contentView.backgroundColor = .lightGray
        barView.backgroundColor = barColor ?? .white
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //self.contentView.backgroundColor = .lightGray
        barView.backgroundColor = barColor ?? .white
        
    }
    
}
