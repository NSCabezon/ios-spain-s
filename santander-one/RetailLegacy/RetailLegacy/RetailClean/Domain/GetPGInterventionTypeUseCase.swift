import CoreFoundationLib
import SANLegacyLibrary

class GetPGInterventionTypeUseCase: UseCase<Void, GetPGInterventionTypeUseCaseOkOutput, GetPGInterventionTypeUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPGInterventionTypeUseCaseOkOutput, GetPGInterventionTypeUseCaseErrorOutput> {
        let response = appRepository.getTypeDescs()
        let ownershipProfile = OwnershipProfile.from(list: try response.getResponseData())
        return UseCaseResponse.ok(GetPGInterventionTypeUseCaseOkOutput(ownershipProfile))
    }
}

struct GetPGInterventionTypeUseCaseOkOutput {
    
    let profile: OwnershipProfile
    
    init(_ profile: OwnershipProfile) {
        self.profile = profile
    }
}

class GetPGInterventionTypeUseCaseErrorOutput: StringErrorOutput {
    
}
