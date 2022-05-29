//
//  ProductListConfigurationRepresentable.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 21/3/22.
//

import Foundation
import UIOneComponents
import CoreDomain
import CoreFoundationLib

public protocol ProductListConfigurationRepresentable {
    var type: ProductTypeConfiguration { get }
    var products: [ProductConfigurationRepresentable]? { get }
    var otherBanksInfo: [ProducListConfigurationOtherBanksRepresentable]? { get }
}

public protocol ProductConfigurationRepresentable {
    var productId: String? { get }
    var title: String { get }
    var subTitle: String? { get }
    var urlImage: String? { get }
    var amount: AmountRepresentable? { get }
    var selected: Bool? { get }
    
    func getProductCardRepresentable(for type: ProductTypeConfiguration) -> OneProductCardViewRepresentable
    func setSelected(isOn: Bool)
}

public protocol ProducListConfigurationOtherBanksRepresentable {
    var companyId: String? { get }
    var companyName: String? { get }
    var bankImageUrl: String? { get }
    var lastUpdate: LocalizedStylableText? { get }
    var notificationTitle: LocalizedStylableText? { get }
    var notificationTitleAccessibilityLabel: String? { get }
    var notificationLinkTitle: String? { get }
    
    func getProductCardRepresentable() -> OneProductCardViewRepresentable
}

public enum ProductTypeConfiguration {
    case accounts
    case cards
    case otherAccounts
    case otherCards
    case otherBanks
    
    var text: String {
        switch self {
        case .accounts: return localized("generic_label_accounts")
        case .cards: return localized("analysis_label_creditCards")
        case .otherAccounts: return localized("generic_label_otherAccounts")
        case .otherCards: return localized("analysis_label_otherCreditCards")
        case .otherBanks: return localized("generic_label_otherBanks")
        }
    }
    
    var accessibilityIdentifier: String {
        switch self {
        case .accounts: return "generic_label_accounts"
        case .cards: return "analysis_label_creditCards"
        case .otherAccounts: return "generic_label_otherAccounts"
        case .otherCards: return "analysis_label_otherCreditCards"
        case .otherBanks: return "generic_label_otherBanks"
        }
    }
}

struct DefaultProductListConfiguration: ProductListConfigurationRepresentable {
    var type: ProductTypeConfiguration
    var products: [ProductConfigurationRepresentable]?
    var otherBanksInfo: [ProducListConfigurationOtherBanksRepresentable]?
}

class DefaultProductConfiguration: ProductConfigurationRepresentable {
    var productId: String?
    var title: String
    var subTitle: String?
    var defatultImageName: String?
    var urlImage: String?
    var amount: AmountRepresentable?
    var selected: Bool?
    
    init(productId: String? = nil, title: String, subTitle: String? = nil, defatultImageName: String? = nil, urlImage: String? = nil, amount: AmountRepresentable? = nil, selected: Bool? = nil) {
        self.productId = productId
        self.title = title
        self.subTitle = subTitle
        self.defatultImageName = defatultImageName
        self.urlImage = urlImage
        self.amount = amount
        self.selected = selected
    }
    
    func getProductCardRepresentable(for type: ProductTypeConfiguration) -> OneProductCardViewRepresentable {
        let logoSize: OneProductCardLogoHeight = (type == .cards || type == .otherCards) ? .big : .small
        var mainAmount: OneProductCardAmountRepresentable?
        var toggleInfo: OneNotificationRepresentable?
        if let amount = amount {
            mainAmount = DefaultProductCardAmount(title: localized("analysis_label_balance"), amount: amount)
        }
        if let isToggleOn = selected {
            toggleInfo = DefaultNotification(type: .textAndToggle(stringKey: localized("analysis_label_seeFinancialHealth"),
                                                                  toggleValue: isToggleOn,
                                                                  toggleIsEnabled: true),
                                             defaultColor: .oneSkyGray,
                                             inactiveColor: .oneWhite)
        }
        return DefaultProductCardView(title: title,
                                      subTitle: subTitle,
                                      defatultImageName: defatultImageName,
                                      urlImage: urlImage,
                                      logoSize: logoSize,
                                      mainAmount: mainAmount,
                                      toggleNotification: toggleInfo,
                                      cardStatus: .normal,
                                      borderStyle: .line,
                                      mainBackgroundColor: .oneWhite,
                                      secundaryBackgroundColor: .oneSkyGray)
    }
    
