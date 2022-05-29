import CoreDomain
import OpenCombine

struct MockUserPreferencesRepresentable: UserPreferencesRepresentable {
    func getReactiveUserAlias() -> AnyPublisher<String, Never> {
        Just("").eraseToAnyPublisher()
    }
    
    var isPrivateMenuCoachManagerShown: Bool
    
    var boxesRepresentable: [UserPrefBoxType: PGBoxRepresentable] = [:]
    var userId: String = "userId"
    
    func isPb() -> Bool {
        return false
    }
    
    func isSmartUser() -> Bool {
        return false
    }
    
    func isAccountBoxOpen() -> Bool {
        return false
    }
    
    func isCardBoxOpen() -> Bool {
        return false
    }
    
    func isLoanBoxOpen() -> Bool {
        return false
    }
    
    func isDepositBoxOpen() -> Bool {
        return false
    }
    
    func isStockBoxOpen() -> Bool {
        return false
    }
    
    func isFundsBoxOpen() -> Bool {
        return false
    }
    
    func isPensionsBoxOpen() -> Bool {
        return false
    }
    
    func isPortfolioManagedBoxOpen() -> Bool {
        return false
    }
    
    func isPortfolioNotManagedBoxOpen() -> Bool {
        return false
    }
    
    func isInsuranceSavingBoxOpen() -> Bool {
        return false
    }
    
    func isInsuranceProtectionBoxOpen() -> Bool {
        return false
    }
    
    func isPortfolioManagedVariableIncomeBoxOpen() -> Bool {
        return false
    }
    
    func isPortfolioNotManagedVariableIncomeBoxOpen() -> Bool {
        return false
    }
    
    func getStatusBoxCollapsed() -> [ProductTypeEntity : Bool] {
        return [:]
    }
    
    func getBoxesOrder() -> [UserPrefBoxType] {
        return []
    }
    
    func getFavoriteContacts() -> [String]? {
        return nil
    }
    
    func getOnboardingFinished() -> Bool {
        return false
    }
    
    func setOnboardingFinished(_ value: Bool) { }
    
    func globalPositionOnboardingSelected() -> GlobalPositionOptionEntity {
        return .classic
    }
    
    func photoThemeOnboardingSelected() -> Int? {
        return nil
    }
    
    func photoThemePersonalAreaSelected() -> Int {
        return 1
    }
    
    func isDiscretModeActivated() -> Bool {
        return false
    }
    
    func isChartModeActivated() -> Bool {
        return false
    }
    
    func getUserAlias() -> String? {
        return nil
    }
    
    func isEmailConfigured() -> Bool {
        return false
    }
    
    func isPhoneConfigured() -> Bool {
        return false
    }

    func isSavingProductBoxOpen() -> Bool {
        return false
    }

    func setSavingProductBoxOpen(isOpen: Bool) {}

    
    func setPb(isPb: Bool) { }
    
    func setAccountBoxOpen(isOpen: Bool) { }
    
    func setCardBoxOpen(isOpen: Bool) { }
    
    func setLoanBoxOpen(isOpen: Bool) { }
    
    func setDepositBoxOpen(isOpen: Bool) { }
    
    func setStockBoxOpen(isOpen: Bool) { }
    
    func setFundsBoxOpen(isOpen: Bool) { }
    
    func setPensionsBoxOpen(isOpen: Bool) { }
    
    func setPortfolioManagedBoxOpen(isOpen: Bool) { }
    
    func setPortfolioNotManagedBoxOpen(isOpen: Bool) { }
    
    func setInsuranceSavingBoxOpen(isOpen: Bool) { }
    
    func setInsuranceProtectionBoxOpen(isOpen: Bool) { }
    
    func setPortfolioManagedVariableIncomeBoxOpen(isOpen: Bool) { }
    
    func setPortfolioNotManagedVariableIncomeBoxOpen(isOpen: Bool) { }
    
    func setGlobalPositionOnboardingSelected(pgSelected: GlobalPositionOptionEntity) { }
    
    func setPhotoThemeOnboardingSelected(photoThemeOptionSelected: PhotoThemeOptionEntity) { }
    
    func setDiscreteMode(discreteModeIsOn: Bool) { }
    
    func setChartMode(chartModeIsOn: Bool) { }
    
    func setPGColorMode(pgColorMode: PGColorMode) { }
    
    func setUserAlias(_ alias: String) { }
    
    func emailConfigured(_ configured: Bool) { }
    
    func phoneConfigured(_ configured: Bool) { }
    
    func getPGColorMode() -> PGColorMode {
        return .red
    }
    
    func setFrequentOperativesKeys(_ frequentOperativesKeys: [String]) { }
    
    func getFrequentOperativesKeys() -> [String]? {
        return nil
    }
    
    func getTrips() -> [TripRepresentable]? {
        return nil
    }
    
    func setTrips(_ trips: [TripRepresentable]?) { }
    
    func setBudget(_ budget: Double) { }
    
    func getBudget() -> Double? {
        return 2.0
    }
    
    func getTripModeVisited() -> Bool {
        return false
    }
    
    func setTripModeVisited() { }
    
    func getFirstTimeBiometricCredentialActivated() -> Bool {
        return false
    }
    
    func setFirstTimeBiometricCredentialActive() { }
    
    func getOnboardingCancelled() -> Bool {
        return false
    }
    
    func setOnboardingCancelled(_ value: Bool) { }
    
    func getAskedForBiometricPermissions() -> Bool {
        return false
    }
    
    func setAskedForBiometricPermissions(_ value: Bool) { }
    
    func getOtpPushBetaFinished() -> Bool {
        return false
    }
    
    func setOtpPushBetaFinished(_ value: Bool) { }
    
    func getWhatsNewCounter() -> Int {
        return 1
    }
    
    func setWhatsNewCounter(_ newCounter: Int) { }
    
    func isWhatsNewBubbleEnabled() -> Bool {
        return false
    }
    
    func setWhatsNewBigBubbleVisible(_ status: Bool) { }
    
    func isWhatsNewBigBubbleVisible() -> Bool {
        return false
    }
    
    func setTransitiveAppIcon(_ appIcon: AppIconRepresentable) { }
    
    func getTransitiveAppIcon() -> AppIconRepresentable? {
        return nil
    }
}
