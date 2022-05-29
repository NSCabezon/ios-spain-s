import CoreDomain
import OpenCombine

public struct UserPrefEntity {
    public var userPrefDTOEntity: UserPrefDTOEntity
    private let subject = CurrentValueSubject<String?, Never>(nil)

    public static func from(dto: UserPrefDTOEntity) -> UserPrefEntity {
        return UserPrefEntity(userPrefDTO: dto)
    }

    init(userPrefDTO: UserPrefDTOEntity) {
        self.userPrefDTOEntity = userPrefDTO
    }

    public var userId: String {
        return userPrefDTOEntity.userId
    }

    public func isPb() -> Bool {
        return userPrefDTOEntity.isUserPb
    }
    
    public func isSmartUser() -> Bool {
        return userPrefDTOEntity.isSmartUser
    }

    public func isAccountBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.account]?.isOpen ?? false
    }

    public func isCardBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.card]?.isOpen ?? false
    }
    
    public func isSavingProductBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.savingProduct]?.isOpen ?? false
    }

    public func isLoanBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.loan]?.isOpen ?? false
    }

    public func isDepositBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.deposit]?.isOpen ?? false
    }

    public func isStockBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.stock]?.isOpen ?? false
    }

    public func isFundsBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.fund]?.isOpen ?? false
    }

    public func isPensionsBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.pension]?.isOpen ?? false
    }

    public func isPortfolioManagedBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.managedPortfolio]?.isOpen ?? false
    }

    public func isPortfolioNotManagedBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.notManagedPortfolio]?.isOpen ?? false
    }

    public func isInsuranceSavingBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.insuranceSaving]?.isOpen ?? false
    }

    public func isInsuranceProtectionBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.insuranceProtection]?.isOpen ?? false
    }

    public func isPortfolioManagedVariableIncomeBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.managedPortfolioVariableIncome]?.isOpen ?? false
    }

    public func isPortfolioNotManagedVariableIncomeBoxOpen() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.boxes[.notManagedPortfolioVariableIncome]?.isOpen ?? false
    }
    
    public func getStatusBoxCollapsed() -> [ProductTypeEntity: Bool] {
        return [
            .account: isAccountBoxOpen(),
            .card: isCardBoxOpen(),
            .managedPortfolio: isPortfolioManagedBoxOpen(),
            .notManagedPortfolio: isPortfolioNotManagedBoxOpen(),
            .deposit: isDepositBoxOpen(),
            .savingProduct: isSavingProductBoxOpen(),
            .loan: isLoanBoxOpen(),
            .stockAccount: isStockBoxOpen(),
            .pension: isPensionsBoxOpen(),
            .fund: isFundsBoxOpen(),
            .insuranceSaving: isInsuranceSavingBoxOpen(),
            .insuranceProtection: isInsuranceProtectionBoxOpen()
        ]
    }
    
    public func getBoxesOrder() -> [UserPrefBoxType] {
        return userPrefDTOEntity.pgUserPrefDTO.sortedProducts.map({$0.0})
    }
    
    public func getFavoriteContacts() -> [String]? {
        return userPrefDTOEntity.pgUserPrefDTO.favoriteContacts
    }
    
    public func getOnboardingFinished() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.onboardingFinished
    }
    
    public func setOnboardingFinished(_ value: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.onboardingFinished = value
    }
    
    public func globalPositionOnboardingSelected() -> GlobalPositionOptionEntity {
        return GlobalPositionOptionEntity(rawValue: userPrefDTOEntity.pgUserPrefDTO.globalPositionOptionSelected) ?? .classic
    }
    
    public func photoThemeOnboardingSelected() -> Int? {
        if let photoThemeSelected = userPrefDTOEntity.pgUserPrefDTO.photoThemeOptionSelected {
            return photoThemeSelected
        } else {
            return nil
        }
    }
    
    public func photoThemePersonalAreaSelected() -> Int {
        if let photoThemeSelected = userPrefDTOEntity.pgUserPrefDTO.photoThemeOptionSelected {
            return photoThemeSelected
        } else {
            return BackgroundImagesTheme.defaultTheme
        }
    }

    public func isDiscretModeActivated() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.discreteMode
    }

    public func isChartModeActivated() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.chartMode
    }
    
    public func getUserAlias() -> String? {
        return userPrefDTOEntity.pgUserPrefDTO.alias
    }
    
    public func getReactiveUserAlias() -> AnyPublisher<String, Never> {
        subject
            .compactMap { alias -> String in
                return alias ?? userPrefDTOEntity.pgUserPrefDTO.alias
            }
            .eraseToAnyPublisher()
    }
    
    public func isEmailConfigured() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.emailConfigured
    }
    
    public func isPhoneConfigured() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.phoneConfigured
    }
    
    public func setPb(isPb: Bool) {
        userPrefDTOEntity.isUserPb = isPb
    }

    public func setAccountBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.account]?.isOpen = isOpen
    }

    public func setCardBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.card]?.isOpen = isOpen
    }
    
    public func setSavingProductBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.savingProduct]?.isOpen = isOpen
    }

    public func setLoanBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.loan]?.isOpen = isOpen
    }

    public func setDepositBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.deposit]?.isOpen = isOpen
    }

    public func setStockBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.stock]?.isOpen = isOpen
    }

    public func setFundsBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.fund]?.isOpen = isOpen
    }

    public func setPensionsBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.pension]?.isOpen = isOpen
    }

    public func setPortfolioManagedBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.managedPortfolio]?.isOpen = isOpen
    }

    public func setPortfolioNotManagedBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.notManagedPortfolio]?.isOpen = isOpen
    }

    public func setInsuranceSavingBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.insuranceSaving]?.isOpen = isOpen
    }

    public func setInsuranceProtectionBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.insuranceProtection]?.isOpen = isOpen
    }

    public func setPortfolioManagedVariableIncomeBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.managedPortfolioVariableIncome]?.isOpen = isOpen
    }

    public func setPortfolioNotManagedVariableIncomeBoxOpen(isOpen: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.boxes[.notManagedPortfolioVariableIncome]?.isOpen = isOpen
    }

    public func setGlobalPositionOnboardingSelected(pgSelected: GlobalPositionOptionEntity) {
        userPrefDTOEntity.pgUserPrefDTO.globalPositionOptionSelected = pgSelected.rawValue
    }

    public func setPhotoThemeOnboardingSelected(photoThemeOptionSelected: PhotoThemeOptionEntity) {
        userPrefDTOEntity.pgUserPrefDTO.photoThemeOptionSelected = photoThemeOptionSelected.rawValue
    }
    
    public func setDiscreteMode(discreteModeIsOn: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.discreteMode = discreteModeIsOn
    }
    
    public func setChartMode(chartModeIsOn: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.chartMode = chartModeIsOn
    }
    
    public func setPGColorMode(pgColorMode: PGColorMode) {
        userPrefDTOEntity.pgUserPrefDTO.pgColorMode = pgColorMode
    }
    
    public func setUserAlias(_ alias: String) {
        subject.send(alias)
        return userPrefDTOEntity.pgUserPrefDTO.alias = alias
    }
    
    public func emailConfigured(_ configured: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.emailConfigured = configured
    }
    
    public func phoneConfigured(_ configured: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.phoneConfigured = configured
    }
    
    public func getPGColorMode() -> PGColorMode {
        return userPrefDTOEntity.pgUserPrefDTO.pgColorMode
    }
    
    public func setFrequentOperativesKeys(_ frequentOperativesKeys: [String]) {
        userPrefDTOEntity.pgUserPrefDTO.frequentOperativesKeys = frequentOperativesKeys
    }
    
    public func getFrequentOperativesKeys() -> [String]? {
        return userPrefDTOEntity.pgUserPrefDTO.frequentOperativesKeys
    }
    
    public func getTrips() -> [TripEntity]? {
        return userPrefDTOEntity.pgUserPrefDTO.currentTrips
    }
    
    public func setTrips(_ trips: [TripEntity]?) {
        userPrefDTOEntity.pgUserPrefDTO.currentTrips = trips
    }
    
    public func setBudget(_ budget: Double) {
        return userPrefDTOEntity.pgUserPrefDTO.budget = budget
    }
    
    public func getBudget() -> Double? {
        return userPrefDTOEntity.pgUserPrefDTO.budget
    }
    
    public func getTripModeVisited() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.isTripModeVisited
    }
    
    public func setTripModeVisited() {
        return userPrefDTOEntity.pgUserPrefDTO.isTripModeVisited = true
    }
    
    public func getFirstTimeBiometricCredentialActivated() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.isFirstTimeBiometricCredentialActivated
    }
    
    public func setFirstTimeBiometricCredentialActive() {
        userPrefDTOEntity.pgUserPrefDTO.isFirstTimeBiometricCredentialActivated = true
    }
    
    public func getOnboardingCancelled() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.onboardingCancelled
    }
    
    public func setOnboardingCancelled(_ value: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.onboardingCancelled = value
    }
    
    public func getAskedForBiometricPermissions() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.askedForBiometricPermissions
    }
    
    public func setAskedForBiometricPermissions(_ value: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.askedForBiometricPermissions = value
    }
    
    public func getOtpPushBetaFinished() -> Bool {
        return userPrefDTOEntity.pgUserPrefDTO.otpPushBetaFinished
    }
    
    public func setOtpPushBetaFinished(_ value: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.otpPushBetaFinished = value
    }
    
    public func getWhatsNewCounter() -> Int {
        return userPrefDTOEntity.pgUserPrefDTO.whatsNewCounter
    }
    
    public func setWhatsNewCounter(_ newCounter: Int) {
        userPrefDTOEntity.pgUserPrefDTO.whatsNewCounter = newCounter
    }
        
    public func isWhatsNewBubbleEnabled() -> Bool {
        let counter = userPrefDTOEntity.pgUserPrefDTO.whatsNewCounter
        return counter <= 5
    }
    
    public func setWhatsNewBigBubbleVisible(_ status: Bool) {
        userPrefDTOEntity.pgUserPrefDTO.whatsNewBigBubbleVisibled = status
    }
    
    public func isWhatsNewBigBubbleVisible() -> Bool {
        return isWhatsNewBubbleEnabled() && !userPrefDTOEntity.pgUserPrefDTO.whatsNewBigBubbleVisibled
    }
    
    public func setTransitiveAppIcon(_ appIcon: AppIconEntity) {
        userPrefDTOEntity.pgUserPrefDTO.transitiveAppIcon = appIcon
    }
    
    public func getTransitiveAppIcon() -> AppIconEntity? {
        return userPrefDTOEntity.pgUserPrefDTO.transitiveAppIcon
    }
}

