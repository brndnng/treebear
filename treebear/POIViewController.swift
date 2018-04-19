//
//  POIViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 19/1/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import Hero
import CoreLocation

class POIViewController: UIViewController,UIScrollViewDelegate, CLLocationManagerDelegate {
    
    var thisPOITitle: String?
    var thisPOIExcerpt: String?
    var thisPOIId: Int?
    var bgColor: UIColor = .clear
    var quiz_button_counter = 1

    
    @IBOutlet weak var POIOverView: UIView!
    @IBOutlet weak var POIName: UILabel!
    @IBOutlet weak var POIExcerpt: UILabel!
    @IBOutlet weak var ScrollingDetails: UIScrollView!
    @IBOutlet weak var PanDownMap: UIPanGestureRecognizer!
    @IBOutlet weak var nothingIndicatorLabel: UILabel!
    
    var location_manager: CLLocationManager?
    var location: CLLocation?
    var cardsList = [Card]()
    //Test card
//    var cardView = UIImageView()
//    var cardInfo = UILabel()
    // Parameters
    let max_num_of_cards = 5
    let padding : CGFloat = 10
    var tripsInProgress: [Int] = UserDefaults.standard.object(forKey: "tripsInProgress") as! [Int]

    var x : CGFloat = 0
    var y : CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nothingIndicatorLabel.isHidden = true
        
        ScrollingDetails.delegate = self
        ScrollingDetails.isPagingEnabled = true
        ScrollingDetails.contentInset = UIEdgeInsets.zero
        location_manager = CLLocationManager()
        location_manager?.delegate = self
        location_manager?.requestAlwaysAuthorization()
        location_manager?.startUpdatingLocation()
        //Load JSON
        //updateContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
        ScrollingDetails.isDirectionalLockEnabled = true
        location_manager?.requestLocation()
        
