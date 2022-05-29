import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary
import Foundation

private extension GetPGUseCase {
    enum Constants {
        static let enabledAnalysisZone = "enabledAnalysisZone"
        static let enableMarketplace = "enableMarketplace"
        static let enabledEnvioDineroPGClasicaNew = "enabledEnvioDineroPGClasicaNew"
        static let enabledEnvioDineroPGSmartNew = "enabledEnvioDineroPGSmartNew"
        static let enabledApplyBySanflix = "enableApplyBySanflix"
        static let enabledPublicProducts = "enablePublicProducts"
        static let enabledFinancingZone = "enableFinancingZone"
        static let enableStockholders = "enableStockholders"
        static let shortcutsPG1 = "shortcutsPG1"
        static let shortcutsPG2 = "shortcutsPG2"
        static let shortcutsPG3 = "shortcutsPG3"
        static let enableTimeLineKey = "enableTimeLine"
        static let enablePregrantedWidget = "enablePregrantedWidget"
        static let enablePGTopPregrantedBanner = "enablePGTopPregrantedBanner"
        static let pregrantedBannerColor = "pgTopPregrantedBannerColor"
        static let pregrantedBannerText = "pgTopPregrantedBannerText"
        static let pgTopPregrantedBannerStartedText = "pgTopPregrantedBannerStartedText"
        static let enableInsurance = "enableSavingInsuranceBalance"
        static let enableWhatsNew = "enabledWhatsNew"
        static let enableAviosZone = "enableAviosZone"
        static let campaignsAviosZone = "campaignsAviosZone"
        static let favouritesPGShow = "favouritesPGShow"
        static let appConfigInsuranceDetailEnabled = "enabledInsuranceDetail"
        static let robinsonCode = "2"
        static let carbonFootprintUrl = "carbonFootprintUrl"
        static let carbonFootprintCloseUrl = "carbonFootprintCloseUrl"
        static let enableCarbonFootprint = "enableCarbonFootprint"
        static let carbonFootprintShow = "carbonFootprintShow"
    }
}

