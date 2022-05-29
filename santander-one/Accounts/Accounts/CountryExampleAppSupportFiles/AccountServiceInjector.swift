import CoreTestData
import QuickSetup

public final class AccountServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        injector.register(
            for: \.pullOffersConfig.getPullOffersConfig,
            filename: "pull_offers_configV4_without_cushion"
        )
        injector.register(
            for: \.appConfigLocalData.getAppConfigLocalData,
            filename: "app_config_v2"
        )
        injector.register(
            for: \.accountData.getAccountDetailMock,
            filename: "detalleCuenta"
        )
        injector.register(
            for: \.accountData.getAccountTransactionCategoryMock,
            filename: "transactionCategoryMovements"
        )
        injector.register(
            for: \.accountData.getAccountEasyPayMock,
            filename: "obtenerCampaCliente"
        )
        injector.register(
            for: \.accountData.getAccountTransactionsMock,
            filename: "listaMovCuentas"
        )
        injector.register(
            for: \.loanSimulatorData.getActiveCampaignsMock,
            filename: "checkActive"
        )
    }
}
