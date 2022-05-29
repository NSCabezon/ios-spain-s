import CoreFoundationLib
import SANLegacyLibrary

class GetUserDataUseCase: UseCase<Void, GetUserDataUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    
    init(provider: BSANManagersProvider, appRepository: AppRepository) {
        self.provider = provider
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetUserDataUseCaseOkOutput, StringErrorOutput> {
        let response = try provider.getBsanPGManager().getGlobalPosition()
        guard response.isSuccess(), let data = try response.getResponseData()?.userDataDTO else {
             return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
        let repositoryResponse = appRepository.getPersistedUser()
        guard repositoryResponse.isSuccess(), let persistedUserDTO = try repositoryResponse.getResponseData(), let persistedUser = PersistedUser(dto: persistedUserDTO) else {
            return UseCaseResponse.error(StringErrorOutput(try repositoryResponse.getErrorMessage()))
        }
        let token = try provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        return UseCaseResponse.ok(GetUserDataUseCaseOkOutput(userData: UserDO(dto: data), persistedUser: persistedUser, token: token))
    }
}

struct GetUserDataUseCaseOkOutput {
    let userData: UserDO
    let persistedUser: PersistedUser
    let token: String
}
