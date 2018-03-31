//
//  entryViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 25/1/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import GoogleSignIn
import Hero

class entryViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
    
    let helper = Helpers()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        Thread.sleep(forTimeInterval: 0.5)
        GIDSignIn.sharedInstance().signInSilently()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        Hero.shared.defaultAnimation = .fade
        if(error == nil){
            print(user.profile.name + " Signed in sliently")
            helper.postRequest(args:["type":"user",
                                     "action":"set"]){
                                        (_json) in
                                        //check user default and update if needed
            }
            performSegue(withIdentifier: "loggedInSliently", sender: self)
        }else{
            performSegue(withIdentifier: "cantLogInSliently", sender: self)
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
