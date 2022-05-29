//
//  SpainShortcutItems.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 27/4/21.
//

import Foundation
import CoreFoundationLib

final class SpainShortcutItems {
    private struct ShortcutItem: ShortcutItemProtocol {
        let localizedTitleKey: String
        let icon: UIApplicationShortcutIcon
        let deepLink: DeepLinkEnumerationCapable
    }
    
    private lazy var chargeDischarge: ShortcutItem = {
        return ShortcutItem(localizedTitleKey: "toolbar_title_chargeDischarge", icon: UIApplicationShortcutIcon(templateImageName: "icnEcash"), deepLink: DeepLink.ecash)
    }()
    
    private lazy var internatlTransfer: ShortcutItem = {
        return ShortcutItem(localizedTitleKey: "toolbar_title_transfer", icon: UIApplicationShortcutIcon(templateImageName: "icnTransfer"), deepLink: DeepLink.internalTransfer)
    }()
    
    private lazy var cvvQuery: ShortcutItem = {
        return ShortcutItem(localizedTitleKey: "toolbar_title_seeCvv", icon: UIApplicationShortcutIcon(templateImageName: "icnCvv"), deepLink: DeepLink.cvvQuery)
    }()
    
    private lazy var billsAndTaxesPay: ShortcutItem = {
        return ShortcutItem(localizedTitleKey: "toolbar_title_receiptsAndTaxes", icon: UIApplicationShortcutIcon(templateImageName: "icnReceipt"), deepLink: DeepLink.billsAndTaxesPay)
    }()
}

extension SpainShortcutItems: ShortcutItemsProviderProtocol {
    func getShortcutItems() -> [ShortcutItemProtocol] {
        return [chargeDischarge, internatlTransfer, cvvQuery, billsAndTaxesPay]
    }
}
