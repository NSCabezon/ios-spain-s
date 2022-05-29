//
//  EasyPaySimpleError.swift
//  Cards
//
//  Created by alvola on 04/12/2020.
//

import UI
import CoreFoundationLib

final class EasyPaySimpleError: UIView {
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .lisboaGray
        label.configureText(withKey: "easyPay_text_error",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(size: 16.0),
                                                                                 alignment: .center,
                                                                                 lineBreakMode: .byWordWrapping))
        label.accessibilityIdentifier = AccessibilityCardsEasyPay.SimpleError.errorLabel
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
    
    func setErrorDescription(_ desc: String?) {
        guard let error = desc, !error.isEmpty else {
            errorLabel.configureText(withKey: "easyPay_text_error")
            return
        }
        errorLabel.configureText(withKey: error)
    }
}

private extension EasyPaySimpleError {
    func setup() {
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30.0),
            errorLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5.0),
            self.bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16.0)
        ])
    }    
}
