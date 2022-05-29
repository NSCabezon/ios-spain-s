//
//  SpainPushLauncher.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 24/5/21.
//

import Foundation
import CoreFoundationLib
import RetailLegacy
import Ecommerce
import CorePushNotificationsService

enum SpainPushActionType: CustomPushLaunchActionTypeCapable {
    case ecommerce(String?)
}

final class SpainPushLauncher {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var sessionManager: CoreSessionManager {
        return self.dependenciesResolver.resolve(for: CoreSessionManager.self)
    }
}

extension SpainPushLauncher: CustomPushLauncherProtocol {
    func executeActionForType(actionType: CustomPushLaunchActionTypeCapable) {
        guard let action = actionType as? SpainPushActionType else { return }
        switch action {
        case .ecommerce(let otpCode):
            guard self.sessionManager.isSessionActive else {
                self.goToEcommerceWithPersistedUser(otpCode: otpCode)
                return
            }
            self.goToDeeplink()
        }
    }
}

private extension SpainPushLauncher {
    /// Launches the ecommerce fake curtain.
    func goToEcommerce(otpCode: String?) {
        let ecommerceNavigator = self.dependenciesResolver.resolve(for: EcommerceNavigatorProtocol.self)
        ecommerceNavigator.showEcommerce(.mainPushNotification, withCode: otpCode)
    }
    
    func goToEcommerceWithPersistedUser(otpCode: String?) {
        Scenario(useCase: IsPersistedUserUseCase(dependenciesResolver: self.dependenciesResolver))
            .execute(on: self.dependenciesResolver.resolve(for: UseCaseHandler.self))
            .onSuccess { [weak self] _ in
                self?.goToEcommerce(otpCode: otpCode)
            }
            .onError { [weak self] _ in
                self?.goToDeeplink()
            }
    }
    
    func goToDeeplink() {
        let deeplinkManager = self.dependenciesResolver.resolve(for: DeepLinkManagerProtocol.self)
        deeplinkManager.registerDeepLink(SpainDeepLink.ecommerce)
    }
}
