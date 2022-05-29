//
//  BiometryConfigurator.swift
//  QuickBalance
//
//  Created by Rubén Márquez Fernández on 22/4/21.
//

import CoreFoundationLib
import SANLegacyLibrary

public protocol BiometryConfiguratorDelegate: AnyObject {
    func errorInFootprintRegistration()
    func biometryEnabled()
    func biometryDisabled()
}

public final class BiometryConfigurator {
    
    // MARK: - Properties
    
    private let dependenciesResolver: DependenciesResolver
    private weak var delegate: BiometryConfiguratorDelegate?
    private var usecaseHandler: UseCaseHandler {
        dependenciesResolver.resolve()
    }
    private var localAuthenticationPermissionsManager: LocalAuthenticationPermissionsManagerProtocol {
        dependenciesResolver.resolve()
    }
    private var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        self.dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    private var biometryType: BiometryTypeEntity {
        return self.localAuthenticationPermissionsManager.biometryTypeAvailable
    }
    
    // MARK: - Initializer
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public init(dependenciesResolver: DependenciesResolver, delegate: BiometryConfiguratorDelegate?) {
        self.dependenciesResolver = dependenciesResolver
        self.delegate = delegate
    }
    
    // MARK: - Public methods
    
    public func enableBiometry() {
        personalAreaCoordinator?.performFootprintRegistration(completion: { [weak self] (response) in
            if response {
                self?.localAuthenticationPermissionsManager.enableBiometric()
                self?.delegate?.biometryEnabled()
            } else {
                self?.delegate?.errorInFootprintRegistration()
            }
        })
    }
    
    public func disableBiometry() {
        self.personalAreaCoordinator?.setTouchIdLoginData(deviceMagicPhrase: nil, touchIDLoginEnabled: nil, completion: { [weak self] _ in
            self?.delegate?.biometryDisabled()
        })
    }
    
    public func isBiometryAvailable() -> Bool {
        return [.faceId, .touchId].contains(self.localAuthenticationPermissionsManager.biometryTypeAvailable)
    }
    
    public func isBiometryEnabled() -> Bool {
        return self.localAuthenticationPermissionsManager.isTouchIdEnabled
    }
    
    public func getBiometryType() -> BiometryTypeEntity {
        self.biometryType
    }
    
    public func getBiometryText() -> String {
        switch self.biometryType {
        case .touchId: return "Touch ID"
        case .faceId: return "Face ID"
        default: return ""
        }
    }
}
