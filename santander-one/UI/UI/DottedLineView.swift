//
//  DottedLineView.swift
//  UI
//
//  Created by alvola on 26/11/2019.
//

import UIKit

public enum Orientation {
    case vertical
    case horizontal
}

public enum LineDashPattern {
    case simple
    case oneDesign
}

public final class DottedLineView: UIView {
    public var strokeColor: UIColor = UIColor.lightSanGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var lineWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var lineDashPattern: [NSNumber]? = [1, 1, 1, 1] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var orientation: Orientation = .horizontal
    public var pattern: LineDashPattern = .simple {
        didSet {
            setLineDashPattern()
        }
    }
    
    private var destiny: (CGRect, Orientation) -> CGPoint = {
        switch $1 {
        case .horizontal:
            return CGPoint(x: $0.width, y: 0.0)
        case .vertical:
            return CGPoint(x: 0.0, y: $0.height)
        }
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = strokeColor.cgColor
        caShapeLayer.lineWidth = lineWidth
        caShapeLayer.lineDashPattern = lineDashPattern
        let cgPath = CGMutablePath()
        cgPath.addLines(between: [CGPoint.zero, destiny(rect, orientation)])
        caShapeLayer.path = cgPath
        layer.addSublayer(caShapeLayer)
    }
}

private extension DottedLineView {
    func setLineDashPattern() {
        switch pattern {
        case .simple:
            lineDashPattern = [1, 1, 1 ,1]
        case .oneDesign:
            lineDashPattern = [3, 3]
        }
    }
}
