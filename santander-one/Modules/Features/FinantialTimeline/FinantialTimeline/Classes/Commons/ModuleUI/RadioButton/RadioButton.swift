//
//  RadioButton.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

protocol RadioButtonDelegate: class {
    func radioButtonSelected()
}

class RadioButton: UIView {
    
    var delegate: RadioButtonDelegate?
    
    internal var outerCircleLayer = CAShapeLayer()
    internal var innerCircleLayer = CAShapeLayer()
    
    var isSelected: Bool = false {
        didSet {
            setFillState()
        }
    }
    
    var outerCircleColor: UIColor = .black {
        didSet {
            outerCircleLayer.strokeColor = UIColor.iceBlue.cgColor
        }
    }
    
    var innerCircleColor: UIColor = .sanRed {
        didSet {
            setFillState()
        }
    }
    
    var outerCircleLineWidth: CGFloat = 1.0 {
        didSet {
            setCircleLayouts()
        }
    }
    
    var innerCircleGap: CGFloat = 5 {
        didSet {
            setCircleLayouts()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override public func draw(_ rect: CGRect) {
        outerCircleLayer.frame = bounds
        outerCircleLayer.lineWidth = outerCircleLineWidth
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.strokeColor = outerCircleColor.cgColor
        layer.addSublayer(outerCircleLayer)
        
        innerCircleLayer.frame = bounds
        innerCircleLayer.lineWidth = outerCircleLineWidth
        innerCircleLayer.fillColor = UIColor.clear.cgColor
        innerCircleLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(innerCircleLayer)
    }
    
    internal var setCircleRadius: CGFloat {
        let width = bounds.width
        let height = bounds.height
        
        let length = width > height ? height : width
        return (length - outerCircleLineWidth) / 2
    }
    
    private var setCircleFrame: CGRect {
        let width = bounds.width
        let height = bounds.height
        
        let radius = setCircleRadius
        let x: CGFloat
        let y: CGFloat
        
        if width > height {
            y = outerCircleLineWidth / 2
            x = (width / 2) - radius
        } else {
            x = outerCircleLineWidth / 2
            y = (height / 2) - radius
        }
        
        let diameter = 2 * radius
        return CGRect(x: x, y: y, width: diameter, height: diameter)
    }
    
    private var circlePath: UIBezierPath {
        return UIBezierPath(roundedRect: setCircleFrame, cornerRadius: setCircleRadius)
    }
    
    private var fillCirclePath: UIBezierPath {
        let trueGap = innerCircleGap + (outerCircleLineWidth / 2)
        return UIBezierPath(roundedRect: setCircleFrame.insetBy(dx: trueGap, dy: trueGap), cornerRadius: setCircleRadius)
    }
    
    private func setupView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchUpInside(_:)))
        addGestureRecognizer(tapGesture)
        
        setFillState()
    }
    
    @objc func touchUpInside(_ sender: UITapGestureRecognizer) {
        delegate?.radioButtonSelected()
    }
    
    private func setCircleLayouts() {
        outerCircleLayer.frame = bounds
        outerCircleLayer.lineWidth = outerCircleLineWidth
        outerCircleLayer.path = circlePath.cgPath
        
        innerCircleLayer.frame = bounds
        innerCircleLayer.lineWidth = outerCircleLineWidth
        innerCircleLayer.path = fillCirclePath.cgPath
    }
    
    private func setFillState() {
        if isSelected {
            outerCircleLayer.strokeColor = innerCircleColor.cgColor
            innerCircleLayer.fillColor = innerCircleColor.cgColor
        } else {
            outerCircleLayer.strokeColor = outerCircleColor.cgColor
            innerCircleLayer.fillColor = UIColor.clear.cgColor
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCircleLayouts()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return setCircleFrame.contains(point) ? self : nil
    }
}
