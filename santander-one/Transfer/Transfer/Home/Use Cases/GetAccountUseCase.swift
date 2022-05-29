//
//  GetTransfersHomeUseCase.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/20/19.
//

import Foundation
import SANLegacyLibrary
import CoreFoundationLib

public final class GetTransfersHomeUseCase: UseCase<Void, GetTransfersHomeUseCaseOutput, StringErrorOutput> {
    let dependencies: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetTransfersHomeUseCaseOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
        dependencies.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let transfersHomeConfiguration = dependencies.resolve(for: TransfersHomeConfiguration.self)
        let accounts = globalPosition.accounts.visibles()
        let response = GetTransfersHomeUseCaseOutput(accounts: accounts, configuration: transfersHomeConfiguration)
        return .ok(response)
    }
}

public struct GetTransfersHomeUseCaseOutput {
    public let accounts: [AccountEntity]
    let configuration: TransfersHomeConfiguration
}
