//
//  UserPreferences.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 27/12/21.
//
import OpenCombine

public protocol UserPreferencesRepresentable {
    var userId: String { get }
    func isPb() -> Bool
    func isSmartUser() -> Bool
    func isAccountBoxOpen() -> Bool
    func isCardBoxOpen() -> Bool
    func isSavingProductBoxOpen() -> Bool
    func isLoanBoxOpen() -> Bool
    func isDepositBoxOpen() -> Bool
    func isStockBoxOpen() -> Bool
    func isFundsBoxOpen() -> Bool
    func isPensionsBoxOpen() -> Bool
    func isPortfolioManagedBoxOpen() -> Bool
    func isPortfolioNotManagedBoxOpen() -> Bool
    func isInsuranceSavingBoxOpen() -> Bool
    func isInsuranceProtectionBoxOpen() -> Bool
    func isPortfolioManagedVariableIncomeBoxOpen() -> Bool
    func isPortfolioNotManagedVariableIncomeBoxOpen() -> Bool
    func getStatusBoxCollapsed() -> [ProductTypeEntity: Bool]
    func getBoxesOrder() -> [UserPrefBoxType]
    func getFavoriteContacts() -> [String]?
    func getOnboardingFinished() -> Bool
    func setOnboardingFinished(_ value: Bool)
    func globalPositionOnboardingSelected() -> GlobalPositionOptionEntity
    func photoThemeOnboardingSelected() -> Int?
    func photoThemePersonalAreaSelected() -> Int
    func isDiscretModeActivated() -> Bool
    func isChartModeActivated() -> Bool
    func getUserAlias() -> String?
    func getReactiveUserAlias() -> AnyPublisher<String, Never>
    func isEmailConfigured() -> Bool
    func isPhoneConfigured() -> Bool
    func setPb(isPb: Bool)
    func setAccountBoxOpen(isOpen: Bool)
    func setCardBoxOpen(isOpen: Bool)
    func setSavingProductBoxOpen(isOpen: Bool)
    func setLoanBoxOpen(isOpen: Bool)
    func setDepositBoxOpen(isOpen: Bool)
    func setStockBoxOpen(isOpen: Bool)
    func setFundsBoxOpen(isOpen: Bool)
    func setPensionsBoxOpen(isOpen: Bool)
    func setPortfolioManagedBoxOpen(isOpen: Bool)
    func setPortfolioNotManagedBoxOpen(isOpen: Bool)
    func setInsuranceSavingBoxOpen(isOpen: Bool)
    func setInsuranceProtectionBoxOpen(isOpen: Bool)
    func setPortfolioManagedVariableIncomeBoxOpen(isOpen: Bool)
    func setPortfolioNotManagedVariableIncomeBoxOpen(isOpen: Bool)
    func setGlobalPositionOnboardingSelected(pgSelected: GlobalPositionOptionEntity)
    func setPhotoThemeOnboardingSelected(photoThemeOptionSelected: PhotoThemeOptionEntity)
    func setDiscreteMode(discreteModeIsOn: Bool)
    func setChartMode(chartModeIsOn: Bool)
    func setPGColorMode(pgColorMode: PGColorMode)
    func setUserAlias(_ alias: String)
    func emailConfigured(_ configured: Bool)
    func phoneConfigured(_ configured: Bool)
    func getPGColorMode() -> PGColorMode
    func setFrequentOperativesKeys(_ frequentOperativesKeys: [String])
    func getFrequentOperativesKeys() -> [String]?
    func getTrips() -> [TripRepresentable]?
    func setTrips(_ trips: [TripRepresentable]?)
    func setBudget(_ budget: Double)
    func getBudget() -> Double?
    func getTripModeVisited() -> Bool
    func setTripModeVisited()
    func getFirstTimeBiometricCredentialActivated() -> Bool
    func setFirstTimeBiometricCredentialActive()
    func getOnboardingCancelled() -> Bool
    func setOnboardingCancelled(_ value: Bool)
    func getAskedForBiometricPermissions() -> Bool
    func setAskedForBiometricPermissions(_ value: Bool)
    func getOtpPushBetaFinished() -> Bool
    func setOtpPushBetaFinished(_ value: Bool)
    func getWhatsNewCounter() -> Int
    func setWhatsNewCounter(_ newCounter: Int)
    func isWhatsNewBubbleEnabled() -> Bool
    func setWhatsNewBigBubbleVisible(_ status: Bool)
    func isWhatsNewBigBubbleVisible() -> Bool
    func setTransitiveAppIcon(_ appIcon: AppIconRepresentable)
    func getTransitiveAppIcon() -> AppIconRepresentable?
    var boxesRepresentable: [UserPrefBoxType: PGBoxRepresentable] { get }
    var isPrivateMenuCoachManagerShown: Bool { get set }
}
