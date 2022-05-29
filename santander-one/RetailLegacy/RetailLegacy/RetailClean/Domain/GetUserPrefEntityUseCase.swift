import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetUserPrefEntityUseCase: UseCase<Void, GetUserPrefEntityUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    private var accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository

     init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
           self.appRepository = appRepository
           self.bsanManagersProvider = bsanManagersProvider
           self.accountDescriptorRepository = accountDescriptorRepository
           self.appConfigRepository = appConfigRepository
       }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetUserPrefEntityUseCaseOkOutput, StringErrorOutput> {
        let persistedUserResponse = appRepository.getPersistedUser()
        var userId: String = ""
        
        if persistedUserResponse.isSuccess(), let persistedUserDTO = try persistedUserResponse.getResponseData() {
            userId = persistedUserDTO.userId ?? ""
        } else {
            //GlobalPositionWrapper & UserPrefs
            let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
            
            if let globalPositionWrapper = merger.globalPositionWrapper {
                userId = globalPositionWrapper.userId
            }
        }
        let userPrefEntity = appRepository.getUserPreferences(userId: userId)
        
        return UseCaseResponse.ok(GetUserPrefEntityUseCaseOkOutput(userPref: UserPrefEntity.from(dto: userPrefEntity)))
    }
}

struct GetUserPrefEntityUseCaseOkOutput {
    var userPref: UserPrefEntity?
}
