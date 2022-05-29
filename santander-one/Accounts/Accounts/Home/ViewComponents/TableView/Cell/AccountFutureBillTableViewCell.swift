//
//  AccountFutureBillTableViewCell.swift
//  Account
//
//  Created by Juan Carlos López Robles on 2/6/20.
//

import UIKit

class AccountFutureBillTableViewCell: UITableViewCell {
    @IBOutlet weak var discontinueLineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addDiscontinueLine()
    }
    
    private func addDiscontinueLine() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.mediumSkyGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [1, 1, 1, 1]
        let path = CGMutablePath()
        shapeLayer.position = CGPoint(x: 0, y: 0)
        path.addLines(between: [CGPoint(x: 0, y: 0),
                                CGPoint(x: discontinueLineView.frame.width, y: 0)])
        shapeLayer.path = path
        self.discontinueLineView.layer.addSublayer(shapeLayer)
    }
    
    private func setAccessibilityIdenfiers() {
        self.accessibilityIdentifier = "accountHome_movement_view"
        titleLabel.accessibilityIdentifier = "accountHome_movement_titleLabel"
        descriptionLabel.accessibilityIdentifier = "accountHome_movement_descriptionLabel"
        amountLabel.accessibilityIdentifier = "accountHome_movement_amountLabel"
        titleLabel.isAccessibilityElement = true
        descriptionLabel.isAccessibilityElement = true
        amountLabel.isAccessibilityElement = true
    }
}

extension AccountFutureBillTableViewCell: AccountTransactionTableViewCell {
    func mustHideDiscontinueLine(_ isHidden: Bool) {
        self.discontinueLineView.isHidden = isHidden
    }
    
    func configure(withViewModel viewModel: TransactionViewModel) {
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
        self.amountLabel.attributedText = viewModel.amountAttributeString
        self.setAccessibilityIdenfiers()
    }
}
