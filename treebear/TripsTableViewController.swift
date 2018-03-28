//
//  TripsTableViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 16/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import Hero

class TripsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var view4Pan: UIView!
    
    var serverResponse: JSON?
    var onGoingTrips: [Int: [String: Any]]?
    var pressedCellTripId: Int?
    
    let helper = Helpers()
    let colors = ExtenedColors()
    let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)

    @IBOutlet weak var pan2Menu: UIScreenEdgePanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        //table height fix
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        
        alert.view.tintColor = .black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        view.addSubview(tableView)
        view.addSubview(view4Pan)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        helper.postRequest(args: ["action": "get",
                                  "type": "finished"], completionHandler: insertDataToLayout)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0){
            return 2
        } else if(section == 1){
            if(serverResponse != nil){
                return serverResponse!["num_trip"].int!
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TripsTableViewCell", for: indexPath) as? TripsTableViewCell else { fatalError("The dequeued cell is not an instance of TripsTableViewCell.") }


            // Configure the cell...
        if(indexPath.section == 0){
            
        } else if (indexPath.section == 1){
                if(serverResponse != nil){
                    helper.getImageByURL(url: serverResponse!["trip"][indexPath.row]["picURL"].string!){
                        (img) in
                        DispatchQueue.main.async {
                            cell.tripPic.image = img
                            cell.setNeedsLayout()
                        }
                    }
                    cell.id = serverResponse!["trip"][indexPath.row]["id"].int
                    cell.tripName.text = serverResponse!["trip"][indexPath.row]["title"].string
                    cell.tripExcerpt.text = serverResponse!["trip"][indexPath.row]["excerpt"].string
                    cell.progressPercentage.text = "Finished"
                    cell.barView.frame.size.width = cell.progressBar.frame.size.width
                    cell.barColor = colors.destColor["dark"]
                    cell.barView.backgroundColor = colors.destColor["dark"]
                    cell.progressPercentage.textColor = cell.barView.backgroundColor
                    cell.barView.layer.cornerRadius = cell.barView.frame.height / 2
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Trips In Progress"
        case 1:
            return "Finished Trips"
        default:
            return "Don't ask me!!"
        }
    }
    
    @IBAction func swipeLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = pan2Menu.translation(in: nil)
        let progress = CGFloat(translation.x / 2 / view.bounds.width)
        switch pan2Menu.state {
        case .began:
            // begin the transition as normal
            Hero.shared.defaultAnimation = .pull(direction: .right)
            navigationController?.hero_dismissViewController()
        //testText.text = "test passed"
        case .ended:
            if progress + pan2Menu.velocity(in: nil).x / view.bounds.width > 0.3 {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TripsTableViewCell {
            pressedCellTripId = cell.id
            Hero.shared.defaultAnimation = .push(direction: .left)
            performSegue(withIdentifier: "getDetailsOfTrip", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "getDetailsOfTrip" && self.pressedCellTripId != nil {
            if let nextViewController = segue.destination as? TripDetailsViewController{
                nextViewController.tripId = self.pressedCellTripId!
            }
        }
    }
    
    func insertDataToLayout(_json: JSON){
        self.serverResponse = _json["trips"]
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if(self.tableView.contentSize.height > self.view.frame.height){
                self.tableView.isScrollEnabled = true
            }else{
                self.tableView.isScrollEnabled = false
            }
            self.alert.dismiss(animated: true, completion: nil)
        }
        
    }
    

}
