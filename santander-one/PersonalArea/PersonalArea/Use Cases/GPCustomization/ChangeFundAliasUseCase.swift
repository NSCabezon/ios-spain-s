//
//  ChangeFundAliasUseCase.swift
//  PersonalArea
//
//  Created by Alvaro Royo on 15/1/22.
//

import SANLegacyLibrary
import CoreFoundationLib

class ChangeFundAliasUseCase: UseCase<ChangeFundAliasUseCaseInput, Void, StringErrorOutput> {
    override func executeUseCase(requestValues: ChangeFundAliasUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let alias = requestValues.alias, !alias.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput("productsOrder_alert_alias"))
        }
        let provider = requestValues.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let dto = requestValues.fund.dto
        let response = try provider.getBsanFundsManager().changeFundAlias(dto, newAlias: alias)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok()
    }
}

struct ChangeFundAliasUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let fund: FundEntity
    let alias: String?
}
