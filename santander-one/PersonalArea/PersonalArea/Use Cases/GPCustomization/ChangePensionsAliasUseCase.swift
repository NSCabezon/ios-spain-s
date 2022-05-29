//
//  ChangePensionsAliasUseCase.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 16/02/2021.
//

import CoreFoundationLib
import SANLegacyLibrary

protocol ChangePensionsAliasUseCaseProtocol: UseCase<ChangePensionsAliasUseCaseInput, Void, StringErrorOutput> { }

final class ChangePensionsAliasUseCase: UseCase<ChangePensionsAliasUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ChangePensionsAliasUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let alias = requestValues.alias, !alias.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput("productsOrder_alert_alias"))
        }
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let dto = requestValues.pension.dto
        let response = try provider.getBsanPensionsManager().changePensionAlias(dto, newAlias: alias)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok()
    }
}

extension ChangePensionsAliasUseCase: ChangePensionsAliasUseCaseProtocol {}

struct ChangePensionsAliasUseCaseInput {
    let pension: PensionEntity
    let alias: String?
}
