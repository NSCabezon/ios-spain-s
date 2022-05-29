//
//  PaymentCoordinatorDevelopmentMock.swift
//  Bills
//
//  Created by Daniel Gómez Barroso on 20/9/21.
//
import CoreFoundationLib
import UI
import Operative

public final class PaymentCoordinatorDelegateMock: PaymentCoordinatorDelegate {
    public let dependenciesResolver: DependenciesResolver
    let navigator: UINavigationController
    
    public init(dependenciesResolver: DependenciesResolver, navigator: UINavigationController) {
        self.dependenciesResolver = dependenciesResolver
        self.navigator = navigator
    }
    
    public func didSelectPayment(accountEntity: AccountEntity?, type: BillsAndTaxesTypeOperativePayment?) { }
    
    public func didSelectBillEmittersPayment(account: AccountEntity?) {
        self.goToBillEmittersPayment(account: account, handler: self)
    }
}

extension PaymentCoordinatorDelegateMock: OperativeLauncherHandler {
    public var operativeNavigationController: UINavigationController? {
        return navigator
    }
    
    public func showOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    public func hideOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    public func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        completion?()
    }
}

extension PaymentCoordinatorDelegateMock: BillEmittersPaymentLauncher {}
