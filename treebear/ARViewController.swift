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

    @IBOutlet weak var pan2Main: UIScreenEdgePanGestureRecognizer!
    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        // Do any additional setup after loading the view.
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
        let progress = CGFloat(translation.x / sceneLocationView.bounds.width)
        switch pan2Main.state {
        case .began:
            sceneLocationView.pause()
            Hero.shared.defaultAnimation = .pull(direction: .left)
            hero_dismissViewController()
        case .changed:
            // not working well
            Hero.shared.update(progress)
//            let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
//            Hero.shared.apply(modifiers: [.position(currentPos)], to: sceneLocationView)
        default:
            //keep causing problem
            if progress + pan2Main.velocity(in: nil).x / sceneLocationView.bounds.width > 0.3 {
                Hero.shared.finish()
            } else {
                sceneLocationView.run()
                Hero.shared.cancel()
            }
        }
        sceneLocationView.pause()
        Hero.shared.defaultAnimation = .pull(direction: .left)
        hero_dismissViewController()
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
