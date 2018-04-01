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
