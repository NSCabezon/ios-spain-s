import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class RemovePersistedUserUseCase: UseCase<Void, Void, RemovePersistedUserUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
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

class RemovePersistedUserUseCaseErrorOutput: StringErrorOutput {
}
