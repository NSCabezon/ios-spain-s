//
//  EcommerceFooterView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 1/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

protocol DidTapInFooterButtons: class {
    func didTapInCancel()
    func didTapInBack()
    func didTapInRightButton(_ type: EcommerceFooterType)
    func didTapInTryAgainInShop()
}

final class EcommerceFooterView: XibView {
    @IBOutlet private weak var footerStackView: UIStackView!
    
    weak var delegate: DidTapInFooterButtons?
    
    private var type: EcommerceFooterType?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ footerType: EcommerceFooterType) {
        self.type = footerType
        self.isHidden = false
        self.footerStackView.removeAllArrangedSubviews()
        switch footerType {
        case .tryAgainInShop:
            self.addFooterWithOneButton()
        case .confirmBy, .useCodeAccess, .processingPayment, .restorePassword:
            self.addFooterWithTwoButtons(footerType)
        case .emptyView:
            self.footerStackView.removeAllArrangedSubviews()
            self.isHidden = true
        }
    }
    
    func handleShadow(_ showShadow: Bool) {
        self.removeShadow()
        guard let footerType = type else {
            return
        }
        if showShadow {
            self.handleShadowIfNeeded(footerType)
        }
    }
}

private extension EcommerceFooterView {
    func setupView() {
        self.setColors()
        self.setAccessibilityIds()
    }
    
    // MARK: SetupView
    func setColors() {
        self.backgroundColor = .skyGray
        self.footerStackView.backgroundColor = .clear
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityEcommerceFooterView.baseView
    }
    
    // MARK: Config Footer
    func handleShadowIfNeeded(_ footerType: EcommerceFooterType) {
        switch footerType {
        case .confirmBy, .useCodeAccess, .processingPayment, .tryAgainInShop:
            self.drawShadow(offset: (x: 0, y: -2), opacity: 0.1, color: .black, radius: 4)
            self.layer.masksToBounds = false
        case .emptyView, .restorePassword:
            break
        }
    }
    
    func addFooterWithOneButton() {
        let view = EcommerceFooterWithOneButton()
        view.delegate = self
        self.footerStackView.addArrangedSubview(view)
    }
    
    func addFooterWithTwoButtons(_ state: EcommerceFooterType) {
        let view = EcommerceFooterWithTwoButtons()
        view.delegate = self
        view.config(state)
        self.footerStackView.addArrangedSubview(view)
    }
}

extension EcommerceFooterView: DidTapInEcommerceFooterWithOneButtonProtocol {
    func didTapInTryInShopButton() {
        delegate?.didTapInTryAgainInShop()
    }
}

extension EcommerceFooterView: DidTapInFooterWithTwoButtonsProtocol {
    func didTapInCancel() {
        if case .useCodeAccess = self.type {
            didTapInBack()
            return
        }
        delegate?.didTapInCancel()
    }
    
    func didTapInBack() {
        delegate?.didTapInBack()
    }
    
    func didTapInRightButton(_ type: EcommerceFooterType) {
        delegate?.didTapInRightButton(type)
    }
}