final class GetPGUseCase: UseCase<GetPGUseCaseInput, GetPGUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let accountDescriptorRepository: AccountDescriptorRepositoryProtocol
    private let pullOffersConfigRepository: PullOffersConfigRepositoryProtocol
    private let pullOffersInterpreter: PullOffersInterpreter
    private let appRepository: AppRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let bsanManagersProvider: BSANManagersProvider
    private let localAppConfig: LocalAppConfig
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.accountDescriptorRepository = dependenciesResolver.resolve()
        self.pullOffersInterpreter = dependenciesResolver.resolve()
        self.appRepository = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
        self.bsanManagersProvider = dependenciesResolver.resolve()
        self.pullOffersConfigRepository = dependenciesResolver.resolve()
        self.localAppConfig = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: GetPGUseCaseInput) throws -> UseCaseResponse<GetPGUseCaseOkOutput, StringErrorOutput> {
        let baseURLProvider: BaseURLProvider = self.dependenciesResolver.resolve()
        let globalPositionConfiguration: GlobalPositionConfiguration = self.dependenciesResolver.resolve()
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve()
        let accountDescriptors: [AccountDescriptorEntity] = accountDescriptorRepository.getAccountDescriptor()?.accountsArray.map({ AccountDescriptorEntity(type: $0.type ?? "", subType: $0.subType ?? "") }) ?? []
        let isAnalysisAreaEnabled = appConfigRepository.getBool(Constants.enabledAnalysisZone) ?? false
        let enableMarketplace = appConfigRepository.getBool(Constants.enableMarketplace) ?? false
        let isSanflixEnabled = appConfigRepository.getBool(Constants.enabledApplyBySanflix) ?? false
        let isPublicProductEnable = appConfigRepository.getBool(Constants.enabledPublicProducts) ?? false
        let isFinancingZoneEnabled = appConfigRepository.getBool(Constants.enabledFinancingZone) ?? false
        let enableStockholders = appConfigRepository.getBool(Constants.enableStockholders) ?? false
        let isTimelineEnabled = appConfigRepository.getBool(Constants.enableTimeLineKey) ?? false && self.localAppConfig.isEnabledTimeline
        let isPregrantedSimulatorEnabled = appConfigRepository.getBool(Constants.enablePregrantedWidget) ?? false && self.localAppConfig.isEnabledPregranted
        let isPGTopPregrantedBannerEnable = appConfigRepository.getBool(Constants.enablePGTopPregrantedBanner) ?? false && localAppConfig.isEnabledPregranted
        let pregrantedBannerColor = appConfigRepository.getString(Constants.pregrantedBannerColor) ?? ""
        let pregrantedBannerText = appConfigRepository.getString(Constants.pregrantedBannerText) ?? ""
        let pgTopPregrantedBannerStartedText = appConfigRepository.getString(Constants.pgTopPregrantedBannerStartedText) ?? ""
        let isInsuranceEnabled = appConfigRepository.getBool(Constants.enableInsurance) ?? false
        let isWhatsNewEnabled = appConfigRepository.getBool(Constants.enableWhatsNew) ?? false
        let isEnabledAviosZone = appConfigRepository.getBool(Constants.enableAviosZone) ?? false
        let campaignsAviosZone = appConfigRepository.getAppConfigListNode(Constants.campaignsAviosZone) ?? []
        let bsanPullOffersManager = bsanManagersProvider.getBsanPullOffersManager()
        let userCampaigns = try (bsanPullOffersManager.getCampaigns().getResponseData()) ?? []
        let hasAviosProduct: Bool = {
            guard !campaignsAviosZone.isEmpty else { return false }
            return campaignsAviosZone.contains(where: { campaign in
                return userCampaigns?.contains(campaign) == true
            })
        }()
        var frequentOperatives: [PGFrequentOperativeOptionProtocol]
        if let getPGFrequentOperative: GetPGFrequentOperativeOptionProtocol = self.dependenciesResolver.resolve(forOptionalType: GetPGFrequentOperativeOptionProtocol.self) {
            frequentOperatives = getPGFrequentOperative.get(globalPositionType: globalPosition.userPref?.globalPositionOnboardingSelected())
        } else {
            frequentOperatives = self.getFrequentOperatives(userCampaigns, userpref: globalPosition.userPref)
        }
        if var savedFrequentOperativesKeys = globalPosition.userPref?.getFrequentOperativesKeys() {
            frequentOperatives.lazy
                .filter { !savedFrequentOperativesKeys.contains($0.rawValue) }
                .forEach { savedFrequentOperativesKeys.append($0.rawValue) }
            globalPosition.userPref?.setFrequentOperativesKeys(savedFrequentOperativesKeys)
            let operatives: [PGFrequentOperativeOptionProtocol] = savedFrequentOperativesKeys.compactMap { key in
                return frequentOperatives.first(where: { return key == $0.rawValue })
            }
            frequentOperatives = operatives
        }
        if globalPosition.accounts.all().count == 0 {
            frequentOperatives = frequentOperatives.filter({PGFrequentOperativeOption(rawValue: $0.rawValue) != PGFrequentOperativeOption.sendMoney})
        }
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        let pgTopCandidates = getPGTopCandidates()
        let bookmarkPullOffers = getBookmarkPullOffers()
        if let userId: String = globalPosition.userId {
            for location in requestValues.locations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        var segmentType: SegmentTypeEntity = .retail
        self.getPgUserSegment(globalPosition) { result in
            segmentType = result
        }
        let existsAccounts = !globalPosition.accountsVisiblesWithoutPiggy.isEmpty
        let isClassicOnePayCarouselEnabled = self.getEnabledSendMoneyCarouselPG(userCampaigns, appConfigConstant: Constants.enabledEnvioDineroPGClasicaNew) && existsAccounts
        let isSmartOnePayCarouselEnabled = self.getEnabledSendMoneyCarouselPG(userCampaigns, appConfigConstant: Constants.enabledEnvioDineroPGSmartNew) && existsAccounts
        let enableInsuranceDetail: Bool = appConfigRepository.getBool(Constants.appConfigInsuranceDetailEnabled) ?? false
        // RobinsonUser
        let isRobinsonUser = userCampaigns?
            .filter({ $0 == Constants.robinsonCode })
            .first != nil
        let isCarbonFootprint = isCarbonFootprintEnabled(userCampaigns)
        return .ok(
            GetPGUseCaseOkOutput(
                isPb: globalPosition.isPb ?? false,
                isSavingInsuranceBalanceAvailable: globalPositionConfiguration.isInsuranceBalanceEnabled,
                clientNameWithoutSurname: globalPosition.clientNameWithoutSurname,
                clientName: globalPosition.dto?.clientName,
                clientBirthDate: globalPosition.clientBirthDate,
                pullOfferCandidates: outputCandidates,
                visibleAccounts: globalPosition.accounts.visibles(),
                allAccounts: globalPosition.accounts.all(),
                cards: globalPosition.cards.visibles(),
                stockAccount: globalPosition.stockAccounts.visibles(),
                loans: globalPosition.loans.visibles(),
                deposits: globalPosition.deposits.visibles(),
                pensions: globalPosition.pensions.visibles(),
                funds: globalPosition.funds.visibles(),
                notManagedPortfolio: globalPosition.notManagedPortfolios.visibles(),
                managedPortfolio: globalPosition.managedPortfolios.visibles(),
                insuranceSavings: globalPosition.insuranceSavings.visibles(),
                protectionInsurances: globalPosition.protectionInsurances.visibles(),
                savingProducts: globalPosition.savingProducts.visibles(),
                baseURL: baseURLProvider.baseURL,
                totalFinance: totalFinance(for: globalPosition, configuration: globalPositionConfiguration, accountDescriptors: accountDescriptors),
                financingTotal: financingTotal(for: globalPosition, configuration: globalPositionConfiguration, accountDescriptors: accountDescriptors),
                userPref: globalPosition.userPref,
                enableMarketplace: enableMarketplace,
                isAnalysisAreaEnabled: isAnalysisAreaEnabled,
                segmentType: segmentType,
                isTimelineEnabled: isTimelineEnabled,
                isPregrantedSimulatorEnabled: isPregrantedSimulatorEnabled,
                isPGTopPregrantedBannerEnable: isPGTopPregrantedBannerEnable,
                pregrantedBannerColor: pregrantedBannerColor,
                pregrantedBannerText: pregrantedBannerText,
                pgTopPregrantedBannerStartedText: pgTopPregrantedBannerStartedText,
                isClassicOnePayCarouselEnabled: isClassicOnePayCarouselEnabled,
                isSmartOnePayCarouselEnabled: isSmartOnePayCarouselEnabled,
                isSanflixEnabled: isSanflixEnabled,
                isPublicProductEnable: isPublicProductEnable,
                isInsuranceEnabled: isInsuranceEnabled,
                isFinancingZoneEnabled: isFinancingZoneEnabled,
                enableStockholders: enableStockholders,
                isWhatsNewZoneEnabled: isWhatsNewEnabled,
                isEnabledAviosZone: isEnabledAviosZone,
                hasAviosProduct: hasAviosProduct,
                frequentOperatives: frequentOperatives,
                bookmarkPullOffers: bookmarkPullOffers,
                enableInsuranceDetail: enableInsuranceDetail,
                topCarrouselOffers: pgTopCandidates,
                isRobinsonUser: isRobinsonUser,
                isCarbonFootprintEnabled: isCarbonFootprint
            )
        )
    }
    
    private func isCarbonFootprintEnabled(_ userCampaigns: [String]?) -> Bool {
        let enableCarbonFootprint: Bool = appConfigRepository.getBool(Constants.enableCarbonFootprint) ?? false
        let carbonFootprintShow = appConfigRepository.getAppConfigListNode(Constants.carbonFootprintShow) ?? []
        let isCampaignsListEmpty = carbonFootprintShow.count == 1 && carbonFootprintShow.first == ""
        let isCarbonFootprintShowEmpty = carbonFootprintShow.isEmpty || isCampaignsListEmpty
        let isCarbonFootprintCampaign = userCampaigns?.contains(where: { item in
            item == carbonFootprintShow.filter({ $0 == item }).first ?? ""
        }) ?? false
        let showCarbonFootprint = isCarbonFootprintShowEmpty || isCarbonFootprintCampaign
        let isCarbonFootprint = enableCarbonFootprint && showCarbonFootprint
        return isCarbonFootprint
    }
    
    private func totalFinance(for globalPosition: GlobalPositionWithUserPrefsRepresentable, configuration: GlobalPositionConfiguration, accountDescriptors: [AccountDescriptorEntity]) -> Decimal? {
        var total: Decimal = 0
        let useAvailableBalance: Bool
        if let accountAvailableBalance = dependenciesResolver.resolve(forOptionalType: AccountAvailableBalanceDelegate.self), accountAvailableBalance.isEnabled() {
            useAvailableBalance = true
        } else {
            useAvailableBalance = false
        }
        if configuration.isCounterValueEnabled {
            total += globalPosition.accounts.totalCounterValueWithoutCreditAccounts(accountDescriptors: accountDescriptors, useAvailableBalance: useAvailableBalance)
            total += globalPosition.deposits.totalOfVisibles(with: \.dto.countervalueCurrentBalance)
            total += globalPosition.funds.totalOfVisibles(with: \.dto.countervalueAmount)
            total += globalPosition.stockAccounts.totalOfVisibles(with: \.dto.countervalueAmount)
            total += globalPosition.pensions.totalOfVisibles(with: \.dto.counterValueAmount)
            if configuration.isInsuranceBalanceEnabled {
                let insurancesValue = globalPosition.insuranceSavings.totalOfVisibles(with: \.dto.importeSaldoActual)
                total += insurancesValue
            }
        } else {
            guard
                let accountsValue = globalPosition.accounts.totalValueWithoutCreditAccounts(accountDescriptors: accountDescriptors, useAvailableBalance: useAvailableBalance),
                let depositsValue = globalPosition.deposits.totalOfVisiblesIfOnlyEuro(with: \.dto.balance),
                let fundsValue = globalPosition.funds.totalOfVisiblesIfOnlyEuro(with: \.dto.valueAmount),
                let stocksValue = globalPosition.stockAccounts.totalOfVisiblesIfOnlyEuro(with: \.dto.valueAmount),
                let pensionsValue = globalPosition.pensions.totalOfVisiblesIfOnlyEuro(with: \.dto.valueAmount) else { return nil }
            total += accountsValue
            total += depositsValue
            total += fundsValue
            total += stocksValue
            total += pensionsValue
            if configuration.isInsuranceBalanceEnabled {
                guard let insurancesValue = globalPosition.insuranceSavings.totalOfVisiblesIfOnlyEuro(with: \.dto.importeSaldoActual) else { return nil }
                total += insurancesValue
            }
        }
        
        guard let managedPortfoliosValue = globalPosition.managedPortfolios.totalOfVisiblesIfOnlyEuro(with: \.dto.consolidatedBalance),
              let notManagedPortfoliosValue = globalPosition.notManagedPortfolios.totalOfVisiblesIfOnlyEuro(with: \.dto.consolidatedBalance) else { return nil }
        total += managedPortfoliosValue
        total += notManagedPortfoliosValue
        total += globalPosition.cards.totalOfVisibles(value: { $0.dataDTO?.availableAmount?.value ?? $0.dataDTO?.currentBalance?.value }, where: { $0.isPrepaidCard })
        total += globalPosition.savingProducts.totalOfVisiblesIfOnlyEuro(with: \.dto.currentBalance) ?? 0
        return total
    }
    
    private func financingTotal(for globalPosition: GlobalPositionWithUserPrefsRepresentable, configuration: GlobalPositionConfiguration, accountDescriptors: [AccountDescriptorEntity]) -> Decimal? {
        var total: Decimal = 0
        let useAvailableBalance: Bool
        if let accountAvailableBalance = dependenciesResolver.resolve(forOptionalType: AccountAvailableBalanceDelegate.self), accountAvailableBalance.isEnabled() {
            useAvailableBalance = true
        } else {
            useAvailableBalance = false
        }
        if configuration.isCounterValueEnabled {
            total += globalPosition.accounts.totalCounterValueFromCreditAccounts(accountDescriptors: accountDescriptors, useAvailableBalance: useAvailableBalance)
            total += globalPosition.loans.totalOfVisibles(with: \.dto.counterValueCurrentBalanceAmount)
            total += globalPosition.cards.totalCreditBalance()
        } else {
            guard let accountsValue = globalPosition.accounts.totalValueFromCreditAccounts(accountDescriptors: accountDescriptors, useAvailableBalance: useAvailableBalance),
                  let loansValue = globalPosition.loans.totalOfVisiblesIfOnlyEuro(with: \.dto.currentBalance) else { return nil }
            total += accountsValue
            total += loansValue
            total += globalPosition.cards.totalCreditBalance()
        }
        return total
    }
}

