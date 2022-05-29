//
//  SetFavoriteContactsUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 12/08/2020.
//

import CoreFoundationLib

public final class SetFavoriteContactsUseCase: UseCase<SetFavoriteContactsUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: SetFavoriteContactsUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoy: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let appRepository: AppRepositoryProtocol = dependenciesResolver.resolve()
        let userPref = appRepository.getUserPreferences(userId: globalPosition.userId ?? "")
        userPref.pgUserPrefDTO.favoriteContacts = requestValues.favoriteContacts
        appRepositoy.setUserPreferences(userPref: userPref)
        return .ok()
    }
}

public struct SetFavoriteContactsUseCaseInput {
    public let favoriteContacts: [String]
    
    public init(favoriteContacts: [String]) {
        self.favoriteContacts = favoriteContacts
    }
}
