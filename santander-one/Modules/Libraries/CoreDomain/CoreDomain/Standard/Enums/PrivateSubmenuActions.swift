public enum PrivateSubmenuAction: Hashable {
    case myProductOffer(PrivateMenuMyProductsOption, OfferRepresentable? = nil)
    case sofiaOffer(SofiaInvestmentOptionType, OfferRepresentable? = nil)
    case otherOffer(PrivateMenuOtherServicesOptionType, OfferRepresentable? = nil)
    case worldOffer(World123OptionType, OfferRepresentable? = nil)

    public static func == (lhs: PrivateSubmenuAction, rhs: PrivateSubmenuAction) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .sofiaOffer(let sofia, _):
            hasher.combine(sofia)
        case .myProductOffer(let product, _):
            hasher.combine(product)
        case .otherOffer(let other, _):
            hasher.combine(other)
        case .worldOffer(let world, _):
            hasher.combine(world)
        }
    }
}
