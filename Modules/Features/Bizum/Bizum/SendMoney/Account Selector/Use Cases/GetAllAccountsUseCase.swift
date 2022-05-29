//
//  GetAllAccountsUseCase.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 26/1/21.
//

import Foundation
import SANLibraryV3
import CoreFoundationLib

final class GetAllAccountsUseCase: UseCase<Void, GetAllAccountsUseCaseOutput, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAllAccountsUseCaseOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
            dependencies.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let visibleAccounts = globalPosition.accountsVisiblesWithoutPiggy
        let allAccounts = globalPosition.allAccountsWithoutPiggy
        let notVisibleAccounts = allAccounts.filter({ !visibleAccounts.contains($0) })
        let response = GetAllAccountsUseCaseOutput(visibleAccounts: visibleAccounts, notVisibleAccounts: notVisibleAccounts)
        return .ok(response)
    }
}

struct GetAllAccountsUseCaseOutput {
    let visibleAccounts: [AccountEntity]
    let notVisibleAccounts: [AccountEntity]
}
