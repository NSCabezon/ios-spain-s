//

import CoreFoundationLib
import SANLegacyLibrary

class GetCoachmarkStatusUseCase: UseCase<GetCoachmarkStatusUseCaseInput, GetCoachmarkStatusOkOutput, StringErrorOutput> {
    
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appRepository: AppRepository, bsanManagersProvider: BSANManagersProvider) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override public func executeUseCase(requestValues: GetCoachmarkStatusUseCaseInput) throws -> UseCaseResponse<GetCoachmarkStatusOkOutput, StringErrorOutput> {
        
        let gPositionDTO = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition())
        let user = UserDO(dto: gPositionDTO?.userDataDTO)
        guard let userId = user.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let status = try appRepository.isCoachmarkShown(coachmarkId: requestValues.coachmarkId, userId: userId).getResponseData()
        return UseCaseResponse.ok(GetCoachmarkStatusOkOutput(status: status ?? false))
    }
}

struct GetCoachmarkStatusUseCaseInput {
    let coachmarkId: CoachmarkIdentifier
}

struct GetCoachmarkStatusOkOutput {
    let status: Bool
}
