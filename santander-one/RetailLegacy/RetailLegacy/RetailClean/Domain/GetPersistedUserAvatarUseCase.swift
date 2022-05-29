import Foundation

import CoreFoundationLib
import SANLegacyLibrary

class GetPersistedUserAvatarUseCase: UseCase<Void, GetPersistedUserAvatarUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPersistedUserAvatarUseCaseOkOutput, StringErrorOutput> {
        let gPositionDTO = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition())
        let user = UserDO(dto: gPositionDTO?.userDataDTO)
        guard let userId = user.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let response = appRepository.getPersistedUserAvatar(userId: userId)
        let image = try response.getResponseData()
        return UseCaseResponse.ok(GetPersistedUserAvatarUseCaseOkOutput(image: image))
    }
}

struct GetPersistedUserAvatarUseCaseOkOutput {
    let image: Data?
}
