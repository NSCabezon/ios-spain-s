//
//  PointLine.swift
//  UI
//
//  Created by Juan Carlos López Robles on 11/27/19.
//

import Foundation

open class PointLine: UIView {
    
    public var pointColor: UIColor = .mediumSkyGray
    public var pattern: [NSNumber] = [1, 1, 1, 1] {
        didSet { self.setNeedsDisplay() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.clear
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addDiscontinueLine()
        self.backgroundColor = UIColor.clear
    }
    
    private func addDiscontinueLine() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = self.pointColor.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = pattern
        let path = CGMutablePath()
        shapeLayer.position = CGPoint(x: 0, y: 0)
        path.addLines(between: [CGPoint(x: 0, y: 0),
                                CGPoint(x: self.frame.width, y: 0)])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
}
