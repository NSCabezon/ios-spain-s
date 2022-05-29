//
//  PaymentPresenter.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 07/04/2020.
//

import Foundation
import CoreFoundationLib

protocol PaymentPresenterProtocol: AnyObject {
    var view: PaymentViewProtocol? { get set }
    func viewDidLoad()
    func paymentActionSelected(type: BillsAndTaxesTypeOperativePayment)
}
public enum BillsAndTaxesTypeOperativePayment: Int {
    case bills
    case taxes
    case billPayment
}

class PaymentPresenter {
    
    weak var view: PaymentViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    private var coordinator: PaymentCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: PaymentCoordinatorProtocol.self)
    }
    private var billConfiguration: BillConfiguration {
        return self.dependenciesResolver.resolve(for: BillConfiguration.self)
    }
    private var paymentConfiguration: PaymentConfiguration {
        return self.dependenciesResolver.resolve(for: PaymentConfiguration.self)
    }
}

extension PaymentPresenter: PaymentPresenterProtocol {
    func paymentActionSelected(type: BillsAndTaxesTypeOperativePayment) {
        switch type {
        case .bills: trackEvent(.bill, parameters: [:])
        case .taxes: trackEvent(.taxes, parameters: [:])
        case .billPayment: trackEvent(.billPayment, parameters: [:])
        }

        self.coordinator.goToPayment(accountEntity: billConfiguration.account, type: type)
    }
    
    func viewDidLoad() {
        let builder = BillPaymentBuilder(paymentConfiguration)
            .addReceipts()
            .addTaxes()
            .addEmitterPayment()
        self.view?.setPaymentView(builder.build())
    }
}

extension PaymentPresenter: AutomaticScreenEmmaActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BillHomePage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.billAndTaxesEventID
        return BillHomePage(emmaToken: emmaToken)
    }
}
