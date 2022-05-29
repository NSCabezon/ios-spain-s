public protocol SanflixContractInfoRepresentable {
    var isSanflixEnabled: Bool { get }
    var isEnabledExploreProductsInMenu: Bool { get }
    var offerRepresentable: OfferRepresentable? { get }
}
