import CoreFoundationLib
import SANLegacyLibrary
import Foundation

class SetPersistedUserAvatarUseCase: UseCase<SetPersistedUserAvatarUseCaseInput, Void, StringErrorOutput> {
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override public func executeUseCase(requestValues: SetPersistedUserAvatarUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let gPositionDTO = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition())
        let user = UserDO(dto: gPositionDTO?.userDataDTO)
        guard let userId = user.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        _ = appRepository.setPersistedUserAvatar(userId: userId, image: requestValues.image)
        return UseCaseResponse.ok()
    }
}

struct SetPersistedUserAvatarUseCaseInput {
    let image: Data
}
