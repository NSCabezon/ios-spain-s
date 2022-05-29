//
//  CardExternalDependenciesResolver.swift
//  Cards
//
//  Created by Gloria Cano López on 4/3/22.
//

import Foundation
import CoreFoundationLib
import UI

public protocol CardExternalDependenciesResolver: CardDetailExternalDependenciesResolver, CardShoppingMapExternalDependenciesResolver, CardTransactionFiltersExternalDependenciesResolver, CardTransactionDetailExternalDependenciesResolver, CardCommonExternalDependenciesResolver {
    func resolve() -> BooleanFeatureFlag
}

public extension CardExternalDependenciesResolver {
    func cardCVVCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardOnCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardInstantCashCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardDelayPaymentCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardPayOffCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardChargeDischargeCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardPinCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardBlockCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardWithdrawMoneyWithCodeCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardMobileTopUpCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardCesCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardPdfExtractCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardHistoricPdfExtractCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardPdfDetailCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardFractionablePurchasesCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardModifyLimitsCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardSolidarityRoundingCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardChangePaymentMethodCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardHireCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardDivideCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardShareCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardFraudCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardChargePrepaidCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardApplePayCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardDuplicatedCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardSuscriptionCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardConfigureCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardSubscriptionsCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardFinancingBillsCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardCustomeCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardOffCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func easyPayCoordinator() -> BindableCoordinator {
        return ToastCoordinator("Tap Action")
    }
    
    func cardExternalDependenciesResolver() -> CardExternalDependenciesResolver {
        return self
    }
}
