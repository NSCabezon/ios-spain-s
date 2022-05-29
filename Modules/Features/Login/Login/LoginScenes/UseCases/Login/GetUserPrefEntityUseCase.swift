//
//  GetUserPrefEntityUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/23/20.
//

import Foundation
import CoreFoundationLib
import SANLibraryV3

final class GetUserPrefEntityUseCase: UseCase<Void, GetUserPrefEntityUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appRepository: AppRepositoryProtocol
    private let globalPositionWithUserPref: GlobalPositionWithUserPrefsRepresentable
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.globalPositionWithUserPref = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetUserPrefEntityUseCaseOkOutput, StringErrorOutput> {
        let persistedUserResponse = self.appRepository.getPersistedUser()
        var userId: String = ""
        
        if persistedUserResponse.isSuccess(), let persistedUserDTO = try persistedUserResponse.getResponseData() {
            userId = persistedUserDTO.userId ?? ""
        } else {
            let userId = self.globalPositionWithUserPref.userId
        }
        let userPrefEntity = appRepository.getUserPreferences(userId: userId)
        return UseCaseResponse.ok(GetUserPrefEntityUseCaseOkOutput(userPref: UserPrefEntity.from(dto: userPrefEntity)))
    }
}

struct GetUserPrefEntityUseCaseOkOutput {
    var userPref: UserPrefEntity?
}
