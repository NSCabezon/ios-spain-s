//
//  GetAccountUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 2/20/20.
//

import Foundation
import SANLegacyLibrary

public class GetAccountUseCase: UseCase<Void, GetAccountUseCaseOutput, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAccountUseCaseOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
            dependencies.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let accounts = globalPosition.accounts.visibles()
        let response = GetAccountUseCaseOutput(accounts: accounts)
        return .ok(response)
    }
}

public struct GetAccountUseCaseOutput {
    public let accounts: [AccountEntity]
    public init(accounts: [AccountEntity]) {
        self.accounts = accounts
    }
}
