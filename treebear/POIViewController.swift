//
//  POIViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 19/1/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import Hero

class POIViewController: UIViewController {
    
    var thisPOITitle: String?
    var thisPOIExcerpt: String?
    var thisPOIId: Int?
    var bgColor: UIColor = .clear
    
    @IBOutlet weak var POIOverView: UIView!
    @IBOutlet weak var POIName: UILabel!
    @IBOutlet weak var POIExcerpt: UILabel!
    @IBOutlet weak var ScrollingDetails: UIScrollView!
    @IBOutlet weak var PanDownMap: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Load JSON
        updateContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateContent(){
        view.backgroundColor = bgColor
        POIName.text = thisPOITitle
        POIExcerpt.text = thisPOIExcerpt
        POIOverView.backgroundColor = bgColor
        ScrollingDetails.backgroundColor = bgColor
        view.addSubview(ScrollingDetails)
    }

    @IBAction func panDownMap(_ sender: UIPanGestureRecognizer) {
        let translation = PanDownMap.translation(in: nil)
        let progress = CGFloat(translation.y / 2 / view.bounds.height)
        switch PanDownMap.state {
        case .began:
            // begin the transition as normal
            Hero.shared.defaultAnimation = .pull(direction: .down)
            hero_dismissViewController()
        case .ended:
            if progress + PanDownMap.velocity(in: nil).y / view.bounds.height > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        default:
            Hero.shared.update(progress)
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

}