private extension GetPGUseCase {
    func getBookmarkPullOffers() -> [(PullOfferBookmarkEntity, [OfferEntity])] {
        let bookmarksDto = pullOffersConfigRepository.getBookmarkOffers()
        let bookmarksPullOffers = bookmarksDto.compactMap { bookmarkDto -> (PullOfferBookmarkEntity, [OfferEntity])? in
            guard
                let size = Int(bookmarkDto.size ?? ""),
                size > 0,
                let offersId = bookmarkDto.offersId
            else { return nil }
            let offers = offersId.compactMap { (offerId) -> OfferEntity? in
                if let offer = pullOffersInterpreter.getValidOffer(offerId: offerId) {
                    return OfferEntity(offer)
                } else {
                    return nil
                }
            }
            guard !offers.isEmpty else { return nil }
            return (PullOfferBookmarkEntity(bookmarkDto), offers)
        }
        return bookmarksPullOffers
    }
    
    func getEnabledSendMoneyCarouselPG(_ userCampaigns: [String]?, appConfigConstant: String) -> Bool {
        let appConfigConstantEnabled = appConfigRepository.getBool(appConfigConstant) ?? false
        guard let favouritesPG = appConfigRepository.getAppConfigListNode(Constants.favouritesPGShow), !favouritesPG.isEmpty, !favouritesPG.filter({!$0.isEmpty}).isEmpty else { return appConfigConstantEnabled }
        guard
            let userCampaigns = userCampaigns,
            let existsCampaignsList = (favouritesPG.first { userCampaigns.contains($0) })
        else {
            return false
        }
        return !existsCampaignsList.isEmpty && appConfigConstantEnabled
    }
    
