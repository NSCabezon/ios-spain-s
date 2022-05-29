//
//  GetMovementsAtmUseCase.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 08/09/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class GetMovementsAtmUseCase: UseCase<GetMovementsAtmUseCaseInput, GetMovementsAtmUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetMovementsAtmUseCaseInput) throws -> UseCaseResponse<GetMovementsAtmUseCaseOkOutput, StringErrorOutput> {
      
        let startDate = Date().startOfDay().getUtcDate()?.addDay(days: -60) ?? Date()
        let endDate = Date().getUtcDate() ?? Date()
        let params = AccountMovementListParams(
            fromDate: startDate,
            toDate: endDate,
            concept: "reintegro,reint,deposito"
        )

        guard let response = try? self.provider.getBsanAccountsManager().getAccountMovements(params: params, account: requestValues.account.dto.oldContract?.contratoPKWithNoSpaces ?? "") else {
            return .error(StringErrorOutput(nil))
        }
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let output = GetMovementsAtmUseCaseOkOutput(movements: data.movements)
        return .ok(output)
    }
}

struct GetMovementsAtmUseCaseInput {
    let account: AccountEntity
}

struct GetMovementsAtmUseCaseOkOutput {
    let movements: [AccountMovementRepresentable]
}
