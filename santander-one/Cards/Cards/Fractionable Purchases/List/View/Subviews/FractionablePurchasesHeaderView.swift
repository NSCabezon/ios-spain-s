//
//  FractionablePurchasesHeaderView.swift
//  Cards
//
//  Created by alvola on 16/02/2021.
//

import UIKit
import CoreFoundationLib
import UI

struct FractionablePurchasesHeaderViewModel {
    let cardName: String
    let cardCode: String
    let cardImageURL: String
    private let amountEntity: AmountEntity
    
    var amount: NSAttributedString? {
        let amount = MoneyDecorator(amountEntity,
                                    font: .santander(family: .text, type: .regular, size: 14),
                                    decimalFontSize: 14)
        return amount.getFormatedAbsWith1M()
    }
    
    init(cardName: String,
         cardCode: String,
         cardImageURL: String,
         amountEntity: AmountEntity) {
        self.cardName = cardName
        self.cardCode = cardCode
        self.cardImageURL = cardImageURL
        self.amountEntity = amountEntity
    }
}

final class FractionablePurchasesHeaderView: UIView {
    
    private lazy var cardImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.accessibilityIdentifier = "fractionatePurchasesHeaderImgCard"
        addSubview(image)
        return image
    }()
    
    private lazy var cardAliasLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(type: .bold, size: 16.0)
        label.textColor = .lisboaGray
        label.accessibilityIdentifier = "fractionatePurchasesHeaderAlias_Card"
        addSubview(label)
        return label
    }()
    
    private lazy var cardNumLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 14.0)
        label.textColor = .lisboaGray
        label.accessibilityIdentifier = "fractionatePurchasesHeaderNum_Card"
        addSubview(label)
        return label
    }()
    
    private lazy var setLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 13.0)
        label.textColor = .lisboaGray
        label.textAlignment = .right
        label.text = localized("financing_label_set")
        label.accessibilityIdentifier = "financing_label_set"
        addSubview(label)
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 14.0)
        label.textColor = .lisboaGray
        label.textAlignment = .right
        label.accessibilityIdentifier = "fractionatePurchasesHeaderAmount"
        addSubview(label)
        return label
    }()
    
    private lazy var bottomSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightSkyBlue
        addSubview(view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setInfo(_ info: FractionablePurchasesHeaderViewModel) {
        cardAliasLabel.text = info.cardName
        cardNumLabel.text = info.cardCode
        amountLabel.attributedText = info.amount
        cardImage.loadImage(urlString: info.cardImageURL,
                            placeholder: Assets.image(named: "defaultCard"))
    }
}

private extension FractionablePurchasesHeaderView {
    func commonInit() {
        configureView()
        configureCardImageConstraints()
        configurecardAliasLabelConstraints()
        configureCardNumLabelConstraints()
        configureSetLabelConstraints()
        configureAmountLabelConstraints()
        configureBottomSeparatorViewConstraints()
    }
    
    func configureView() {
        backgroundColor = .skyGray
        accessibilityIdentifier = "fractionatePurchasesHeader"
    }
    
    func configureCardImageConstraints() {
        NSLayoutConstraint.activate([
            cardImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            cardImage.topAnchor.constraint(equalTo: topAnchor, constant: 7.0),
            cardImage.widthAnchor.constraint(equalToConstant: 45.0),
            cardImage.heightAnchor.constraint(equalToConstant: 29.0)
        ])
    }
    
    func configurecardAliasLabelConstraints() {
        NSLayoutConstraint.activate([
            cardAliasLabel.leadingAnchor.constraint(equalTo: cardImage.trailingAnchor, constant: 13.0),
            cardAliasLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2.0),
            cardAliasLabel.heightAnchor.constraint(equalToConstant: 24.0)
        ])
    }
    
    func configureCardNumLabelConstraints() {
        NSLayoutConstraint.activate([
            cardNumLabel.leadingAnchor.constraint(equalTo: cardImage.trailingAnchor, constant: 12.0),
            cardNumLabel.topAnchor.constraint(equalTo: cardAliasLabel.bottomAnchor, constant: -2.0),
            cardNumLabel.heightAnchor.constraint(equalToConstant: 20.0)
        ])
    }
    
    func configureSetLabelConstraints() {
        NSLayoutConstraint.activate([
            setLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cardAliasLabel.trailingAnchor, constant: 10.0),
            trailingAnchor.constraint(equalTo: setLabel.trailingAnchor, constant: 17.0),
            setLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7.0),
            setLabel.heightAnchor.constraint(equalToConstant: 16.0)
        ])
    }
    
    func configureAmountLabelConstraints() {
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 17.0),
            amountLabel.topAnchor.constraint(equalTo: setLabel.bottomAnchor),
            amountLabel.heightAnchor.constraint(equalToConstant: 18.0)
        ])
    }
    
    func configureBottomSeparatorViewConstraints() {
        NSLayoutConstraint.activate([
            bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
}
