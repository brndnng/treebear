//
//  MenuViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 11/1/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import Hero

protocol SegueHandler: class {
    func segueToNext(identifier: String)
}

class MenuViewController: UIViewController, UITableViewDelegate, UICollectionViewDelegate, SegueHandler {
    
    func segueToNext(identifier: String) {
        switch identifier{
        case "LoggedOut":
            Hero.shared.defaultAnimation = .fade
        default:
            Hero.shared.defaultAnimation = .push(direction: .left)
        }
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    @IBOutlet weak var pan2Main: UIScreenEdgePanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func swipeLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = pan2Main.translation(in: nil)
        let progress = CGFloat(translation.x / 2 / view.bounds.width)
        switch pan2Main.state {
        case .began:
            // begin the transition as normal
            //            let story = UIStoryboard(name: "Main", bundle: nil)
            //            let arVC = story.instantiateViewController(withIdentifier: "ARVC")
            //            arVC.loadViewIfNeeded()
            Hero.shared.defaultAnimation = .slide(direction: .right)
            hero_dismissViewController()
        //testText.text = "test passed"
        case .ended:
            if progress + pan2Main.velocity(in: nil).x / view.bounds.width > 0.3 {
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
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "EmbedH"  {
            if let nextViewController = segue.destination as? MenuTableViewController{
                nextViewController.delegate = self
            }
        }
     }
    
}
