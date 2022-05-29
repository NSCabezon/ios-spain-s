//
//  AccesibilitySantanderKey.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 14/2/22.
//

import Foundation

public enum AccessibilitySkFirstStepOnboarding {
    public static let descriptionLabel = "sanKey_text_authoriseAllTransactions"
    
    public enum SkHeaderView {
        public static let titleLabel = "santanderKey_label_santanderKey"
        public static let imageView = "oneIcnSanKeyLock"
        public static let knowMoreButton = "ganeric_label_knowMore"
    }
    
    public enum SkVideoView {
        public static let imageView = "imgVideoTutorialSanKey"
    }
    
    public enum ItemDescriptionView {
        public static let firstItemImage = "iconInfoItem_biometrics"
        public static let secondItemImage = "iconInfoItem_notifications"
        public static let thirdItemImage = "iconInfoItem_pendingTransactions"
        public static let firstItemLabel = "textInfoItem_biometrics"
        public static let secondItemLabel = "textInfoItem_notifications"
        public static let thirdItemLabel = "textInfoItem_pendingTransactions"
    }
    
    public enum KnowMoreView {
        public static let firstTitleLabel = "sanKey_title_whatIs"
        public static let firstDescriptionLabel = "sanKey_text_whatIs"
        public static let secondTitleLabel = "sanKey_title_whatIsBiometrics"
        public static let secondDescriptionLabel = "sanKey_text_whatIsBiometrics"
        public static let thirdTitleLabel = "sanKey_title_multichannelSignature"
        public static let thirdDescriptionLabel = "sanKey_text_multichannelSignature"
    }
}

public enum AccessibilitySkSecondStepOnboarding {
    public static let imageView = "imgSanKeyTutorial"
    public static let headerImageView = "oneIcnSanKeyLockOval"
    public static let titleLabel = "sanKey_title_santanderKeySuccess"
    public static let firstItemLabel = "textInfoItem_confirmationQuickerAndSure"
    public static let secondItemLabel = "textInfoItem_notificationPurchase"
    public static let firstItemIconImage = "iconInfoItem_confirmationQuickerAndSure"
    public static let secondItemIconImage = "iconInfoItem_notificationPurchase"
}

public enum AccessibilitySKDeviceAlias {
    public static let labelTitle = "sanKey_title_chooseAlias"
    public static let labelSubtitle = "sanKey_text_recognizeDevice"
    public static let textfieldTitle = "sanKey_input_alias"
}

public enum AccessibilitySKBiometricsActivationView {
    public static let view = "santanderKeyBiometricsActivationView"
    public static let titleFaceIdLabel = "sanKey_title_wantActivateFaceID"
    public static let titleTouchIdLabel = "sanKey_title_wantActivateTouchID"
    public static let subTitleFaceIdLabel = "sanKey_text_activateFaceID"
    public static let subTitleTouchIdLabel = "sanKey_text_activateTouchID"
}

public enum AccessibilitySKBiometricsToggleView {
    public static let view = "santanderKeyBiometricsToggleView"
    public static let titleFaceIdLabel = "sanKey_title_faceId"
    public static let titleTouchIdLabel = "sanKey_title_touchId"
    public static let subTitleFaceIdLabel = "sanKey_protectOperationsFaceId"
    public static let subTitleTouchIdLabel = "sanKey_protectOperationsFingerprint"
}

public enum AccessibilitySKRegisteredAnotherDevice {
    public static let imageView = "oneIcnSanKeyDanger"
    public static let labelTitle = "sanKey_title_registeredAnotherDevice"
    public static let labelSubtitle = "sanKey_text_linkNewDevice"
    public static let moreInfoButton = "ganeric_label_knowMore"
    public static let closeButton = "oneIcnClose"
}

public enum AccessibilitySKCardSelector {
    public static let labelTitle = "sanKey_title_selectCard"
    public static let labelSubtitle = "sanKey_text_selectCard"
}

public enum AccessibilitySKPinStep {
    public static let labelTitle = "sanKey_title_addPin"
    public static let labelSubtitle = "sanKey_text_enterPin"
    public static let buttonSelectOtherCard = "sanKey_link_selectOtherCard"
    public static let labelPinTitle = "sanKey_label_pin"
    public static let buttonRememberPin = "sanKey_link_rememberPin"

}
