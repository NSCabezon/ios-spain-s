import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class UpdatePGUserPrefUseCase: UseCase<UpdatePGUserPrefUseCaseInput, Void, StringErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: UpdatePGUserPrefUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let userPrefResponse = appRepository.getUserPrefDTO(userId: requestValues.userPref.userPrefDTO.userId)
        guard let userPrefDTO = try userPrefResponse.getResponseData() else { return .error(StringErrorOutput(nil)) }
        userPrefDTO.pgUserPrefDTO = requestValues.userPref.userPrefDTO.pgUserPrefDTO
        let response = appRepository.setUserPrefDTO(userPrefDTO: userPrefDTO)
        if response.isSuccess() {
            return .ok()
        }
        return .error(StringErrorOutput(try response.getErrorMessage()))
    }
}

struct UpdatePGUserPrefUseCaseInput {
    let userPref: UserPref
}
