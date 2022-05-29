//
//  ReactiveOperativeOTPViewModel.swift
//  Operative
//
//  Created by David Gálvez Alonso on 17/3/22.
//

import OpenCombine
import CoreFoundationLib
import CoreDomain
import Foundation

public protocol OTPViewModelProtocol {
    var state: AnyPublisher<ReactiveOperativeOTPState, Never> { get set }
    func viewDidLoad()
    func didSetOTP(_ otp: String)
    func next()
    func resendCode()
}

public final class ReactiveOperativeOTPViewModel<Capability: OTPCapabilityStrategy>: OTPViewModelProtocol, DataBindable {
    
    public var state: AnyPublisher<ReactiveOperativeOTPState, Never>
    
    private let dependencies: ReactiveOperativeOTPExternalDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    private var availableToContinue: Bool = false
    private let stateSubject = CurrentValueSubject<ReactiveOperativeOTPState, Never>(.idle)
    private let capability: Capability
    private var maxLength: Int {
        let otpConfiguration: OTPConfigurationProtocol? = dependencies.resolve()
        guard let otpConfiguration = otpConfiguration else {
            return 8
        }
        return otpConfiguration.maxlength
    }
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        let appNotification: APPNotificationManagerBridgeProtocol? = dependencies.resolve()
        return appNotification?.getOtpPushManager()
    }()
    
    private var otpValidation: OTPValidationRepresentable?
    
    public init(dependencies: ReactiveOperativeOTPExternalDependenciesResolver, capability: Capability) {
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
    
    public func didSetOTP(_ otp: String) {
        self.otpValidation?.magicPhrase = otp
        let availableToContinue = maxLength == otp.count
        stateSubject.send(.didChangeAvailabilityToContinue(availableToContinue))
    }
    
    public func resendCode() {
        otpPushManager?.updateToken { [unowned self] _, _ in
            showResendAlert()
        }
    }
    
    public func next() {
        dataBinding.set(otpValidation)
        self.stateSubject.send(.showLoading(true))
        capability.otpPublisher
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

private extension ReactiveOperativeOTPViewModel {
    func loadData() {
        let operativeConfig: OperativeConfig? = dataBinding.get()
        stateSubject.send(.loaded(ReactiveOperativeOTPLoadedInformation(maxLength: maxLength, phoneNumber: operativeConfig?.consultiveUserPhone ?? "")))
        guard let otpValidation: OTPValidationRepresentable? = dataBinding.get() else {
            return
        }
        self.otpValidation = otpValidation
    }
    
    func showResendAlert() {
        stateSubject.send(.showError(getResendViewModel()))
    }
    
    func handle(error: Error) {
        guard let errorType = error as? GenericErrorOTPErrorOutput else {
            HapticTrigger.operativeError()
            stateSubject.send(.showError(nil))
            return
        }
        switch errorType.otpResult {
        case .correctOTP:
            coordinator.next()
        case .wrongOTP:
            stateSubject.send(.showError(getInvalidViewModel(errorDescription: errorType.getErrorDesc())))
        case .otpRevoked: // go to GP
            stateSubject.send(.showError(getRevokedViewModel(errorDescription: errorType.getErrorDesc())))
        case .serviceDefault:
            stateSubject.send(.showError(getInvalidViewModel(errorDescription: errorType.getErrorDesc())))
        case .otpExpired :
            stateSubject.send(.showError(nil))
        case .otherError: // reset operative
            stateSubject.send(.showError(getResetOperativeViewModel(errorDescription: errorType.getErrorDesc())))
        case .unknown: // stay
            stateSubject.send(.showError(getStayViewModel(errorDescription: errorType.getErrorDesc())))
        }
    }
    
    func getResendViewModel() -> OneOperativeAlertErrorViewData {
        let operativeConfig: OperativeConfig? = dataBinding.get()
        let alertDescription = localized("otp_text_popup_notReceived", [StringPlaceholder(.phone, operativeConfig?.otpSupportPhone ?? "")])
        return OneOperativeAlertErrorViewData(alertTitle: "otp_titlePopup_notReceived",
                                              alertDescription: alertDescription.text,
                                              floatingButtonText: localized("otp_button_understand"),
                                              viewAccessibilityIdentifier: AccessibilityOperative.Alerts.otpNotReceivedCodeView
        )
    }
    
    func getRevokedViewModel(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(iconName: "oneIcnWarning",
                                              alertDescription: errorDescription ?? "",
                                              floatingButtonText: localized("generic_button_accept"),
                                              floatingButtonAction: { [unowned self] in coordinator.goToGlobalPosition() },
                                              typeBottomSheet: .unowned,
                                              viewAccessibilityIdentifier: AccessibilityOperative.Alerts.blockedView)
    }
    
    func getInvalidViewModel(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(iconName: "oneIcnWarning",
                                              alertDescription: errorDescription ?? "",
                                              floatingButtonText: localized("generic_button_accept"),
                                              viewAccessibilityIdentifier: AccessibilityOperative.Alerts.otpInvalidReceivedCodeView
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

private extension ReactiveOperativeOTPViewModel {
    var coordinator: OperativeCoordinator {
        return dependencies.resolve()
    }
}
    
public enum ReactiveOperativeOTPState: State {
    case idle
    case loaded(ReactiveOperativeOTPLoadedInformation)
    case didChangeAvailabilityToContinue(Bool)
    case showError(OneOperativeAlertErrorViewData?)
    case showLoading(Bool)
}

public struct ReactiveOperativeOTP {
    var otp: OTPValidationRepresentable
}

public struct ReactiveOperativeOTPLoadedInformation {
    var maxLength: Int
    var phoneNumber: String
}
