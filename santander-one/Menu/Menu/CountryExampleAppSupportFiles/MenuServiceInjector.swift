import CoreTestData
import QuickSetup

public final class MenuServiceInjector: CustomServiceInjector {
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
            for: \.tricks.getTricks,
            filename: "tricks"
        )
        injector.register(
            for: \.loadingTips.getLoadingTips,
            filename: "loading_tips"
        )
        injector.register(
            for: \.segmentedUser.getSegmentedUser,
            filename: "segmentosDefV2"
        )
    }
}
