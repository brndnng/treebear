//
//  MenuTableViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 25/1/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import GoogleSignIn
import SafariServices
import Hero

class MenuTableViewController: UITableViewController, GIDSignInUIDelegate {
    
    weak var delegate: SegueHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 4
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        switch section{
//        case 0:
//            return 1
//        case 1:
//            return 2
//        case 2:
//            return 2
//        case 3:
//            return 1
//        default:
//            return 0
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            if(indexPath.row == 0){
                // starred location
                delegate?.segueToNext(identifier: "StarredPOI")
            }else{
                //trips
                delegate?.segueToNext(identifier: "Trips")
            }
        case 1:
            if(indexPath.row == 0){
                //about us
                let svc = SFSafariViewController(url: URL(string: "http://ec2-50-112-76-72.us-west-2.compute.amazonaws.com/project/ios/about.html")!)
                Hero.shared.defaultAnimation = .push(direction: .left)
                present(svc, animated: true, completion: {()->Void in Hero.shared.defaultAnimation = .pull(direction: .right)})
            } else {
                //t&c
                let svc = SFSafariViewController(url: URL(string: "http://ec2-50-112-76-72.us-west-2.compute.amazonaws.com/project/ios/tnc.html")!)
                Hero.shared.defaultAnimation = .push(direction: .left)
                present(svc, animated: true, completion: {()->Void in Hero.shared.defaultAnimation = .pull(direction: .right)})
            }
        case 2:
            let dialogMessage = UIAlertController(title: "Confirm to Logout", message: "All progress of on-going trips will be lost. Are you sure you want to log out?", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "Logout", style: .default, handler: { (action) -> Void in
                GIDSignIn.sharedInstance().signOut()
                print("logout")
                let defaults = UserDefaults.standard
                let dictionary = defaults.dictionaryRepresentation()
                dictionary.keys.forEach { key in
                    defaults.removeObject(forKey: key)
                }
                UserDefaults.standard.synchronize()
                self.delegate?.segueToNext(identifier: "LoggedOut")
            })
            
            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button tapped")
            }
            
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
        default:
            _ = 1
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
