//
//  AccessibilityBiometryValidaor.swift
//  Commons
//
//  Created by Rubén Márquez Fernández on 24/5/21.
//

import Foundation

public enum AccessibilityBiometryValidatorHeaderView {
    public static let baseView = "biometry_validatorHeaderBaseView"
    public static let moreInfoButton = "ganeric_label_knowMore"
    public static let closeButton = "icnCloseGray"
    public static let titleLabel = "biometry_validator_label_SantanderKey"
    public static let topImageView = "icnBigSantanderLock"
    public static let contentView = "biometry_validatorHeaderContentView"
}

public enum AccessibilityBiometryValidatorContainerView {
    public static let baseView = "biometry_validatorContainerBaseView"
}

public enum AccessibilityBiometryValidatorActionView {
    public static let baseView = "biometry_validatorTicketConfirmTypeBaseView"
    public static let topImageView = "biometry_validatorTicketConfirmTypeTopImageView"
    public static let titleLabel = "biometry_validatorTicketConfirmTypeTitleLabel"
}

public enum AccessibilityBiometryValidatorFooterView {
    public static let baseView = "biometry_validatorFooterBaseView"
    public static let footerButton = "biometry_validatorFooterWithOneButton"
    public static let cancelButton = "generic_button_cancel"
    public static let rightButton = "FooterWithTwoButtonsRightButton"
    public static let sanSafeImage = "icnSecurePurchase"
    public static let sanSafeLabel = "biometry_validator_label_safeOperation"
}
