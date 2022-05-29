import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class GetPGProductsUseCase: UseCase<Void, GetPGProductsUseCaseOkOutput, GetPGProductsUseCaseErrorOutput> {

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

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPGProductsUseCaseOkOutput, GetPGProductsUseCaseErrorOutput> {
        //GlobalPositionWrapper & UserPrefs
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(GetPGProductsUseCaseErrorOutput(nil))
        }
        let userPref = merger.oldUserPref
        return UseCaseResponse.ok(GetPGProductsUseCaseOkOutput(globalPosition: globalPositionWrapper, userPref: userPref))
    }
}

struct GetPGProductsUseCaseOkOutput {
    var globalPosition: GlobalPositionWrapper
    var userPref: UserPref?
    
    init(globalPosition: GlobalPositionWrapper, userPref: UserPref?) {
        self.globalPosition = globalPosition
        self.userPref = userPref
    }
}

class GetPGProductsUseCaseErrorOutput: StringErrorOutput {}
