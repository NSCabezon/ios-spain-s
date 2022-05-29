//
//  AccountFinanceableTransactionCollectionViewCell.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import UIKit
import CoreFoundationLib
import UI

class AccountFinanceableTransactionCollectionViewCell: UICollectionViewCell {
    static let identifier = "AccountFinanceableTransactionCollectionViewCell"
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conceptLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var accountDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: AccountFinanceableTransactionViewModel) {
        self.dateLabel.configureText(withLocalizedString: viewModel.dateFormatted,
                                    andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 12)))
        self.conceptLabel.text = viewModel.concept
        self.amountLabel.attributedText = viewModel.amount
        self.accountDescriptionLabel.text = viewModel.accountDescription
    }
}

private extension AccountFinanceableTransactionCollectionViewCell {
    func setAppearance() {
        self.setViews()
        self.setLabels()
        self.setImageView()
        self.setAccessibilityIdentifers()
    }
    
    func setLabels() {
        self.dateLabel.textColor = .bostonRed
        self.conceptLabel.font = .santander(family: .text, type: .bold, size: 14)
        self.conceptLabel.textColor = .lisboaGray
        self.amountLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.amountLabel.textColor = .lisboaGray
        self.accountDescriptionLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.accountDescriptionLabel.textColor = .grafite
    }
    
    func setImageView() {
        self.accountImageView.image = Assets.image(named: "icnSanSmall")
    }
    
    func setViews() {
        self.separatorView.backgroundColor = .mediumSkyGray
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.setShadowAndBorder()
    }
    
    func setShadowAndBorder() {
       self.drawShadow(offset: (x: 1, y: 2),
                       opacity: 0.7,
                       color: UIColor.lightSkyBlue.withAlphaComponent(0.7),
                       radius: 0.5)
       self.contentView.subviews.first?.drawBorder(cornerRadius: 4,
                                                   color: UIColor.lightSkyBlue,
                                                   width: 1)
    }
    
    func setAccessibilityIdentifers() {
        self.dateLabel.accessibilityIdentifier = AccessibilityFinancingAccountCarousel.accountCellDate
        self.conceptLabel.accessibilityIdentifier = AccessibilityFinancingAccountCarousel.accountCellConcept
        self.amountLabel.accessibilityIdentifier = AccessibilityFinancingAccountCarousel.accountCellAmount
        self.accountDescriptionLabel.accessibilityIdentifier = AccessibilityFinancingAccountCarousel.accountCellDescription
        self.accountImageView.accessibilityIdentifier = AccessibilityFinancingAccountCarousel.accountCellImageView
    }
}