        let viewWidth = ScrollingDetails.frame.size.width - 2 * padding //width for each card
        let viewHeight = ScrollingDetails.frame.size.height - 2 * padding //height for each card
        y = viewHeight
        let helpers = Helpers()
        print("Searching for POI:",thisPOIId!)
        print("Trips in progress:", tripsInProgress)
        helpers.postRequest(args:["type":"poi",
                                  "action":"get",
                                  "POIId":"\(thisPOIId!)"]){(_json) in
                                    DispatchQueue.main.async {
//                                        print(_json["cards"])
                                        let cards = _json["cards"].array
                                        let POI_coordinates = CLLocationCoordinate2D(latitude: _json["latitude"].doubleValue, longitude: _json["longitude"].doubleValue)
                                        var sthAppeared = false
                                        for card in cards!{
                                            let view = UIView()
                                            print("POI_coor:",POI_coordinates)
                                            print("My location:",self.location)
                                            let distance = (self.location?.distance(from: CLLocation(coordinate: POI_coordinates, altitude: 0)))
                                            print("Distance:",distance)
                                            // Check if trip is in progress or 'always shown', add ||true|| for testing card layout
                                            if (card["trip"].intValue == -1 || (self.tripsInProgress.contains(card["trip"].intValue) && Double(distance!) < 100.0)){
                                                    if card["card_type"].stringValue == "info" {
                                                        var cardInfo = UILabel()
                                                        var cardImage = UIImageView()
                                                        
                                                        
                                                        helpers.getImageByURL(url: card["picURL"].stringValue){(_img) in DispatchQueue.main.async{
                                                            cardImage.image = _img
                                                            
                                                            }}

                                                        cardInfo.text = card["info"].stringValue
                                                        print("Add infocard")
                                                        cardInfo.textColor = UIColor.black
        //                                                view.addSubview(cardInfo)
        //                                                view.bringSubview(toFront: cardInfo)
                                                        cardInfo.numberOfLines = 0
                                                        cardInfo.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                        // Calculate new size for content view
                                                        let newSize = cardInfo.sizeThatFits(CGSize(width: viewWidth - 2*self.padding, height: 5000))
                                                        
                                                        cardImage.contentMode = UIViewContentMode.scaleAspectFit
                                                        cardImage.frame = CGRect(x: self.padding, y: self.padding, width: max(newSize.width,viewWidth - 2*self.padding), height: 200)
                                                        cardInfo.frame = CGRect(x: self.padding, y: cardImage.frame.origin.y + cardImage.frame.height + self.padding * 2, width: max(newSize.width,viewWidth - 2*self.padding), height: newSize.height)
                                                        
                                                        view.layer.cornerRadius = 5
                                                        view.frame = CGRect(x: self.x+self.padding, y: self.padding, width: viewWidth, height:max(cardInfo.frame.height + cardImage.frame.height + self.padding * 4,viewHeight))
                                                        self.cardsList.append(InfoCard(info: cardInfo, trip: card["trip"].intValue, pic: cardImage))
                                                        print(view.frame)
                                                        view.addSubview(cardImage)
                                                        view.addSubview(cardInfo)
                                                        if card == cards![0]{
                                                            self.markPOIComplete(index: 0)
                                                        }
                                                        print("x:",self.x,"y:",self.y)
                                                    }
                                                    else if card["card_type"].stringValue == "quiz" {
                                                        var question = UILabel()
                                                        var options = [UIButton]()
                                                        
                                                        question.text = card["question"].stringValue
                                                        question.numberOfLines = 0
                                                        question.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                        print("Add quizcard")
                                                        
                                                        for (key,value) in card{
    //                                                        print(key,value)
                                                            if key.contains("option"){
                                                                print(value)
                                                                var button = UIButton()
                                                                button.setTitle(value.stringValue, for: .normal)
                                                                options.append(button)
                                                            }
                                                        }
                                                       
                                                       
                                                        // Calculate new size for content view
                                                        let newSize = question.sizeThatFits(CGSize(width: viewWidth - 2*self.padding, height: 500))
                                                        print("x:",self.x,"y:",self.y)
                                                        
                                                        
                                                        view.frame = CGRect(x: self.x+self.padding, y: self.padding, width: viewWidth, height:viewHeight)
                                                        view.layer.cornerRadius = 5
                                                        question.frame = CGRect(x: self.padding, y: self.padding, width: max(newSize.width,viewWidth - 2*self.padding), height: newSize.height)
                                                        view.addSubview(question)
                                                        var button_y = question.frame.height + self.padding * 3
                                                        
                                                        let optionA = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: button_y + self.padding, width:200, height: 75))
                                                        optionA.setTitle(card["optionA"].stringValue, for: .normal)
                                                        optionA.backgroundColor = UIColorFromRGB(rgbValue: 0x37474F)
                                                        optionA.layer.cornerRadius = 5
                                                        optionA.tag = Int(card["trip"].stringValue + String(self.quiz_button_counter))!
                                                        optionA.addTarget(self,action:#selector(self.quizButtonClicked),for:.touchUpInside)
                                                        self.quiz_button_counter += 1
                                                        optionA.sizeThatFits(CGSize(width: view.frame.width - 2*self.padding, height: 100))
                                                        optionA.center.x = view.frame.width / 2
                                                        view.addSubview(optionA)
                                                        options.append(optionA)
                                                        button_y += 100
                                                        
                                                        let optionB = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: button_y + self.padding, width:200, height: 75))
                                                        optionB.setTitle(card["optionB"].stringValue, for: .normal)
                                                        optionB.backgroundColor = UIColorFromRGB(rgbValue: 0x37474F)
                                                        optionB.layer.cornerRadius = 5
                                                        optionB.tag = Int(card["trip"].stringValue + String(self.quiz_button_counter))!
                                                        optionB.addTarget(self,action:#selector(self.quizButtonClicked),for:.touchUpInside)
                                                        self.quiz_button_counter += 1
                                                        optionB.sizeThatFits(CGSize(width: view.frame.width - 2*self.padding, height: 100))
                                                        optionB.center.x = view.frame.width / 2
                                                        view.addSubview(optionB)
                                                        options.append(optionB)
                                                        button_y += 100
                                                        
                                                        let optionC = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: button_y + self.padding, width:200, height: 75))
                                                        optionC.setTitle(card["optionC"].stringValue, for: .normal)
                                                        optionC.backgroundColor = UIColorFromRGB(rgbValue: 0x37474F)
                                                        optionC.layer.cornerRadius = 5
                                                        optionC.tag = Int(card["trip"].stringValue + String(self.quiz_button_counter))!
                                                    optionC.addTarget(self,action:#selector(self.quizButtonClicked),for:.touchUpInside)
                                                        self.quiz_button_counter += 1
                                                        optionC.sizeThatFits(CGSize(width: view.frame.width - 2*self.padding, height: 100))
                                                        optionC.center.x = view.frame.width / 2
                                                        view.addSubview(optionC)
                                                        options.append(optionC)
                                                        button_y += 100
                                                        let optionD = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: button_y + self.padding, width:200, height: 75))
                                                        optionD.setTitle(card["optionD"].stringValue, for: .normal)
                                                        optionD.backgroundColor = UIColorFromRGB(rgbValue: 0x37474F)
                                                        optionD.layer.cornerRadius = 5
                                                        optionD.tag = Int(card["trip"].stringValue + String(self.quiz_button_counter))!
                                                    optionD.addTarget(self,action:#selector(self.quizButtonClicked),for:.touchUpInside)
                                                        self.quiz_button_counter += 1
                                                        optionD.sizeThatFits(CGSize(width: view.frame.width - 2*self.padding, height: 100))
                                                        optionD.center.x = view.frame.width / 2
                                                        view.addSubview(optionD)
                                                        options.append(optionD)
                                                        button_y += 100
                                                        
                                                        self.cardsList.append(QuizCard(question: question, options: options, CorrectAns: card["CorrectAns"].stringValue, trip: card["trip"].intValue))

                                                    }
                                                    
