//
//  SignInViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 24/1/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import GoogleSignIn
import Hero

class SignInViewController: UIViewController, GIDSignInUIDelegate {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func disconnect(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
    }
}
