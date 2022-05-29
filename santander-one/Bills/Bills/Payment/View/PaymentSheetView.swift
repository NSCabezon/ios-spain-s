//
//  PaymentView.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 07/04/2020.
//

import Foundation
import UIKit
import UI

protocol PaymentViewProtocol: AnyObject {
    func setPaymentView(_ viewModel: [PaymentViewModel])
}

class PaymentSheetView: SheetView {
    
    let presenter: PaymentPresenterProtocol
    
    init(presenter: PaymentPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func load() {
        self.presenter.viewDidLoad()
    }
}

extension PaymentSheetView: PaymentViewProtocol {
    
    func setPaymentView(_ viewModel: [PaymentViewModel]) {
        let paymentView = PaymentView()
        paymentView.setViewModel(viewModel)
        paymentView.delegate = self
        self.removeContent()
        self.addContentView(paymentView)
        self.show()
    }
}

extension PaymentSheetView: PaymentViewDelegate {
    
    func didSelectAction(type: BillsAndTaxesTypeOperativePayment) {
        self.closeWithAnimationAndCompletion { [weak self] in
            self?.presenter.paymentActionSelected(type: type)
        }
    }
}
