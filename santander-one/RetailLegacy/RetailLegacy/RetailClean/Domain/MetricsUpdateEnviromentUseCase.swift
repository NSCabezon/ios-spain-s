import CoreFoundationLib
import SANLegacyLibrary

class MetricsUpdateEnviromentUseCase: UseCase<Void, Void, StringErrorOutput> {
    private var netInsightRepository: NetInsightRepository
    private let bsanProvider: BSANManagersProvider
    
    init(netInsightRepository: NetInsightRepository, bsanProvider: BSANManagersProvider) {
        self.netInsightRepository = netInsightRepository
        self.bsanProvider = bsanProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let bsanEnvironment = try bsanProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        netInsightRepository.baseUrl = bsanEnvironment.urlNetInsight
        return UseCaseResponse.ok()
    }
}
