//
//  ClusterView.swift
//  BranchLocator
//
//  Created by Tarsha De Souza on 26/06/2019.
//

import UIKit
import MapKit

// clustering will only be available from ios 11 above..
@available(iOS 11.0, *)
class ClusterView: MKAnnotationView {
 
   internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }

  
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with annotation: MKAnnotation) {
        guard let annotation = annotation as? MKClusterAnnotation else { return }
        //    CONFIGURE
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40.0, height: 40.0))
        let count = annotation.memberAnnotations.count
        image = renderer.image { _ in
            MapViewControllerThemeColor.clusterViewBackground.value.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)).fill()
            let attributes = [NSAttributedString.Key.foregroundColor: MapViewControllerThemeColor.clusterViewTextColor.value, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0)]
            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
            self.canShowCallout = false
        }
    }
    
    
}

@available(iOS 11.0, *)
extension MKClusterAnnotation {
    func mapRect() -> MKMapRect {
        let clusterPoint = MKMapPoint(coordinate)
        var mapRect = MKMapRect(origin: clusterPoint, size: MKMapSize(width: 0.1, height: 0.1))
        
        for annotation in memberAnnotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            mapRect = mapRect.union(pointRect)
        }
        return mapRect
    }
}