    func getPGTopCandidates() -> [ExpirableOfferEntity] {
        let pgTopCandidates: [ExpirableOfferEntity] = (pullOffersConfigRepository.getPGTopOffers() ?? [])
            .lazy
            .sorted(by: { return $0.priority < $1.priority })
            .compactMap { (offer) in
                guard let validOffer = pullOffersInterpreter.getValidOffer(offerId: offer.id) else { return nil }
                return ExpirableOfferEntity(validOffer,
                                            location: PullOfferLocation(stringTag: "", hasBanner: false, pageForMetrics: nil),
                                            expiresOnClick: offer.expireOnClick)
            }
        return pgTopCandidates
    }
    
    func getPgUserSegment(_ globalPosition: GlobalPositionWithUserPrefsRepresentable, completion: @escaping (SegmentTypeEntity) -> Void) {
        guard let userSegmentDelegate: UserSegmentProtocol = self.dependenciesResolver.resolve(forOptionalType: UserSegmentProtocol.self) else {
            if globalPosition.isPb == true {
                completion(.privateBanking)
            } else if globalPosition.userPref?.isSmartUser() == true {
                completion(.smart)
            } else if (try? bsanManagersProvider.getBsanUserSegmentManager().isSelectUser()) ?? false {
                completion(.select)
            } else {
                completion(.retail)
            }
            return
        }
        userSegmentDelegate.getUserSegment { result, _ in
            completion(result)
        }
    }
}

