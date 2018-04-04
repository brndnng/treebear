//
//  extras.swift
//  treebear
//
//  Created by Ricky Cheng on 3/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import Foundation
import MapKit
import GoogleSignIn


class ExtenedColors{
    public var tripColor = [
        ["light": UIColorFromRGB(rgbValue: 0xF48FB1), "dark": UIColorFromRGB(rgbValue: 0xAD1457)],
        ["light": UIColorFromRGB(rgbValue: 0xCE93D8), "dark": UIColorFromRGB(rgbValue: 0x6A1B9A)],
        ["light": UIColorFromRGB(rgbValue: 0x9FA8DA), "dark": UIColorFromRGB(rgbValue: 0x283593)],
        ["light": UIColorFromRGB(rgbValue: 0x80DEEA), "dark": UIColorFromRGB(rgbValue: 0x00838F)],
        ["light": UIColorFromRGB(rgbValue: 0xBCAAA4), "dark": UIColorFromRGB(rgbValue: 0x4E342E)],
    ]
    
    public var noTripColor = ["light": UIColorFromRGB(rgbValue: 0xB0BEC5), "dark": UIColorFromRGB(rgbValue: 0x37474F)]
    
    public var destColor = ["light": UIColorFromRGB(rgbValue: 0xA5D6A7), "dark": UIColorFromRGB(rgbValue: 0x2E7D32)]
}

class Helpers{
    public func getDist(from:CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> Double {
        return CLLocation(latitude: to.latitude, longitude: to.longitude).distance(from: CLLocation(latitude: from.latitude, longitude: from.longitude))
    }
    
    public func postRequest(args:[String:String], completionHandler: @escaping (JSON)->Void) -> Void {
        //update id token to avoid 403
        GIDSignIn.sharedInstance().currentUser.authentication.getTokensWithHandler(){ (_, _) in
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded",
                "Cache-Control": "no-cache"
            ]
            
            let postData = NSMutableData(data: "idToken=\(GIDSignIn.sharedInstance().currentUser.authentication.idToken!)".data(using: String.Encoding.utf8)!)
            for (postKey, postValue) in args{
                postData.append("&\(postKey)=\(postValue)".data(using: String.Encoding.utf8)!)
            }
            
            let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-50-112-76-72.us-west-2.compute.amazonaws.com/project/json/postTest.php/")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    //let httpResponse = response as? HTTPURLResponse
                    do {
                        let json = try JSON(data: data!)
                        completionHandler(json)
                    } catch {
                        print("JSON parsing error.\n\(response)")
                    }
                }
            })
            
            dataTask.resume()
        }
    }
    
    public func getImageByURL(url: String, completionHandler: @escaping (UIImage)->Void) -> Void{
        let url = URL(string: url)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        if let image = data {
            completionHandler(UIImage(data: image)!)
        }
        
    }
    
    public func syncUserDefaultIfNeeded(completionHandler: @escaping ()->Void){
        if(UserDefaults.standard.object(forKey: "tripsInProgress") == nil ||
            UserDefaults.standard.object(forKey: "tripsDetails") == nil ||
            UserDefaults.standard.object(forKey: "finishedTrips") == nil){
            let dictionary = UserDefaults.standard.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
            postRequest(args:["type":"user",
                              "action":"set"]){
                                (_json) in
                                //check user default and update if needed
                                
                                    var tripsInProgress: [Int] = []
                                    for poiId in _json["onGoing"].arrayValue{
                                        tripsInProgress.append(poiId.intValue)
                                    }
                                    if(tripsInProgress.count < 5){
                                        for _ in (tripsInProgress.count)...4{
                                            tripsInProgress.append(-1)
                                        }
                                    }else if(tripsInProgress.count > 5){
                                        tripsInProgress = Array(tripsInProgress[0..<5])
                                    }
                                    UserDefaults.standard.set(tripsInProgress, forKey: "tripsInProgress")
                                
                                    self.recursion(remaining: tripsInProgress.filter({$0 != -1}), tripsDetails: [:])
                                //}

            }
            postRequest(args: ["action": "get",
                               "type": "finished"]){
                                (_json) in
                                var finishedTrips:[Int] = []
                                for trip in _json["trips"]["trip"].arrayValue{
                                    finishedTrips.append(trip["id"].intValue)
                                }
                                UserDefaults.standard.set(finishedTrips, forKey: "finishedTrips")
            }
            
            //wait til above async finish
            while true{
                if(UserDefaults.standard.object(forKey: "tripsInProgress") != nil &&
                    UserDefaults.standard.object(forKey: "tripsDetails") != nil &&
                    UserDefaults.standard.object(forKey: "finishedTrips") != nil){
                    completionHandler()
                    break
                }
            }
        } else{
            postRequest(args:["type":"user",
                              "action":"set"]){ (_json) in
                                DispatchQueue.main.async {
                                    completionHandler()
                                }
            }
        }
    }
    
    func recursion(remaining: [Int], tripsDetails:[String: Any]){
        if(remaining.isEmpty){
            UserDefaults.standard.set(tripsDetails, forKey: "tripsDetails")
        }else{
            //add to trip details
            postRequest(args: ["action": "get",
                               "type": "trip",
                               "tripId": "\(remaining[0])"]){
                                (serverResponse) in
                                var pois:[String: Bool] = [:]
                                for poi in serverResponse["POI_sequence"].arrayValue{
                                    pois["\(poi.intValue)"] = false
                                }
                                let tripDetails: [String : Any] = ["name": serverResponse["title"].stringValue,
                                                                    "excerpt": serverResponse["excerpt"].stringValue,
                                                                    "pic_url": serverResponse["picURL"].stringValue,
                                                                    "POIS": pois]
                                var tripsDetail = tripsDetails
                                tripsDetail["\(serverResponse["id"].intValue)"] = tripDetails
                                //recursion
                                self.recursion(remaining: Array(remaining.dropFirst()), tripsDetails: tripsDetail)
            }
        }
    }
}

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
struct SearchItem {
    let type : String
    let title : String
    let id : Int
    let excerpt : String
    let coordinates: CLLocationCoordinate2D
}
class Card {
    var type: String { return ""}
    func applyCard(baseview: UIView){
        
    }
}
class InfoCard : Card {
    override var type: String { return "info"}
    var info: UILabel
    var trip: Int
    var pic: UIImageView
    init(info: UILabel, trip: Int, pic: UIImageView) {
        self.info = info
        self.trip = trip
        self.pic = pic
    }
    override func applyCard(baseview: UIView){
        print("Add subview of InfoCard")
        baseview.addSubview(pic)
        baseview.addSubview(info)
    }
}
class QuizCard : Card {
    override var type: String {return "quiz"}
    var question: UILabel
    var options: [UIButton]
    var CorrectAns: String
    var trip: Int
    init(question: UILabel, options:[UIButton],CorrectAns: String, trip: Int) {
        self.question = question
        self.options = options
        self.CorrectAns = CorrectAns
        self.trip = trip
    }
    override func applyCard(baseview: UIView) {
        print("Add subview of QuizCard")
        baseview.addSubview(question)
        for option in options{
            baseview.addSubview(option)
        }
    }
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-160, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.sizeToFit()
        toastLabel.frame.size = CGSize(width: toastLabel.frame.width + 16, height: toastLabel.frame.height + 16)
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 2.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }


