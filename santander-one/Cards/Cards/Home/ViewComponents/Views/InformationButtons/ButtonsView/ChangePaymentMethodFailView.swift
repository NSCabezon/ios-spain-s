//
//  ChangePaymentMethodFailView.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 23/03/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol ChangePaymentMethodFailViewDelegate: AnyObject {
    func changePaymentMethodWithCodeButtonTapped()
}

class ChangePaymentMethodFailView: BaseInformationButton {
    @IBOutlet weak var changePaymentMethodImageView: UIImageView!
    @IBOutlet weak var changePaymentMethodLabel: UILabel!
    
    weak var delegate: ChangePaymentMethodFailViewDelegate?
    
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
        self.addGesture()
        self.configureLabel()
        self.changePaymentMethodImageView.image = Assets.image(named: "imgChangeWayToPay")
    }
    
    private func addGesture() {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    private func configureLabel() {
        self.changePaymentMethodLabel.textColor = .lisboaGray
        self.changePaymentMethodLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.changePaymentMethodLabel.configureText(withKey: "cards_button_changeWayToPay")
        self.changePaymentMethodLabel.adjustsFontSizeToFitWidth = true
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        self.delegate?.changePaymentMethodWithCodeButtonTapped()
    }
}
