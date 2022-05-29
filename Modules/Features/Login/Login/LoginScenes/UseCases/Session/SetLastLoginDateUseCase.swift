//
//  SetLastLoginDateUseCase.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/20/20.
//
import Foundation
import SANLibraryV3
import CoreFoundationLib

final class SetLastLoginDateUseCase: UseCase<SetLastLoginDateUseCaseInput, Void, StringErrorOutput> {
    private let appRepository: AppRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appRepository = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: SetLastLoginDateUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let persistedUserResponse = appRepository.getPersistedUser()
        guard
            persistedUserResponse.isSuccess(),
            let user = try persistedUserResponse.getResponseData()
            else { return .error(StringErrorOutput(nil)) }
        let userId: String? = user.userId
        let userPrefDTO = appRepository.getUserPreferences(userId: userId ?? "")
        userPrefDTO.pgUserPrefDTO.lastLogin?.previousLoginDate = userPrefDTO.pgUserPrefDTO.lastLogin?.currentLoginDate
        userPrefDTO.pgUserPrefDTO.lastLogin?.currentLoginDate = requestValues.date
        userPrefDTO.pgUserPrefDTO.whatsNewBigBubbleVisibled = false
        appRepository.setUserPreferences(userPref: userPrefDTO)
        return .ok()
    }
}

struct SetLastLoginDateUseCaseInput {
    let date: Date
}
