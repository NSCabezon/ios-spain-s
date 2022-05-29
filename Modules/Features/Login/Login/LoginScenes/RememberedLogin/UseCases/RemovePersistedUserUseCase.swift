//
//  RemovePersistedUserUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/10/20.
//

import Foundation
import CoreFoundationLib
import SANLibraryV3

class RemovePersistedUserUseCase: UseCase<Void, Void, RemovePersistedUserUseCaseErrorOutput> {
    private let appRepository: AppRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appRepository = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, RemovePersistedUserUseCaseErrorOutput> {
        let persistedUserResponse = appRepository.getPersistedUser()
        if persistedUserResponse.isSuccess() {
            let user = try persistedUserResponse.getResponseData()
            if let userId: String = user?.userId {
                let userPrefDTOEntity = appRepository.getUserPreferences(userId: userId)
                userPrefDTOEntity.pgUserPrefDTO.onboardingFinished = false
                userPrefDTOEntity.pgUserPrefDTO.otpPushBetaFinished = false
                userPrefDTOEntity.pgUserPrefDTO.onboardingCancelled = false
                _ = appRepository.setUserPreferences(userPref: userPrefDTOEntity)
            }
        }
        let repositoryResponse = appRepository.removePersistedUser()
        if repositoryResponse.isSuccess() {
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(RemovePersistedUserUseCaseErrorOutput(try repositoryResponse.getErrorMessage()))
    }
}

class RemovePersistedUserUseCaseErrorOutput: StringErrorOutput { }
