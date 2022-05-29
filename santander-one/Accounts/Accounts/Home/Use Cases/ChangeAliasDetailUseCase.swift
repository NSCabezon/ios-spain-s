//
//  ChangeAliasDetailUseCase.swift
//  Account
//
//  Created by crodrigueza on 13/4/21.
//

import SANLegacyLibrary
import CoreFoundationLib

protocol ChangeAliasDetailUseCaseProtocol: UseCase<ChangeAliasDetailUseCaseInput, Void, StringErrorOutput> {}

final class ChangeAliasDetailUseCase: UseCase<ChangeAliasDetailUseCaseInput, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ChangeAliasDetailUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let alias = requestValues.alias, !alias.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput("productsOrder_alert_alias"))
        }
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let globalPositionRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let globalPositionResponse = try provider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true,
                                                                                    isPB: globalPositionRepresentable.isPb ?? false)
        guard
            let accounts = try globalPositionResponse.getResponseData()?.accounts,
            let accountDTO: AccountDTO = accounts.first(where: { $0.iban == requestValues.account.dto.iban })
        else {
            return UseCaseResponse.error(StringErrorOutput(try globalPositionResponse.getErrorMessage() ?? ""))
        }
        let response = try provider.getBsanAccountsManager().changeAccountAlias(accountDTO: accountDTO,
                                                                                newAlias: alias)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok()
    }
}

struct ChangeAliasDetailUseCaseInput {
    let account: AccountEntity
    let alias: String?
}

extension ChangeAliasDetailUseCase: ChangeAliasDetailUseCaseProtocol {}
