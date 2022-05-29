//

import CoreFoundationLib
import SANLegacyLibrary

class SetCoachmarkSeenUseCase: UseCase<SetCoachmarkSeenInput, Void, StringErrorOutput> {
    
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider

    init(appRepository: AppRepository, bsanManagersProvider: BSANManagersProvider) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override public func executeUseCase(requestValues: SetCoachmarkSeenInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        
        let gPositionDTO = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition())
        let user = UserDO(dto: gPositionDTO?.userDataDTO)
        guard let userId = user.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        if requestValues.coachmarkIds.count > 0 {
            _ = appRepository.setCoachmarkShown(coachmarkId: requestValues.coachmarkIds, userId: userId)
        }
        
        return UseCaseResponse.ok()
    }
}

struct SetCoachmarkSeenInput {
    let coachmarkIds: [CoachmarkIdentifier]
}