private extension GetPGUseCase {
    func getFrequentOperatives(_ userCampaigns: [String]?, userpref: UserPrefEntity?) -> [PGFrequentOperativeOption] {
        guard userpref?.globalPositionOnboardingSelected() != GlobalPositionOptionEntity.simple else {
            return PGFrequentOperativeOption.simpleDefaultOperatives
        }
        let listShortcutsPG1 = appConfigRepository.getAppConfigListNode(Constants.shortcutsPG1) ?? []
        let listShortcutsPG2 = appConfigRepository.getAppConfigListNode(Constants.shortcutsPG2) ?? []
        let listShortcutsPG3 = appConfigRepository.getAppConfigListNode(Constants.shortcutsPG3) ?? []
        let shortcuts = [listShortcutsPG1, listShortcutsPG2, listShortcutsPG3].enumerated().first {
            $0.element.first { userCampaigns?.contains($0) == true } != nil
        }
        switch shortcuts?.offset {
        case 0?:
            return PGFrequentOperativeOption.operativesForConfigurationOne
        case 1?:
            return PGFrequentOperativeOption.operativesForConfigurationTwo
        case 2?:
            return PGFrequentOperativeOption.operativesForConfigurationThree
        default:
            return PGFrequentOperativeOption.defaultOperatives
        }
    }
}

