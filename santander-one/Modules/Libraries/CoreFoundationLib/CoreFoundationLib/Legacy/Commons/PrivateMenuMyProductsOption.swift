import CoreDomain

extension PrivateMenuMyProductsOption: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .accounts:
            return AccessibilitySideProduct.btnAccounts
        case .cards:
            return AccessibilitySideProduct.btnCards
        case .stocks:
            return AccessibilitySideProduct.btnSupplyWallet
        case .deposits:
            return AccessibilitySideProduct.btnDeposits
        case .loans:
            return AccessibilitySideProduct.btnLoans
        case .pensions:
            return AccessibilitySideProduct.btnPlans
        case .funds:
            return AccessibilitySideProduct.btnFunds
        case .insuranceSavings:
            return AccessibilitySideProduct.btnInsuranceSaving
        case .insuranceProtection:
            return AccessibilitySideProduct.btnInsurances
        case .savingProducts:
            return AccessibilitySideProduct.btnSavingProducts
        case .tpvs:
            return AccessibilitySideProduct.btnTPVs
        }
    }
}
