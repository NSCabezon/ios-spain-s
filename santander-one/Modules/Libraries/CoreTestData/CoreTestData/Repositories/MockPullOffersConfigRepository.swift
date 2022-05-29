import CoreFoundationLib

public final class MockPullOffersConfigRepository {
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func getPullOffers() -> PullOffersConfigDTO {
        return self.mockDataInjector.mockDataProvider.pullOffersConfig.getPullOffersConfig
    }    
}

extension MockPullOffersConfigRepository: PullOffersConfigRepositoryProtocol {
    public func getAccountTopOffers() -> [CarouselOffersInfoDTO]? {
        return getPullOffers().pullOffersConfig.accountTopOffers
    }
    
    public func getPublicCarouselOffers() -> [PullOffersConfigTipDTO] {
        return getPullOffers().pullOffersConfig.publicProducts ?? []
    }
    
    public func getActionTipsOffers() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.actionsTips ?? []
    }
    
    public func getHomeTipsOffers() -> [PullOfferHomeTipDTO]? {
        return getPullOffers().pullOffersConfig.homeTips ?? []
    }
    
    public func getLocations() -> [String : [String]]? {
        return getPullOffers().pullOffersConfig.locations ?? [:]
    }
    
    public func getBookmarkOffers() -> [PullOffersConfigBookmarkDTO] {
        return getPullOffers().pullOffersConfig.offersBookmarksPG ?? []
    }
    
    public func getHomeTips() -> [PullOffersHomeTipsDTO]? {
        return getPullOffers().homeTips ?? []
    }
    
    public func getInterestTipsOffers() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.interestTips ?? []
    }
    
    public func getPGTopOffers() -> [CarouselOffersInfoDTO]? {
        return getPullOffers().pullOffersConfig.pgTopOffers
    }
    
    public func getAnalysisFinancialCushionHelp() -> [PullOffersConfigRangesDTO]? {
        return getPullOffers().pullOffersConfig.analysisFinancialCushionHelp
    }
    
    public func getAnalysisFinancialBudgetHelp() -> [PullOffersConfigBudgetDTO]? {
        return getPullOffers().pullOffersConfig.analysisFinancialBudgetHelp
    }

    public func getSecurityTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.securityTips
    }

    public func getSecurityTravelTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.securityTravelTips
    }

    public func getHelpCenterTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.helpCenterTips
    }

    public func getAtmTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.atmTips
    }

    public func getActivateCreditCardTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.activateCreditCardTips
    }

    public func getActivateDebitCardTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.activateDebitCardTips
    }

    public func getCardBoardingWelcomeCreditCardTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.cardBoardingWelcomeCreditCardTips
    }

    public func getCardBoardingWelcomeDebitCardTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.cardBoardingWelcomeDebitCardTips
    }

    public func getSantanderExperiences() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.santanderExperiences
    }

    public func getCardBoardingAlmostDoneCreditTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.cardBoardingAlmostFinishedCreditTips
    }

    public func getCardBoardingAlmostDoneDebitTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.cardBoardingAlmostFinishedDebitTips
    }

    public func getTips() -> [PullOffersConfigTipDTO]? {
        return getPullOffers().pullOffersConfig.tips
    }
    
    public func getFinancingCommercialOffers() -> PullOffersFinanceableCommercialOfferDTO? {
        return getPullOffers().pullOffersConfig.financingCommercialOffers
    }
}

public struct PullOffersConfigDTO: Codable {
    let pullOffersConfig: PullOffersContainerConfigDTO
    let homeTips: [PullOffersHomeTipsDTO]?
    let interestTips: [PullOffersHomeTipsDTO]?

    public init(pullOffersConfig: PullOffersContainerConfigDTO, homeTips: [PullOffersHomeTipsDTO]?, interestTips: [PullOffersHomeTipsDTO]?) {
        self.pullOffersConfig = pullOffersConfig
        self.homeTips = homeTips
        self.interestTips = interestTips
    }
    
    init() {
        self.pullOffersConfig = PullOffersContainerConfigDTO()
        self.homeTips = nil
        self.interestTips = nil
    }
}

