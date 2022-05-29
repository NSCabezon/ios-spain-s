//
//  EcommerceNumberPadPresenter.swift
//  Pods
//
//  Created by Francisco del Real Escudero on 3/3/21.
//  

import CoreFoundationLib

protocol EcommerceNumberPadPresenterProtocol {
    var view: EcommerceNumberPadViewProtocol? { get set }
    func viewDidLoad()
    func dismiss()
    func confirm(_ accessKey: String)
    func back()
    func showMoreInfo()
    func goToRecoveryPassword()
    var isBiometryEnabled: Bool { get }
}

final class EcommerceNumberPadPresenter {
    weak var view: EcommerceNumberPadViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var urlForgotPassword: String?

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension EcommerceNumberPadPresenter {
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var coordinatorDelegate: EcommerceMainModuleCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: EcommerceMainModuleCoordinatorDelegate.self)
    }
    
    var coordinator: EcommerceNumberPadCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: EcommerceNumberPadCoordinatorProtocol.self)
    }
    
    var homeCoordinator: EcommerceCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: EcommerceCoordinatorDelegate.self)
    }
    
    var biometricsManager: LocalAuthenticationPermissionsManagerProtocol {
        self.dependenciesResolver.resolve(for: LocalAuthenticationPermissionsManagerProtocol.self)
    }
    
    var getRecoverPasswordUrlUseCase: GetRecoverPasswordUrlUseCase {
        self.dependenciesResolver.resolve(for: GetRecoverPasswordUrlUseCase.self)
    }
}

extension EcommerceNumberPadPresenter: EcommerceNumberPadPresenterProtocol {
    func viewDidLoad() {
        Scenario(useCase: getRecoverPasswordUrlUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] in
                self?.urlForgotPassword = $0.recoverPasswordUrl
            }
    }
    
    func goToRecoveryPassword() {
        guard let urlForgotPassword = urlForgotPassword else {
            view?.showToast(description: "No hay URL configurada para este entorno")
            return
        }
        coordinatorDelegate.openUrl(urlForgotPassword)
    }
    
    func showMoreInfo() {
        self.homeCoordinator.moreInfo()
    }
    
    func back() {
        coordinator.back()
    }
    
    func confirm(_ accessKey: String) {
        self.back()
        self.homeCoordinator.confirmWithAccessKey(accessKey)
    }
    
    func dismiss() {
        coordinator.dismiss()
    }
    
    var isBiometryEnabled: Bool {
        return biometricsManager.isTouchIdEnabled
    }
}
