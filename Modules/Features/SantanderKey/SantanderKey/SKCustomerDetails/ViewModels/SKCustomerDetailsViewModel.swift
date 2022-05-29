//
//  SKCustomerDetailsViewModel.swift
//  SantanderKey
//
//  Created by David Gálvez Alonso on 11/4/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import SANSpainLibrary
import Operative
import ESCommons
import SANLibraryV3

enum SKCustomerDetailsState: State {
    case idle
    case showLoading(Bool)
    case faqsLoaded(OneFooterData)
    case didReceiveDetailResult(SKCustomerDetailsDeviceInfoType)
    case didFailed
    case didReciveBiometryResult((message: String?, success: Bool))
    case showError(OneOperativeAlertErrorViewData?)
}

final class SKCustomerDetailsViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKCustomerDetailsDependenciesResolver
    private let stateSubject = CurrentValueSubject<SKCustomerDetailsState, Never>(.idle)
    private let compilation: SpainCompilationProtocol
    private let biometricsManager: LocalAuthenticationPermissionsManagerProtocol
    
    private let biometricPassword = "biometricIsActive"
    private var device: Device
    
    var state: AnyPublisher<SKCustomerDetailsState, Never>
    var clientStatus: SantanderKeyStatusRepresentable?
    var retry = true
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: SKCustomerDetailsDependenciesResolver) {
        self.dependencies = dependencies
        self.state = stateSubject.eraseToAnyPublisher()
        self.compilation = dependencies.external.resolve()
        self.biometricsManager = dependencies.external.resolve()
        self.device = IOSDevice()
    }
    
    func viewDidLoad() {
        if retry {
            retry.toggle()
            loadFaqs()
            subscribeStatus()
        }
    }
    
    func linkDevice() {
        guard let clientStatus = clientStatus?.clientStatus else { return }
        if clientStatus == "2" {
            suscribeTransparentRegister()
        } else {
            coordinator.goToOperative()
        }
    }
    
    func goToSearch() {
        coordinator.goToSearch()
    }
    
    func goToMenu() {
        coordinator.goToMenu()
    }
    
    func didChangeSwitch(_ isOn: Bool, type: BiometryTypeEntity) {
        if isOn {
            let touchIdData = TouchIdData(
                deviceMagicPhrase: biometricPassword,
                touchIDLoginEnabled: true,
                footprint: device.footprint)
            do {
                try KeychainWrapper().saveTouchIdData(touchIdData, compilation: compilation)
                showToast(success: true, isEnabling: true, type: type)
                biometricsManager.enableBiometric()
            } catch {
                showToast(success: false, isEnabling: true, type: type)
            }
        } else {
            do {
                try KeychainWrapper().deleteTouchIdData(compilation: compilation)
                showToast(success: true, isEnabling: false, type: type)
            } catch {
                showToast(success: false, isEnabling: false, type: type)
            }
        }
    }
}

private extension SKCustomerDetailsViewModel {
    var coordinator: SKCustomerDetailsCoordinator {
        dependencies.resolve()
    }
    var customerDetailsUseCase: SKCustomerDetailsUseCase {
        dependencies.resolve()
    }
    var getFaqsUseCase: GetOneFaqsUseCase {
        dependencies.resolve()
    }
    var transparentRegisterUseCase: SantanderKeyTransparentRegisterUseCase {
        dependencies.external.resolve()
    }
    
    func saveSankeyId(_ sanKeyId: String) {
        let sankeyIdQuery = KeychainQuery(service: compilation.service,
                                          account: compilation.keychainSantanderKey.sankeyId,
                                          accessGroup: compilation.sharedTokenAccessGroup,
                                          data: sanKeyId as NSCoding)
        do {
            try KeychainWrapper().save(query: sankeyIdQuery)
        } catch {
            return
        }
    }
    
    func showToast(success: Bool, isEnabling: Bool, type: BiometryTypeEntity) {
        var message: String?
        if isEnabling {
            switch type {
            case .faceId:
                message = success ? "faceId_alert_activeSuccess" : "faceId_alert_errorActivation"
            case .touchId:
                message = success ? "touchId_alert_activeSuccess" : "touchId_alert_errorActivation"
            default:
                break
            }
        } else {
            switch type {
            case .faceId:
                message = success ? "faceId_alert_desactiveFaceId" : "faceId_alert_errorActivation"
            case .touchId:
                message = success ? "touchId_alert_desactiveTouchId" : "touchId_alert_errorActivation"
            default:
                break
            }
        }
        stateSubject.send(.didReciveBiometryResult((message: message, success: success)))
    }
}

// MARK: - Subscriptions

