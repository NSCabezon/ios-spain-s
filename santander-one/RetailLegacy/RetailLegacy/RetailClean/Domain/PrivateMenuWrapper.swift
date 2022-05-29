import SANLegacyLibrary
import CoreDomain
import CoreFoundationLib
import CoreDomain

final class PrivateMenuWrapper {
    static func createFromGlobalPositionWrapper(
        globalPositionPreferences: GlobalPositionPrefsMergerEntity,
        dto: GlobalPositionDTO,
        isPb: Bool,
        products: [UserPrefBoxType: PGBoxRepresentable],
        isSmartUser: Bool,
        servicesForYouDTO: ServicesForYouDTO?,
        isMarketplaceEnabled: Bool,
        isEnabledBillsAndTaxesInMenu: Bool,
        isEnabledExploreProductsInMenu: Bool,
        isVirtualAssistantEnabled: Bool,
        featuredOptions: [PrivateMenuOptions: String],
        myProductsOffers: String?,
        enablePublicProducts: Bool,
        enableComingFeatures: Bool,
        enableFinancingZone: Bool,
        enableStockholders: Bool,
        localAppConfig: LocalAppConfig) -> PrivateMenuWrapper {
            var servicesForYouResolve: ServicesForYou? = nil
            if let servicesForYouDTO = servicesForYouDTO {
                servicesForYouResolve = ServicesForYou(servicesForYouDTO)
            }
        return PrivateMenuWrapper(
            dto: dto,
            globalPositionPreferences: globalPositionPreferences,
            isPb: isPb,
            products: products,
            isSmartUser: isSmartUser,
            servicesForYou: servicesForYouResolve,
            isMarketplaceEnabled: isMarketplaceEnabled,
            isEnabledBillsAndTaxesInMenu: isEnabledBillsAndTaxesInMenu,
            isEnabledExploreProductsInMenu: isEnabledExploreProductsInMenu,
            isVirtualAssistantEnabled: isVirtualAssistantEnabled,
            featuredOptions: featuredOptions,
            myProductsOffers: myProductsOffers,
            enablePublicProducts: enablePublicProducts,
            enableComingFeatures: enableComingFeatures,
            enableFinancingZone: enableFinancingZone,
            enableStockholders: enableStockholders,
            localAppConfig: localAppConfig
        )
    }
    var globalPositionPreferences: GlobalPositionPrefsMergerEntity
    var dto: GlobalPositionDTO
    var isPb: Bool
    var products: [UserPrefBoxType: PGBoxRepresentable]
    var isSmart: Bool
    var smartServices: ServicesForYou?
    var tips: [PullOffersConfigTip]?
    var isRenting: Bool
    var isMarketplaceEnabled: Bool
    var isEnabledBillsAndTaxesInMenu: Bool
    var isEnabledExploreProductsInMenu: Bool
    var isVirtualAssistantEnabled: Bool
    var isSofiaInvestments: Bool
    var featuredOptions: [PrivateMenuOptions: String]
    var analysisAreaEnabled: Bool = false
    var sanflixEnabled: Bool = false
    var myProductsOffers: String?
    var enablePublicProducts: Bool = false
    var enableComingFeatures: Bool = false
    var enableFinancingZone: Bool = false
    var enableStockholders: Bool = false
    var localAppConfig: LocalAppConfig
    
    var userId: String {
        let userDo = UserDO(dto: dto.userDataDTO)
        return userDo.userId ?? ""
    }
    
    func isSmartServicesEnabled() -> Bool {
        guard let categories = smartServices?.categories else {
            return false
        }
        return isSmart && categories.isNotEmpty
    }
    
    func isMarketPlaceMenuVisible() -> Bool {
        return isMarketplaceEnabled
    }
    
    func isEnabledBillsAndTaxes() -> Bool {
        return isEnabledBillsAndTaxesInMenu
    }
    
