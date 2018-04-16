//
//  SceneAnnotation.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation
import MapKit

///A location node can be added to a scene using a coordinate.
///Its scale and position should not be adjusted, as these are used for scene layout purposes
///To adjust the scale and position of items within a node, you can add them to a child node and adjust them there
open class LocationNode: SCNNode {
    ///Location can be changed and confirmed later by SceneLocationView.
    public var location: CLLocation!
    
    ///Whether the location of the node has been confirmed.
    ///This is automatically set to true when you create a node using a location.
    ///Otherwise, this is false, and becomes true once the user moves 100m away from the node,
    ///except when the locationEstimateMethod is set to use Core Location data only,
    ///as then it becomes true immediately.
    public var locationConfirmed = false
    
    ///Whether a node's position should be adjusted on an ongoing basis
    ///based on its' given location.
    ///This only occurs when a node's location is within 100m of the user.
    ///Adjustment doesn't apply to nodes without a confirmed location.
    ///When this is set to false, the result is a smoother appearance.
    ///When this is set to true, this means a node may appear to jump around
    ///as the user's location estimates update,
    ///but the position is generally more accurate.
    ///Defaults to true.
    public var continuallyAdjustNodePositionWhenWithinRange = true
    
    ///Whether a node's position and scale should be updated automatically on a continual basis.
    ///This should only be set to false if you plan to manually update position and scale
    ///at regular intervals. You can do this with `SceneLocationView`'s `updatePositionOfLocationNode`.
    public var continuallyUpdatePositionAndScale = true
    
    public enum TypeOfAltitude{
        case fixedAltitude, sameAltitudeAsUser, snapToGround
    }
    
    public var typeOfAltitude: TypeOfAltitude
    
    public init(location: CLLocation?, altitudeType: TypeOfAltitude) {
        self.location = location
        self.locationConfirmed = location != nil
        self.typeOfAltitude = altitudeType
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //extensions
    public static func create(polyline: MKPolyline, altitude: CLLocationDistance, altitudeType: TypeOfAltitude = .snapToGround)  -> [LocationNode] {
        let points = polyline.points()
        
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .ambient
//        lightNode.light!.intensity = 25
//        lightNode.light!.attenuationStartDistance = 100
//        lightNode.light!.attenuationEndDistance = 100
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 0)
//        lightNode.castsShadow = false
//        lightNode.light!.categoryBitMask = 3
        
        let lightNode3 = SCNNode()
        lightNode3.light = SCNLight()
        lightNode3.light!.type = .ambient
        lightNode3.light!.intensity = 100
        lightNode3.light!.castsShadow = true
        lightNode3.castsShadow = false
        lightNode3.light!.categoryBitMask = 3
        
        var nodes = [LocationNode]()
        
        for i in 0..<polyline.pointCount - 1 {
            let currentPoint = points[i]
            let currentCoordinate = MKCoordinateForMapPoint(currentPoint)
            let currentLocation = CLLocation(coordinate: currentCoordinate, altitude: altitude)
            
            let nextPoint = points[i + 1]
            let nextCoordinate = MKCoordinateForMapPoint(nextPoint)
            let nextLocation = CLLocation(coordinate: nextCoordinate, altitude: altitude)
            
            let distance = currentLocation.distance(from: nextLocation)
            
            let box = SCNBox(width: 1.0, height: 0.2, length: CGFloat(distance), chamferRadius: 0.1)
            
            let materialTwoColor = SCNMaterial()
            materialTwoColor.diffuse.contents = #imageLiteral(resourceName: "materialContent")
            materialTwoColor.metalness.contents = 0.5
            
            let materialOneColor = SCNMaterial()
            materialOneColor.diffuse.contents = UIColor(red:1.00, green:0.92, blue:0.23, alpha:1.0)
            materialOneColor.metalness.contents = 0.5
            
            box.materials = [materialTwoColor, materialOneColor, materialTwoColor, materialOneColor, materialTwoColor, materialTwoColor]
            //box.firstMaterial?.diffuse.contents = UIColor(hue: 0.589, saturation: 0.98, brightness: 1.0, alpha: 1)
            
            let bearing = 0 - bearingBetweenLocations(point1: currentLocation, point2: nextLocation)
            
            let boxNode = SCNNode(geometry: box)
            boxNode.pivot = SCNMatrix4MakeTranslation(0, 0, 0.5 * Float(distance))
            boxNode.eulerAngles.y = Float(bearing).degreesToRadians
            boxNode.categoryBitMask = 3
            //boxNode.addChildNode(lightNode)
            boxNode.addChildNode(lightNode3)
            
            let locationNode = LocationNode(location: currentLocation, altitudeType: altitudeType)
            locationNode.addChildNode(boxNode)
            nodes.append(locationNode)
        }
        return nodes
    }
    
    public static func bearingBetweenLocations(point1 : CLLocation, point2 : CLLocation) -> Double {
        let lat1 = point1.coordinate.latitude.degreesToRadians
        let lon1 = point1.coordinate.longitude.degreesToRadians
        
        let lat2 = point2.coordinate.latitude.degreesToRadians
        let lon2 = point2.coordinate.longitude.degreesToRadians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing.radiansToDegrees
    }
}

open class LocationAnnotationNode: LocationNode {
    ///An image to use for the annotation
    ///When viewed from a distance, the annotation will be seen at the size provided
    ///e.g. if the size is 100x100px, the annotation will take up approx 100x100 points on screen.
    public let image: UIImage
    
    ///Subnodes and adjustments should be applied to this subnode
    ///Required to allow scaling at the same time as having a 2D 'billboard' appearance
    public let annotationNode: SCNNode
    
    ///Whether the node should be scaled relative to its distance from the camera
    ///Default value (false) scales it to visually appear at the same size no matter the distance
    ///Setting to true causes annotation nodes to scale like a regular node
    ///Scaling relative to distance may be useful with local navigation-based uses
    ///For landmarks in the distance, the default is correct
    public var scaleRelativeToDistance = false
    
    public init(location: CLLocation?, image: UIImage, altitudeType: TypeOfAltitude = .fixedAltitude) {
        self.image = image
        
        let plane = SCNPlane(width: image.size.width / 100, height: image.size.height / 100)
        plane.firstMaterial!.diffuse.contents = image
        plane.firstMaterial!.lightingModel = .constant
        
        annotationNode = SCNNode()
        annotationNode.geometry = plane
        
        super.init(location: location, altitudeType: altitudeType)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
        
        addChildNode(annotationNode)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
