//
//  GraphicInformationButtonView.swift
//  Cards-Cards
//
//  Created by Juan Carlos López Robles on 11/4/19.
//

import Foundation
import UI
import CoreFoundationLib

protocol CashDispositionButtonViewProtocol: AnyObject {
    func cashDispositionWithCodeButtonTapped()
}

class CashDispositionButtonView: BaseInformationButton {
    @IBOutlet weak var cashDispositionImageView: UIImageView!
    @IBOutlet weak var cashDispositionLabel: UILabel!
    
    weak var delegate: CashDispositionButtonViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
        addGesture()
        configureLabel()
        cashDispositionImageView.image = Assets.image(named: "imgGetMoneyCode")
        setAccessibilityIdentifiers()
    }
    
    private func addGesture() {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    private func configureLabel() {
        self.cashDispositionLabel.textColor = .lisboaGray
        self.cashDispositionLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.cashDispositionLabel.configureText(withKey: "cards_button_moneyWithCode")
        self.cashDispositionLabel.adjustsFontSizeToFitWidth = true
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        delegate?.cashDispositionWithCodeButtonTapped()
    }
    
    private func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "cards_button_moneyWithCode"
        self.cashDispositionLabel.accessibilityIdentifier = "cards_label_moneyWithCode_title"
        self.cashDispositionImageView.accessibilityIdentifier = "cards_button_moneyWithCode_image"
    }
}
