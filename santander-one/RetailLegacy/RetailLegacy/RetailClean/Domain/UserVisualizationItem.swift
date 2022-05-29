enum VisualizationBoxType {
    case accounts
    case notManagedPortfolios
    case managedPortfolios
    case cards
    case deposits
    case loans
    case stocks
    case pensions
    case funds
    case insuranceSavings
    case insuranceProtection
}

struct UserVisualizationBox {
    let type: VisualizationBoxType
    let items: [UserVisualizationItem]
}

struct UserVisualizationItem {
    let itemIdentifier: String
    let isVisible: Bool
}

struct UserVisualizationModule {
    let itemIdentifier: String
    let isVisible: Bool
}
