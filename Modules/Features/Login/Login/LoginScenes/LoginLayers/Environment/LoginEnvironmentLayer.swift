//
//  LoginEnvironmentLayer.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/26/20.
//

import Foundation
import CoreFoundationLib

protocol LoginEnvironmentLayerDelegate: class {
    func didLoadEnvironment(_ environment: EnvironmentEntity, publicFilesEnvironment: PublicFilesEnvironmentEntity)
}

final class LoginEnvironmentLayer {
    private let dependenciesResolver: DependenciesResolver
    private weak var delegate: LoginEnvironmentLayerDelegate?
    
    private var getBSANCurrentEnvironmentUseCase: GetBSANCurrentEnvironmentUseCase {
        self.dependenciesResolver.resolve(for: GetBSANCurrentEnvironmentUseCase.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func setDelegate(_ delegate: LoginEnvironmentLayerDelegate) {
        self.delegate = delegate
    }
    
    func getCurrentEnvironments() {
        MainThreadUseCaseWrapper(
            with: self.getBSANCurrentEnvironmentUseCase,
            onSuccess: { [weak self] result in
                   self?.delegate?.didLoadEnvironment(
                    result.bsanEnvironment,
                    publicFilesEnvironment: result.publicFilesEnvironment
                )
        })
    }
}
