//
//  ChangeLoansAliasUseCase.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 15/02/2021.
//

import CoreFoundationLib
import SANLegacyLibrary

protocol ChangeLoansAliasUseCaseProtocol: UseCase<ChangeLoansAliasUseCaseInput, Void, StringErrorOutput> { }

final class ChangeLoansAliasUseCase: UseCase<ChangeLoansAliasUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ChangeLoansAliasUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let alias = requestValues.alias, !alias.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput("productsOrder_alert_alias"))
        }
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let dto = requestValues.loan.dto
        let response = try provider.getBsanLoansManager().changeLoanAlias(dto, newAlias: alias)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok()
    }
}

extension ChangeLoansAliasUseCase: ChangeLoansAliasUseCaseProtocol {}

struct ChangeLoansAliasUseCaseInput {
    let loan: LoanEntity
    let alias: String?
}