public struct PullOffersContainerConfigDTO: Codable {
    let categories: [PullOffersConfigCategoryDTO]?
    let tips: [PullOffersConfigTipDTO]?
    let locations: [String: [String]]?
    let securityTips: [PullOffersConfigTipDTO]?
    let securityTravelTips: [PullOffersConfigTipDTO]?
    let helpCenterTips: [PullOffersConfigTipDTO]?
    let atmTips: [PullOffersConfigTipDTO]?
    let activateCreditCardTips: [PullOffersConfigTipDTO]?
    let activateDebitCardTips: [PullOffersConfigTipDTO]?
    let cardBoardingWelcomeCreditCardTips: [PullOffersConfigTipDTO]?
    let cardBoardingWelcomeDebitCardTips: [PullOffersConfigTipDTO]?
    let publicProducts: [PullOffersConfigTipDTO]?
    let santanderExperiences: [PullOffersConfigTipDTO]?
    let actionsTips: [PullOffersConfigTipDTO]?
    let homeTips: [PullOfferHomeTipDTO]?
    let interestTips: [PullOffersConfigTipDTO]?
    let offersBookmarksPG: [PullOffersConfigBookmarkDTO]?
    let cardBoardingAlmostFinishedCreditTips: [PullOffersConfigTipDTO]?
    let cardBoardingAlmostFinishedDebitTips: [PullOffersConfigTipDTO]?
    let pgTopOffers: [CarouselOffersInfoDTO]?
    let accountTopOffers: [CarouselOffersInfoDTO]?
    let analysisFinancialCushionHelp: [PullOffersConfigRangesDTO]?
    let analysisFinancialBudgetHelp: [PullOffersConfigBudgetDTO]?
    let financingCommercialOffers: PullOffersFinanceableCommercialOfferDTO?
    
    public init(categories: [PullOffersConfigCategoryDTO]?, tips: [PullOffersConfigTipDTO]?, locations: [String : [String]]?, securityTips: [PullOffersConfigTipDTO]?, securityTravelTips: [PullOffersConfigTipDTO]?, helpCenterTips: [PullOffersConfigTipDTO]?, atmTips: [PullOffersConfigTipDTO]?, activateCreditCardTips: [PullOffersConfigTipDTO]?, activateDebitCardTips: [PullOffersConfigTipDTO]?, cardBoardingWelcomeCreditCardTips: [PullOffersConfigTipDTO]?, cardBoardingWelcomeDebitCardTips: [PullOffersConfigTipDTO]?, publicProducts: [PullOffersConfigTipDTO]?, santanderExperiences: [PullOffersConfigTipDTO]?, actionsTips: [PullOffersConfigTipDTO]?, homeTips: [PullOfferHomeTipDTO]?, interestTips: [PullOffersConfigTipDTO]?, offersBookmarksPG: [PullOffersConfigBookmarkDTO]?, cardBoardingAlmostFinishedCreditTips: [PullOffersConfigTipDTO]?, cardBoardingAlmostFinishedDebitTips: [PullOffersConfigTipDTO]?, pgTopOffers: [CarouselOffersInfoDTO]?, accountTopOffers: [CarouselOffersInfoDTO]?, analysisFinancialCushionHelp: [PullOffersConfigRangesDTO]?, analysisFinancialBudgetHelp: [PullOffersConfigBudgetDTO]?, financingCommercialOffers: PullOffersFinanceableCommercialOfferDTO?) {
        self.categories = categories
        self.tips = tips
        self.locations = locations
        self.securityTips = securityTips
        self.securityTravelTips = securityTravelTips
        self.helpCenterTips = helpCenterTips
        self.atmTips = atmTips
        self.activateCreditCardTips = activateCreditCardTips
        self.activateDebitCardTips = activateDebitCardTips
        self.cardBoardingWelcomeCreditCardTips = cardBoardingWelcomeCreditCardTips
        self.cardBoardingWelcomeDebitCardTips = cardBoardingWelcomeDebitCardTips
        self.publicProducts = publicProducts
        self.santanderExperiences = santanderExperiences
        self.actionsTips = actionsTips
        self.homeTips = homeTips
        self.interestTips = interestTips
        self.offersBookmarksPG = offersBookmarksPG
        self.cardBoardingAlmostFinishedCreditTips = cardBoardingAlmostFinishedCreditTips
        self.cardBoardingAlmostFinishedDebitTips = cardBoardingAlmostFinishedDebitTips
        self.pgTopOffers = pgTopOffers
        self.accountTopOffers = accountTopOffers
        self.analysisFinancialCushionHelp = analysisFinancialCushionHelp
        self.analysisFinancialBudgetHelp = analysisFinancialBudgetHelp
        self.financingCommercialOffers = financingCommercialOffers
    }
    
    init() {
        self.init(
            categories: nil,
            tips: nil,
            locations: nil,
            securityTips: nil,
            securityTravelTips: nil,
            helpCenterTips: nil,
            atmTips: nil,
            activateCreditCardTips: nil,
            activateDebitCardTips: nil,
            cardBoardingWelcomeCreditCardTips: nil,
            cardBoardingWelcomeDebitCardTips: nil,
            publicProducts: nil,
            santanderExperiences: nil,
            actionsTips: nil,
            homeTips: nil,
            interestTips: nil,
            offersBookmarksPG: nil,
            cardBoardingAlmostFinishedCreditTips: nil,
            cardBoardingAlmostFinishedDebitTips: nil,
            pgTopOffers: nil,
            accountTopOffers: nil,
            analysisFinancialCushionHelp: nil,
            analysisFinancialBudgetHelp: nil,
            financingCommercialOffers: nil
        )
    }
}
