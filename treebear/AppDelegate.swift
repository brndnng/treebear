//
//  AppDelegate.swift
//  treebear
//
//  Created by Brandon Ng on 7/11/2017.
//  Copyright © 2017 Brandon Ng. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let googleInfo = NSDictionary(contentsOfFile: path),
            let clientId = googleInfo["CLIENT_ID"] as? String {
            GIDSignIn.sharedInstance().clientID = clientId
        }
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    private func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handle(
            url as URL!,
            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication.rawValue] as! String?,
            annotation: options[UIApplicationOpenURLOptionsKey.annotation.rawValue])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("signIN")
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            //            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            //            let givenName = user.profile.givenName
            //            let familyName = user.profile.familyName
            //            let email = user.profile.email
            //            if(user.profile.hasImage){
            //                let url = try? user.profile.imageURL(withDimension: 300)
            //                if(url != nil){
            //                    let imageData = try? Data(contentsOf: url!)
            //                    if(imageData != nil){
            //                        let image = UIImage(data: imageData!)
            //                    } else{
            //                        let image = UIImage(named: "user")
            //                    }
            //                }else{
            //                    let image = UIImage(named: "user")
            //                }
            //            }
            print(fullName! + userId!)
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") 
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            self.window?.rootViewController = vc
//            self.window?.makeKeyAndVisible()
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    

}

