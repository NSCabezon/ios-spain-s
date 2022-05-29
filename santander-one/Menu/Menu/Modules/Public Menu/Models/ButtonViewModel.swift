import UIKit
import CoreFoundationLib

public struct ButtonViewModel {
    public let titleKey: String
    public let iconKey: String
    public let titleFont: UIFont?

    public init(titleKey: String, iconKey: String, titleFont: UIFont? = nil) {
        self.titleKey = titleKey
        self.iconKey = iconKey
        self.titleFont = titleFont
    }
}

public extension ButtonViewModel {
    static let recoverPasswordViewModel = ButtonViewModel(titleKey: "menuPublic_link_lostKey", iconKey: "icnRecoverKey")
    static let fraudViewModel = ButtonViewModel(titleKey: "menuPublic_link_emergency", iconKey: "icnBlockCard1")
    static let mobileWebViewModel = ButtonViewModel(titleKey: "menuPublic_link_accessWeb", iconKey: "icnWorld2")
    static let getPasswordViewModel = ButtonViewModel(titleKey: "menuPublic_link_getKey", iconKey: "icnGetYourKeys")
    static let stockholdersViewModel = ButtonViewModel(titleKey: "menuPublic_link_santanderStockholders", iconKey: "icnEquities")
    static let becomeAClientViewModel = ButtonViewModel(titleKey: "menuPublic_link_becomeClient", iconKey: "icnHandShake")
    static let publicProductsViewModel = ButtonViewModel(titleKey: "menuPublic_link_ourProduct", iconKey: "icnBuyStock1")
    static let homeTipsViewModel = ButtonViewModel(titleKey: "menuPublic_link_discoverOurTips", iconKey: "icnAdvices")
    static let prepaidLoginViewModel = ButtonViewModel(titleKey: "menuPublic_link_loginPrePaid", iconKey: "icnLoginPrepaid")
    static let shareHoldersViewModel = ButtonViewModel(titleKey: "menuPublic_link_santanderStockholders", iconKey: "icnShareHoldersPublicMenu")
    static let pricingConditions = ButtonViewModel(titleKey: "menuPublic_link_priceAndConditions", iconKey: "icnPricing")
}
