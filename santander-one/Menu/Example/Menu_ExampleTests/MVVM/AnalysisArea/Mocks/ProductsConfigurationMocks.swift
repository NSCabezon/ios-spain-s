//
//  ProductsConfigurationMocks.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 25/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Menu
import CoreDomain
import UIOneComponents
import CoreFoundationLib

struct SetFinancialHealthPreferencesMock: SetFinancialHealthPreferencesRepresentable {
    var preferencesProducts: [SetFinancialHealthPreferencesProductRepresentable]?
    
    init(preferencesProducts: [SetFinancialHealthPreferencesProductRepresentable]?) {
        self.preferencesProducts = preferencesProducts
    }
}

struct SetPreferencesProductRepresentableMock: SetFinancialHealthPreferencesProductRepresentable {
    var preferencesProductType: PreferencesProductType?
    var preferencesData: [SetFinancialHealthPreferencesProductDataRepresentable]?
    
    init(preferencesProductType: PreferencesProductType?, _ preferencesData: [SetFinancialHealthPreferencesProductDataRepresentable]?) {
        self.preferencesProductType = preferencesProductType
        self.preferencesData = preferencesData
    }
}

struct SetPreferencesProductDataRepresentableMock: SetFinancialHealthPreferencesProductDataRepresentable {
    var productId: String?
    var productSelected: Bool?
    
    init(productId: String?, productSelected: Bool?) {
        self.productSelected = productSelected
        self.productId = productId
    }
}

struct ProducListConfigurationOtherBanksRepresentableMock: ProducListConfigurationOtherBanksRepresentable {
    var companyId: String?
    var companyName: String?
    var bankImageUrl: String?
    var lastUpdate: LocalizedStylableText?
    var notificationTitle: LocalizedStylableText?
    var notificationTitleAccessibilityLabel: String?
    var notificationLinkTitle: String?
    func getProductCardRepresentable() -> OneProductCardViewRepresentable {
        OneProductCardViewRepresentableMock()
    }
    
    private struct OneProductCardViewRepresentableMock: OneProductCardViewRepresentable {
        var title: String = ""
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
        var cardStatus: OneProductCardStatus = .normal
        var borderStyle: OneProductCardBorderStyle = .line
        var mainBackgroundColor: UIColor = .white
        var secundaryBackgroundColor: UIColor?
        var notificationTitleAccessibilityLabel: String?
    }
}
