//
//  GetUserPreferencesUseCase.swift
//  Menu
//
//  Created by David Gálvez Alonso on 27/03/2020.
//

import CoreFoundationLib

final class GetUserPreferencesUseCase: UseCase<Void, GetUserPreferencesUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetUserPreferencesUseCaseOkOutput, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let globalPosition: GlobalPositionRepresentable = self.dependenciesResolver.resolve()

        let userPrefDTO = appRepositoryProtocol.getUserPreferences(userId: globalPosition.userId ?? "")
        return UseCaseResponse.ok(GetUserPreferencesUseCaseOkOutput(userPref: UserPrefEntity.from(dto: userPrefDTO)))
    }
}

struct GetUserPreferencesUseCaseOkOutput {
    let userPref: UserPrefEntity
}
