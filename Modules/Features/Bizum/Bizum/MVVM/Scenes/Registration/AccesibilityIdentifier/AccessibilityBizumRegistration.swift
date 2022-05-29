//
//  AccessibilityBizumRegistration.swift
//  Bizum
//
//  Created by Johnatan Zavaleta Milla on 25/4/22.
//

import Foundation

public enum AccessibilityBizumRegistration {
    public static let titleLabel = "bizum_title_instantlyMoneyMobile"
    public static let subtitleLabel = "bizum_label_payEcommerce"
    
    public enum RegisterItemView {
        public static let firstItemLabel = "bizum_label_dischargedNumberPhone"
        public static let firstItemImage = "oneIcnMobile"
        public static let secondItemLabel = "bizum_label_selectAccount"
        public static let secondItemImage = "oneIcnMoneyBag"
        public static let thirdItemLabel = "bizum_label_chooseSecretNumber"
        public static let thirdItemImage = "oneIcnLockBizum"
    }
}

public struct RegisterAccessibiltyItemView {
    var labelId: String
    var imageId: String
}
