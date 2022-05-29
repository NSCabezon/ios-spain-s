//
//  SKSecurityPersonalAreaModifier.swift
//  Santander
//
//  Created by David Gálvez Alonso on 12/4/22.
//

import RetailLegacy
import CoreFoundationLib
import SantanderKey
import SANSpainLibrary
import UI
import PersonalArea
import OpenCombine

final class SKSecurityPersonalAreaModifier: SKSecurityPersonalAreaModifierProtocol {
    let dependencies: SKCustomerDetailsExternalDependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    
    init(dependencies: SKCustomerDetailsExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func getCustomSecurityDeviceView() -> UIView? {
        let viewModel = SecurityViewModel(
            title: "security_button_sanKey",
            subtitle: "security_text_securitySanKey",
            icon: "icnSanKeyLockSecurity"
        )
        let view = self.makeSantanderKeyView(viewModel, idContainer: "", idButton: "")
        view.isUserInteractionEnabled = true
        view.action = self.goToSantanderKeyDetail
        return view
    }
    
    func isEnabledSantanderKey(completion: @escaping (Bool) -> Void) {
        let dependenciesResolver: DependenciesResolver = dependencies.resolve()
        let booleanFeatureFlag: BooleanFeatureFlag = dependenciesResolver.resolve()
        booleanFeatureFlag.fetch(SpainFeatureFlag.santanderKey)
            .sink { result in
                completion(result)
            }
            .store(in: &subscriptions)
    }
}

private extension SKSecurityPersonalAreaModifier {
    
    func goToSantanderKeyDetail() {
        let coordinator: SKCustomerDetailsCoordinator = dependencies.resolve()
        coordinator.start()
    }
    
    func makeSantanderKeyView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> SecureDeviceView {
        let view = SecureDeviceView()
        view.setViewModel(viewModel)
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
}

