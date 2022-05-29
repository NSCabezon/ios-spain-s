import CoreDomain

public struct PullOffersConfigRepository: BaseRepository {
    public typealias T = PullOffersConfigDTO
    public let datasource: FullDataSource<PullOffersConfigDTO, CodableParser<PullOffersConfigDTO>>
    
    public init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "pull_offers_configV4.json")
        let parser = CodableParser<PullOffersConfigDTO>()
        datasource = FullDataSource<PullOffersConfigDTO, CodableParser<PullOffersConfigDTO>>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension PullOffersConfigRepository: PullOffersConfigRepositoryProtocol {
    public func getPublicCarouselOffers() -> [PullOffersConfigTipDTO] {
        return self.get()?.pullOffersConfig.publicProducts ?? []
    }
    
    public func getActionTipsOffers() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.actionsTips
    }
    
    public func getHomeTipsOffers() -> [PullOfferHomeTipDTO]? {
        return self.get()?.pullOffersConfig.homeTips
    }
    
    public func getLocations() -> [String: [String]]? {
        return self.get()?.pullOffersConfig.locations
    }
    
    public func getBookmarkOffers() -> [PullOffersConfigBookmarkDTO] {
        return self.get()?.pullOffersConfig.offersBookmarksPG ?? []
    }
    
    public func getHomeTips() -> [PullOffersHomeTipsDTO]? {
        return self.get()?.homeTips
    }
    
    public func getInterestTipsOffers() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.interestTips
    }
    
    public func getPGTopOffers() -> [CarouselOffersInfoDTO]? {
        return self.get()?.pullOffersConfig.pgTopOffers
    }
    
    public func getAccountTopOffers() -> [CarouselOffersInfoDTO]? {
        return self.get()?.pullOffersConfig.accountTopOffers
    }
    
    public func getAnalysisFinancialCushionHelp() -> [PullOffersConfigRangesDTO]? {
        return self.get()?.pullOffersConfig.analysisFinancialCushionHelp
    }
    
    public func getAnalysisFinancialBudgetHelp() -> [PullOffersConfigBudgetDTO]? {
        return self.get()?.pullOffersConfig.analysisFinancialBudgetHelp
    }
    
    public func getTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.tips
    }
    
    public func getSecurityTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.securityTips
    }
    
    public func getSecurityTravelTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.securityTravelTips
    }
    
    public func getHelpCenterTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.helpCenterTips
    }
    
    public func getAtmTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.atmTips
    }
    
    public func getActivateCreditCardTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.activateCreditCardTips
    }
    
    public func getActivateDebitCardTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.activateDebitCardTips
    }
    
    public func getCardBoardingWelcomeCreditCardTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.cardBoardingWelcomeCreditCardTips
    }
    
    public func getCardBoardingWelcomeDebitCardTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.cardBoardingWelcomeDebitCardTips
    }
    
    public func getSantanderExperiences() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.santanderExperiences
    }
    
    public func getCardBoardingAlmostDoneCreditTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.cardBoardingAlmostFinishedCreditTips
    }
    
    public func getCardBoardingAlmostDoneDebitTips() -> [PullOffersConfigTipDTO]? {
        return self.get()?.pullOffersConfig.cardBoardingAlmostFinishedDebitTips
    }
    
    public func getFinancingCommercialOffers() -> PullOffersFinanceableCommercialOfferDTO? {
        return self.get()?.pullOffersConfig.financingCommercialOffers
    }
}
