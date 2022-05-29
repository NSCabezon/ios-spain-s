//
//  EasyPayDescriptionView.swift
//  Cards
//
//  Created by alvola on 03/12/2020.
//

import UI
import CoreFoundationLib

final class EasyPayDescriptionView: UIView {
    
    private lazy var howManyFeesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .lisboaGray
        label.configureText(withKey: "easyPay_label_pay",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 18.0),
                                                                                 alignment: .center,
                                                                                 lineBreakMode: .byWordWrapping))
        label.accessibilityIdentifier = AccessibilityCardsEasyPay.DescriptionView.howManyFeesLabel
        addSubview(label)
        return label
    }()
    
    private lazy var dividePayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .lisboaGray
        label.configureText(withKey: "easyPay_label_dividePay",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(size: 14.0),
                                                                                 alignment: .center,
                                                                                 lineBreakMode: .byWordWrapping))
        label.accessibilityIdentifier = AccessibilityCardsEasyPay.DescriptionView.dividePayLabel
        addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setDescription(_ description: LocalizedStylableText) {
        dividePayLabel.configureText(withLocalizedString: description)
    }
}

private extension EasyPayDescriptionView {
    func setup() {
        howManyFeesLabelConstraints()
        dividePayLabelConstraints()
    }
    
    func howManyFeesLabelConstraints() {
        NSLayoutConstraint.activate([
            howManyFeesLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            howManyFeesLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30.0),
            howManyFeesLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.0)
        ])
    }
    
    func dividePayLabelConstraints() {
        NSLayoutConstraint.activate([
            dividePayLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dividePayLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0),
            dividePayLabel.topAnchor.constraint(equalTo: howManyFeesLabel.bottomAnchor, constant: 7.0),
            self.bottomAnchor.constraint(equalTo: dividePayLabel.bottomAnchor, constant: 16.0)
        ])
    }
}
