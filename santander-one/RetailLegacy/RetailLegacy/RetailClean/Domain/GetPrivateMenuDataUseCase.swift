import Foundation
import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class GetPrivateMenuDataUseCase: UseCase<Void, GetPrivateMenuDataUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    private var accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository
    private let servicesForYouRepository: ServicesForYouRepository
    private let dependenciesResolver: DependenciesResolver
    
    init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository, servicesForYouRepository: ServicesForYouRepository, dependenciesResolver: DependenciesResolver) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
        self.servicesForYouRepository = servicesForYouRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPrivateMenuDataUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let merger = GlobalPositionPrefsMergerEntity(resolver: dependenciesResolver, globalPosition: globalPosition, saveUserPreferences: true)
        let isSmart = try bsanManagersProvider.getBsanUserSegmentManager().isSmartUser()
        let servicesForYouRepositoryDTO = servicesForYouRepository.get()
        let isMarketplaceEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigIsMarketplaceEnabled) ?? false
        let isEnabledBillsAndTaxesInMenu = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigIsEnabledBillsAndTaxesInMenu) ?? false
        let isEnabledExploreProductsInMenu = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigIsEnabledExploreProductsInMenu) ?? false
        
        let enableVirtualAssistant = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableVirtualAssistant) ?? false
        let visibleAnalysisZoneFromAppConfig = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigAnalysisEnabled) ?? false
        var featuredOptions: [PrivateMenuOptions: String] = [:]
        let highlightMenuAppConfigValue: String = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigHighlightMenu) ?? ""
        let enablePublicProducts = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.enablePublicProducts) ?? false
        let enableComingFeatures = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableComingFeatures) ?? false
        let enableFinancingZone = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableFinancingZone) ?? false
        if let serializedAppConfigValue: [String: String] = CodableParser<[String: String]>().serialize(highlightMenuAppConfigValue) {
            let validKeys: [PrivateMenuOptions] = serializedAppConfigValue.keys.compactMap({PrivateMenuOptions(featuredOptionString: $0)})
            for key in validKeys {
                featuredOptions[key] = serializedAppConfigValue[key.featuredOptionsId]
            }
        }
        guard let globalPositionDTO = merger.dto, let userId = merger.userId else {
            return .error(StringErrorOutput(nil))
        }
        let userPrefEntity = appRepository.getUserPreferences(userId: userId)
        let products: [UserPrefBoxType: PGBoxRepresentable] = userPrefEntity.pgUserPrefDTO.boxes
        let myProductsOffers: String? = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigMyProducts)
        let enableStockholders = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableStockholders) ?? false
        var localAppConfig: LocalAppConfig {
            self.dependenciesResolver.resolve(for: LocalAppConfig.self)
        }
        let privateMenuWrapper = PrivateMenuWrapper
            .createFromGlobalPositionWrapper(
                globalPositionPreferences: merger,
                dto: globalPositionDTO,
                isPb: merger.isPb ?? false,
                products: products,
                isSmartUser: isSmart,
                servicesForYouDTO: servicesForYouRepositoryDTO,
                isMarketplaceEnabled: isMarketplaceEnabled,
                isEnabledBillsAndTaxesInMenu: isEnabledBillsAndTaxesInMenu,
                isEnabledExploreProductsInMenu: isEnabledExploreProductsInMenu,
                isVirtualAssistantEnabled: enableVirtualAssistant,
                featuredOptions: featuredOptions,
                myProductsOffers: myProductsOffers,
                enablePublicProducts: enablePublicProducts,
                enableComingFeatures: enableComingFeatures,
                enableFinancingZone: enableFinancingZone,
                enableStockholders: enableStockholders,
                localAppConfig: localAppConfig
        )
        privateMenuWrapper.analysisAreaEnabled = visibleAnalysisZoneFromAppConfig
        privateMenuWrapper.sanflixEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableApplyBySanflix) ?? false
        return UseCaseResponse.ok(GetPrivateMenuDataUseCaseOkOutput(privateMenuWrapper: privateMenuWrapper))
    }
}

struct GetPrivateMenuDataUseCaseOkOutput {
    let privateMenuWrapper: PrivateMenuWrapper
}
