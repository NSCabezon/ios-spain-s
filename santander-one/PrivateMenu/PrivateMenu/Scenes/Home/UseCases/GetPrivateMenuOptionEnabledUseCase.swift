import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetPrivateMenuOptionEnabledUseCase {
    func fetchOptionsEnabledVisible() -> AnyPublisher<PrivateMenuOptionEnabledRepresentable, Never>
}

struct DefaultGetPrivateMenuOptionEnabledUseCase {
    private let boxes: GetMyProductsUseCase
    private let offers: GetCandidateOfferUseCase
    private let appConfig: AppConfigRepositoryProtocol
    private let menuConfig: GetPrivateMenuConfigUseCase
    private let servicesForYou: ServicesForYouRepository
    private let userPrefRepository: UserPreferencesRepository
    private let globalPositionRepository: GlobalPositionDataRepository
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        boxes = dependencies.resolve()
        offers = dependencies.resolve()
        appConfig = dependencies.resolve()
        menuConfig = dependencies.resolve()
        servicesForYou = ServicesForYouRepository(
            netClient: NetClientImplementation(),
            assetsClient: AssetsClient())
        userPrefRepository = dependencies.resolve()
        globalPositionRepository = dependencies.resolve()
    }
}

extension DefaultGetPrivateMenuOptionEnabledUseCase: GetPrivateMenuOptionEnabledUseCase {
    func fetchOptionsEnabledVisible() -> AnyPublisher<PrivateMenuOptionEnabledRepresentable, Never> {
        return notPrivateMenuOptions
    }
}

private extension DefaultGetPrivateMenuOptionEnabledUseCase {
    struct PrivateMenuOptionEnabled: PrivateMenuOptionEnabledRepresentable {
        let data: [PrivateMenuOptions]
        
        init(data: [PrivateMenuOptions]) {
            self.data = data
        }
    }
}

private extension DefaultGetPrivateMenuOptionEnabledUseCase {
    var notPrivateMenuOptions: AnyPublisher<PrivateMenuOptionEnabledRepresentable, Never> {
        var result: [PrivateMenuOptions] = []
        return isAnalysisZoneNotVisible
            .zip(isMyProductsNotVisible, isTransferMenuNotVisible) { notAnalysis, notProduct, notTransfers -> [PrivateMenuOptions] in
                if notAnalysis {
                    result.append(.analysisArea)
                }
                if notProduct {
                    result.append(.myProducts)
                }
                if notTransfers {
                    result.append(.transfers)
                }
                return result
            }
            .zip(isMarketPlaceMenuNotVisible, isBillMenuNotVisible) { _, notMarket, notBill -> [PrivateMenuOptions] in
                if notMarket {
                    result.append(.marketplace)
                }
                if notBill {
                    result.append(.bills)
                }
                return result
            }
            .zip(sofiaInvestmentsNotVisible, santanderOne1NotVisible) { _, notSofia, notSantan1 -> [PrivateMenuOptions] in
                if notSofia {
                    result.append(.sofiaInvestments)
                }
                if notSantan1 {
                    result.append(.santanderOne1)
                }
                return result
            }
            .zip(santanderOne2NotVisible, isContractNotVisible) { _, notSantan2, notContract -> [PrivateMenuOptions] in
                if notSantan2 {
                    result.append(.santanderOne2)
                }
                if notContract {
                    result.append(.contract)
                }
                return result
            }
            .zip(isMyHomeNotVisible, isOtherServicesNotVisible) { _, notHome, notOtherServices -> [PrivateMenuOptions] in
                if notHome {
                    result.append(.myHome)
                }
                if notOtherServices {
                    result.append(.otherServices)
                }
                return result
            }
            .zip(isFinancingNotVisible, isWorld123NotVisible) { _, notFinancing, notWorld -> [PrivateMenuOptions] in
                if notFinancing {
                    result.append(.financing)
                }
                if notWorld {
                    result.append(.world123)
                }
                return result
            }
            .zip(isTopUpsNotVisible) { _, notTop -> [PrivateMenuOptions] in
                if notTop {
                    result.append(.topUps)
                }
                return result
            }
            .map { PrivateMenuOptionEnabled(data: $0) }
            .replaceError(with: PrivateMenuOptionEnabled(data: []))
            .eraseToAnyPublisher()
    }
    
