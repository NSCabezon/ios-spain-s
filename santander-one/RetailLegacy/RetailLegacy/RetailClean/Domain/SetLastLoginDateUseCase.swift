//
//  SetLastLoginDateUseCase.swift
//  RetailClean
//
//  Created by Laura González on 30/06/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class SetLastLoginDateUseCase: UseCase<SetLastLoginDateUseCaseInput, Void, StringErrorOutput> {
    let appRepository: AppRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appRepository = dependenciesResolver.resolve()
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
