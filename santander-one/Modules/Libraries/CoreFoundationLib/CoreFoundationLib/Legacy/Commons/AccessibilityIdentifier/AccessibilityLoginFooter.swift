//
//  AccessibilityLoginFooter.swift
//  Commons
//
//  Created by Ignacio González Miró on 10/3/21.
//

import Foundation

public enum AccessibilityLoginFooter {
    public static let baseView = "loginFooterBaseView"
    public static let biometricsView = "loginFooterBiometricsView"
    public static let ecommerceButton = "loginFooterEcommerceButton"
    public static let recoveryKeyView = "loginFooterRecoveryKeyView"
    
    public enum BiometricsView {
        public static let image = "loginFooterBiometricsImageView"
        public static let text = "loginFooterBiometricsLabel"
    }
    
    public enum RecoveryView {
        public static let text = "login_button_retrieveKey"
    }
}
