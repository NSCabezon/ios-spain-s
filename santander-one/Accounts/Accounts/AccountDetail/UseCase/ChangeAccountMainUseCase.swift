//
//  ChangeAccountMainUseCase.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 23/02/2021.
//

import Foundation
import SANLegacyLibrary
import CoreFoundationLib

typealias ChangeAccountMainUseCaseAlias = UseCase<ChangeAccountMainUseCaseInput, Void, StringErrorOutput>

final class ChangeAccountMainUseCase: ChangeAccountMainUseCaseAlias {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ChangeAccountMainUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let main = requestValues.main, main == true else {
            return UseCaseResponse.error(StringErrorOutput(""))
        }
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let dto = requestValues.account.dto
        let response = try provider.getBsanAccountsManager().changeMainAccount(accountDTO: dto, newMain: main)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        self.removeAccountPreferences()
        return UseCaseResponse.ok()
    }
    
    fileprivate func removeAccountPreferences() {
        let globalPosition: GlobalPositionRepresentable = self.dependenciesResolver.resolve()
        let appRepositoryProtocol = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        guard let userId: String = globalPosition.userId else {
            return
        }
        let userPref = UserPrefEntity.from(dto: appRepositoryProtocol.getUserPreferences(userId: userId))
        guard var box = userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.account] else {
            return
        }
        if !box.products.isEmpty {
            box.removeAllItems()
            userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.account] = box
            appRepositoryProtocol.setUserPreferences(userPref: userPref.userPrefDTOEntity)
        }
    }
}

struct ChangeAccountMainUseCaseInput {
    let account: AccountEntity
    let main: Bool?
}
