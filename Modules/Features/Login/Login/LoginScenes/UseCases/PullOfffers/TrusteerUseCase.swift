//
//  TrusteerUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/25/20.
//

import Foundation
import CoreFoundationLib

class TrusteerUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let trusteerRepository: TrusteerRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.trusteerRepository = dependenciesResolver.resolve(for: TrusteerRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let enableTrusteer = appConfigRepository.getBool(LoginConstants.enabledTrusteer)
        if enableTrusteer == true {
            self.trusteerRepository.initialize()
        }
        return UseCaseResponse.ok()
    }
}