extension UserPrefEntity: UserPreferencesRepresentable {
    public func getTrips() -> [TripRepresentable]? {
        return userPrefDTOEntity.pgUserPrefDTO.currentTrips
    }
    
    public func setTrips(_ trips: [TripRepresentable]?) {
        let tripsEntity = trips?.compactMap { TripEntity(country: CountryEntity(
            code: $0.tripCountry.code,
            currency: $0.tripCountry.currency,
            name: $0.tripCountry.name,
            embassyTitle: $0.tripCountry.embassyTitle,
            embassyAddress: $0.tripCountry.embassyAddress,
            embassyTitleTelephone: $0.tripCountry.embassyTitleTelephone,
            embassyTelephone: $0.tripCountry.embassyTelephone,
            embassyTitleConsular: $0.tripCountry.embassyTitleConsular,
            embassyTelephoneConsularEmergency: $0.tripCountry.embassyTelephoneConsularEmergency),
                                                         fromDate: $0.fromDate,
                                                         toDate: $0.toDate,
                                                         currencies: $0.currencies,
                                                         tripReason: $0.tripReason)}
        userPrefDTOEntity.pgUserPrefDTO.currentTrips = tripsEntity
    }
    
    public func setTransitiveAppIcon(_ appIcon: AppIconRepresentable) {
        userPrefDTOEntity.pgUserPrefDTO.transitiveAppIcon = AppIconEntity(startDate: appIcon.startDate,
                                                                          endDate: appIcon.endDate,
                                                                          iconName: appIcon.iconName)
    }
    
    public func getTransitiveAppIcon() -> AppIconRepresentable? {
        return userPrefDTOEntity.pgUserPrefDTO.transitiveAppIcon
    }
    
    public var boxesRepresentable: [UserPrefBoxType: PGBoxRepresentable] {
        return userPrefDTOEntity.pgUserPrefDTO.boxesRepresentable
    }
    
    public var isPrivateMenuCoachManagerShown: Bool {
        get {
            return userPrefDTOEntity.pgUserPrefDTO.isPrivateMenuCoachManagerShown
        }
        set(newValue) {
            userPrefDTOEntity.pgUserPrefDTO.isPrivateMenuCoachManagerShown = newValue
        }
    }
}
