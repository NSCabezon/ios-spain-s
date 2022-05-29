//
//  RoundedView.swift
//  toTest
//
//  Created by alvola on 09/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    
    public enum RoundedPosition {
        case top
        case topJoined
        case bottom
        case bottomJoined
        case all
        case any
        case sideOnly
    }
    
    private let lineLayer: CAShapeLayer = CAShapeLayer()
    
    public var frameBackgroundColor: CGColor = UIColor.white.cgColor {
        didSet {
            lineLayer.fillColor = frameBackgroundColor
            setNeedsDisplay()
        }
    }
    
    public var frameCornerRadious: CGFloat = 6.0 {
        didSet {
            lineLayer.strokeColor = frameStrokeColor
            setNeedsDisplay()
        }
    }
    
    public var frameStrokeColor: CGColor = UIColor.mediumSkyGray.cgColor {
        didSet {
            lineLayer.strokeColor = frameStrokeColor
            setNeedsDisplay()
        }
    }
    
    private var roundedCorners: RoundedPosition = .any {
        didSet {
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
    
    private func initLayer() {
        layer.insertSublayer(lineLayer, at: 0)
        lineLayer.fillColor = frameBackgroundColor
        lineLayer.strokeColor = frameStrokeColor
        lineLayer.lineWidth = 1.0
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let halfLine = lineLayer.lineWidth / 2.0
        lineLayer.frame = CGRect(x: rect.origin.x + halfLine,
                                 y: rect.origin.y + topLimit(),
                                 width: rect.size.width  - lineLayer.lineWidth,
                                 height: rect.size.height - bottomLimit())
        lineLayer.path = nil
        lineLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        switch roundedCorners {
        case .top:
            drawTopCorneredFrame()
        case .topJoined:
            drawTopJoinedCorneredFrame()
        case .bottom:
            drawBottomCorneredFrame()
        case .bottomJoined:
            drawBottomJoinedCorneredFrame()
        case .all:
            drawAllCorneredFrame()
        case .sideOnly:
            drawOnlySideFrame()
        case .any:
            break
        }
    }
    
    public func roundAllCorners() { roundedCorners = .all }
    public func roundTopCorners() { roundedCorners = .top }
    public func roundTopCornersJoined() { roundedCorners = .topJoined }
    public func roundBottomCorners() { roundedCorners = .bottom }
    public func roundBottomCornersJoined() { roundedCorners = .bottomJoined }
    public func removeCorners() { roundedCorners = .any }
    public func onlySideFrame() { roundedCorners = .sideOnly }
    public func removeBorder() { lineLayer.lineWidth = 0 }
    
    private func topLimit() -> CGFloat {
        switch roundedCorners {
        case .top, .topJoined, .all, .bottom, .bottomJoined, .any:
            return lineLayer.lineWidth / 2.0
        case .sideOnly:
            return 0.0
        }
    }
    
    private func bottomLimit() -> CGFloat {
        switch roundedCorners {
        case .top, .topJoined, .all, .bottom, .bottomJoined, .any:
            return lineLayer.lineWidth
        case .sideOnly:
            return 0.0
        }
    }
    
    private func drawTopCorneredFrame() {
        let linePath = CGMutablePath()
        
        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x,
                                  y: lineLayer.bounds.size.height))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y + topCornerRadious()))
        
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x + topCornerRadious(), y: lineLayer.bounds.origin.y),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y))
        
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width - topCornerRadious(), y: lineLayer.bounds.origin.y))
        
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y + topCornerRadious()),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height))
        
        lineLayer.path = linePath
    }
    
    private func drawTopJoinedCorneredFrame() {
        let linePath = CGMutablePath()

        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x,
                                  y: lineLayer.bounds.origin.y + topCornerRadious()))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x + topCornerRadious(), y: lineLayer.bounds.origin.y),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width - topCornerRadious(), y: lineLayer.bounds.origin.y))

        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y + topCornerRadious()),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y + topCornerRadious()))

        lineLayer.path = linePath
    }
    
    private func drawBottomCorneredFrame() {
        let linePath = CGMutablePath()
        
        linePath.move(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - bottomCornerRadious()))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width - bottomCornerRadious(), y: lineLayer.bounds.size.height),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x + bottomCornerRadious(), y: lineLayer.bounds.size.height))

        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - bottomCornerRadious()),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y + topCornerRadious()))
        
        lineLayer.path = linePath
    }
    
    private func drawBottomJoinedCorneredFrame() {
        let linePath = CGMutablePath()

        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x,
                                  y: lineLayer.bounds.origin.y + lineLayer.lineWidth))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y + lineLayer.lineWidth))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - bottomCornerRadious()))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width - bottomCornerRadious(), y: lineLayer.bounds.size.height),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x + bottomCornerRadious(), y: lineLayer.bounds.size.height))

        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - bottomCornerRadious()),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y))

        lineLayer.path = linePath
    }
    
    private func drawAllCorneredFrame() {
        let linePath = CGMutablePath()

        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x,
                                  y: lineLayer.bounds.origin.y + topCornerRadious()))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x + topCornerRadious(), y: lineLayer.bounds.origin.y),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width - topCornerRadious(), y: lineLayer.bounds.origin.y))

        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y + topCornerRadious()),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - bottomCornerRadious()))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width - bottomCornerRadious(), y: lineLayer.bounds.size.height),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x + bottomCornerRadious(), y: lineLayer.bounds.size.height))

        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - bottomCornerRadious()),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height))

        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y + topCornerRadious()))

        lineLayer.path = linePath
    }
    
    private func drawOnlySideFrame() {
        let frameLineLayer: CAShapeLayer = CAShapeLayer()
        frameLineLayer.frame = lineLayer.bounds
        frameLineLayer.fillColor = lineLayer.fillColor
        frameLineLayer.strokeColor = lineLayer.strokeColor
        frameLineLayer.lineWidth = lineLayer.lineWidth
        
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height))
        linePath.move(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height))

        frameLineLayer.path = linePath
        
        let backLayer: CAShapeLayer = CAShapeLayer()
        backLayer.frame = lineLayer.bounds
        backLayer.frame.size = CGSize(width: backLayer.frame.width, height: backLayer.frame.height + 1)
        frameLineLayer.frame.size = backLayer.frame.size
        backLayer.fillColor = frameBackgroundColor
        backLayer.strokeColor = UIColor.clear.cgColor
        
        let squarePath = CGMutablePath()
        squarePath.addRect(backLayer.frame)
        backLayer.path = squarePath
        
        lineLayer.addSublayer(backLayer)
        lineLayer.insertSublayer(frameLineLayer, above: backLayer)
    }
    
    private func topCornerRadious() -> CGFloat {
        switch roundedCorners {
        case .top, .topJoined, .all:
            return frameCornerRadious
        case .bottom, .bottomJoined, .any, .sideOnly:
            return 0.0
        }
    }
    
    private func bottomCornerRadious() -> CGFloat {
        switch roundedCorners {
        case .bottom, .bottomJoined, .all:
            return frameCornerRadious
        case .top, .topJoined, .any, .sideOnly:
            return 0.0
        }
    }
}
