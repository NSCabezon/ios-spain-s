//
//  SKPinStepViewModel.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 23/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import Operative
import SANSpainLibrary
import SANLibraryV3

enum PinStepState: State {
    case idle
    case pinEditing(Bool)
    case pinFilled(Bool)
    case showLoading(Bool)
    case showError(OneOperativeAlertErrorViewData?)
}

final class SKPinStepViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKPinStepDependenciesResolver
    private let stateSubject = CurrentValueSubject<PinStepState, Never>(.idle)
    var state: AnyPublisher<PinStepState, Never>
    var stepsCoordinator: StepsCoordinator<SKOperativeStep>?
    @BindingOptional var operativeData: SKOnboardingOperativeData!
    
    init(dependencies: SKPinStepDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        stepsCoordinator = operative.stepsCoordinator
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    @objc func didTapSelecOtherCard() {
        operative.back()
    }
    
    func setInputCodeFilled(_ filled: Bool) {
        stateSubject.send(.pinFilled(filled))
    }
    
    func setInputCodeEditing(_ editing: Bool) {
        stateSubject.send(.pinEditing(editing))
    }

    func didTapContinueButton(pin: String) {
        operativeData.selectedCardPIN = pin
        dataBinding.set(operativeData)
        validateWithPin()
    }
}

private extension SKPinStepViewModel {
    func validateWithPin() {
        let skOperativeData: SKOnboardingOperativeData? = dataBinding.get()
        guard let sankeyId = skOperativeData?.sanKeyId, let cardPan = skOperativeData?.selectedCardPAN, let cardType = skOperativeData?.cardType,
              let pin = skOperativeData?.selectedCardPIN else { return }
        self.stateSubject.send(.showLoading(true))
        registerValidationPinPublisher(sanKeyId: sankeyId, cardPan: cardPan, cardType: cardType, pin: pin)
            .subscribe(on: Schedulers.global)
            .receive(on: Schedulers.main)
            .sink { [unowned self] completion in
                stateSubject.send(.showLoading(false))
                if case .failure(let error) = completion {
                    handle(error: error)
                }
            } receiveValue: { [unowned self] result in
                let operativeConfig: OperativeConfig? = OperativeConfig(signatureSupportPhone: nil, otpSupportPhone: nil, cesSupportPhone: nil, consultiveUserPhone: result.0.mobileNumber, loanAmortizationSupportPhone: nil)
                operative.operativeData.otpReference = result.0.otpReference
                dataBinding.set(operative.operativeData)
                dataBinding.set(operativeConfig)
                dataBinding.set(result.1)
                operative.coordinator.next()
            }
            .store(in: &anySubscriptions)
    }
}

private extension SKPinStepViewModel {
    var operative: SKOperative {
        dependencies.resolve()
    }
    var registerValidationPinUseCase: SantanderKeyRegisterValidationWithPINUseCase {
        dependencies.external.resolve()
    }

    var coordinator: OperativeCoordinator {
        let operative: SKOperative = dependencies.resolve()
        return operative.coordinator
    }

    func handle(error: Error) {
        guard let errorType = error as? SantanderKeyError else {
            HapticTrigger.operativeError()
            stateSubject.send(.showError(nil))
            return
        }
        switch errorType.getAction() {
        case .goToPG:
            stateSubject.send(.showError(showBlockingError(errorDescription: errorType.getLocalizedDescription())))
        case .goToOperative:
            stateSubject.send(.showError(showNonBlockingError(errorDescription: errorType.getLocalizedDescription())))
        case .stay:
            stateSubject.send(.showError(showStayError(errorDescription: errorType.getLocalizedDescription())))
        }
    }

    func showBlockingError(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(
            iconName: "oneIcnWarning",
            alertDescription: errorDescription ?? "",
            floatingButtonText: localized("otp_button_goGlobalPosition"),
            floatingButtonAction: { [unowned self] in
                coordinator.goToGlobalPosition()
            },
            typeBottomSheet: .unowned,
            viewAccessibilityIdentifier: ""
        )
    }

    func showNonBlockingError(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(
            iconName: "oneIcnWarning",
            alertDescription: errorDescription ?? "",
            floatingButtonText: localized("generic_button_accept"),
            floatingButtonAction: { [unowned self] in
                operative.coordinator.resetOperative()
            },
            typeBottomSheet: .unowned,
            viewAccessibilityIdentifier: ""
        )
    }

    func showStayError(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(
            iconName: "oneIcnWarning",
            alertDescription: errorDescription ?? "",
            floatingButtonText: localized("generic_button_accept"),
            typeBottomSheet: .all,
            viewAccessibilityIdentifier: ""
        )
    }
}

// MARK: - Subscriptions

private extension SKPinStepViewModel {

}

// MARK: - Publishers

private extension SKPinStepViewModel {
    func registerValidationPinPublisher(sanKeyId: String, cardPan: String, cardType: String, pin: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> {
        return registerValidationPinUseCase.registerValidationPIN(sanKeyId: sanKeyId, cardPan: cardPan, cardType: cardType, pin: pin)
    }
}
