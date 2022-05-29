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
    
    private func updateMetricsEnviorement() {
        guard let bsanEnvironment = try? bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() else {
            return
        }
        netInsightRepository.baseUrl = bsanEnvironment.urlNetInsight
    }
    
    override func executeUseCase(requestValues: Void) -> UseCaseResponse<ExtensionsLoginUseCaseOkOutput, StringErrorOutput> {
        let touchIdAccount = Compilation.Keychain.Account.touchId
        let widgetAccount = Compilation.Keychain.Account.widget
        let service = Compilation.Keychain.service
        let accessGroup = Compilation.Keychain.sharedTokenAccessGroup
        guard let response = try? executeLogin(touchIdAccount: touchIdAccount, widgetAccount: widgetAccount, service: service, accessGroup: accessGroup)
        else {
            return .error(StringErrorOutput(nil))
        }
        updateMetricsEnviorement()
        return response
    }
}