    var isAnalysisZoneNotVisible: AnyPublisher<Bool, Never> {
        let emptyProducts = isVisibleAccountsEmpty
            .zip(isCardsMenuEmpty, isLoansMenuEmpty) { accountsEmpty, cardsEmpty, loansEmpty in
                return accountsEmpty && cardsEmpty && loansEmpty
            }
            .eraseToAnyPublisher()
        return appConfig.value(for: "enabledAnalysisZone", defaultValue: false)
            .zip(emptyProducts) { enabledAnalysisZone, previousEmpty in
                return !enabledAnalysisZone || previousEmpty
            }
            .eraseToAnyPublisher()
    }
    
    var isMyProductsNotVisible: AnyPublisher<Bool, Never> {
        return isVisibleAccountsEmpty
            .zip(isCardsMenuEmpty, isLoansMenuEmpty) { accountsEmpty, cardsEmpty, loansEmpty in
                return accountsEmpty && cardsEmpty && loansEmpty
            }
            .zip(isFundsMenuEmpty, isDepositsMenuEmpty) { previousEmpty, fundsEmpty, depositsEmpty in
                return previousEmpty && fundsEmpty && depositsEmpty
            }
            .zip(isStocksMenuEmpty, isPensionsMenuEmpty) { previousEmpty, stocksEmpty, pensionsEmpty in
                return previousEmpty && stocksEmpty && pensionsEmpty
            }
            .zip(isInsuranceSavingMenuEmpty, isInsuranceProtectionMenuEmpty) { previousEmpty, savingsEmpty, protectionsEmpty in
                return previousEmpty && savingsEmpty && protectionsEmpty
            }
            .zip(isPortfolioManagedMenuEmpty, isPortfolioNotManagedMenuEmpty) { previousEmpty, portfolioEmpty, notPorfolioEmpty in
                return previousEmpty && portfolioEmpty && notPorfolioEmpty
            }
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    var isTransferMenuNotVisible: AnyPublisher<Bool, Never> {
        return boxes.fetchMyProducts()
            .map { value  in
                let product = value[.account]?.productsRepresentable.map { $0.value }
                return (product?.isEmpty ?? true)
            }
            .replaceError(with: true)
            .eraseToAnyPublisher()
    }
    
    var isMarketPlaceMenuNotVisible: AnyPublisher<Bool, Never> {
        return menuConfig
            .fetchPrivateConfigMenuData()
            .map { return $0.isMarketplaceEnabled.isFalse }
            .eraseToAnyPublisher()
    }
    
    var isBillMenuNotVisible: AnyPublisher<Bool, Never> {
        return menuConfig
            .fetchPrivateConfigMenuData()
            .map(\.isEnabledBillsAndTaxesInMenu)
            .zip(isVisibleAccountsEmpty) { bills, accountsEmpty in
                return !bills && accountsEmpty
            }
            .eraseToAnyPublisher()
    }
    
    var sofiaInvestmentsNotVisible: AnyPublisher<Bool, Never> {
        let locations = PullOffersLocationsFactoryEntity().sofiaInvestment
        return isPortfolioManagedMenuEmpty
            .zip(isPortfolioNotManagedMenuEmpty, isVariableIncomeMenuEmpty) { portfolioEmpty, notPortfolioEmpty, variableEmpty in
                return portfolioEmpty && notPortfolioEmpty && variableEmpty
            }
            .zip(isCandidate(locations)) { productsEmpty, location in
                return productsEmpty && !location
            }
            .eraseToAnyPublisher()
    }
    
    var santanderOne1NotVisible: AnyPublisher<Bool, Never> {
        return isCandidate(PullOffersLocationsFactoryEntity().santanderOne1)
            .map { !$0 }
            .eraseToAnyPublisher()
    }
    
    var santanderOne2NotVisible: AnyPublisher<Bool, Never> {
        return isCandidate(PullOffersLocationsFactoryEntity().santanderOne2)
            .map { return !$0 }
            .eraseToAnyPublisher()
    }
    
    var isContractNotVisible: AnyPublisher<Bool, Never> {
        let isSanflixEnabled = menuConfig
            .fetchPrivateConfigMenuData()
            .map(\.sanflixEnabled)
        let location = PullOffersLocationsFactoryEntity().privateMenuSanflix
        let contractSanflix = isCandidate(location)
        let enablePublicProducts = menuConfig
            .fetchPrivateConfigMenuData()
            .map(\.enablePublicProducts)
        return isSanflixEnabled
            .zip(contractSanflix, enablePublicProducts) { sanflixConfig, location, enabledPublicProduct in
                return !sanflixConfig && !location && !enabledPublicProduct
            }
            .eraseToAnyPublisher()
    }
    
    var isMyHomeNotVisible: AnyPublisher<Bool, Never> {
        let location = PullOffersLocationsFactoryEntity().privateMenuMyHome
        return isCandidate(location)
            .map { !$0 }
            .eraseToAnyPublisher()
    }
    
    var isOtherServicesNotVisible: AnyPublisher<Bool, Never> {
        let isComingFeaturesEnabled = menuConfig
            .fetchPrivateConfigMenuData()
            .map(\.enableComingFeatures)
        let locations = PullOffersLocationsFactoryEntity().privateMenuCarbonFootPrint
        return isComingFeaturesEnabled
            .zip(isCandidate(locations), isSmartServicesEnabled) { enabledComing, footprint, isSmart in
                return !enabledComing && !footprint && !isSmart
            }
            .eraseToAnyPublisher()
    }
    
    var isFinancingNotVisible: AnyPublisher<Bool, Never> {
        return menuConfig
            .fetchPrivateConfigMenuData()
            .map { return !$0.enableFinancingZone }
            .eraseToAnyPublisher()
    }
    
    var isWorld123NotVisible: AnyPublisher<Bool, Never> {
        let locations = PullOffersLocationsFactoryEntity().world123SideMenu
        return isCandidate(locations)
            .map { !$0 }
            .eraseToAnyPublisher()
    }
    
    var isTopUpsNotVisible: AnyPublisher<Bool, Never> {
        return isVisibleAccountsEmpty
            .map { !$0 }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helpers
    var isVisibleAccountsEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.account)
    }
    var isCardsMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.card)
    }
    var isLoansMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.loan)
    }
    var isFundsMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.fund)
    }
    var isDepositsMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.deposit)
    }
    var isStocksMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.stock)
    }
    var isPensionsMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.pension)
    }
    var isInsuranceSavingMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.insuranceSaving)
    }
    var isInsuranceProtectionMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.insuranceProtection)
    }
    var isPortfolioManagedMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.managedPortfolio)
    }
    var isPortfolioNotManagedMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.notManagedPortfolio)
    }
    
    var isVariableIncomeMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.managedPortfolioVariableIncome)
            .zip(isEmptyProduct(.notManagedPortfolioVariableIncome)) { previous, own in
                return previous && own
            }
            .eraseToAnyPublisher()
    }
    
    func isEmptyProduct(_ product: UserPrefBoxType) -> AnyPublisher<Bool, Never> {
        return boxes.fetchMyProducts()
            .map() { value -> Bool in
                let product = value[product]?.productsRepresentable.map { $0.value }
                return product?.filter { $0.isVisible == true }.isEmpty ?? true
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func isCandidate(_ locations: [PullOfferLocationRepresentable]) -> AnyPublisher<Bool, Never> {
        return mergeEnabledOffers(from: locations, doing: checkCandidate)
            .flatMap { data -> AnyPublisher<Bool, Never> in
                checkOneEnabled(data)
            }
            .eraseToAnyPublisher()
    }
    
    func mergeEnabledOffers(
        from offers: [PullOfferLocationRepresentable],
        doing loadOffers: (PullOfferLocationRepresentable) -> AnyPublisher<[Bool], Never>
    ) -> AnyPublisher<[Bool], Never> {
        return Publishers.MergeMany(offers.map(loadOffers))
            .reduce([Bool]()) { $0 + $1 }
            .eraseToAnyPublisher()
    }
    
    func checkOneEnabled(_ value: [Bool]) -> AnyPublisher<Bool, Never> {
        let result = value.first(where: { $0 == true }) ?? false
        return Just(result).eraseToAnyPublisher()
    }
    
    func checkCandidate( _ location: PullOfferLocationRepresentable) -> AnyPublisher<[Bool], Never> {
        return offers.fetchCandidateOfferPublisher(location: location)
            .receive(on: Schedulers.main)
            .flatMap { offerRepresentable -> AnyPublisher<[Bool], Never> in
                return Just([true]).eraseToAnyPublisher()
            }
            .replaceError(with: [false])
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    var isSmartServicesEnabled: AnyPublisher<Bool, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .map(\.userId)
            .flatMap { userId -> AnyPublisher<String, Error> in
                guard let userId = userId else { return Fail(error: NSError(description: "no-user-id")).eraseToAnyPublisher() }
                return Just(userId).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .map(userPrefRepository.getUserPreferences)
            .flatMap { $0 }
            .map { userPref in
                let smartServices = servicesForYou.get()
                let categoriesNotEmpty = smartServices?.categoriesRepresentable.isNotEmpty ?? false
                return userPref.isSmartUser() && categoriesNotEmpty
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
