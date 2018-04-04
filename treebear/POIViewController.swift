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
    // Parameters
    let max_num_of_cards = 5
    let padding : CGFloat = 10
    let tripsInProgress: [Int] = UserDefaults.standard.object(forKey: "tripsInProgress") as! [Int]
    
    var x : CGFloat = 0
    var y : CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ScrollingDetails.delegate = self
        ScrollingDetails.isPagingEnabled = true
        ScrollingDetails.contentInset = UIEdgeInsets.zero

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
        ScrollingDetails.isDirectionalLockEnabled = true

        let viewWidth = ScrollingDetails.frame.size.width - 2 * padding //width for each card
        let viewHeight = ScrollingDetails.frame.size.height - 2 * padding //height for each card
        y = viewHeight
        let helpers = Helpers()
        print("Searching for POI: ",thisPOIId!)
        helpers.postRequest(args:["type":"poi",
                                  "action":"get",
                                  "POIId":"\(thisPOIId!)"]){(_json) in
                                    DispatchQueue.main.async {
//                                        print(_json["cards"])
                                        let cards = _json["cards"].array
                                        for card in cards!{
                                            let view = UIView()
                                            // Check if trip is in progress or 'always shown', add ||true|| for testing card layout
                                            if (card["trip"].intValue == 1 || self.tripsInProgress.contains(card["trip"].intValue)){
                                                
                                                if card["card_type"].stringValue == "info" {
                                                    var cardInfo = UILabel()
                                                    var cardImage = UIImageView()
                                                    
                                                    
                                                    helpers.getImageByURL(url: card["picURL"].stringValue){(_img) in DispatchQueue.main.async{
                                                        cardImage.image = _img
                                                        
                                                        }}

                                                    cardInfo.text = card["info"].stringValue
    //                                                cardInfo.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et purus dignissim, porta diam id, sodales nulla. Mauris pulvinar varius ex, nec fermentum felis sagittis a. Integer eget lacus dui. Donec faucibus convallis commodo. Phasellus lacinia, justo ut convallis ultrices, lorem tellus varius leo, vel semper magna metus vel tortor. Donec at sagittis magna. Nullam egestas libero nec ligula consequat hendrerit. Nullam sit amet risus odio. Donec vitae lacus sollicitudin, porta ex sed, ultricies neque. Nulla mattis lectus vel leo tempus, ac tincidunt odio luctus. Suspendisse vel molestie est, elementum varius tellus. Ut a eros id augue semper commodo eget quis libero. Praesent varius risus in lacus malesuada fringilla. Nunc facilisis dapibus ipsum, a fringilla tortor. Etiam hendrerit ex nec egestas porttitor."
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
                                                    
                                                    
                                                    view.frame = CGRect(x: self.x+self.padding, y: self.padding, width: viewWidth, height:max(cardInfo.frame.height + cardImage.frame.height + self.padding * 4,viewHeight))
                                                    self.cardsList.append(InfoCard(info: cardInfo, trip: card["trip"].intValue, pic: cardImage))
                                                    print(view.frame)
                                                    view.addSubview(cardImage)
                                                    view.addSubview(cardInfo)
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
                                                    question.frame = CGRect(x: self.padding, y: self.padding, width: max(newSize.width,viewWidth - 2*self.padding), height: newSize.height)
                                                    var button_y = question.frame.height + self.padding * 3
                                                    let optionA = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: button_y + self.padding, width:200, height: 75))
                                                    optionA.setTitle(card["optionA"].stringValue, for: .normal)
                                                    optionA.backgroundColor = .blue
                                                    view.addSubview(optionA)
                                                    options.append(optionA)
                                                    button_y += 100
                                                    let optionB = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: button_y + self.padding, width:200, height: 75))
                                                    optionB.setTitle(card["optionB"].stringValue, for: .normal)
                                                    optionB.backgroundColor = .blue
                                                    view.addSubview(optionB)
                                                    options.append(optionB)
                                                    button_y += 100
                                                    let optionC = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: button_y + self.padding, width:200, height: 75))
                                                    optionC.setTitle(card["optionC"].stringValue, for: .normal)
                                                    optionC.backgroundColor = .blue
                                                    view.addSubview(optionC)
                                                    options.append(optionC)
                                                    button_y += 100
                                                    let optionD = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: button_y + self.padding, width:200, height: 75))
                                                    optionD.setTitle(card["optionD"].stringValue, for: .normal)
                                                    optionD.backgroundColor = .blue
                                                    view.addSubview(optionD)
                                                    options.append(optionD)
                                                    button_y += 100
                                                    view.addSubview(question)
                                                    self.cardsList.append(QuizCard(question: question, options: options, CorrectAns: card["CorrectAns"].stringValue, trip: card["trip"].intValue))

                                                }

                                                view.backgroundColor = UIColor.white
                                                self.ScrollingDetails.addSubview(view)
                                                self.x = view.frame.origin.x + viewWidth + self.padding
                                                self.y = max(self.y,view.frame.height + self.padding * 2)
//                                                print("x:",self.x,"y:",self.y)


                                            }
                                        }
                                        self.ScrollingDetails.contentSize = CGSize(width: self.x, height:self.y)
                                        print(self.ScrollingDetails.contentSize)
//                                        for card in self.cardsList{
//                                            card.applyCard(baseview: self.ScrollingDetails)
//                                            }
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
