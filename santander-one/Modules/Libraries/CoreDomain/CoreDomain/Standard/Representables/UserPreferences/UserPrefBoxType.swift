public enum UserPrefBoxType: String, Codable {
    case account
    case card
    case pension
    case fund
    case managedPortfolio
    case notManagedPortfolio
    case stock
    case deposit
    case loan
    case insuranceProtection
    case insuranceSaving
    case managedPortfolioVariableIncome
    case notManagedPortfolioVariableIncome
    case savingProduct
    
    public init(type: ProductTypeEntity) {
        let conversions: [ProductTypeEntity: UserPrefBoxType] = [
            .account: .account,
            .card: .card,
            .pension: .pension,
            .fund: .fund,
            .managedPortfolio: .managedPortfolio,
            .notManagedPortfolio: .notManagedPortfolio,
            .stockAccount: .stock,
            .deposit: .deposit,
            .loan: .loan,
            .insuranceProtection: .insuranceProtection,
            .insuranceSaving: .insuranceSaving,
            .managedPortfolioVariableIncome: .managedPortfolioVariableIncome,
            .notManagedPortfolioVariableIncome: .notManagedPortfolioVariableIncome,
            .savingProduct: .savingProduct
        ]
        self = conversions[type]!
    }
}
