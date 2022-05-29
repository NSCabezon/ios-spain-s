import SANLegacyLibrary
import CoreFoundationLib

struct UserPref {

    var userPrefDTO: UserPrefDTO

    static func from(dto: UserPrefDTO) -> UserPref {
        return UserPref(userPrefDTO: dto)
    }

    init(userPrefDTO: UserPrefDTO) {
        self.userPrefDTO = userPrefDTO
    }
    
    func isPfmVisible() -> Bool {
        return userPrefDTO.pgUserPrefDTO.pfmModule.isVisible
    }
    
    func isChatVisible() -> Bool {
        return userPrefDTO.pgUserPrefDTO.chatModule.isVisible
    }
    
    func isYourMoneyVisible() -> Bool {
        return userPrefDTO.pgUserPrefDTO.yourMoneyModule.isVisible
    }

    func isPb() -> Bool {
        return userPrefDTO.isUserPb
    }

    func isAccountBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.accountsBox.isOpen
    }

    func isCardBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.cardsBox.isOpen
    }

    func isLoanBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.loansBox.isOpen
    }

    func isDepositBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.depositsBox.isOpen
    }

    func isStockBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.stocksBox.isOpen
    }

    func isFundsBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.fundssBox.isOpen
    }

    func isPensionsBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.pensionssBox.isOpen
    }

    func isPortfolioManagedBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.portfolioManagedsBox.isOpen
    }

    func isPortfolioNotManagedBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.portfolioNotManagedsBox.isOpen
    }

    func isInsuranceSavingBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.insuranceSavingsBox.isOpen
    }

    func isInsuranceProtectionBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.insuranceProtectionsBox.isOpen
    }
    
    func isPortfolioManagedVariableIncomeBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.portfolioManagedVariableIncomesBox.isOpen
    }

    func isPortfolioNotManagedVariableIncomeBoxOpen() -> Bool {
        return userPrefDTO.pgUserPrefDTO.portfolioNotManagedVariableIncomesBox.isOpen
    }
    
    func onboardingFinished() -> Bool {
        return userPrefDTO.pgUserPrefDTO.onboardingFinished
    }
    
    func otpPushBetaFinished() -> Bool {
        return userPrefDTO.pgUserPrefDTO.otpPushBetaFinished
    }
    
    func globalPositionOnboardingSelected() -> GlobalPositionOption {
        guard
            let option = GlobalPositionOption(rawValue: userPrefDTO.pgUserPrefDTO.globalPositionOptionSelected)
            else { return .classic}
        return option
    }
    
    func photoThemeOnboardingSelected() -> PhotoThemeOption {
        guard let option = userPrefDTO.pgUserPrefDTO.photoThemeOptionSelected, let value = PhotoThemeOption(rawValue: option) else { return .nature }
        return value
    }
}