    func isEnabledExploreProducts() -> Bool {
        return isEnabledExploreProductsInMenu
    }
    
    func isVirtualAssistantMenuVisible() -> Bool {
        return isVirtualAssistantEnabled
    }
    
    func isTipsMenuVisible() -> Bool {
        return tips?.isEmpty == false
    }
    
    func isTransferMenuVisible() -> Bool {
        return isAllAccountsEmpty() ? false : true
    }
    
    func isAnalysisMenuVisible() -> Bool {
        if self.analysisAreaEnabled == true {
            return !self.isVisibleAccountsEmpty() || !self.isCardsMenuEmpty() || !self.isLoansMenuEmpty()
        }
        return false
    }
    
    func isSanflixEnabled() -> Bool {
        return self.sanflixEnabled
    }
    
    func isInvestmentMenuVisible() -> Bool {
        return isPortfolioManagedMenuEmpty() == false
            || isPortfolioNotManagedMenuEmpty() == false
            || isVariableIncomeMenuEmpty() == false
    }
    
    func isMyProductsAllowed() -> Bool {
        return isVisibleAccountsEmpty() == false
            || isCardsMenuEmpty() == false
            || isLoansMenuEmpty() == false
            || isFundsMenuEmpty() == false
            || isDepositsMenuEmpty() == false
            || isStocksMenuEmpty() == false
            || isPensionsMenuEmpty() == false
            || isInsuranceSavingMenuEmpty() == false
            || isInsuranceProtectionMenuEmpty() == false
            || isPortfolioManagedMenuEmpty() == false
            || isPortfolioNotManagedMenuEmpty() == false
    }
    
    func isVisibleAccountsEmpty() -> Bool {
        let accountList = products[.account]?.productsRepresentable.map { $0.value }
        guard let accounts = accountList else { return true }
        return accounts.filter { $0.isVisible == true }.isEmpty
    }
    
    func isAllAccountsEmpty() -> Bool {
        let accountList = products[.account]?.productsRepresentable.map { $0.value }
        guard let accounts = accountList else { return true }
        return accounts.isEmpty
    }
    
    func isCardsMenuEmpty() -> Bool {
        let cardList = products[.card]?.productsRepresentable.map { $0.value }
        guard let cards = cardList else { return true }
        return cards.filter { $0.isVisible == true }.isEmpty
    }
    
    func isLoansMenuEmpty() -> Bool {
        let loanList = products[.loan]?.productsRepresentable.map { $0.value }
        guard let loans = loanList else { return true }
        return loans.filter { $0.isVisible == true }.isEmpty
    }
    
    func isFundsMenuEmpty() -> Bool {
        let fundList = products[.fund]?.productsRepresentable.map { $0.value }
        guard let funds = fundList else { return true }
        return funds.filter { $0.isVisible == true }.isEmpty
    }
    
    func isDepositsMenuEmpty() -> Bool {
        let depositsList = products[.deposit]?.productsRepresentable.map { $0.value }
        guard let deposits = depositsList else { return true }
        return deposits.filter { $0.isVisible == true }.isEmpty
    }
    
    func isStocksMenuEmpty() -> Bool {
        let stockList = products[.stock]?.productsRepresentable.map { $0.value }
        guard let stocks = stockList else { return true }
        return stocks.filter { $0.isVisible == true }.isEmpty
    }
    
    func isPensionsMenuEmpty() -> Bool {
        let pensionList = products[.pension]?.productsRepresentable.map { $0.value }
        guard let pensions = pensionList else { return true }
        return pensions.filter { $0.isVisible == true }.isEmpty
    }
    
    func isInsuranceSavingMenuEmpty() -> Bool {
        let insuranceSavingList = products[.insuranceSaving]?.productsRepresentable.map { $0.value }
        guard let insurancesSaving = insuranceSavingList else { return true }
        return insurancesSaving.filter { $0.isVisible == true }.isEmpty
    }
    