                                                    view.backgroundColor = UIColor.white
                                                    self.ScrollingDetails.addSubview(view)
                                                    self.x = view.frame.origin.x + viewWidth + self.padding
                                                    self.y = max(self.y,view.frame.height + self.padding * 2)
    //                                                print("x:",self.x,"y:",self.y)

                                                    sthAppeared = true
                                                }
                                            
                                        }
                                        if(sthAppeared){
                                            self.nothingIndicatorLabel?.removeFromSuperview()
                                        }else{
                                            self.nothingIndicatorLabel?.isHidden = false
                                        }
                                        
                                        self.quiz_button_counter = 1 //reset quiz button counter to 1
                                        self.ScrollingDetails.contentSize = CGSize(width: self.x, height:self.y)
                                        print(self.ScrollingDetails.contentSize)
                                    }
                                    
        }
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
    @objc func quizButtonClicked(sender:UIButton)
    {
        let tag = String(sender.tag)
        let last_char = tag.index(before: tag.endIndex)
        let trip_of_quiz = Int(tag[..<last_char])
        let choice = Int(String(tag[last_char]))//get last char of tag
        print(trip_of_quiz,choice)
        for card in cardsList{
            if card is QuizCard {
                let temp_card = (card as? QuizCard)
                if temp_card?.trip == trip_of_quiz{
                    let correct_ans = temp_card?.CorrectAns
                    let correct_ans_int: Int
                    switch correct_ans
                    {
                    case "A"?: correct_ans_int = 1
                        break
                    case "B"?: correct_ans_int = 2
                        break
                    case "C"?: correct_ans_int = 3
                        break
                    case "D"?: correct_ans_int = 4
                        break
                    case .none:
                        print("Empty")
                        correct_ans_int = -1
                    case .some(_):
                        print("Other...")
                        correct_ans_int = -1
                    }
                    if choice == correct_ans_int{
                        print("Correct!")
                        sender.backgroundColor = .green
                    }
                    else{
                        print("Try again!")
                        sender.superview?.subviews.forEach({$0.backgroundColor = .blue})//Set other buttons to                blue
                        sender.superview?.subviews[0].backgroundColor = .clear
                        sender.backgroundColor = .red //Set button to red
                        sender.superview?.subviews[correct_ans_int].backgroundColor = .green //Set button with correct answer to green
                    }
                    let currentIndex = Int(ScrollingDetails.contentOffset.x / CGFloat(ScrollingDetails.frame.width))
                    print(currentIndex)
                    markPOIComplete(index: currentIndex)
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            location = locations.first
//            print("location",location)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            location_manager?.requestLocation()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let viewWidth = ScrollingDetails.frame.size.width - 2 * padding //width for each card
        let currentIndex = Int(ScrollingDetails.contentOffset.x / CGFloat(ScrollingDetails.frame.width))
        print(currentIndex)
        markPOIComplete(index: currentIndex)
    }
    func markPOIComplete(index: Int){
        print("index:",index)
//        thisPOIId
        let trip_id = cardsList[index].trip
        print("TripId:",trip_id)
        print("POIId:",thisPOIId)
        var tripsDetails = UserDefaults.standard.dictionary(forKey: "tripsDetails") as! [String: Any]
        var POIS = tripsDetails["1"] as? [String:Any]
    
        for (key,value) in tripsDetails{
            if trip_id == Int(key){
                var temp_trip = value as! [String:Any]
                var POIS = temp_trip["POIS"] as! [String:Bool]
                var POIId = String(describing: thisPOIId!)
                let keyExists = POIS[POIId] != nil //Check if POI in trip
                if keyExists && POIS[POIId] == false{ //Check if POI already marked
                    POIS.updateValue(true, forKey: POIId) // Update POI value to true
                    // Check if all POIS are visited
                    let allPOISvisited = !POIS.values.contains { (value) -> Bool in value == false}
                    if allPOISvisited{
                        tripsDetails.removeValue(forKey: key) // Remove trip from tripsDetails
                        var finishedTrips: [Int] = UserDefaults.standard.object(forKey: "finishedTrips") as! [Int]
                        finishedTrips.append(trip_id) // Add trip to finishedTrips
                        UserDefaults.standard.set(finishedTrips, forKey: "finishedTrips")
                        // Update tripsInProgess
                        tripsInProgress[tripsInProgress.index(of: trip_id)!] = -1
                        UserDefaults.standard.set(tripsInProgress, forKey: "tripsInProgress")
                        // Send a post request
                        let helper = Helpers()
                        helper.postRequest(args: ["action": "set",
                                                   "type": "tripEnd",
                                                   "tripId": "\(trip_id)"]){(response) in print(response)}
                        // Display dialog that user has completed trip
                        let dialogMessage = UIAlertController(title: "Congratulations!", message: "You have completed this trip!", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Yay!", style: .default){ (action) -> Void in
                            print("OK button tapped")}
                        dialogMessage.addAction(ok)
                        // Present dialog message to user
                        self.present(dialogMessage, animated: true, completion: nil)
                        }
                        
                    else{
                        temp_trip.updateValue(POIS, forKey: "POIS")
                        tripsDetails.updateValue(temp_trip, forKey: key)
                        print(POIS)
                        print(temp_trip)
                        print(tripsDetails)
                    }
                }
                break
            }
        }
        UserDefaults.standard.set(tripsDetails, forKey: "tripsDetails")
//        cardsList[index]
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

//                                            if card["card_type"].stringValue == "info" {
//                                                var cardView = UIImageView()
//                                                var cardInfo = UILabel()
//                                                cardView.frame = CGRect(x: self.ScrollingDetails.frame.origin.x+20, y: self.ScrollingDetails.frame.origin.y-50, width: self.ScrollingDetails.frame.size.width-40, height: self.ScrollingDetails.frame.size.height/2)
//                                                cardView.contentMode = UIViewContentMode.scaleToFill
//                                                cardInfo.frame = CGRect(x: self.ScrollingDetails.frame.origin.x+20, y: cardView.frame.origin.y+cardView.frame.size.height/2+20, width: self.ScrollingDetails.frame.size.width-40, height: self.ScrollingDetails.frame.size.height/2)
//
//                                                print(card["info"].stringValue)
//                                                helpers.getImageByURL(url: card["picURL"].stringValue){(_img) in DispatchQueue.main.async{
//                                                    cardView.image = _img

//                                                    }}
//                                                cardInfo.text = card["info"].stringValue
////                                                self.ScrollingDetails.addSubview(cardInfo)
////                                                self.ScrollingDetails.addSubview(cardView)
////                                                var a = InfoCard(info: cardInfo, trip: card["trip"].intValue, pic: cardView)
////                                                a.applyCard(baseview: self.ScrollingDetails)
//                                                self.cardsList.append(InfoCard(info: cardInfo, trip: card["trip"].intValue, pic: cardView))
////                                                print(self.cardsList)
//                                            }
