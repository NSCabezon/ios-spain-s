//
//  ExpandContainer.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/3/20.
//

import Foundation
import UIKit

final class HeaderContainerView: UIView {
    private let bottomLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addBottomLineView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addBottomLineView()
    }
    
    func drawAllCornersWithShadow() {
        self.bottomLine.isHidden = true
        self.removeBorderLayer()
        self.drawRoundedAndShadowedNew(radius: 6, borderColor: .lightSkyBlue)
    }
    
    func drawCornerExceptBottom() {
        self.clearLayer()
        self.bottomLine.isHidden = false
        let borderLayer = self.createLayerMask()
        self.removeBorderLayer()
        self.layer.addSublayer(borderLayer)
    }
    
    func clearLayer() {
        self.layer.cornerRadius = 0
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func addBottomLineView() {
        self.bottomLine.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLine.backgroundColor = UIColor.skyGray
        self.addSubview(bottomLine)
        NSLayoutConstraint.activate([
            self.bottomLine.heightAnchor.constraint(equalToConstant: 2),
            self.bottomLine.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1),
            self.bottomLine.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 1),
            self.bottomLine.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -1)
        ])
    }
}

private extension HeaderContainerView {
    func removeBorderLayer() {
        self.layer.sublayers?.first(where: {$0.name == "borderLayer"})?.removeFromSuperlayer()
    }
    
    func createLayerMask() -> CAShapeLayer {
        let borderLayer = CAShapeLayer()
        borderLayer.name = "borderLayer"
        borderLayer.zPosition = -2
        borderLayer.lineWidth = 1
        borderLayer.fillColor = UIColor.skyGray.cgColor
        borderLayer.strokeColor = UIColor.lightSkyBlue.cgColor
        borderLayer.path = self.cGPath(for: [.topRight, .topLeft])
        return borderLayer
    }
    
    func cGPath(for corners: UIRectCorner) -> CGPath {
        return UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 6.0, height: 0)
        ).cgPath
    }
}
