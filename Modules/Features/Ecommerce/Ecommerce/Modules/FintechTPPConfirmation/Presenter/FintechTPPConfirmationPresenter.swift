//
//  FintechTPPConfirmationPresenter.swift
//  Ecommerce
//
//  Created by alvola on 15/04/2021.
//

import CoreFoundationLib

protocol FintechTPPConfirmationPresenterProtocol {
    var view: FintechTPPConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func dismiss()
    func confirm(withType type: EcommerceAuthType)
    func confirm(withAccessKey accessKey: String)
    func confirm(withDocumentType documentType: String, documentNumber: String, accessKey: String)
    func restorePassword()
}

final class FintechTPPConfirmationPresenter {
    
    private let dependenciesResolver: DependenciesResolver
    
    private var biometricsManager: LocalAuthenticationPermissionsManagerProtocol {
        self.dependenciesResolver.resolve(for: LocalAuthenticationPermissionsManagerProtocol.self)
    }
    
    weak var view: FintechTPPConfirmationViewProtocol?
    
    private var getRememberedUserNameUseCase: GetRememberedUserNameUseCase {
        return self.dependenciesResolver.resolve(for: GetRememberedUserNameUseCase.self)
    }
    
    private var getRecoverPasswordUrlUseCase: GetRecoverPasswordUrlUseCase {
        self.dependenciesResolver.resolve(for: GetRecoverPasswordUrlUseCase.self)
    }
            
    private var configuration: FintechTPPConfiguration {
        dependenciesResolver.resolve(for: FintechTPPConfiguration.self)
    }
    
    private var fintechConfirmAccessKeyUseCase: FintechConfirmAccessKeyUseCase {
        self.dependenciesResolver.resolve(for: FintechConfirmAccessKeyUseCase.self)
    }
    
    private var fintechConfirmFootprintUseCase: FintechConfirmFootprintUseCase {
        self.dependenciesResolver.resolve(for: FintechConfirmFootprintUseCase.self)
    }
    
    private var touchIdDataUseCase: GetTouchIdLoginDataUseCase {
        return dependenciesResolver.resolve(for: GetTouchIdLoginDataUseCase.self)
    }
    
    private var coordinator: FintechTPPConfirmationCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: FintechTPPConfirmationCoordinatorProtocol.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
   
    private var userName: String?
    private var userDocumentNumber: String?
    private var userDocumentType: String?
    private var biometryData: TouchIdData?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension FintechTPPConfirmationPresenter: FintechTPPConfirmationPresenterProtocol {
    
    func viewDidLoad() {
        view?.setViewState(.loading)
        Scenario(useCase: touchIdDataUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] response in
                self?.biometryData = response.touchIdData
            }.finally {
                Scenario(useCase: self.getRememberedUserNameUseCase)
                    .execute(on: self.useCaseHandler)
                    .onSuccess { output in
                        self.userName = output.userName?.camelCasedString
                        self.userDocumentNumber = output.login
                        self.userDocumentType = output.loginType
                    }
                    .finally {
                        self.view?.setViewState(.home(authType: self.ecommerceAuthType,
                                                      authStatus: .confirmed,
                                                      paymentStatus: nil,
                                                      userName: self.userName))
                    }
            }
        
    }
    
    func confirm(withType type: EcommerceAuthType) {
        switch type {
        case .faceId, .fingerPrint:
            evaluateBiometryAccess()
        case .code:
            self.view?.setViewState(userName != nil ? .identifyRemembered : .identifyUnremembered)
        }
    }
    
    func confirm(withAccessKey accessKey: String) {
        var fintechUserInfoAccessKey = FintechUserInfoAccessKey()
        fintechUserInfoAccessKey.documentType = userDocumentType ?? ""
        fintechUserInfoAccessKey.documentNumber = userDocumentNumber ?? ""
        fintechUserInfoAccessKey.magic = accessKey
        let input = FintechConfirmAccessKeyUseCaseInput(userAuthentication: configuration.userAuthentication,
                                                        userInfo: fintechUserInfoAccessKey)
        accessKeyConfirmation(input: input)
    }
    
