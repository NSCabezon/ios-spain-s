//
//  LastContributionsCardsCell.swift
//  Menu
//
//  Created by Ignacio González Miró on 01/09/2020.
//

import UIKit
import UI
import CoreFoundationLib

class LastContributionsCardsCell: UITableViewCell {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var cardImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var separatorView: DottedLineView!
    @IBOutlet private weak var feeTitleLabel: UILabel!
    @IBOutlet private weak var feeDetailLabel: UILabel!

    public static var identifier: String {
        return String(describing: self)
    }
    
    public static var height: CGFloat {
        return CGFloat(113.0)
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func config(_ viewModel: LastContributionsViewModel) {
        self.cardImage.loadImage(urlString: viewModel.card?.urlImg ?? "")
        if self.cardImage.image == nil {
            self.cardImage.image = Assets.image(named: "defaultCard")
        }
        self.titleLabel.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.card?.title ?? "", styles: nil),
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18.0),
                                                                                           alignment: .left,
                                                                                           lineHeightMultiple: 0.7))
        self.detailLabel.text = localized("financing_label_set")
        self.ibanLabel.text = viewModel.card?.iban
        guard let cardEntity = viewModel.card else { return }
        let amountAttributed = viewModel.amountAttributedText(cardEntity.amount?.value)
        self.amountLabel.attributedText = amountAttributed
        self.configureFeeFooter(viewModel, cardEntity: cardEntity)
    }
}

private extension LastContributionsCardsCell {
    func setupView() {
        self.selectionStyle = .none
        self.setAppeareance()
        self.setIdentifiers()
    }
    
    func setAppeareance() {
        let shadowConfiguration = ShadowConfiguration(color: UIColor.lightSanGray.withAlphaComponent(0.35), opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        self.baseView.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 6.0, borderColor: .mediumSkyGray, borderWith: 1.0)
        self.separatorView.strokeColor = .mediumSkyGray
        self.setLabels()
    }
    
    func setLabels() {
        self.titleLabel.numberOfLines = 2
        self.titleLabel.textColor = .lisboaGray
        self.detailLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.detailLabel.textColor = .grafite
        self.detailLabel.textAlignment = .right
        self.ibanLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.ibanLabel.textColor = .lisboaGray
        self.ibanLabel.textAlignment = .left
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.textAlignment = .right
        self.feeTitleLabel.font = .santander(family: .text, type: .regular, size: 10.0)
        self.feeTitleLabel.textColor = .lisboaGray
        self.feeTitleLabel.textAlignment = .left
        self.feeDetailLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        self.feeDetailLabel.textColor = .lisboaGray
        self.feeDetailLabel.textAlignment = .right
    }
    
    func setIdentifiers() {
        self.baseView.accessibilityIdentifier = AccessibilityLastContributions.lcCardsBaseView.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityLastContributions.lcCardsTitle.rawValue
        self.detailLabel.accessibilityIdentifier = AccessibilityLastContributions.lcCardsDetail.rawValue
    }
    
    func configureFeeFooter(_ viewModel: LastContributionsViewModel, cardEntity: LastContributionsCardsEntity) {
        guard let feeDescription = viewModel.loadFeeDescription(cardEntity) else {
            self.separatorView.isHidden = true
            self.feeTitleLabel.isHidden = true
            self.feeDetailLabel.isHidden = true
            return
        }
        let feeTitle = viewModel.loadFeeTitle(cardEntity)
        self.separatorView.isHidden = false
        self.feeTitleLabel.text = feeTitle
        self.feeDetailLabel.text = feeDescription
    }
}
