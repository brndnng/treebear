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

class ARViewController: UIViewController, UIGestureRecognizerDelegate{

    @IBOutlet weak var loadingGIF: UIActivityIndicatorView!
    
    @IBOutlet weak var pan2Main: UIScreenEdgePanGestureRecognizer!
    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func swipeRight(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = pan2Main.translation(in: nil)
        let progress = CGFloat(-1 * translation.x / sceneLocationView.bounds.width)
        switch pan2Main.state {
        case .began:
            Hero.shared.defaultAnimation = .pull(direction: .left)
            hero_dismissViewController()
        case .ended:
            if progress / 2 + -1 * pan2Main.velocity(in: nil).x / sceneLocationView.bounds.width > 0.15 {
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

}
