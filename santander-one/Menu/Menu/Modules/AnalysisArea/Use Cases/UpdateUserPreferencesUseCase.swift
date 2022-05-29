//
//  UpdateUserPreferencesUseCase.swift
//  Menu
//
//  Created by David Gálvez Alonso on 31/03/2020.
//

import CoreFoundationLib

final class UpdateUserPreferencesUseCase: UseCase<UpdateUserPreferencesUseCaseInput, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: UpdateUserPreferencesUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        _ = appRepositoryProtocol.setUserPreferences(userPref: requestValues.userPref.userPrefDTOEntity)
        return UseCaseResponse.ok()
    }
}

struct UpdateUserPreferencesUseCaseInput {
    let userPref: UserPrefEntity
}
