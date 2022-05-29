
public protocol PullOffersConfigRepositoryProtocol {
    func getPublicCarouselOffers() -> [PullOffersConfigTipDTO]
    func getActionTipsOffers() -> [PullOffersConfigTipDTO]?
    func getHomeTipsOffers() -> [PullOfferHomeTipDTO]?
    func getLocations() -> [String: [String]]?
    func getBookmarkOffers() -> [PullOffersConfigBookmarkDTO]
    func getHomeTips() -> [PullOffersHomeTipsDTO]?
    func getInterestTipsOffers() -> [PullOffersConfigTipDTO]?
    func getTips() -> [PullOffersConfigTipDTO]?
    func getSecurityTips() -> [PullOffersConfigTipDTO]?
    func getSecurityTravelTips() -> [PullOffersConfigTipDTO]?
    func getHelpCenterTips() -> [PullOffersConfigTipDTO]?
    func getAtmTips() -> [PullOffersConfigTipDTO]?
    func getActivateCreditCardTips() -> [PullOffersConfigTipDTO]?
    func getActivateDebitCardTips() -> [PullOffersConfigTipDTO]?
    func getCardBoardingWelcomeCreditCardTips() -> [PullOffersConfigTipDTO]?
    func getCardBoardingWelcomeDebitCardTips() -> [PullOffersConfigTipDTO]?
    func getSantanderExperiences() -> [PullOffersConfigTipDTO]?
    func getCardBoardingAlmostDoneCreditTips() -> [PullOffersConfigTipDTO]?
    func getCardBoardingAlmostDoneDebitTips() -> [PullOffersConfigTipDTO]?
    func getPGTopOffers() -> [CarouselOffersInfoDTO]?
    func getAccountTopOffers() -> [CarouselOffersInfoDTO]?
    func getAnalysisFinancialCushionHelp() -> [PullOffersConfigRangesDTO]?
    func getAnalysisFinancialBudgetHelp() -> [PullOffersConfigBudgetDTO]?
    func getFinancingCommercialOffers() -> PullOffersFinanceableCommercialOfferDTO?
}
