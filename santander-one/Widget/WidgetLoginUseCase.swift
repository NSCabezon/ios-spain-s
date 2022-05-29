import CoreFoundationLib
import SANLibraryV3
import CommonAppExtensions
import RetailLegacy

final class WidgetLoginUseCase: ExtensionsLoginUseCase {
    private var netInsightRepository: NetInsightRepository
    
    init(bsanManagersProvider: BSANManagersProvider, daoSharedPersistedUser: DAOSharedPersistedUserProtocol, netInsightRepository: NetInsightRepository) {
        self.netInsightRepository = netInsightRepository
        super.init(bsanManagersProvider: bsanManagersProvider, daoSharedPersistedUser: daoSharedPersistedUser)
        loginCase = .widget
    }
    
    private func updateMetricsEnviorement() throws {
        guard let bsanEnvironment = try bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() else {
            return
        }
        netInsightRepository.baseUrl = bsanEnvironment.urlNetInsight
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ExtensionsLoginUseCaseOkOutput, StringErrorOutput> {
        let account = Compilation.Keychain.Account.widget
        let service = Compilation.Keychain.service
        let accessGroup = Compilation.Keychain.sharedTokenAccessGroup
        let response = try executeLogin(account, service: service, accessGroup: accessGroup)
        try updateMetricsEnviorement()
        return response
    }
}
