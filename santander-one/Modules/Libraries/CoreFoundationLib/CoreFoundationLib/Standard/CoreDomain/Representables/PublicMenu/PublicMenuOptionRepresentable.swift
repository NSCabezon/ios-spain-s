import CoreDomain

public protocol PublicMenuElementRepresentable {
    var top: PublicMenuOptionRepresentable? { get set }
    var bottom: PublicMenuOptionRepresentable? { get set }
}

public protocol PublicMenuOptionRepresentable {
    var kindOfNode: KindOfPublicMenuNode { get }
    var titleKey: String { get }
    var iconKey: String { get }
    var action: PublicMenuAction { get set }
    var event: String { get }
    var accessibilityIdentifier: String? { get }
    var type: PublicMenuOptionType { get set }
}

public enum KindOfPublicMenuNode {
    case recoverPassword
    case mobileWeb
    case getMagic
    case becomeClient
    case recoverProcess
    case enablePublicProducts
    case enableStockholders
    case prepaidLogin
    case shareHolders
    case enablePricingConditions
    case enableLoanRepayment
    case enableChangeLoanLinkedAccount
    case commercialSegment
    case none
}

public enum PublicMenuOptionType {
    case smallButton(style: SmallButtonTypeRepresentable)
    case bigButton(style: BigButtonTypeRepresentable)
    case bigCallButton
    case atm(bgImage: String)
    case selectOptionButton(options: [SelectOptionButtonModelRepresentable])
    case phonesButton(top: String, bottom: String)
    case callNow(phone: String)
    case flipButton(principalItem: PublicMenuOptionRepresentable, secondaryItem: PublicMenuOptionRepresentable, time: Double)
    case publicOffer(items: [PublicOfferElementRepresentable])
}

public enum PublicMenuAction: Equatable {
    case openURL(url: String)
    case goToATMLocator
    case goToStockholders
    case goToOurProducts
    case toggleSideMenu
    case goToHomeTips
    case callPhone(number: String)
    case none
    case custom(action: String)
    case comingSoon
}