struct GetPGUseCaseInput {
    let locations: [PullOfferLocation]
}

struct GetPGUseCaseOkOutput {
    let isPb: Bool
    let isSavingInsuranceBalanceAvailable: Bool
    let clientNameWithoutSurname: String?
    let clientName: String?
    let clientBirthDate: Date?
    let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    let visibleAccounts: [AccountEntity]
    let allAccounts: [AccountEntity]
    let cards: [CardEntity]
    let stockAccount: [StockAccountEntity]
    let loans: [LoanEntity]
    let deposits: [DepositEntity]
    let pensions: [PensionEntity]
    let funds: [FundEntity]
    let notManagedPortfolio: [PortfolioEntity]
    let managedPortfolio: [PortfolioEntity]
    let insuranceSavings: [InsuranceSavingEntity]
    let protectionInsurances: [InsuranceProtectionEntity]
    let savingProducts: [SavingProductEntity]
    let baseURL: String?
    let totalFinance: Decimal?
    let financingTotal: Decimal?
    var userPref: UserPrefEntity?
    let enableMarketplace: Bool
    let isAnalysisAreaEnabled: Bool
    let segmentType: SegmentTypeEntity
    let isTimelineEnabled: Bool
    let isPregrantedSimulatorEnabled: Bool
    let isPGTopPregrantedBannerEnable: Bool
    let pregrantedBannerColor: String
    let pregrantedBannerText: String
    let pgTopPregrantedBannerStartedText: String
    let isClassicOnePayCarouselEnabled: Bool
    let isSmartOnePayCarouselEnabled: Bool
    let isSanflixEnabled: Bool
    let isPublicProductEnable: Bool
    let isInsuranceEnabled: Bool
    let isFinancingZoneEnabled: Bool
    let enableStockholders: Bool
    let isWhatsNewZoneEnabled: Bool
    let isEnabledAviosZone: Bool
    let hasAviosProduct: Bool
    let frequentOperatives: [PGFrequentOperativeOptionProtocol]?
    let bookmarkPullOffers: [(PullOfferBookmarkEntity, [OfferEntity])]
    let enableInsuranceDetail: Bool
    let topCarrouselOffers: [ExpirableOfferEntity]?
    let isRobinsonUser: Bool
    let isCarbonFootprintEnabled: Bool
}
