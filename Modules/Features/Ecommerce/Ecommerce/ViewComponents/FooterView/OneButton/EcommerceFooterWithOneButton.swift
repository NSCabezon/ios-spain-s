//
//  EcommerceFooterWithOneButton.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 3/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

protocol DidTapInEcommerceFooterWithOneButtonProtocol: class {
    func didTapInTryInShopButton()
}

final class EcommerceFooterWithOneButton: XibView {
    @IBOutlet private weak var buttonContent: UIView!
    @IBOutlet private weak var buttonLabel: UILabel!
    @IBOutlet private weak var buttonImage: UIImageView!
    
    weak var delegate: DidTapInEcommerceFooterWithOneButtonProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @IBAction func didTapInFooterButton(_ sender: Any) {
        delegate?.didTapInTryInShopButton()
    }
}

private extension EcommerceFooterWithOneButton {
    func setupView() {
        self.buttonLabel.text = localized("ecommerce_button_business")
        self.setButtonWithImage()
        self.backgroundColor = .clear
        self.setFooterButton()
        self.setAccessibilityIds()
    }
    
    func setFooterButton() {
        self.buttonLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.buttonLabel.textColor = .white
        self.buttonImage.tintColor = .white
        self.buttonContent.backgroundColor = .darkTorquoise
        self.buttonContent.layer.cornerRadius = buttonContent.frame.size.height / 2
    }
    
    func setAccessibilityIds() {
        self.buttonContent.accessibilityIdentifier = AccessibilityEcommerceFooterView.footerButton
    }
    
    // MARK: Right Button state config
    func setButtonWithImage() {
        let rightTitle: EcommerceFooterType = .tryAgainInShop
        let rightImage = Assets.image(named: "icnBusinessWhite20")
        self.buttonLabel.text = localized("ecommerce_button_business")
        if let image = rightImage {
            buttonImage.image = image.withRenderingMode(.alwaysTemplate)
        }
    }
}
