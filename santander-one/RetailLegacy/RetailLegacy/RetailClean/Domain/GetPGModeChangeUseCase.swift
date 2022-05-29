import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class GetPGModeChangeUseCase: UseCase<GetPGModeChangeUseCaseInput, GetPGModeChangeUseCaseOkOutput, GetPGModeChangeUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: GetPGModeChangeUseCaseInput) throws -> UseCaseResponse<GetPGModeChangeUseCaseOkOutput, GetPGModeChangeUseCaseErrorOutput> {
        _ = appRepository.setUserPrefPb(isPB: requestValues.newPbPref, userId: requestValues.userId)
        return UseCaseResponse.ok(GetPGModeChangeUseCaseOkOutput())
    }
}

struct GetPGModeChangeUseCaseInput {
    let newPbPref: Bool
    let userId: String

    init(newPbPref: Bool, userId: String) {
        self.newPbPref = newPbPref
        self.userId = userId
    }
}

struct GetPGModeChangeUseCaseOkOutput {
}

class GetPGModeChangeUseCaseErrorOutput: StringErrorOutput {
}
