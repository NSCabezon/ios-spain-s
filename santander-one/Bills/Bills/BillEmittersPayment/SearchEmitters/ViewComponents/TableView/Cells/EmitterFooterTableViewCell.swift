//
//  EmitterFooterTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import UIKit

class EmitterFooterTableViewCell: UITableViewCell {
    static let identifier = "EmitterFooterTableViewCell"
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var bottomLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setAppearance()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setAppearance()
    }
}

private extension EmitterFooterTableViewCell {
    func setAppearance() {
        self.clearLayers()
        self.drawBottomCornerBorder()
        self.bottomLine.backgroundColor = UIColor.skyGray
    }
    
    func clearLayers() {
        self.viewContainer.layer.sublayers?
            .first(where: {$0.name == "borderLayer"})?.removeFromSuperlayer()
    }

    func drawBottomCornerBorder() {
        let borderLayer = CAShapeLayer()
        borderLayer.name = "borderLayer"
        borderLayer.fillColor = UIColor.skyGray.cgColor
        borderLayer.strokeColor = UIColor.lightSkyBlue.cgColor
        borderLayer.lineWidth = 1
        borderLayer.zPosition = -2
        borderLayer.path = self.cGPath(for: [.bottomRight, .bottomLeft])
        viewContainer.layer.addSublayer(borderLayer)
    }
    
    func cGPath(for corners: UIRectCorner) -> CGPath {
        return UIBezierPath(
            roundedRect: self.viewContainer.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 6.0, height: 0)
        ).cgPath
    }
}
