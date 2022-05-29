import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetPersistedUserUseCase: UseCase<Void, GetPersistedUserUseCaseOkOutput, GetPersistedUserUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPersistedUserUseCaseOkOutput, GetPersistedUserUseCaseErrorOutput> {
        let repositoryResponse = appRepository.getPersistedUser()
        if repositoryResponse.isSuccess() {
            return UseCaseResponse.ok(GetPersistedUserUseCaseOkOutput(try repositoryResponse.getResponseData()))
        }
        return UseCaseResponse.error(GetPersistedUserUseCaseErrorOutput(try repositoryResponse.getErrorMessage()))
    }
}

struct GetPersistedUserUseCaseOkOutput {
    
    fileprivate let persistedUser: PersistedUser?
    
    init(_ persistedUserDTO: PersistedUserDTO?) {
        guard let persistedUserDTO = persistedUserDTO else {
            self.persistedUser = nil
            return
        }
        self.persistedUser = PersistedUser(dto: persistedUserDTO)
        
    }
    
    public func getPersistedUserDTO() -> PersistedUser? {
        return persistedUser
    }
    
}

class GetPersistedUserUseCaseErrorOutput: StringErrorOutput {

}
