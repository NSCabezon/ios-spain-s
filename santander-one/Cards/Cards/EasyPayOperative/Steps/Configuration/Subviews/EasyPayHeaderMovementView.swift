//
//  EasyPayHeaderMovementView.swift
//  Cards
//
//  Created by alvola on 03/12/2020.
//

import UIKit
import UI
import CoreFoundationLib

struct EasyPayHeaderMovementViewModel {
    let movementName: String
    let cardName: String
    let amount: NSAttributedString?
    let operationDay: String
    let operationHour: String
    let settleDay: String
}

final class EasyPayHeaderMovementView: UIView {
    private lazy var movementTitleLabel: UILabel = {
        return defaultLabelCreator(UIFont.santander(type: .bold, size: 15.0),
                                   .lisboaGray)
    }()
    
    private lazy var cardNameLabel: UILabel = {
        return defaultLabelCreator(UIFont.santander(size: 14.0),
                                   .grafite)
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = defaultLabelCreator(UIFont.santander(type: .bold, size: 30.0),
                                        .lisboaGray)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var movementDateTitleLabel: UILabel = {
        let label = defaultLabelCreator(UIFont.santander(size: 13.0),
                                        .grafite)
        label.text = localized("transaction_label_operationDate")
        return label
    }()
    
    private lazy var movementDateLabel: UILabel = {
        return defaultLabelCreator(UIFont.santander(size: 14.0),
                                   .lisboaGray)
    }()
    
    private lazy var settleDateTitleLabel: UILabel = {
        let label = defaultLabelCreator(UIFont.santander(size: 13.0),
                                        .grafite)
        label.text = localized("cardDetail_text_liquidated")
        label.textAlignment = .right
        return label
    }()
    
    private lazy var settleDateLabel: UILabel = {
        let label = defaultLabelCreator(UIFont.santander(size: 13.0),
                                        .lisboaGray)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var tornImageView: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "imgTornBig"))
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        return image
    }()
    
    private lazy var background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        addSubview(view)
        return view
    }()
    
    private lazy var leftMargin: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mediumSkyGray
        addSubview(view)
        return view
    }()
    
    private lazy var rightMargin: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mediumSkyGray
        addSubview(view)
        return view
    }()
    
    private lazy var defaultLabelCreator: (UIFont, UIColor) -> UILabel = { [weak self] in
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = $1
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.font = $0
        self?.addSubview(label)
        return label
    }
    
    private var attributedString: (CGFloat, String) -> NSMutableAttributedString = {
        return NSMutableAttributedString(string: $1,
                                         attributes: [ .font: UIFont.santander(size: $0),
                                                       .foregroundColor: UIColor.lisboaGray,
                                                       .kern: 0.0
                                         ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setInfo(_ info: EasyPayHeaderMovementViewModel) {
        movementTitleLabel.text = info.movementName
        cardNameLabel.text = info.cardName
        amountLabel.attributedText = info.amount
        configureOperationDate(info.operationDay, hour: info.operationHour)
        guard !info.settleDay.isEmpty else { return settleDateTitleLabel.text = localized("cardDetail_text_notLiquidated") }
        settleDateLabel.text = info.settleDay
    }
}

private extension EasyPayHeaderMovementView {
    func setup() {
        configureView()
        setupConstraints()
    }
    
    func configureView() {
        background.backgroundColor = .white
    }
    
    func setupConstraints() {
        movementTitleLabelConstraints()
        cardNameLabelConstraints()
        amountLabelConstraints()
        movementDateTitleLabelConstraints()
        movementDateLabelConstraints()
        settleDateTitleLabelConstraints()
        settleDateLabelConstraints()
        tornImageViewConstraints()
        marginsConstraints()
        backgroundConstraints()
    }
    
    func movementTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            movementTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0),
            movementTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 39.0),
            movementTitleLabel.heightAnchor.constraint(equalToConstant: 22.0)
        ])
    }
    
    func cardNameLabelConstraints() {
        NSLayoutConstraint.activate([
            cardNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0),
            cardNameLabel.topAnchor.constraint(equalTo: movementTitleLabel.bottomAnchor, constant: 2.0),
            cardNameLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: 5.0)
        ])
    }
    
    func amountLabelConstraints() {
        NSLayoutConstraint.activate([
            amountLabel.leadingAnchor.constraint(equalTo: movementTitleLabel.trailingAnchor, constant: 5.0),
            self.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 21.0),
            amountLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 37.0),
            amountLabel.heightAnchor.constraint(equalToConstant: 43.0)
        ])
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func movementDateTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            movementDateTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0),
            movementDateTitleLabel.topAnchor.constraint(equalTo: cardNameLabel.bottomAnchor, constant: 16.0),
            movementDateTitleLabel.heightAnchor.constraint(equalToConstant: 20.0),
            self.centerXAnchor.constraint(equalTo: movementDateTitleLabel.trailingAnchor)
        ])
    }
    
    func movementDateLabelConstraints() {
        NSLayoutConstraint.activate([
            movementDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0),
            movementDateLabel.topAnchor.constraint(equalTo: movementDateTitleLabel.bottomAnchor),
            movementDateLabel.heightAnchor.constraint(equalToConstant: 20.0),
            self.centerXAnchor.constraint(equalTo: movementDateLabel.trailingAnchor)
        ])
    }
    
    func settleDateTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            settleDateTitleLabel.topAnchor.constraint(equalTo: movementDateTitleLabel.topAnchor),
            settleDateTitleLabel.heightAnchor.constraint(equalToConstant: 20.0),
            self.trailingAnchor.constraint(equalTo: settleDateTitleLabel.trailingAnchor, constant: 21.0)
        ])
    }
    
    func settleDateLabelConstraints() {
        NSLayoutConstraint.activate([
            settleDateLabel.topAnchor.constraint(equalTo: settleDateTitleLabel.bottomAnchor),
            settleDateLabel.heightAnchor.constraint(equalToConstant: 20.0),
            self.trailingAnchor.constraint(equalTo: settleDateLabel.trailingAnchor, constant: 21.0)
        ])
    }
    
    func tornImageViewConstraints() {
        NSLayoutConstraint.activate([
            tornImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tornImageView.topAnchor.constraint(equalTo: movementDateLabel.bottomAnchor),
            tornImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tornImageView.heightAnchor.constraint(equalToConstant: 28.0),
            tornImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func marginsConstraints() {
        NSLayoutConstraint.activate([
            leftMargin.topAnchor.constraint(equalTo: self.topAnchor),
            leftMargin.bottomAnchor.constraint(equalTo: tornImageView.topAnchor),
            leftMargin.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            leftMargin.widthAnchor.constraint(equalToConstant: 1.0),
            rightMargin.topAnchor.constraint(equalTo: self.topAnchor),
            rightMargin.bottomAnchor.constraint(equalTo: tornImageView.topAnchor),
            self.trailingAnchor.constraint(equalTo: rightMargin.trailingAnchor),
            rightMargin.widthAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    func backgroundConstraints() {
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: self.topAnchor),
            background.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            background.bottomAnchor.constraint(equalTo: tornImageView.topAnchor),
            self.trailingAnchor.constraint(equalTo: background.trailingAnchor)
        ])
    }
    
    func configureOperationDate(_ day: String, hour: String) {
        let attributedDate = attributedString(14.0, day)
        let hourAttributedString = attributedString(11.0, " · " + hour)
        attributedDate.append(hourAttributedString)
        movementDateLabel.attributedText = attributedDate
    }
}
