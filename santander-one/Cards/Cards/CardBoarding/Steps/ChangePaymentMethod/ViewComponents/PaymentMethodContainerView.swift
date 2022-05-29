//
//  PaymentMethodContainerView.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 09/10/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol PaymentMethodContainerDelegate: AnyObject {
    func didUpdatedNewPaymentMethod(_ paymentMethod: PaymentMethodCategory)
}

class PaymentMethodContainerView: XibView {
    @IBOutlet weak var stackView: UIStackView!
    private var monthlyView = PaymentMethodView()
    private var deferredView = PaymentMethodExpandableView()
    private var fixedFeeView = PaymentMethodExpandableView()
    private var selectedPaymentMethod: PaymentMethodCategory?
    weak var delegate: PaymentMethodContainerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setSelectedPaymentMethod(_ paymentMethod: PaymentMethodCategory) {
        self.selectedPaymentMethod = paymentMethod
    }
    
    func setMonthlyView(_ viewModel: PaymentMethodViewModel) {
        self.monthlyView.setViewModel(viewModel)
        self.monthlyView.delegate = self
        self.stackView.addArrangedSubview(self.monthlyView)
        self.stackView.layoutIfNeeded()
    }
    
    func setDeferredView(_ viewModel: PaymentMethodExpandableViewModel) {
        self.deferredView.translatesAutoresizingMaskIntoConstraints = false
        self.deferredView.setViewModel(viewModel)
        self.deferredView.delegate = self
        self.stackView.addArrangedSubview(self.deferredView)
        self.stackView.layoutIfNeeded()
    }
    
    func setFixedFeeView(_ viewModel: PaymentMethodExpandableViewModel) {
        self.fixedFeeView.translatesAutoresizingMaskIntoConstraints = false
        self.fixedFeeView.setViewModel(viewModel)
        self.fixedFeeView.delegate = self
        self.stackView.addArrangedSubview(self.fixedFeeView)
        self.stackView.layoutIfNeeded()
    }
}

private extension PaymentMethodContainerView {
    func setAppearance() {
        self.backgroundColor = .clear
        self.setStackView()
    }
    
    func setStackView() {
        self.stackView.backgroundColor = .clear
        self.stackView.spacing = 13
    }
    
    func setContainerViews(_ newPaymentMethod: PaymentMethodCategory) {
        switch newPaymentMethod {
        case .monthlyPayment:
            self.setMonthlyViewSelected()
        case .deferredPayment:
            self.setDeferredViewSelected()
        case .fixedFee:
            self.setFixedFeeSelected()
        }
    }
    
    func setMonthlyViewSelected() {
        self.deferredView.setViewState(.deselected)
        self.fixedFeeView.setViewState(.deselected)
        self.monthlyView.setViewState(.selected)
    }
    
    func setDeferredViewSelected() {
        self.monthlyView.setViewState(.deselected)
        self.fixedFeeView.setViewState(.deselected)
        self.deferredView.setViewState(.selected)
    }
    
    func setFixedFeeSelected() {
        self.monthlyView.setViewState(.deselected)
        self.deferredView.setViewState(.deselected)
        self.fixedFeeView.setViewState(.selected)
    }
    
    func didSelectNewPaymentMethod(_ paymentMethod: PaymentMethodCategory) {
        self.delegate?.didUpdatedNewPaymentMethod(paymentMethod)
        self.selectedPaymentMethod = paymentMethod
        self.setContainerViews(paymentMethod)
    }
}

extension PaymentMethodContainerView: PaymentMethodViewDelegate {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethodCategory) {
        self.didSelectNewPaymentMethod(paymentMethod)
    }
}

extension PaymentMethodContainerView: PaymentMethodExpandableViewDelegate {
    func didSelectPaymentMethodExpandable(_ paymentMethod: PaymentMethodCategory) {
        self.didSelectNewPaymentMethod(paymentMethod)
    }
}
