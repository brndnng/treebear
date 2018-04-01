//
//  POIViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 19/1/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import UIKit
import Hero

class POIViewController: UIViewController,UIScrollViewDelegate {
    
    var thisPOITitle: String?
    var thisPOIExcerpt: String?
    var thisPOIId: Int?
    var bgColor: UIColor = .clear
    
    @IBOutlet weak var POIOverView: UIView!
    @IBOutlet weak var POIName: UILabel!
    @IBOutlet weak var POIExcerpt: UILabel!
    @IBOutlet weak var ScrollingDetails: UIScrollView!
    @IBOutlet weak var PanDownMap: UIPanGestureRecognizer!
    
    var cardsList = [Card]()
    //Test card
//    var cardView = UIImageView()
//    var cardInfo = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ScrollingDetails.delegate = self
        //Load JSON
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
        
//        cardView.frame = CGRect(x: ScrollingDetails.frame.origin.x+20, y: ScrollingDetails.frame.origin.y-50, width: ScrollingDetails.frame.size.width-40, height: ScrollingDetails.frame.size.height/2)
//        cardView.contentMode = UIViewContentMode.scaleToFill
//        cardInfo.frame = CGRect(x: ScrollingDetails.frame.origin.x+20, y: cardView.frame.origin.y+cardView.frame.size.height/2+20, width: ScrollingDetails.frame.size.width-40, height: ScrollingDetails.frame.size.height/2)
        
        let helpers = Helpers()
        print("Searching for POI: ",thisPOIId!)
        helpers.postRequest(args:["type":"poi",
                                  "action":"get",
                                  "POIId":"\(thisPOIId!)"]){(_json) in
                                    DispatchQueue.main.async {
//                                        print(_json["cards"])
                                        let cards = _json["cards"].array
                                        for card in cards!{
                                            if card["card_type"].stringValue == "info" {
                                                var cardView = UIImageView()
                                                var cardInfo = UILabel()
                                                cardView.frame = CGRect(x: self.ScrollingDetails.frame.origin.x+20, y: self.ScrollingDetails.frame.origin.y-50, width: self.ScrollingDetails.frame.size.width-40, height: self.ScrollingDetails.frame.size.height/2)
                                                cardView.contentMode = UIViewContentMode.scaleToFill
                                                cardInfo.frame = CGRect(x: self.ScrollingDetails.frame.origin.x+20, y: cardView.frame.origin.y+cardView.frame.size.height/2+20, width: self.ScrollingDetails.frame.size.width-40, height: self.ScrollingDetails.frame.size.height/2)
                                                
                                                print(card["info"].stringValue)
                                                helpers.getImageByURL(url: card["picURL"].stringValue){(_img) in DispatchQueue.main.async{
                                                    cardView.image = _img
                                                    
                                                    }}
                                                cardInfo.text = card["info"].stringValue
//                                                self.ScrollingDetails.addSubview(cardInfo)
//                                                self.ScrollingDetails.addSubview(cardView)
//                                                var a = InfoCard(info: cardInfo, trip: card["trip"].intValue, pic: cardView)
//                                                a.applyCard(baseview: self.ScrollingDetails)
                                                self.cardsList.append(InfoCard(info: cardInfo, trip: card["trip"].intValue, pic: cardView))
//                                                print(self.cardsList)
                                            }
                                            else if card["card_type"].stringValue == "quiz" {
                                                
                                            }
                                        }
                                        for card in self.cardsList{
                                            card.applyCard(baseview: self.ScrollingDetails)
                                            }
                                    }
                                    
        }
//        for card in cardsList{
//            print(card)
//            card.applyCard(baseview: ScrollingDetails)
//        }
//        ScrollingDetails.addSubview(self.cardInfo)
//        ScrollingDetails.addSubview(self.cardView)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