    func isInsuranceProtectionMenuEmpty() -> Bool {
        let insuranceProtectionList = products[.insuranceProtection]?.productsRepresentable.map { $0.value }
        guard let insurancesProtection = insuranceProtectionList else { return true }
        return insurancesProtection.filter { $0.isVisible == true }.isEmpty
    }
    
    func isPortfolioManagedMenuEmpty() -> Bool {
        let managedPortfolioList = products[.managedPortfolio]?.productsRepresentable.map { $0.value }
        guard let managedPortfolios = managedPortfolioList else { return true }
        return managedPortfolios.filter { $0.isVisible == true }.isEmpty
    }
    
    func isPortfolioNotManagedMenuEmpty() -> Bool {
        let notManagedPortfolioList = products[.notManagedPortfolio]?.productsRepresentable.map { $0.value }
        guard let notManagedPortfolios = notManagedPortfolioList else { return true }
        return notManagedPortfolios.filter { $0.isVisible == true }.isEmpty
    }
    
    func isVariableIncomeMenuEmpty() -> Bool {
        let managedRVStockList = products[.managedPortfolioVariableIncome]?.productsRepresentable.map { $0.value }
        let notManagedRVStockList = products[.notManagedPortfolioVariableIncome]?.productsRepresentable.map { $0.value }
        guard let managedRVStock = managedRVStockList, let notManagedRVStock = notManagedRVStockList else { return true }
        return managedRVStock.filter { $0.isVisible == true }.isEmpty && notManagedRVStock.filter { $0.isVisible == true }.isEmpty
    }
    
    func isEnablePublicProducts() -> Bool {
        return enablePublicProducts
    }
    
    func isComingFeaturesEnabled() -> Bool {
        return enableComingFeatures
    }
    
    func isFinancingZoneEnabled() -> Bool {
        return enableFinancingZone
    }
    
    func isStockholdersEnable() -> Bool {
        return enableStockholders
    }
    
    init(dto: GlobalPositionDTO,
         globalPositionPreferences: GlobalPositionPrefsMergerEntity,
         isPb: Bool,
         products: [UserPrefBoxType: PGBoxRepresentable],
         isSmartUser: Bool,
         servicesForYou: ServicesForYou?,
         isMarketplaceEnabled: Bool,
         isEnabledBillsAndTaxesInMenu: Bool,
         isEnabledExploreProductsInMenu: Bool,
         isVirtualAssistantEnabled: Bool,
         featuredOptions: [PrivateMenuOptions: String],
         myProductsOffers: String?,
         enablePublicProducts: Bool,
         enableComingFeatures: Bool,
         enableFinancingZone: Bool,
         enableStockholders: Bool,
         localAppConfig: LocalAppConfig) {
        self.globalPositionPreferences = globalPositionPreferences
        self.dto = dto
        self.isPb = isPb
        self.products = products
        self.isSmart = isSmartUser
        self.smartServices = servicesForYou
        self.isRenting = false
        self.isMarketplaceEnabled = isMarketplaceEnabled
        self.isVirtualAssistantEnabled = isVirtualAssistantEnabled
        self.isEnabledBillsAndTaxesInMenu = isEnabledBillsAndTaxesInMenu
        self.isEnabledExploreProductsInMenu = isEnabledExploreProductsInMenu
        self.isSofiaInvestments = false
        self.featuredOptions = featuredOptions
        self.myProductsOffers = myProductsOffers
        self.enablePublicProducts = enablePublicProducts
        self.enableComingFeatures = enableComingFeatures
        self.enableFinancingZone = enableFinancingZone
        self.enableStockholders = enableStockholders
        self.localAppConfig = localAppConfig
    }
}

extension PrivateMenuWrapper: GlobalPositionNameProtocol {    
    var globalPositionDataRepresentable: GlobalPositionDataRepresentable {
        return dto
    }
}
