//
//  SetupPullOffersUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/24/20.
//

import Foundation
import SANLegacyLibrary

public class SetupPullOffersUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let pullOffersRepository: PullOffersRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.pullOffersRepository = dependenciesResolver.resolve(for: PullOffersRepositoryProtocol.self)
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        _ = pullOffersRepository.setup()
        return .ok()
    }
}
