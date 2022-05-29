//
//  BiometryValidatorPresenter.swift
//  Pods
//
//  Created by Rubén Márquez Fernández on 20/5/21.
//

import CoreFoundationLib


protocol BiometryValidatorPresenterProtocol {
    var view: BiometryValidatorViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func dismiss()
    func moreInfo()
    func cancel()
    func confirm(status: BiometryValidatorStatus)
    func useSign()
}

final class BiometryValidatorPresenter {
    weak var view: BiometryValidatorViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var biometryData: TouchIdData?

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension BiometryValidatorPresenter {
    
    // MARK: - Attributes
    
    var coordinator: BiometryValidatorModuleCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: BiometryValidatorModuleCoordinatorProtocol.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var biometricsManager: LocalAuthenticationPermissionsManagerProtocol {
        self.dependenciesResolver.resolve(for: LocalAuthenticationPermissionsManagerProtocol.self)
    }
    
    var biometryValidatorAuthType: BiometryValidatorAuthType? {
        switch biometricsManager.biometryTypeAvailable {
        case .touchId, .error(.touchId, _):
            return .fingerPrint
        case .faceId, .error(.faceId, _):
            return .faceId
        default:
            return nil
        }
    }
    
    var authMessage: String {
        switch self.biometricsManager.biometryTypeAvailable {
        case .touchId:
            return "touchId_alert_fingerprintLogin"
        default:
            return ""
        }
    }
    
    var touchIdDataUseCase: GetTouchIdDataUseCase {
        return dependenciesResolver.resolve(for: GetTouchIdDataUseCase.self)
    }

    // MARK: - Methods

    func getTouchIdData() {
        Scenario(useCase: touchIdDataUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] response in
                self?.biometryData = response.touchIdData
            }
    }
    
    func evaluateBiometryAccess() {
        if let biometryValidatorAuthType = self.biometryValidatorAuthType {
            self.view?.update(biometryValidatorAuthType, status: .identifying)
            self.biometricsManager.evaluateBiometry(reason: localized(authMessage)) { [weak self] resultEntity in
                Async.main { [weak self] in
                    guard let self = self else { return }
                    switch resultEntity {
                    case .success:
                        self.onBiometrySuccess()
                    case .evaluationError:
                        self.onBiometryError()
                    }
                }
            }
        }
    }
    
    func onBiometrySuccess() {
        self.trackEvent(.biometricsOK, parameters: [:])
        if let biometryData = self.biometryData {
            self.coordinator.success(deviceToken: biometryData.deviceMagicPhrase, footprint: biometryData.footprint)
        } else {
            self.coordinator.cancel()
        }
    }
    
    func onBiometryError() {
        self.trackEvent(.biometricsKO, parameters: [:])
        if let biometryValidatorAuthType = self.biometryValidatorAuthType {
            self.view?.update(biometryValidatorAuthType, status: .error)
        }
    }
}

extension BiometryValidatorPresenter: BiometryValidatorPresenterProtocol {
    
    func viewDidLoad() {
        self.getTouchIdData()
        self.trackEvent(.startsBiometrics, parameters: [:])
    }

    func viewWillAppear() {
        guard let biometryValidatorAuthType = self.biometryValidatorAuthType else { return }
        self.view?.update(biometryValidatorAuthType, status: .confirm)
    }

    func dismiss() {
        self.coordinator.cancel()
    }
    
    func moreInfo() {
        self.trackEvent(.clickMoreInfo, parameters: [:])
        self.coordinator.moreInfo()
    }
    
    func cancel() {
        self.coordinator.cancel()
    }
    
    func confirm(status: BiometryValidatorStatus) {
        switch status {
        case .confirm:
            self.evaluateBiometryAccess()
        case .error, .identifying:
            self.coordinator.signProcess()
        }
    }
    
    func useSign() {
        self.coordinator.signProcess()
    }
}

extension BiometryValidatorPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BiometryValidatorPage {
        return BiometryValidatorPage(page: self.coordinator.getScreen())
    }
}
