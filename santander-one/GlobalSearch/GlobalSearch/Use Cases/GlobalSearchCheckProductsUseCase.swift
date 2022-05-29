//
//  GlobalSearchCheckProductsUseCase.swift
//  GlobalSearch
//
//  Created by Luis Escámez Sánchez on 04/03/2020.
//

import CoreFoundationLib

class GlobalSearchCheckProductsUseCase: UseCase<GlobalSearchCheckProductsUseCaseInput, GlobalSearchCheckProductsUseCaseOkOutput, StringErrorOutput> {
    
    override func executeUseCase(requestValues: GlobalSearchCheckProductsUseCaseInput) throws -> UseCaseResponse<GlobalSearchCheckProductsUseCaseOkOutput, StringErrorOutput> {
        
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = requestValues.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        
        let userCards = globalPosition.cards
        let userAccounts = globalPosition.accounts
        
        return .ok(GlobalSearchCheckProductsUseCaseOkOutput(userAccounts: userAccounts, userCards: userCards))
    }
}

struct GlobalSearchCheckProductsUseCaseInput {
    let dependenciesResolver: DependenciesResolver
}

struct GlobalSearchCheckProductsUseCaseOkOutput {
    let userAccounts: GlobalPositionProductList<AccountEntity>
    let userCards: GlobalPositionProductList<CardEntity>
}
