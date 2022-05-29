//
//  DeepLinkApplePayProxy.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 6/9/20.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Cards
import CoreFoundationLib
import Foundation

protocol DeepLinkProxy {
    func begin()
}

final class DeepLinkApplePayProxy: DeepLinkProxy {
    private let navigatorProvider: NavigatorProvider
    private let enrollmentManager: ApplePayEnrollmentManager
    private var errorHandler: GenericPresenterErrorHandler {
        self.dependencies.resolve(for: GenericPresenterErrorHandler.self)
    }
    private let dependencies: DependenciesResolver
    
    enum DeepLinkError: Error {
        case disableInAppEnrollment
        case unableAddApplePayment(String)
    }
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
        self.navigatorProvider = dependencies.resolve(for: NavigatorProvider.self)
        self.enrollmentManager = ApplePayEnrollmentManager(dependenciesResolver: dependencies)
    }
    
    func begin() {
        self.validateEnrollableCards { [weak self] in
            self?.performAction()
        }
    }
}

private extension DeepLinkApplePayProxy {
    private func performAction() {
        guard enrollmentManager.isEnrollingCardEnabled() else { return self.enrollCardNotAvailable() }
        self.navigatorProvider.applePayNavigator.goToAddToApplePay()
    }
    
    private func enrollCardNotAvailable() {
        let errorDesc = localized("deeplink_alert_deviceNotAddCard", [StringPlaceholder(.value, localized("cardsOption_button_pay_ios"))])
        self.errorHandler.onError(keyDesc: errorDesc.text, completion: {})
    }
    
    private func validateEnrollableCards(completion: @escaping() -> Void) {
        UseCaseWrapper(
            with: self.dependencies.resolve(for: PreSetupAddToApplePayUseCase.self),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            errorHandler: errorHandler,
            onSuccess: { _ in
                completion()
            }, onError: { [weak self] error in
                guard let errorKey = error?.getErrorDesc() else { return }
                let errorDesc = localized(errorKey, [StringPlaceholder(.value, localized("cardsOption_button_pay_ios"))])
                self?.errorHandler.onError(keyDesc: errorDesc.text, completion: {})
            }
        )
    }
}
