//
//  BadgesCollectionViewController.swift
//  treebear
//
//  Created by Ricky Cheng on 12/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import Foundation
import UIKit
import Hero

class BadgesCollectionViewController: UIViewController {
    
    @IBOutlet weak var blocker: UIView!
    
    let helper = Helpers()
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let slidingBadges = CardGroupSliding(frame: view.frame)
        slidingBadges.icons = [UIImage(named:"iconInApp")!]
        
        slidingBadges.iconsSize = view.frame.height / 4
        slidingBadges.iconsRadius = view.frame.height / 8
        if(firstLoad){
            helper.postRequest(args: ["action": "get",
                                      "type": "badges"]){
                                        (_json) in
                                        for url in _json["picURL"].arrayValue{
                                            self.helper.getImageByURL(url: url.stringValue){
                                            (image) in
                                                slidingBadges.icons?.append(image)
                                            }
                                        }
                                        DispatchQueue.main.async {
                                            slidingBadges.alpha = 0
                                            self.view.addSubview(slidingBadges)
                                            slidingBadges.startSlide()
                                            UIView.animate(withDuration: 0.5, animations: {
                                                slidingBadges.alpha = 1.0
                                                self.blocker.alpha = 0
                                            })
                                        }
            }
            firstLoad = false
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

// Acknowledgement: The following classes are modified from PaoloCuscela/Cards (MIT License).
// Link to GitHub: https://github.com/PaoloCuscela/Cards

@IBDesignable open class CardGroupSliding: UIView {
    
    /**
     Size for the collection view items.
     */
    @IBInspectable public var iconsSize: CGFloat = 50 {
        didSet{
            slidingCV.reloadData()
        }
    }
    /**
     Corner radius of the collection view items
     */
    @IBInspectable public var iconsRadius: CGFloat = 25 {
        didSet{
            slidingCV.reloadData()
        }
    }
    
    /**
     Data source for the collection view.
     */
    public var icons: [UIImage]?

    
    // Priv vars
    fileprivate final let CellID = "SlidingCVCell"
    fileprivate var slidingCV: UICollectionView!
    fileprivate var timer = Timer()
    fileprivate var w: CGFloat = 0
    fileprivate var layout = UICollectionViewFlowLayout()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        //super.initialize()
        
        //self.delegate = self
        
        layout.scrollDirection = .horizontal
        slidingCV = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        slidingCV.register(SlidingCVCell.self, forCellWithReuseIdentifier: CellID)
        slidingCV.delegate = self
        slidingCV.dataSource = self
        slidingCV.backgroundColor = UIColor.white
        slidingCV.isUserInteractionEnabled = false
        
//        backgroundIV.addSubview(subtitleLbl)
//        backgroundIV.addSubview(titleLbl)
//        backgroundIV.addSubview(slidingCV)
//        blurV.removeFromSuperview()
//
//        backgroundIV.backgroundColor = UIColor.white
        
        //startSlide()
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //subtitleLbl.textColor = textColor.withAlphaComponent(0.4)
        layout(animating: false)
    }
    
    func layout(animating: Bool) {
        //super.layout(animating: animating)
        
        //let gimme = LayoutHelper(rect: backgroundIV.bounds)
        slidingCV.frame = super.frame
        self.addSubview(slidingCV)
    }
    
    //MARK: - Sliding Logic
    
    public func startSlide() {
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.slide), userInfo: nil, repeats: true)
    }
    
    public func stopSlide() {
        timer.invalidate()
    }
    
    private func onTimer(){ slide() }
    
    @objc private func slide(){
        let startPoint = CGPoint(x: w, y: 0)
        if __CGPointEqualToPoint(startPoint, slidingCV.contentOffset) {
            
            if w<slidingCV.contentSize.width { w+=0.3 }
            else { w = -self.frame.size.width }
            
            slidingCV.contentOffset = CGPoint(x: w, y: 0)
        } else {
            w = slidingCV.contentOffset.x
        }
    }
}


//MARK: - Collection View Delegates
extension CardGroupSliding: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if icons?.count != nil { return 10000 }
        else { return 0 }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let icon = icons?[indexPath.row % icons!.count]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath) as! SlidingCVCell
        cell.radius = cell.frame.height/2
        cell.icon = icon
        return cell
        
    }
    
}

extension CardGroupSliding: UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        iconsSize = collectionView.frame.height/3 - layout.minimumLineSpacing
        return CGSize(width: iconsSize, height: iconsSize )
    }
}


open class SlidingCVCell: UICollectionViewCell {
    
    public var icon = UIImage(named: "math")
    public var iconIV = UIImageView()
    public var radius: CGFloat?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(iconIV)
        self.backgroundColor = UIColor.clear
        self.layer.backgroundColor = UIColor.lightGray.cgColor
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = radius ?? 15
        iconIV.image = icon
        iconIV.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.width)
        iconIV.layer.cornerRadius = radius ?? 15
        iconIV.clipsToBounds = true
        iconIV.contentMode = .scaleAspectFill
    }
}












