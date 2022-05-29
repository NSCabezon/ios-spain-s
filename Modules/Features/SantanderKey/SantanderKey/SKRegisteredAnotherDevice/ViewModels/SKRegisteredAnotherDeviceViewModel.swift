//
//  SKRegisteredAnotherDeviceViewModel.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import SANSpainLibrary
import Operative
import ESCommons

enum SKRegisteredAnotherDeviceState: State {
    case idle
    case showLoading(Bool)
    case showError(OneOperativeAlertErrorViewData?)
}

final class SKRegisteredAnotherDeviceViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKRegisteredAnotherDeviceDependenciesResolver
    private let stateSubject = CurrentValueSubject<SKRegisteredAnotherDeviceState, Never>(.idle)
    var state: AnyPublisher<SKRegisteredAnotherDeviceState, Never>
    let compilation: SpainCompilationProtocol

    init(dependencies: SKRegisteredAnotherDeviceDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
        self.compilation = dependencies.external.resolve()
    }
    
    func viewDidLoad() {
        
    }
    
    func checkSKinDevice() -> Bool {
        let clientStatus: SantanderKeyStatusRepresentable? = dataBinding.get()
        if let clientStatus = clientStatus?.otherSKinDevice, clientStatus.lowercased() == "true" {
            return true
        }
        return false
    }
    
    func didSelectLaterButton() {
        coordinator.goToGlobalPosition()
    }

    func didSelectLinkButton() {
        if checkTokenPush() {
            stateSubject.send(.showLoading(true))
            self.coordinator.goToOperative()
        } else {
            stateSubject.send(.showError(showPushBlockingError()))
        }
    }

    func close() {
        coordinator.goToGlobalPosition()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

private extension SKRegisteredAnotherDeviceViewModel {
    var coordinator: SKRegisteredAnotherDeviceCoordinator {
        return dependencies.resolve()
    }
    
    func checkTokenPush() -> Bool {
        let lookupQuery = KeychainQuery(compilation: compilation,
                                        accountPath: \.keychain.account.tokenPush)
        return (try? KeychainWrapper().fetch(query: lookupQuery) as? Data) != nil
    }
}

// MARK: - Subscriptions

private extension SKRegisteredAnotherDeviceViewModel {
    func showPushBlockingError() -> OneOperativeAlertErrorViewData {
        OneOperativeAlertErrorViewData(iconName: "oneIcnNotification",
                                       alertTitle: localized("sanKey_title_activateNotifications"),
                                       alertDescription: localized("sanKey_text_activationNotifications"),
                                       floatingButtonText: localized("otp_button_goGlobalPosition"),
                                       floatingButtonAction: { [unowned self] in
                                           coordinator.dismiss()
                                       },
                                       typeBottomSheet: .unowned,
                                       viewAccessibilityIdentifier: "")
    }
}

// MARK: - Publishers

private extension SKRegisteredAnotherDeviceViewModel {}
