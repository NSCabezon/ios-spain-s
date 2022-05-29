//
//  PaymentMethodView.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 07/10/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol PaymentMethodViewDelegate: AnyObject {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethodCategory)
}

class PaymentMethodView: XibView {
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    weak var delegate: PaymentMethodViewDelegate?
    private var viewModel: PaymentMethodViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    @IBAction private func paymentMethodPressed(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        self.delegate?.didSelectPaymentMethod(viewModel.paymentMethod)
    }
    
    func setViewModel(_ viewModel: PaymentMethodViewModel) {
        self.viewModel = viewModel
        self.setView(with: viewModel)
    }
    
    func setViewState(_ viewState: PaymentMethodViewState) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.setViewStyle(viewState)
        })
    }
}

private extension PaymentMethodView {
    func setAppearance() {
        self.view?.backgroundColor = .clear
        self.containerView?.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.selectionBtn.accessibilityIdentifier = AccessibilityCardBoarding.ChangePayment.monthlyButton.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.ChangePayment.monthlyTitle.rawValue
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.ChangePayment.monthlyDescription.rawValue
    }
    
    func setView(with viewModel: PaymentMethodViewModel) {
        self.titleLabel.text = localized(viewModel.title)
        self.descriptionLabel.configureText(withKey: viewModel.description,
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14),
                                                                                                 lineHeightMultiple: 0.85))
        self.setViewStyle(viewModel.viewState)
    }
    
    func setViewStyle(_ viewState: PaymentMethodViewState) {
        switch viewState {
        case .selected:
            self.setSelectedStyle()
        case .deselected:
            self.setDeselectedStyle()
        }
    }
    
    func setSelectedStyle() {
        self.containerView?.backgroundColor = .darkTorquoise
        self.titleLabel.textColor = .white
        self.descriptionLabel.textColor = .white
    }
    
    func setDeselectedStyle() {
        self.containerView?.backgroundColor = .white
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.textColor = .lisboaGray
    }
}