    func confirm(withDocumentType documentType: String, documentNumber: String, accessKey: String) {
        var fintechUserInfoAccessKey = FintechUserInfoAccessKey()
        fintechUserInfoAccessKey.documentType = documentType
        fintechUserInfoAccessKey.documentNumber = documentNumber
        fintechUserInfoAccessKey.magic = accessKey
        let input = FintechConfirmAccessKeyUseCaseInput(userAuthentication: configuration.userAuthentication,
                                                        userInfo: fintechUserInfoAccessKey)
        accessKeyConfirmation(input: input)
    }
    
    func restorePassword() {
        goToRecoveryPassword()
    }
    
    func dismiss() {
        coordinator.dismiss()
    }
}

private extension FintechTPPConfirmationPresenter {
    
    var ecommerceAuthType: EcommerceAuthType {
        guard self.biometryData?.touchIDLoginEnabled == true else { return .code }
        switch biometricsManager.biometryTypeAvailable {
        case .error(biometry: .touchId, error: .unknown),
             .error(biometry: .faceId, error: .unknown),
             .error(biometry: .touchId, error: .biometryNotAvailable),
             .error(biometry: .faceId, error: .biometryNotAvailable):
            return .code
        case .touchId, .error(.touchId, _):
            return .fingerPrint
        case .faceId, .error(.faceId, _):
            return .faceId
        case .none, .error:
            return .code
        }
    }
    
    var ecommerceAuthMessage: String {
        switch biometricsManager.biometryTypeAvailable {
        case .touchId:
            return "touchId_alert_fingerprintLogin"
        default:
            return ""
        }
    }
    
    func accessKeyConfirmation(input: FintechConfirmAccessKeyUseCaseInput) {
        view?.setViewState(.home(authType: self.ecommerceAuthType,
                                    authStatus: .confirmed,
                                    paymentStatus: .identifying,
                                    userName: userName))
        Scenario(useCase: fintechConfirmAccessKeyUseCase, input: input)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] output in
                self?.onConfirmationSuccess(urlLocation: output.urlLocation)
            }.onError(onConfirmationError)
    }
    
    var fintechUserInfoFootprint: FintechUserInfoFootprint {
        var view = FintechUserInfoFootprint()
        view.documentType = userDocumentType ?? ""
        view.documentNumber = userDocumentNumber ?? ""
        view.deviceMagicPhrase = biometryData?.deviceMagicPhrase
        view.footprint = biometryData?.footprint
        return view
    }
    
    func footPrintConfirmation() {
        view?.setViewState(.home(authType: self.ecommerceAuthType,
                                    authStatus: .confirmed,
                                    paymentStatus: .identifying,
                                    userName: userName))
        
        let input = FintechConfirmaFootprintUseCaseInput(userAuthentication: configuration.userAuthentication,
                                                         userInfo: fintechUserInfoFootprint)
        Scenario(useCase: self.fintechConfirmFootprintUseCase, input: input)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] output in
                self?.onConfirmationSuccess(urlLocation: output.urlLocation)
            }.onError(onConfirmationError)
    }
    
    func goToRecoveryPassword() {
        Scenario(useCase: getRecoverPasswordUrlUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] in
                guard let urlForgotPassword = $0.recoverPasswordUrl else { return }
                self?.coordinator.openUrl(urlForgotPassword)
            }
    }
        
    func evaluateBiometryAccess() {
        biometricsManager.evaluateBiometry(reason: localized(ecommerceAuthMessage)) { [weak self] resultEntity in
            Async.main {
                guard let self = self else { return }
                switch resultEntity {
                case .success:
                    self.footPrintConfirmation()
                case .evaluationError:
                    self.view?.setViewState(.home(authType: self.ecommerceAuthType,
                                                  authStatus: .notConfirmed,
                                                  paymentStatus: nil,
                                                  userName: self.userName))
                }
            }
        }
    }
    
    func onConfirmationSuccess(urlLocation: String) {
        view?.setViewState(.success)
        Async.after(seconds: 3.0) {
            self.coordinator.openUrl(urlLocation)
            self.coordinator.dismiss()
        }
    }
    
    func onConfirmationError(_ error: UseCaseError<StringErrorOutput>) {
        view?.setViewState(.error(reason: error.getErrorDesc() ?? "ecommerce_label_noIdentification"))
    }
}
