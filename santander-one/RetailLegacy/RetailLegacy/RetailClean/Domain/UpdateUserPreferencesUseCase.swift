//
//  UpdateUserPreferencesUseCase.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 25/09/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib

final class UpdateUserPreferencesUseCase: UseCase<UpdateUserPreferencesUseCaseInput, Void, StringErrorOutput> {    
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: UpdateUserPreferencesUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        appRepositoryProtocol.setUserPreferences(userPref: requestValues.userPref.userPrefDTOEntity)
        return UseCaseResponse.ok()
    }
}

struct UpdateUserPreferencesUseCaseInput {
    let userPref: UserPrefEntity
}
