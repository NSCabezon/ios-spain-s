//
//  CircleGraphView.swift
//  UI
//
//  Created by alvola on 16/02/2021.
//

import UIKit

public final class CircleGraphView: UIView {
    private lazy var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private lazy var circleShadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    public var percentage = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var frontCircleColor: UIColor = .darkTorquoise {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var backCircleColor: UIColor = .lightSanGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var fillColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var frontCircleLineWidth: CGFloat = 3.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var backCircleLineWidth: CGFloat = 3.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var circlesLineWidth: CGFloat = 3.5 {
        didSet {
            frontCircleLineWidth = circlesLineWidth
            backCircleLineWidth = circlesLineWidth
        }
    }
    
    public var animate: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
        
    public var clockwise: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBackCircle()
        guard percentage > 0.0 else { return }
        drawPercentageCircle()
    }
}

private extension CircleGraphView {
    private func drawPercentageCircle() {
        self.circleLayer.removeFromSuperlayer()
        let start: CGFloat = 3.0 * .pi / 2.0
        let end = start + (CGFloat(percentage) * 2.0 * .pi / 100.0)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                                      radius: (frame.size.width - frontCircleLineWidth) / 2.0,
                                      startAngle: start,
                                      endAngle: end,
                                      clockwise: clockwise)
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = self.fillColor.cgColor
        circleLayer.strokeColor = self.frontCircleColor.cgColor
        circleLayer.lineWidth = self.frontCircleLineWidth
        circleLayer.strokeEnd = animate ? 0.0 : 1.0
        layer.addSublayer(circleLayer)
        if animate {
            animateCircle()
        }
    }
    
    private func drawBackCircle() {
        self.circleShadowLayer.removeFromSuperlayer()
        
        circleShadowLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0,
                                                                 y: frame.size.height / 2.0),
                                              radius: (frame.size.width - backCircleLineWidth) / 2.0,
                                              startAngle: 0.0,
                                              endAngle: 2 * .pi,
                                              clockwise: true).cgPath
        circleShadowLayer.fillColor = self.fillColor.cgColor
        circleShadowLayer.strokeColor = self.backCircleColor.cgColor
        circleShadowLayer.lineWidth = self.frontCircleLineWidth
        circleShadowLayer.strokeEnd = 1.0
        layer.addSublayer(circleShadowLayer)
    }
    
    private func animateCircle() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.circleLayer.strokeEnd = 1.0
        self.circleLayer.add(animation, forKey: "animateCircle")
    }
}
