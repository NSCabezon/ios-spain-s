//
//  AccessibilityOperative.swift
//  Commons
//
//  Created by Carlos Monfort Gómez on 06/04/2021.
//

import Foundation

public enum AccessibilityOperative {
    public static let btcClose = "icnClose"
    
    public enum ForgotSignatureView {
        public static let forgotView = "viewForgotElectronicSignature"
        public static let forgotTitle = "signing_title_popup_rememberInfo"
        public static let forgotSubtitle = "signing_text_popup_rememberInfoSigning"
    }
    
    public enum Alerts {
        public static let signatureIncorrectPasswordView = "signatureIncorrectPassword"
        public static let signatureBlockedView = "signatureAccessBlocked"
        public static let incorrectPasswordView = "otpIncorrectPassword"
        public static let blockedView = "viewOtpAccessBlocked"
        public static let otpNotReceivedCodeView = "otpNotReceivedCodeView"
        public static let otpInvalidReceivedCodeView = "otpInvalidReceivedCodeView"
    }
}

public enum AccessibilityOperativeSummary {
    public static let title = "summary_title"
    public static let subtitle = "summary_subtitle"
    public static let ticImage = "icnCheckOval"
    public static let extraInfo = "summary_extraInfo"
    public static let summaryStandardBodySubtitle = "summaryStandardBodySubtitle"
    public static let summaryStandardBodyInfo = "summaryStandardBodyInfo"
    public static let summaryFooterTitle = "summaryFooter_label_title"
}

public enum AccessibilityOperativeSignature {
    public static let signatureIcon = "oneIcnLock"
    public static let signatureTitle = "signing_text_key"
    public static let signatureSubtitle = "signing_text_insertNumbers"
    public static let signatureRemember = "signing_text_remember"
}
