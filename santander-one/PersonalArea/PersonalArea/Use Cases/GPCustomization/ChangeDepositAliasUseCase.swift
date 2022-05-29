//
//  ChangeDepositAliasUseCase.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 12/02/2021.
//

import CoreFoundationLib
import SANLegacyLibrary

protocol ChangeDepositAliasUseCaseProtocol: UseCase<ChangeDepositAliasUseCaseInput, Void, StringErrorOutput> { }

final class ChangeDepositAliasUseCase: UseCase<ChangeDepositAliasUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ChangeDepositAliasUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let alias = requestValues.alias, !alias.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput("productsOrder_alert_alias"))
        }
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let dto = requestValues.deposit.dto
        let response = try provider.getBsanDepositsManager().changeDepositAlias(dto, newAlias: alias)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok()
    }
}

extension ChangeDepositAliasUseCase: ChangeDepositAliasUseCaseProtocol {}

struct ChangeDepositAliasUseCaseInput {
    let deposit: DepositEntity
    let alias: String?
}
