import CoreFoundationLib
import SANLegacyLibrary

class SetPGInterventionTypeUseCase: UseCase<SetPGInterventionTypeUseCaseInput, Void, SetPGInterventionTypeUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: SetPGInterventionTypeUseCaseInput) throws -> UseCaseResponse<Void, SetPGInterventionTypeUseCaseErrorOutput> {
        _ = appRepository.setTypeDescs(typeDescs: requestValues.profile.ownershipTypeDescs)
        return UseCaseResponse.ok()
    }
}

struct SetPGInterventionTypeUseCaseInput {
    
    let profile: OwnershipProfile
    
    init(profile: OwnershipProfile) {
        self.profile = profile
    }
}

class SetPGInterventionTypeUseCaseErrorOutput: StringErrorOutput {
    
}
