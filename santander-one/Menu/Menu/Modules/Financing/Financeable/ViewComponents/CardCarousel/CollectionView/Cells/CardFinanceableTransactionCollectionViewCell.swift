//
//  CardFinanceableTransactionCollectionViewCell.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 23/06/2020.
//

import UIKit
import CoreFoundationLib
import UI

class CardFinanceableTransactionCollectionViewCell: UICollectionViewCell {
    static let identifier = "CardFinanceableTransactionCollectionViewCell"
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conceptLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: CardFinanceableTransactionViewModel) {
        self.dateLabel.configureText(withLocalizedString: viewModel.dateFormatted)
        self.conceptLabel.text = viewModel.concept
        self.amountLabel.attributedText = viewModel.amount
        self.cardDescriptionLabel.text = viewModel.cardDescription
        self.setCardImage(viewModel)
    }
}

private extension CardFinanceableTransactionCollectionViewCell {
    func setAppearance() {
        self.setViews()
        self.setLabels()
        self.setImageView()
        self.setAccessibilityIdentifers()
    }
    
    func setLabels() {
        self.dateLabel.font = .santander(family: .text, type: .bold, size: 12)
        self.dateLabel.textColor = .bostonRed
        self.conceptLabel.font = .santander(family: .text, type: .bold, size: 14)
        self.conceptLabel.textColor = .lisboaGray
        self.amountLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.amountLabel.textColor = .lisboaGray
        self.cardDescriptionLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.cardDescriptionLabel.textColor = .grafite
    }
    
    func setImageView() {
        self.cardImageView.image = Assets.image(named: "imgTarjetaDebito")
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
    
    func setCardImage(_ viewModel: CardFinanceableTransactionViewModel) {
        guard let imageUrl = viewModel.miniatureImageUrl else {
            self.cardImageView.image = Assets.image(named: "defaultCard")
            return
        }
        _ = self.cardImageView.loadImage(urlString: imageUrl, placeholder: Assets.image(named: "defaultCard"))
    }
    
    func setAccessibilityIdentifers() {
        self.dateLabel.accessibilityIdentifier = AccessibilityFinancingCardCarousel.cardCellDate
        self.conceptLabel.accessibilityIdentifier = AccessibilityFinancingCardCarousel.cardCellConcept
        self.amountLabel.accessibilityIdentifier = AccessibilityFinancingCardCarousel.cardCellAmount
        self.cardDescriptionLabel.accessibilityIdentifier = AccessibilityFinancingCardCarousel.cardCellDescription
        self.cardImageView.accessibilityIdentifier = AccessibilityFinancingCardCarousel.cardCellImageView
    }
}
