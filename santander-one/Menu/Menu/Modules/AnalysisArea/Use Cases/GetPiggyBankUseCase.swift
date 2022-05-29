//
//  GetPiggyBankUseCase.swift
//  Menu
//
//  Created by Ignacio González Miró on 05/06/2020.
//

import CoreFoundationLib

final class GetPiggyBankUseCase: UseCase<Void, GetPiggyBankUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPiggyBankUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let piggyBankAccount = globalPosition.accounts.filter({
            $0.isPiggyBankAccount
        })
        return UseCaseResponse.ok(GetPiggyBankUseCaseOkOutput(account: piggyBankAccount.first))
    }
}

struct GetPiggyBankUseCaseOkOutput {
    let account: AccountEntity?
}
