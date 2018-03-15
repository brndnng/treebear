//
//  extras.swift
//  treebear
//
//  Created by Ricky Cheng on 3/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import Foundation
import MapKit


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
        return 0.0
    }
    
    public func postRequest(args:[String:String], completionHandler: @escaping (JSON)->Void) -> Void {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Cache-Control": "no-cache"
        ]
        
        let postData = NSMutableData(data: "\(args.first?.key)=\(args.first?.value)".data(using: String.Encoding.utf8)!)
        for (postKey, postValue) in args.dropFirst(){
            postData.append("&\(postKey)=\(postValue)".data(using: String.Encoding.utf8)!)
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-50-112-76-72.us-west-2.compute.amazonaws.com/project/postTest.php/")! as URL,
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
                    print("JSON parsing error.")
                }
            }
        })
        
        dataTask.resume()
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
