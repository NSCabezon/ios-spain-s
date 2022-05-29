//
//  ReactiveOperativeSignatureViewModel.swift
//  Operative
//
//  Created by David Gálvez Alonso on 8/3/22.
//

import OpenCombine
import CoreFoundationLib
import CoreDomain
import Foundation

public protocol SignatureViewModelProtocol {
    var state: AnyPublisher<ReactiveOperativeSignatureState, Never> { get set }
    func viewDidLoad()
    func didSetSignaturePositions(_ values: [String])
    func next()
}

public final class ReactiveOperativeSignatureViewModel<Capability: SignatureCapabilityStrategy>: SignatureViewModelProtocol, DataBindable {
    
    private let dependencies: ReactiveOperativeSignatureExternalDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    private var availableToContinue: Bool = false
    private let stateSubject = CurrentValueSubject<ReactiveOperativeSignatureState, Never>(.idle)
    private let capability: Capability
    private var signature: SignatureRepresentable?
    
    public var state: AnyPublisher<ReactiveOperativeSignatureState, Never>

    public init(dependencies: ReactiveOperativeSignatureExternalDependenciesResolver, capability: Capability) {
        self.dependencies = dependencies
        self.capability = capability
        state = stateSubject.eraseToAnyPublisher()
    }

    public func viewDidLoad() {
        loadData()
    }
    
    public var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    public func didSetSignaturePositions(_ values: [String]) {
        signature?.values = values
        let availableToContinue = signature?.values?.count == signature?.positions?.count
        stateSubject.send(.didChangeAvailabilityToContinue(availableToContinue))
    }
    
    public func next() {
        dataBinding.set(signature)
        self.stateSubject.send(.showLoading(true))
        capability.signaturePublisher
            .sink(receiveCompletion: { [unowned self] result in
                self.stateSubject.send(.showLoading(false))
                switch result {
                case .finished:
                    coordinator.next()
                case .failure(let error):
                    handle(error: error)
                }
            }, receiveValue: { _ in })
            .store(in: &anySubscriptions)
    }
}

private extension ReactiveOperativeSignatureViewModel {
    func loadData() {
        guard let signature: SignatureRepresentable = dataBinding.get() else {
            return
        }
        self.signature = signature
        publishLoadedInformation(signature)
    }
    
    func publishLoadedInformation(_ signature: SignatureRepresentable) {
        stateSubject.send(.loaded(ReactiveOperativeSignature(signature: signature)))
    }
    
    func handle(error: Error) {
        guard let errorType = error as? GenericErrorSignatureErrorOutput else {
            stateSubject.send(.showError(nil))
            return
        }
        switch errorType.signatureResult {
        case .revoked: // go to GP
            stateSubject.send(.showError(getRevokedViewModel(errorDescription: errorType.getErrorDesc())))
        case .otpUserExcepted:
            stateSubject.send(.showError(nil))
        case .ok:
            coordinator.next()
        case .invalid:
            stateSubject.send(.showError(getInvalidViewModel(errorDescription: errorType.getErrorDesc())))
        case .otherError: // reset operative
            stateSubject.send(.showError(getResetOperativeViewModel(errorDescription: errorType.getErrorDesc())))
        case .unknown: // stay
            stateSubject.send(.showError(getInvalidViewModel(errorDescription: errorType.getErrorDesc())))
        }
    }
    
    func getRevokedViewModel(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(iconName: "oneIcnWarning",
                                               alertDescription: errorDescription ?? "",
                                               floatingButtonText: localized("otp_button_goGlobalPosition"),
                                               floatingButtonAction: { [unowned self] in coordinator.goToGlobalPosition() },
                                               typeBottomSheet: .unowned,
                                               viewAccessibilityIdentifier: AccessibilityOperative.Alerts.signatureBlockedView)
    }
    
    func getInvalidViewModel(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(iconName: "oneIcnWarning",
                                               alertDescription: errorDescription ?? "",
                                               floatingButtonText: localized("generic_button_accept"),
                                               viewAccessibilityIdentifier: AccessibilityOperative.Alerts.signatureIncorrectPasswordView
        )
    }

    func getResetOperativeViewModel(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(iconName: "oneIcnWarning",
                                              alertDescription: errorDescription ?? "",
                                              floatingButtonText: localized("generic_button_accept"),
                                              floatingButtonAction: { [unowned self] in coordinator.resetOperative() },
                                              typeBottomSheet: .unowned,
                                              viewAccessibilityIdentifier: AccessibilityOperative.Alerts.blockedView)
    }

    func getStayViewModel(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(iconName: "oneIcnWarning",
                                              alertDescription: errorDescription ?? "",
                                              floatingButtonText: localized("generic_button_accept"),
                                              floatingButtonAction: nil,
                                              typeBottomSheet: .all,
                                              viewAccessibilityIdentifier: AccessibilityOperative.Alerts.blockedView)
    }
}

private extension ReactiveOperativeSignatureViewModel {
    var coordinator: OperativeCoordinator {
        return dependencies.resolve()
    }
}
    
public enum ReactiveOperativeSignatureState: State {
    case idle
    case loaded(ReactiveOperativeSignature)
    case didChangeAvailabilityToContinue(Bool)
    case showError(OneOperativeAlertErrorViewData?)
    case showLoading(Bool)
}

public struct ReactiveOperativeSignature {
    var signature: SignatureRepresentable
}
