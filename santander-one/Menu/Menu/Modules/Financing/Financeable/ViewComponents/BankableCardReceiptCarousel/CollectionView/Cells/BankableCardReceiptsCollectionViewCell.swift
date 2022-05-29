//
//  BankableCardReceiptsCollectionViewCell.swift
//  Menu
//
//  Created by Sergio Escalante Ordoñez on 13/1/22.
//

import UIKit
import UI
import CoreFoundationLib

final class BankableCardReceiptsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BankableCardReceiptsCollectionViewCell"
    
    @IBOutlet private weak var nextReceiptLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var postponeReceiptLabel: UILabel!
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var cardDescriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
    }
    
    func configView(_ viewModel: BankableCardReceiptViewModel) {
        let datePlaceholder = [StringPlaceholder(.date, viewModel.dateFormatted)]
        nextReceiptLabel.configureText(withLocalizedString: localized("financing_label_nextBillDay", datePlaceholder))
        amountLabel.configureText(withKey: viewModel.amount ?? "")
        postponeReceiptLabel.configureText(withLocalizedString: localized("cardsOption_button_postponeReceipt").uppercased())
        cardDescriptionLabel.configureText(withKey: viewModel.cardDescription ?? "")
        setCardImage(viewModel)
    }
}

// MARK: Private extension

private extension BankableCardReceiptsCollectionViewCell {
    func setAppearance() {
        setViews()
        setLabels()
        setImageView()
    }

    func setLabels() {
        nextReceiptLabel.font = .santander(family: .micro, type: .regular, size: 12)
        nextReceiptLabel.textColor = .lisboaGray
        amountLabel.font = .santander(family: .micro, type: .bold, size: 16)
        amountLabel.textColor = .lisboaGray
        postponeReceiptLabel.font = .santander(family: .micro, type: .regular, size: 12)
        postponeReceiptLabel.textColor = .darkTorquoise
        cardDescriptionLabel.font = .santander(family: .micro, type: .regular, size: 12)
        cardDescriptionLabel.textColor = .brownishGray
    }
    
    func setImageView() {
        cardImageView.image = Assets.image(named: "imgTarjetaDebito")
    }
    
    func setViews() {
        separatorView.backgroundColor = .mediumSkyGray
        layer.masksToBounds = false
        clipsToBounds = false
        setShadowAndBorder()
    }
    
    func setShadowAndBorder() {
        let shadowConfiguration = ShadowConfiguration(
            color: .mediumSkyGray,
            opacity: 0.7,
            radius: 2,
            withOffset: 1,
            heightOffset: 2
        )
        contentView.drawRoundedBorderAndShadow(
            with: shadowConfiguration,
            cornerRadius: 8,
            borderColor: .lightSkyBlue,
            borderWith: 1
        )
    }
    
    func setCardImage(_ viewModel: BankableCardReceiptViewModel) {
        guard let imageUrl = viewModel.miniatureImageUrl else {
            cardImageView.image = Assets.image(named: "defaultCard")
            return
        }
        cardImageView.loadImage(urlString: imageUrl, placeholder: Assets.image(named: "defaultCard"))
    }
}
