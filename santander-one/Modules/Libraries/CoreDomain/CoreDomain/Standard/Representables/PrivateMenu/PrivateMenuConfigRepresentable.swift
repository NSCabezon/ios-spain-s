public protocol PrivateMenuConfigRepresentable {
    var isMarketplaceEnabled: Bool { get }
    var isEnabledBillsAndTaxesInMenu: Bool { get }
    var isEnabledExploreProductsInMenu: Bool { get }
    var isVirtualAssistantEnabled: Bool { get }
    var sanflixEnabled: Bool { get }
    var enablePublicProducts: Bool { get }
    var enableComingFeatures: Bool { get }
    var enableFinancingZone: Bool { get }
    var enableStockholders: Bool { get }
    var enableManagerMenu: Bool { get }
}

