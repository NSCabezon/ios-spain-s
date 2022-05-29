

public struct PullOffersContainerConfigDTO: Codable {
    public let categories: [PullOffersConfigCategoryDTO]?
    public let tips: [PullOffersConfigTipDTO]?
    public let locations: [String: [String]]?
    public let securityTips: [PullOffersConfigTipDTO]?
    public let securityTravelTips: [PullOffersConfigTipDTO]?
    public let helpCenterTips: [PullOffersConfigTipDTO]?
    public let atmTips: [PullOffersConfigTipDTO]?
    public let activateCreditCardTips: [PullOffersConfigTipDTO]?
    public let activateDebitCardTips: [PullOffersConfigTipDTO]?
    public let cardBoardingWelcomeCreditCardTips: [PullOffersConfigTipDTO]?
    public let cardBoardingWelcomeDebitCardTips: [PullOffersConfigTipDTO]?
    public let publicProducts: [PullOffersConfigTipDTO]?
    public let santanderExperiences: [PullOffersConfigTipDTO]?
    public let actionsTips: [PullOffersConfigTipDTO]?
    public let homeTips: [PullOfferHomeTipDTO]?
    public let interestTips: [PullOffersConfigTipDTO]?
    public let offersBookmarksPG: [PullOffersConfigBookmarkDTO]?
    public let cardBoardingAlmostFinishedCreditTips: [PullOffersConfigTipDTO]?
    public let cardBoardingAlmostFinishedDebitTips: [PullOffersConfigTipDTO]?
    public let pgTopOffers: [CarouselOffersInfoDTO]?
    public let accountTopOffers: [CarouselOffersInfoDTO]?
    public let analysisFinancialCushionHelp: [PullOffersConfigRangesDTO]?
    public let analysisFinancialBudgetHelp: [PullOffersConfigBudgetDTO]?
    public let financingCommercialOffers: PullOffersFinanceableCommercialOfferDTO?
}
