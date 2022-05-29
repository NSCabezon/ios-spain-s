//
//  FutureCollectionViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import UIKit
import CoreFoundationLib

class FutureCollectionViewCell: UICollectionViewCell {
    static let identifier = "FutureCollectionViewCell"
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var accountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    private func setAppearance() {
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.setShadowAndBorder()
        self.setColors()
     }
    
    private func setShadowAndBorder() {
       self.drawShadow(offset: (x: 1, y: 2),
                       opacity: 0.7,
                       color: UIColor.lightSkyBlue.withAlphaComponent(0.7),
                       radius: 0.5)
       self.contentView.subviews.first?.drawBorder(cornerRadius: 4,
                                                   color: UIColor.lightSkyBlue,
                                                   width: 1)
    }
    
    private func setColors() {
        self.dateLabel.textColor = .bostonRed
        self.personNameLabel.textColor = .lisboaGray
        self.amountLabel.textColor = .lisboaGray
        self.accountLabel.textColor = .grafite
        self.bottomLineView.backgroundColor = .mediumSkyGray
    }
    
    func setViewModel(_ viewModel: FutureBillViewModel) {
        self.personNameLabel.text = viewModel.personName
        self.dateLabel.configureText(withLocalizedString: viewModel.dateLocalized)
        self.amountLabel.attributedText = viewModel.amount
        self.accountLabel.text = viewModel.accountNumber
    }
}

private extension FutureCollectionViewCell {
    func setAccessibilityIdentifiers() {
        self.personNameLabel.accessibilityIdentifier = AccesibilityBills.FutureBillCellView.personNameLabel
        self.dateLabel.accessibilityIdentifier = AccesibilityBills.FutureBillCellView.dateLabel
        self.amountLabel.accessibilityIdentifier = AccesibilityBills.FutureBillCellView.amountLabel
        self.accountLabel.accessibilityIdentifier = AccesibilityBills.FutureBillCellView.accountLabel
    }
}
