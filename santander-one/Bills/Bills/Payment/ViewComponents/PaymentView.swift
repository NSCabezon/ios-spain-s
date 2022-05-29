//
//  PaymentView.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 07/04/2020.
//

import Foundation
import UIKit
import UI
import CoreFoundationLib

protocol PaymentViewDelegate: AnyObject {
    func didSelectAction(type: BillsAndTaxesTypeOperativePayment)
}

class PaymentView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    weak var delegate: PaymentViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModels: [PaymentViewModel]) {

        viewModels.forEach { viewModel in
            let paymentActionView = PaymentActionView()
            paymentActionView.setViewModel(viewModel)
            paymentActionView.delegate = self
            self.stackView.addArrangedSubview(paymentActionView)
        }
    }
}

extension PaymentView: PaymentActionViewDelegate {
    func didSelectAction(type: BillsAndTaxesTypeOperativePayment) {
        self.delegate?.didSelectAction(type: type)
    }
}

private extension PaymentView {
    
     func setAppearance() {
        self.titleLabel.configureText(withKey: "receiptsAndTaxes_title_makePayment",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 18)))
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.accessibilityIdentifier = "receiptsAndTaxes_title_makePayment"
        self.accessibilityIdentifier = "areaCard"
    }
}
