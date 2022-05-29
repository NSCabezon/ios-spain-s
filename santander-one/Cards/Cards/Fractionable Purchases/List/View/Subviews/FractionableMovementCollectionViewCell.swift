//
//  FractionableMovementCollectionViewCell.swift
//  Cards
//
//  Created by alvola on 17/02/2021.
//

import UIKit
import UI
import CoreFoundationLib

struct FractionableMovementCollectionViewModel {
    let date: String
    let name: String
    let amountEntity: AmountEntity?
    let cardImageName: String
    let cardAlias: String
    let cardCode: String
    let transactionEntity: CardTransactionEntity?
    
    var amount: NSAttributedString? {
        guard let amount = amountEntity else { return nil }
        let font = UIFont.santander(type: .bold, size: 20.0)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 14.0)
        return decorator.formatAsMillions()
    }
}

final class FractionableMovementCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var frameView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var movementNameLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var cardImage: UIImageView!
    @IBOutlet private weak var cardAlias: UILabel!
    @IBOutlet private weak var cardCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setInfo(_ info: FractionableMovementCollectionViewModel) {
        dateLabel.text = info.date
        movementNameLabel.configureText(withLocalizedString: LocalizedStylableText(text: info.name, styles: nil),
                                        andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .bold, size: 14.0),
                                                                                             lineHeightMultiple: 0.8))
        amountLabel.attributedText = info.amount
        cardImage.loadImage(urlString: info.cardImageName,
                            placeholder: Assets.image(named: "defaultCard"))
        cardAlias.text = info.cardAlias
        cardCodeLabel.text = " | " + info.cardCode
    }
}

private extension FractionableMovementCollectionViewCell {
    func commonInit() {
        configureView()
        configureLabels()
    }
    
    func configureView() {
        frameView.backgroundColor = .white
        frameView.layer.borderWidth = 1.0
        frameView.layer.borderColor = UIColor.mediumSky.cgColor
        frameView.layer.cornerRadius = 5.0
        separatorView.backgroundColor = .mediumSkyGray
    }
    
    func configureLabels() {
        dateLabel.font = UIFont.santander(type: .bold, size: 12.0)
        dateLabel.textColor = .bostonRed
        movementNameLabel.textColor = .lisboaGray
        movementNameLabel.baselineAdjustment = .alignBaselines
        amountLabel.font = UIFont.santander(type: .bold, size: 20.0)
        amountLabel.textColor = .lisboaGray
        cardAlias.font = UIFont.santander(size: 13.0)
        cardAlias.textColor = .lisboaGray
        cardCodeLabel.font = UIFont.santander(size: 13.0)
        cardCodeLabel.textColor = .lisboaGray
    }
}
