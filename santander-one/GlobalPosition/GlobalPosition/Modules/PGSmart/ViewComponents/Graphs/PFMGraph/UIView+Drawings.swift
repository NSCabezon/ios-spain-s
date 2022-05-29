//
//  UIView+Drawings.swift
//  Grafica
//
//  Created by Boris Chirino Fernandez on 20/12/2019.
//  Copyright © 2019 Boris Chirino Fernandez. All rights reserved.
//

import UIKit

private let redInnerColor = UIColor(red: 169/255, green: 5/255, blue: 56/255, alpha: 1)
private let blackInnerColor = UIColor(red: 49/255, green: 48/255, blue: 54/255, alpha: 1)

enum CircleFillColor {
    case red
    case black
    
    func cgColor() -> CGColor {
        switch self {
        case .red:
            return redInnerColor.cgColor
        case .black:
            return blackInnerColor.cgColor
        }
    }
}

extension UIView {
    func drawCircle(point: CGPoint, color: UIColor, radius: CGFloat, innerColor: CircleFillColor) {

      let circlePath = UIBezierPath(arcCenter: point,
                                    radius: CGFloat(radius),
                                    startAngle: CGFloat(0),
                                    endAngle: CGFloat(Double.pi * 2),
                                    clockwise: true)

      let shapeLayer = CAShapeLayer()
      shapeLayer.path = circlePath.cgPath

      // change the fill color
        shapeLayer.fillColor = innerColor.cgColor()
      // you can change the stroke color
      shapeLayer.strokeColor = color.cgColor
      // you can change the line width
      shapeLayer.lineWidth = BoardAttributes.lineWidth
      
      layer.addSublayer(shapeLayer)
    }
    /**
    A control point essentially dictates the curve of the line. The closer you place the control point to the line, the less dramatic the curve. By placing the control point farther away from the line, the more pronounced the curve. Think of a control point as a little magnet that pulls the line towards it.
     - Parameters:
       - p1: first point of curve
       - p2: second point of curve whose control point we are looking for
       - next: predicted next point which will use antipodal control point for finded
     */
    func controlPointForPoints(start: CGPoint, end: CGPoint, next thirdPoint: CGPoint?) -> CGPoint? {
        guard let thirdPoint = thirdPoint else { return nil }

        let leftMidPoint  = midPointForPoints(firstPoint: start, secondPoint: end)
        let rightMidPoint = midPointForPoints(firstPoint: end, secondPoint: thirdPoint)
        
        guard let antipodalPoint = antipodalFor(point: rightMidPoint, center: end) else { return nil }
        var controlPoint = midPointForPoints(firstPoint: leftMidPoint, secondPoint: antipodalPoint)

        if start.y.between(lhs: end.y, rhs: controlPoint.y) {
            controlPoint.y = start.y
        } else if end.y.between(lhs: start.y, rhs: controlPoint.y) {
            controlPoint.y = end.y
        }

        let imaginContol = antipodalFor(point: controlPoint, center: end)!
        if end.y.between(lhs: thirdPoint.y, rhs: imaginContol.y) {
            controlPoint.y = end.y
        }
        if thirdPoint.y.between(lhs: end.y, rhs: imaginContol.y) {
            let diffY = abs(end.y - thirdPoint.y)
            controlPoint.y = end.y + diffY * (thirdPoint.y < end.y ? 1 : -1)
        }

        // make lines easier
        controlPoint.x += (end.x - start.x) * 0.1

        return controlPoint
    }
    
    /**
       In mathematics, the antipodal point of a point on the surface of a sphere is the point which is diametrically opposite to it – so situated that a line drawn from the one to the other passes through the center of the sphere and forms a true diameter. This term applies to opposite points on a circle or any n-sphere.
       This particular case is used to find a point located on the opposite side from the center point. Using control point as point parameter to smoth the curve and give a little angle.
       - Parameter point : control point
       - Parameter center : center
    */
    func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
        guard let firstPoint = point, let center = center else { return nil }
        let newX = 2 * center.x - firstPoint.x
        let diffY = abs(firstPoint.y - center.y)
        let newY = center.y + diffY * (firstPoint.y < center.y ? 1 : -1)
        return CGPoint(x: newX, y: newY)
    }

    /// halfway of two points
    func midPointForPoints(firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
       let midPoint = CGPoint(x: (firstPoint.x + secondPoint.x) / 2, y: (firstPoint.y + secondPoint.y) / 2)
       return midPoint
    }
}
