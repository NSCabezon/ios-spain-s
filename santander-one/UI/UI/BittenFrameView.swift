//
//  BittenFrameView.swift
//  UI
//
//  Created by alvola on 04/06/2020.
//

import UIKit

public final class BittenFrameView: UIView {
    
    private let lineLayer: CAShapeLayer = CAShapeLayer()
    
    public var biteRadius: CGFloat = 8.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var biteCenterY: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var frameBackgroundColor: CGColor = UIColor.white.cgColor {
        didSet {
            lineLayer.fillColor = frameBackgroundColor
            setNeedsDisplay()
        }
    }
    
    public var frameCornerRadious: CGFloat = 6.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var frameStrokeColor: CGColor = UIColor.lightSkyBlue.cgColor {
        didSet {
            lineLayer.strokeColor = frameStrokeColor
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayer()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    private func initLayer() {
        layer.insertSublayer(lineLayer, at: 0)
        lineLayer.fillColor = frameBackgroundColor
        lineLayer.strokeColor = frameStrokeColor
        lineLayer.lineWidth = 1.0
    }
    
    private func resetLayer(in rect: CGRect) {
        let halfLine = lineLayer.lineWidth / 2.0
        lineLayer.frame = CGRect(x: rect.origin.x + halfLine,
                                 y: rect.origin.y + halfLine,
                                 width: rect.size.width  - lineLayer.lineWidth,
                                 height: rect.size.height - lineLayer.lineWidth)
        lineLayer.path = nil
        lineLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        resetLayer(in: rect)
        
        let linePath = CGMutablePath()
        let halfHeight = biteCenterY == 0.0 ? (lineLayer.bounds.height / 2.0) : biteCenterY
        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x,
                                  y: lineLayer.bounds.size.height))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x,
                                     y: halfHeight + biteRadius))
        
        linePath.addArc(center: CGPoint(x: lineLayer.bounds.origin.x,
                                        y: halfHeight),
                        radius: biteRadius,
                        startAngle: CGFloat.pi / 2.0,
                        endAngle: 3.0 * CGFloat.pi / 2.0,
                        clockwise: true)
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x,
                                     y: lineLayer.bounds.origin.y + frameCornerRadious))
        
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x + frameCornerRadious,
                                          y: lineLayer.bounds.origin.y),
                              control: CGPoint(x: lineLayer.bounds.origin.x,
                                               y: lineLayer.bounds.origin.y))
        
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width - frameCornerRadious,
                                     y: lineLayer.bounds.origin.y))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width,
                                          y: lineLayer.bounds.origin.y + frameCornerRadious),
                              control: CGPoint(x: lineLayer.bounds.size.width,
                                               y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width,
                                     y: halfHeight - biteRadius))
        linePath.addArc(center: CGPoint(x: lineLayer.bounds.size.width,
                                        y: halfHeight),
                        radius: biteRadius,
                        startAngle: 3.0 * CGFloat.pi / 2.0,
                        endAngle: CGFloat.pi / 2.0,
                        clockwise: true)
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width,
                                     y: lineLayer.bounds.size.height))
        lineLayer.path = linePath
    }
}
