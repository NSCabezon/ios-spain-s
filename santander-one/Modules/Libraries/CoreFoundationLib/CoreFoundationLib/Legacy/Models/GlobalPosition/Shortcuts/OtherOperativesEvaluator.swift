public protocol OtherOperativesEvaluator {
    var isSmartGP: Bool? { get }
    func isAnalysisDisabled() -> Bool
    func isFinancingZoneDisabled() -> Bool
    func isConsultPinEnabled() -> Bool
    func isVisibleAccountsEmpty() -> Bool
    func isAllAccountsEmpty() -> Bool
    func isCardsMenuEmpty() -> Bool
    func isSmartUser() -> Bool
    func isEnableMarketplace() -> Bool
    func isLocationEnabled(_ location: String) -> Bool
    func getOffer(forLocation location: String) -> PullOfferCompleteInfo?
    func isSanflixEnabled() -> Bool
    func isPublicProductEnable() -> Bool
    func getFrequentOperatives() -> [PGFrequentOperativeOptionProtocol]?
    func isStockholdersEnable() -> Bool
    func hasTwoOrMoreAccounts() -> Bool
    func isCarbonFootprintDisable() -> Bool
}
