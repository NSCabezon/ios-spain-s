//
//  AssociatedTransactionCollectionViewCell.swift
//  Account
//
//  Created by Tania Castellano Brasero on 23/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class AssociatedTransactionCollectionViewCell: UICollectionViewCell {
    static let identifier = "AssociatedTransactionCollectionViewCell"
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
        self.setAccessibilityIdentifiers()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetCell()
    }
    
    func setViewModel(_ viewModel: AssociatedTransactionViewModel) {
        self.titleLabel.configureText(withLocalizedString: viewModel.title,
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 16),
                                                                                           lineHeightMultiple: 0.8,
                                                                                           lineBreakMode: .byTruncatingTail))
        self.descriptionLabel.configureText(withLocalizedString: viewModel.description,
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
        self.dateLabel.configureText(withLocalizedString: viewModel.dateDescription,
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
        self.amountLabel.attributedText = viewModel.amountAttributedString
    }
}

private extension AssociatedTransactionCollectionViewCell {
    func configureCell() {
        self.contentView.backgroundColor = UIColor.blueAnthracita
        self.viewContainer.layer.cornerRadius = 5
        self.titleLabel.textColor = UIColor.lisboaGray
        self.descriptionLabel.textColor = UIColor.grafite
        self.amountLabel.font = UIFont.santander(family: .text, type: .bold, size: 32)
        self.amountLabel.textColor = UIColor.lisboaGray
        self.dateLabel.textColor = UIColor.grafite
        self.dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    func resetCell() {
        self.titleLabel.text = nil
        self.descriptionLabel.text = nil
        self.amountLabel.text = nil
        self.dateLabel.text = nil
    }
    
    func setAccessibilityIdentifiers() {
        self.dateLabel?.accessibilityIdentifier = AccessibilityAccountTransaction.relatedTransactionDate
    }
}
