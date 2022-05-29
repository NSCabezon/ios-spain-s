import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary

struct UseCaseProviderBuilder {
    let versionInfo: VersionInfoDTO
    let appRepository: AppRepository
    let bsanManagersProvider: BSANManagersProvider
    let pullOffersRepository: PullOffersRepositoryProtocol
    let pullOffersEngine: EngineInterface
    let downloadsRepository: DownloadsRepository
    let appGroupsDataRepository: DataRepository
    let documentsRepository: DocumentsRepository
    let dataRepository: DataRepository
    let dependenciesEngine: DependenciesInjector & DependenciesResolver
    let trusteerRepository: TrusteerRepositoryProtocol
    let bsanDataProvider: BSANDataProviderProtocol
    let coreDependenciesResolver: RetailLegacyExternalDependenciesResolver
    let assetsClient = AssetsClient()
    let netClient = NetClientImplementation()
    let fileClient = FileClient()
    
    func build() -> UseCaseProvider {
        let siriHandler = self.dependenciesEngine.resolve(for: SiriAssistantProtocol.self)
        let appConfigRepository = AppConfigRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, versionName: versionInfo.getVersionName())
        let siriAssistant = SiriAssistant(appConfigRepository: appConfigRepository, appRepository: appRepository, bsanManagersProvider: bsanManagersProvider, siriHandler: siriHandler)
        let appInfoRepository = AppInfoRepository(netClient: netClient, assetsClient: assetsClient)
        let pullOffersConfigRepository = PullOffersConfigRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        let segmentedUserRepository = DefaultSegmentedUserRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        let faqsRepository = FaqsRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        let searchKeywordsRepository = SearchKeywordsRepository(netClient: netClient, assetClient: assetsClient, fileClient: fileClient)
        let rulesRepository: RulesRepository = coreDependenciesResolver.resolve()
        let publicProductsRepository = PublicProductsRepository(netClient: netClient, assetsClient: assetsClient)
        let offersRepository: OffersRepository = coreDependenciesResolver.resolve()
        let servicesForYouRepository = ServicesForYouRepository(netClient: netClient, assetsClient: assetsClient)
        let sepaInfoRepository = SepaInfoRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        let comingFeaturesRepository = ComingFeaturesRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        let frequentEmittersRepository = FrequentEmittersRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        let loadingTipsRepository = LoadingTipsRepository(netClient: netClient, assetClient: assetsClient, fileClient: fileClient)
        let countriesRepository = CountriesRepository(netClient: netClient, assetClient: assetsClient)
        let merchantRepository = MerchantRepository(netClient: netClient, assetClient: assetsClient, fileClient: fileClient)
        let managersHobbiesRepository = ManagerHobbiesRepository(netClient: netClient, assetClient: assetsClient, fileClient: fileClient)
        let accountDescriptorRepository = AccountDescriptorRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        let tricksRepository = TricksRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        let tealiumRepository = TealiumRepositoryImpl(dependenciesResolver: self.dependenciesEngine)
        let services = NetworkServiceImpl(callExecutor: NetworkURLSessionExecutor(dependenciesResolver: self.dependenciesEngine))
        let netInsightRepository = NetInsightRepositoryImpl(networkService: services)
        let pullOffersInterpreter: PullOffersInterpreter = PullOffersInterpreterImpl(pullOffersRepository: pullOffersRepository, offersRepository: offersRepository, rulesRepository: rulesRepository, pullOffersEngine: pullOffersEngine, dependenciesResolver: dependenciesEngine)
        let daoSharedAppConfig = DAOSharedAppConfigImpl(dataRepository: appGroupsDataRepository)
        let bizumDefaultNGOs = BizumDefaultNGOsRepository(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient)
        
        return UseCaseProvider(
            appRepository: appRepository,
            downloadsRepository: downloadsRepository,
            appInfoRepository: appInfoRepository,
            segmentedUserRepository: segmentedUserRepository,
            faqsRepository: faqsRepository,
            rulesRepository: rulesRepository,
            offersRepository: offersRepository,
            servicesForYouRepository: servicesForYouRepository,
            bsanManagersProvider: bsanManagersProvider,
            appConfigRepository: appConfigRepository,
            accountDescriptorRepository: accountDescriptorRepository,
            pullOffersRepository: pullOffersRepository,
            pullOffersConfigRepository: pullOffersConfigRepository,
            sepaInfoRepository: sepaInfoRepository,
            pullOffersEngine: pullOffersEngine,
            publicProductsRepository: publicProductsRepository,
            pullOffersInterpreter: pullOffersInterpreter,
            tealiumRepository: tealiumRepository,
            netInsightRepository: netInsightRepository,
            daoSharedAppConfig: daoSharedAppConfig,
            siriAssistant: siriAssistant,
            documentsRepository: documentsRepository,
            bsanDataProvider: bsanDataProvider,
            dependenciesEngine: dependenciesEngine,
            loadingTipsRepository: loadingTipsRepository,
            countriesRepository: countriesRepository,
            searchKeywordRepository: searchKeywordsRepository,
            managerHobbiesRepository: managersHobbiesRepository,
            comingFeaturesRepository: comingFeaturesRepository,
            frequentEmittersRepository: frequentEmittersRepository,
            tricksRepository: tricksRepository,
            trusteerRepository: trusteerRepository,
            bizumDefaultNGOsRepository: bizumDefaultNGOs,
            merchantRepository: merchantRepository)
    }
}

private extension UseCaseProviderBuilder {
    var offersDataSourceParameters: BaseDataSourceParameters {
        return coreDependenciesResolver.resolve()
    }
}
