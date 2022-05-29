//
//  QuickBalanceConfigurable.swift
//  PersonalArea
//
//  Created by Rubén Márquez Fernández on 19/4/21.
//

import CoreFoundationLib
import SANLegacyLibrary
import PersonalArea

protocol QuickBalanceConfiguratorDelegate: class {
    func quickBalanceEnabled()
    func enableQuickBalanceError()
    func quickBalanceDisabled()
    func disableQuickBalanceError()
}

public final class QuickBalanceConfigurator {
    
    // MARK: - Properties
    
    private let dependenciesResolver: DependenciesResolver
    private var usecaseHandler: UseCaseHandler {
        dependenciesResolver.resolve()
    }
    private weak var delegate: QuickBalanceConfiguratorDelegate?
    private var localAuthenticationPermissionsManager: LocalAuthenticationPermissionsManagerProtocol {
        dependenciesResolver.resolve()
    }
    private var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        self.dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }

    // MARK: - Initializer
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    init(dependenciesResolver: DependenciesResolver, delegate: QuickBalanceConfiguratorDelegate?) {
        self.dependenciesResolver = dependenciesResolver
        self.delegate = delegate
    }

    // MARK: - Public methods
    
    func enableQuickBalance() {
        Scenario(useCase: ActivateQuickBalanceAccessUseCase(dependenciesResolver: self.dependenciesResolver))
            .execute(on: self.usecaseHandler)
            .onSuccess { [weak self] _ in
                self?.delegate?.quickBalanceEnabled()
            }
            .onError({ [weak self] _ in
                self?.delegate?.enableQuickBalanceError()
            })
    }
    
    func disableQuickBalance() {
        Scenario(useCase: DeleteQuickBalanceAccessUseCase(dependenciesResolver: dependenciesResolver))
            .execute(on: self.usecaseHandler)
            .onSuccess { [weak self] _ in
                self?.delegate?.quickBalanceDisabled()
            }
            .onError({ [weak self] _ in
                self?.delegate?.disableQuickBalanceError()
            })

    }
    
    public func isQuickBalanceEnabled(_ completion: @escaping (Bool) -> Void) {
        Scenario(useCase: GetQuickBalanceAccessUseCase(dependenciesResolver: self.dependenciesResolver))
            .execute(on: self.usecaseHandler)
            .onSuccess { (output) in
                completion(output.isKeychainQuickBalanceEnabled)
            }
            .onError { _ in
                completion(false)
            }
    }
}
