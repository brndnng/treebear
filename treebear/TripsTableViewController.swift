//
//  TripsTableViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 16/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import Hero

class TripsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var view4Pan: UIView!
    
    var serverResponse: JSON?
    var onGoingTrips: [Int]?
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
        
        onGoingTrips = UserDefaults.standard.array(forKey: "tripsInProgress") as? [Int]
        onGoingTrips = onGoingTrips?.filter({ $0 != -1})
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        //table height fix
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        
        navigationController?.delegate = self
        
        alert.view.tintColor = .black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        view.addSubview(tableView)
        view.addSubview(view4Pan)
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
        if(section == 0){
            return onGoingTrips!.count
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
            let tripInfo = UserDefaults.standard.dictionary(forKey: "tripsDetails")!["\(onGoingTrips![indexPath.row])"] as! [String: Any]
            helper.getImageByURL(url: (tripInfo["pic_url"] as! String)){
                (img) in
                DispatchQueue.main.async {
                    cell.tripPic.image = img
                    cell.setNeedsLayout()
                }
                cell.layoutIfNeeded()
                cell.id = self.onGoingTrips![indexPath.row]
                cell.tripName.text = tripInfo["name"] as? String
                cell.tripExcerpt.text = tripInfo["excerpt"] as? String
                cell.tripName.textColor = .white
                cell.tripExcerpt.textColor = .white
                let trip = UserDefaults.standard.array(forKey: "tripsInProgress") as? [Int]
                let tripPosition = trip?.index(of: self.onGoingTrips![indexPath.row])
                cell.backgroundColor = self.colors.tripColor[tripPosition!]["dark"]
                cell.barColor = .white
                cell.barView.backgroundColor = .white
                var doneCount = 0
                var poiCount = 0
                for (_, value) in (tripInfo["POIS"] as? [String:Bool])!{
                    poiCount += 1
                    if(value == true){
                        doneCount += 1
                    }
                }
                let percentage = Double(doneCount * 100 / poiCount)
                cell.progressPercentage.text = "\(Int(percentage))%"
                cell.percentageWidth.constant = cell.progressBar.frame.size.width * CGFloat(percentage / 100)
                cell.barView.setNeedsLayout()
                cell.progressPercentage.textColor = cell.barView.backgroundColor
                cell.barView.layer.cornerRadius = cell.barView.frame.height / 2
            }
            
        } else if (indexPath.section == 1){
                if(serverResponse != nil){
                    helper.getImageByURL(url: serverResponse!["trip"][indexPath.row]["picURL"].string!){
                        (img) in
                        DispatchQueue.main.async {
                            cell.tripPic.image = img
                            cell.setNeedsLayout()
                        }
                    }
                    cell.layoutIfNeeded()
                    cell.id = serverResponse!["trip"][indexPath.row]["id"].int
                    cell.tripName.text = serverResponse!["trip"][indexPath.row]["title"].string
                    cell.tripExcerpt.text = serverResponse!["trip"][indexPath.row]["excerpt"].string
                    cell.tripName.textColor = .black 
                    cell.tripExcerpt.textColor = .black
                    cell.progressPercentage.text = "Finished"
                    cell.sizeToFit()
                    cell.layoutIfNeeded()
                    cell.percentageWidth.constant = cell.progressBar.frame.size.width * 1
                    cell.barView.setNeedsLayout()
                    cell.barColor = colors.destColor["dark"]
                    cell.barView.backgroundColor = colors.destColor["dark"]
                    cell.progressPercentage.textColor = cell.barView.backgroundColor
                    cell.barView.layer.cornerRadius = cell.barView.frame.height / 2
                    cell.backgroundColor = .clear
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
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        present(alert, animated: true){
            self.helper.postRequest(args: ["action": "get",
                                           "type": "finished"], completionHandler: self.insertDataToLayout)
            self.onGoingTrips = UserDefaults.standard.array(forKey: "tripsInProgress") as? [Int]
            self.onGoingTrips = self.onGoingTrips?.filter({ $0 != -1})
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
                nextViewController.from = "TripsTableViewController"
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
