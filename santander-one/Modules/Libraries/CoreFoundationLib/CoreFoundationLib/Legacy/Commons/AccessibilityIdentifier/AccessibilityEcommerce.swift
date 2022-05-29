//
//  AccessibilityEcommerce.swift
//  Commons
//
//  Created by Ignacio González Miró on 1/3/21.
//

import Foundation

public enum AccessibilityEcommerceHeaderView {
    public static let baseView = "ecommerceHeaderBaseView"
    public static let moreInfoButton = "ganeric_label_knowMore"
    public static let closeButton = "icnCloseGray"
    public static let titleLabel = "ecommerce_label_SantanderKey"
    public static let topImageView = "icnBigSantanderLock"
    public static let contentView = "ecommerceHeaderContentView"
}

public enum AccessibilityEcommerceContainerView {
    public static let baseView = "ecommerceContainerBaseView"
    public static let ticketView = "ecommerceContainerTicketView"
    public static let keyAccessButton = "ecommerceContainerButton"
}

public enum AccessibilityEcommerceTicketView {
    public static let baseTicket = "ecommerceTicketBaseView"
    public static let topImage = "ecommerceTicketTopImageView"
    public static let bottomImage = "ecommerceTicketBottomImageView"
    public static let stackContainer = "ecommerceTicketStackContainerView"
}

public enum AccessibilityEcommerceConfirmTypeView {
    public static let baseView = "ecommerceTicketConfirmTypeBaseView"
    public static let topImageView = "ecommerceTicketConfirmTypeTopImageView"
    public static let titleLabel = "ecommerceTicketConfirmTypeTitleLabel"
}

public enum AccessibilityEcommerceDateView {
    public static let baseView = "ecommerceTicketDateBaseView"
    public static let hourLabel = "ecommerceTicketDateLabel"
    public static let dateImageView = "icnClockGray20"
}

public enum AccessibilityEcommerceTicketField {
    public static let baseView = "ecommerceTicketFieldBaseView"
    public static let amountLabel = "ecommerceTicketFieldAmountLabel"
    public static let cardImageView = "icnCardEcommerce"
    public static let descriptionLabel = "ecommerceTicketFieldDescriptionLabel"
    public static let cardCodeLabel = "ecommerceTicketFieldCodeLabel"
}

public enum AccessibilityEcommerceProgressView {
    public static let baseView = "ecommerceTicketProgressBaseView"
    public static let titleLabel = "ecommerce_label_timeRemaining"
    public static let remainingLabel = "ecommerceTicketProgressRemainingLabel"
    public static let progressView = "ecommerceTicketProgressProgressView"
}

public enum AccessibilityEcommercePurchaseStatusView {
    public static let baseView = "ecommerceTicketPurchaseStatusBaseView"
    public static let titleLabel = "ecommerceTicketPurchaseStatusTitleLabel"
    public static let descriptionLabel = "ecommerceTicketPurchaseStatusDescriptionLabel"
    public static let statusImageView = "ecommercePurchaseStatusImageView"
    public static let errorView = "ecommercePurchaseStatusErrorView"
    public static let errorImageView = "ecommerceImgIllustration"
}

public enum AccessibilityEcommerceLoadingView {
    public static let baseView = "ecommerceLoadingBaseView"
    public static let ticket = "ecommerceLoadingTicketView"
    public static let loading = "ecommerceLoadingImageLoadingView"
}

public enum AccessibilityEcommerceEmptyView {
    public static let title = "ecommerce_title_advise"
    public static let viewLoadingText = "ecommerce_text_advise"
    public static let buttonVideoText = "ecommerce_button_video"
    public static let videoButton = "ecommerceBtnVideo"
    public static let noPendingPurchasesText = "ecommerce_label_empty"
}

public enum AccessibilityEcommerceFooterView {
    public static let baseView = "ecommerceFooterBaseView"
    public static let footerButton = "ecommerceFooterWithOneButton"
    public static let cancelButton = "generic_button_cancel"
    public static let rightButton = "FooterWithTwoButtonsRightButton"
    public static let sanSafeImage = "icnSecurePurchase"
    public static let sanSafeLabel = "ecommerce_label_safeOperation"
}

public enum AccessibilityEcommerceNumberPadView {
    public static let enterKeyLabel = "ecommerce_title_enterPassword"
    public static let ecommerceNumberPadView = "ecommerceNumberPadView"
    public static let backToBiometryLabel = "ecommerceNumberPadBackToBiometryLabel"
    public static let backToBiometryImageView = "ecommerceNumberPadBackToBiometryImageView"
    public static let recoverPasswordLabel = "login_button_retrieveKey"
    public static let footerView = "ecommerceNumberPadFooterView"
}

public enum AccessibilityFintechTicketView {
    public static let ticket = "ecommerceImgCard"
}

public enum AccessibilityFintechLoadingView {
    public static let emptyLoading = "emptyLoadingPurchase"
    public static let loader = "ecommerceImgLoader"
    public static let loadingLabel = "ecommerce_label_loadingProcess"
}

public enum AccessibilityFintechConfirmationView {
    public static let greetingLabel = "ecommerce_label_hello"
    public static let externalIdentLabel = "ecommerce_label_externalIdentification"
    public static let changeUserButton = "ecommerce_button_changeUser"
    public static let sanIdentLabel = "ecommerce_label_sanIdentification"
    public static let usePasswordButton = "ecommerce_button_usePassword"
    public static let padImage = "icnAccessCode"
}

public enum AccessibilityFintechSuccessView {
    public static let icon = "icnSantanderKeyOkLock"
    public static let identificationLabel = "ecommerce_label_Identification"
}

public enum AccessibilityFintechRememberedLoginView {
    public static let titleLabel = "ecommerce_title_enterPassword"
    public static let textField = "fintonic_placeholder"
    public static let dropList = "fintonic_dropList"
}

public enum AccessibilityFintechUnrememberedLoginView {
    public static let titleLabel = "ecommerce_title_enterPassword"
    public static let textField = "fintonic_placeholder"
    public static let dropList = "fintonic_dropList"
}

public enum AccessibilitySecureDeviceEcommerce {
    public static let statusDescriptionLabel = "santanderKeySecureDeviceLabelStatusDescription"
    public static let updateStatusDescriptionBtn = "santanderKeySecureDeviceBtnUpdateStatus"
    public static let titleAdviceLabel = "ecommerce_title_advise"
    public static let subtitleAdviceLabel = "ecommerce_text_advise"
}
