import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class CheckPersistedUserUseCase: UseCase<Void, Void, CheckPersistedUserUseCaseErrorOutput> {
    private var netInsightRepository: NetInsightRepository
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider

    init(appRepository: AppRepository, bsanManagersProvider: BSANManagersProvider, netInsightRepository: NetInsightRepository) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.netInsightRepository = netInsightRepository
    }
    
    private func updateMetricsEnviorement() throws {
        guard let bsanEnvironment = try bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() else {
            return
        }
        netInsightRepository.baseUrl = bsanEnvironment.urlNetInsight
    }

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, CheckPersistedUserUseCaseErrorOutput> {
        let repositoryResponse = appRepository.hasPersistedUser()
        if let hasPersistedUser = try repositoryResponse.getResponseData(), hasPersistedUser,
            let persistedUser = try appRepository.getPersistedUser().getResponseData() {
            _ = bsanManagersProvider.getBsanEnvironmentsManager().setEnvironment(bsanEnvironmentName: persistedUser.environmentName)
            try updateMetricsEnviorement()
            return UseCaseResponse.ok()
        }
        _ = appRepository.removePersistedUser()
        return UseCaseResponse.error(CheckPersistedUserUseCaseErrorOutput(CheckPersistedUserErrorType.incompletePersistedUser))
    }
}

class CheckPersistedUserUseCaseErrorOutput: StringErrorOutput {

    let checkPersistedUserErrorType: CheckPersistedUserErrorType

    override init(_ errorDesc: String?) {
        self.checkPersistedUserErrorType = CheckPersistedUserErrorType.serviceFault
        super.init(errorDesc)
    }

    init(_ checkPersistedUserErrorType: CheckPersistedUserErrorType) {
        self.checkPersistedUserErrorType = checkPersistedUserErrorType
        super.init(nil)
    }

}