    func setSelected(isOn: Bool) {
        self.selected = isOn
    }
}

class DefaultProducListConfigurationOtherBanks: ProducListConfigurationOtherBanksRepresentable {
    var companyId: String?
    var companyName: String?
    var bankImageUrl: String?
    var lastUpdate: LocalizedStylableText?
    var notificationTitle: LocalizedStylableText?
    var notificationLinkTitle: String?
    var notificationTitleAccessibilityLabel: String?
    
    init(companyId: String? = nil, companyName: String? = nil, bankImageUrl: String? = nil, lastUpdate: LocalizedStylableText? = nil, notificationTitle: LocalizedStylableText? = nil, notificationTitleAccessibilityLabel: String? = nil, notificationLinkTitle: String? = nil) {
        self.companyId = companyId
        self.companyName = companyName
        self.bankImageUrl = bankImageUrl
        self.lastUpdate = lastUpdate
        self.notificationTitle = notificationTitle
        self.notificationTitleAccessibilityLabel = notificationTitleAccessibilityLabel
        self.notificationLinkTitle = notificationLinkTitle
    }
    
    func getProductCardRepresentable() -> OneProductCardViewRepresentable {
        var notificationInfo: OneNotificationRepresentable?
        if let notificationTitle = notificationTitle {
            if let notificationLinkTitle = notificationLinkTitle {
                notificationInfo = DefaultNotification(type: .stylableTextAndLink(withLocalizedString: notificationTitle,
                                                                          linkKey: notificationLinkTitle,
                                                                          linkIsEnabled: true),
                                                       defaultColor: .onePaleYellow)
            } else {
                notificationInfo = DefaultNotification(type: .stylableTextOnly(withLocalizedString: notificationTitle),
                                                       defaultColor: .onePaleYellow)
            }
        }
        return DefaultProductCardView(title: companyName ?? "",
                                      defatultImageName: "oneIcnBankGenericLogo",
                                      urlImage: bankImageUrl,
                                      logoSize: .small,
                                      moreActionsImageName: "oneIcnMoreOptions",
                                      infoExtra: lastUpdate,
                                      firstNotification: notificationInfo,
                                      cardStatus: .normal,
                                      borderStyle: .shadow,
                                      mainBackgroundColor: .oneWhite,
                                      secundaryBackgroundColor: .oneSkyGray,
                                      notificationTitleAccessibilityLabel: notificationTitleAccessibilityLabel)
    }
}

struct DefaultProductCardView: OneProductCardViewRepresentable {
    var title: String
    var subTitle: String?
    var defatultImageName: String?
    var urlImage: String?
    var logoSize: OneProductCardLogoHeight?
    var moreActionsImageName: String?
    var mainAmount: OneProductCardAmountRepresentable?
    var extraAmounts: [OneProductCardAmountRepresentable]?
    var infoExtra: LocalizedStylableText?
    var firstNotification: OneNotificationRepresentable?
    var secondNotification: OneNotificationRepresentable?
    var thirdNotification: OneNotificationRepresentable?
    var toggleNotification: OneNotificationRepresentable?
    var cardStatus: OneProductCardStatus
    var borderStyle: OneProductCardBorderStyle
    var mainBackgroundColor: UIColor
    var secundaryBackgroundColor: UIColor?
    var notificationTitleAccessibilityLabel: String?
}

struct DefaultProductCardAmount: OneProductCardAmountRepresentable {
    var title: String
    var amount: AmountRepresentable
}

struct DefaultNotification: OneNotificationRepresentable {
    var type: OneNotificationType
    var defaultColor: UIColor
    var inactiveColor: UIColor?
}