private extension SKCustomerDetailsViewModel {
    func subscribeStatus() {
        statusPublisher()
            .subscribe(on: Schedulers.global)
            .receive(on: Schedulers.main)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    stateSubject.send(.didFailed)
                }
            } receiveValue: { [unowned self] result in
                self.clientStatus = result
                guard result.shouldCallDetail else {
                    let otherSKinDevice = result.otherSKinDevice?.lowercased() == "true"
                    guard let clientStatus = result.clientStatus else { return }
                    if clientStatus == SantanderKeyClientStatusState.notRegistered || (clientStatus == SantanderKeyClientStatusState.resgisteredSafeDevice && !otherSKinDevice) {
                        stateSubject.send(.didReceiveDetailResult(.clientNotRegistered1))
                    } else if clientStatus == SantanderKeyClientStatusState.resgisteredSafeDevice && otherSKinDevice {
                        stateSubject.send(.didReceiveDetailResult(.clientNotRegistered2))
                    }
                    return
                }
                subscribeDetail()
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeDetail() {
        detailPublisher()
            .subscribe(on: Schedulers.global)
            .receive(on: Schedulers.main)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    stateSubject.send(.didFailed)
                }
            } receiveValue: { [unowned self] result in
                let otherSKinDevice = clientStatus?.otherSKinDevice?.lowercased() == "true"
                guard let clientStatus = clientStatus?.clientStatus else { return }
                if clientStatus == SantanderKeyClientStatusState.rightRegisteredDevice {
                    stateSubject.send(.didReceiveDetailResult(.clientRegistered(deviceManu: result.deviceManu, creationDate: result.creationDate, deviceAlias: result.deviceAlias, deviceModel: result.deviceModel)))
                } else if clientStatus == SantanderKeyClientStatusState.anotherDeviceRegistered && !otherSKinDevice {
                    stateSubject.send(.didReceiveDetailResult(.registeredOtherDevice(deviceManu: result.deviceManu, creationDate: result.creationDate, deviceAlias: result.deviceAlias, deviceModel: result.deviceModel)))
                } else if clientStatus == SantanderKeyClientStatusState.anotherDeviceRegistered && otherSKinDevice {
                    stateSubject.send(.didReceiveDetailResult(.registeredOtherSesion(deviceManu: result.deviceManu, creationDate: result.creationDate, deviceAlias: result.deviceAlias, deviceModel: result.deviceModel)))
                }
            }
            .store(in: &anySubscriptions)
    }
    
    func loadFaqs() {
        getFaqsPublisher()
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .sink { [unowned self] faqRepresentables in
                stateSubject.send(.faqsLoaded(faqRepresentables))
            }.store(in: &anySubscriptions)
    }
    
    func suscribeTransparentRegister() {
        transparentRegisterPublisher()
            .subscribe(on: Schedulers.global)
            .receive(on: Schedulers.main)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    handle(error: error)
                }
                stateSubject.send(.showLoading(false))
            } receiveValue: { [unowned self] result in
                if let sankeyId = result.sankeyId {
                    saveSankeyId(sankeyId)
                }
                let hasBiometry = biometricsManager.isTouchIdEnabled
                if hasBiometry {
                    coordinator.goToSecondStep()
                } else {
                    coordinator.goToBiometricsStep()
                }
            }.store(in: &anySubscriptions)
    }

    func handle(error: Error) {
        guard let errorType = error as? SantanderKeyError else {
            HapticTrigger.operativeError()
            stateSubject.send(.showError(nil))
            return
        }
        switch errorType.getAction() {
        case .goToPG, .goToOperative:
            stateSubject.send(.showError(showBlockingError(errorDescription: errorType.getLocalizedDescription())))
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
                coordinator.dismiss()
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

// MARK: - Publishers

private extension SKCustomerDetailsViewModel {
    func statusPublisher() -> AnyPublisher<SantanderKeyStatusRepresentable, Error> {
        return customerDetailsUseCase.getStatus()
    }
    func detailPublisher() -> AnyPublisher<SantanderKeyDetailResultRepresentable, Error> {
        return customerDetailsUseCase.getDetail()
    }
    func getFaqsPublisher() -> AnyPublisher<OneFooterData, Never> {
        return getFaqsUseCase.fetchFaqs(type: .santanderKey)
    }
    func transparentRegisterPublisher() -> AnyPublisher<SantanderKeyAutomaticRegisterResultRepresentable, Error> {
        return transparentRegisterUseCase.completeTransparentRegister()
    }
}

// MARK: - SKCustomerDetailsDeviceInfoType

enum SKCustomerDetailsDeviceInfoType {
    case clientRegistered(deviceManu: String?, creationDate: String?, deviceAlias: String?, deviceModel: String?)
    case registeredOtherDevice(deviceManu: String?, creationDate: String?, deviceAlias: String?, deviceModel: String?)
    case registeredOtherSesion(deviceManu: String?, creationDate: String?, deviceAlias: String?, deviceModel: String?)
    case clientNotRegistered1
    case clientNotRegistered2
    case error
    
    var hidesContainer: Bool {
        switch self {
        case .error: return true
        default: return false
        }
    }
    
    var hidesLinkView: Bool {
        switch self {
        case .clientRegistered, .error: return true
        default: return false
        }
    }
    
    var hidesInfoView: Bool {
        switch self {
        case .clientNotRegistered1, .clientNotRegistered2: return true
        default: return false
        }
    }
    
    var accessInfoImage: String {
       hidesLinkView ? "oneIcnDoubleTick" : "oneIcnAlertBell"
    }
    
    var accessInfoTitleKey: String? {
        switch self {
        case .clientRegistered:
            return "santanderKey_label_infoAccess"
        case .registeredOtherDevice:
            return "santanderKey_label_accessingAnotherDevice"
        case .registeredOtherSesion:
            return "santanderKey_label_accessingAnotherUser"
        case .clientNotRegistered1:
            return "santanderKey_label_withoutDeviceLinked"
        case .clientNotRegistered2:
            return "santanderKey_label_anotherDeviceRegistered"
        case .error:
            return nil
        }
    }
    
    var linkDeviceButtonTitle: String? {
        switch self {
        case .registeredOtherDevice, .clientNotRegistered1, .clientNotRegistered2:
            return "santanderKey_button_linkDevice"
        case .registeredOtherSesion:
            return "santanderKey_button_registerDevice"
        default:
            return nil
        }
    }
}
