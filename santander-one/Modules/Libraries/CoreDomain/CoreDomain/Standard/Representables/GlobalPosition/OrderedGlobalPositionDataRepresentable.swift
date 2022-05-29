public struct DefaultGlobalPositionAndUserPrefMerged: GlobalPositionAndUserPrefMergedRepresentable {
    public var loans: [GlobalPositionMergedProduct<LoanRepresentable>]
    public var accounts: [GlobalPositionMergedProduct<AccountRepresentable>]
    public var stockAccounts: [GlobalPositionMergedProduct<StockAccountRepresentable>]
    public var cards: [GlobalPositionMergedProduct<CardRepresentable>]
    public var deposits: [GlobalPositionMergedProduct<DepositRepresentable>]
    public var funds: [GlobalPositionMergedProduct<FundRepresentable>]
    public var managedPortfolios: [GlobalPositionMergedProduct<PortfolioRepresentable>]
    public var notManagedPortfolios: [GlobalPositionMergedProduct<PortfolioRepresentable>]
    public var managedPortfolioVariableIncome: [GlobalPositionMergedProduct<StockAccountRepresentable>]
    public var notManagedPortfolioVariableIncome: [GlobalPositionMergedProduct<StockAccountRepresentable>]
    public var pensions: [GlobalPositionMergedProduct<PensionRepresentable>]
    public var savingsInsurances: [GlobalPositionMergedProduct<InsuranceRepresentable>]
    public var protectionInsurances: [GlobalPositionMergedProduct<InsuranceRepresentable>]
    public var savingsProducts: [GlobalPositionMergedProduct<SavingProductRepresentable>]
    
    public init(
        loans: [GlobalPositionMergedProduct<LoanRepresentable>] = [],
        accounts: [GlobalPositionMergedProduct<AccountRepresentable>] = [],
        stockAccounts: [GlobalPositionMergedProduct<StockAccountRepresentable>] = [],
        cards: [GlobalPositionMergedProduct<CardRepresentable>] = [],
        deposits: [GlobalPositionMergedProduct<DepositRepresentable>] = [],
        funds: [GlobalPositionMergedProduct<FundRepresentable>] = [],
        managedPortfolios: [GlobalPositionMergedProduct<PortfolioRepresentable>] = [],
        notManagedPortfolios: [GlobalPositionMergedProduct<PortfolioRepresentable>] = [],
        managedPortfolioVariableIncome: [GlobalPositionMergedProduct<StockAccountRepresentable>] = [],
        notManagedPortfolioVariableIncome: [GlobalPositionMergedProduct<StockAccountRepresentable>] = [],
        pensions: [GlobalPositionMergedProduct<PensionRepresentable>] = [],
        savingsInsurances: [GlobalPositionMergedProduct<InsuranceRepresentable>] = [],
        protectionInsurances: [GlobalPositionMergedProduct<InsuranceRepresentable>] = [],
        savingsProducts: [GlobalPositionMergedProduct<SavingProductRepresentable>] = []
    ) {
        self.loans = loans
        self.accounts = accounts
        self.stockAccounts = stockAccounts
        self.cards = cards
        self.deposits = deposits
        self.funds = funds
        self.managedPortfolios = managedPortfolios
        self.notManagedPortfolios = notManagedPortfolios
        self.managedPortfolioVariableIncome = managedPortfolioVariableIncome
        self.notManagedPortfolioVariableIncome = notManagedPortfolioVariableIncome
        self.pensions = pensions
        self.savingsInsurances = savingsInsurances
        self.protectionInsurances = protectionInsurances
        self.savingsProducts = savingsProducts
    }
}
