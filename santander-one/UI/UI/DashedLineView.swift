//
//  DashedLineView.swift
//  UI
//
//  Created by Laura González on 08/10/2020.
//

import UIKit

public final class DashedLineView: UIView {
    public var strokeColor: UIColor = UIColor.mediumSkyGray {
        didSet {
            setNeedsDisplay()
        }
    }
    public var dashPattern: [NSNumber]? = [5, 3] {
        didSet {
            setNeedsDisplay()
        }
    }
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = strokeColor.cgColor
        caShapeLayer.lineWidth = 1
        caShapeLayer.lineDashPattern = dashPattern
        let cgPath = CGMutablePath()
        cgPath.addLines(between: [CGPoint.zero, CGPoint(x: rect.width, y: 0)])
        caShapeLayer.path = cgPath
        layer.addSublayer(caShapeLayer)
    }
}
