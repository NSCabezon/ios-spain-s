//
//  AccessibilityCardBoarding.swift
//  Commons
//
//  Created by Boris Chirino Fernandez on 13/10/2020.
//

import Foundation

public enum AccessibilityCardBoarding {
    public enum Alias {
        public static let titleHeading = "cardBoarding_title_nameCard"
        public static let titleExplanationLabel = "cardBoarding_text_nameCard"
        public static let textFieldAlias = "cardBoardingInputSearch"
        public static let shadowCardImage = "shadowCard"
        public static let placeholder = "cardBoarding_label_nameCard"
        public static let keyboardInputButton = "cardBoardingBtnNext"
        public enum PlasticCard {
            public static let image = "CardBoardingImgCard"
            public static let pan = "credit_card_pan_text_view"
            public static let expiration = "credit_card_expiration_date_text_view"
            public static let ownerName = "credit_card_name_text_view"
        }
    }
    
    public enum ApplePay {
        public static let title = "cardBoarding_title_payWithMobile"
        public static let text = "cardBoarding_text_applePayments"
        public static let perfectText = "generic_label_perfect"
        public static let activeSuccess = "cardBoarding_label_activeSuccess"
        public static let appleWalletPay = "cardBoarding_label_appleWalletPay"
        public static let howPayWithMobile = "cardBoarding_label_howPayWithMobile"
        public static let addToApplePayText = "addCard_button_AddToApplePay"
        public static let ngBtnAppleWallet = "cardBoardingBtnAppleWallet"
        public static let imgCard = "CardBoardingImgCard"
        public static let icnApple = "icnApplePaySummary"
    }
    
    public enum Summary {
        public static let imgSantander = "icnSanRedInfo"
        public static let title = "cardBoarding_text_brilliant"
        public static let readyCard = "cardBoarding_text_readyCard"
        public static let help = "cardBoarding_text_help"
        public static let nowThat = "summary_label_nowThat"
        public static let myCards = "generic_button_myCards"
        public static let globalPosition = "generic_button_globalPosition"
        public static let improve = "generic_button_improve"
        public static let myCardsButton = "cardBoardingBtnMyCards"
        public static let globalPositionButton = "cardBoardingBtnGlobalPosition"
        public static let improveButton = "cardBoardingBtnImprove"
    }

    public enum ChangePaymentMethod {
        public enum Summary {
            public static let icnClose = "icnClose"
            public static let icnCheck = "icnCheckAlert"
            public static let title = "summe_title_perfect"
            public static let description = "summary_text_changePayment"
            public static let icnChangeWayToPay = "icnChangeWayToPay"
            public static let monthly = "changeWayToPay_label_monthly"
            public static let postpone = "changeWayToPay_label_postpone"
            public static let postponeValue = "changeWayToPay_label_postpone_value"
            public static let fixedFee = "changeWayToPay_label_fixedFee"
            public static let fixedFeeValue = "changeWayToPay_label_fixedFee_value"
            public static let continueText = "summary_text_continueProcessSigning"
            public static let nextStepButton = "cardBoarding_button_next"
        }
    }
    
    public enum ChangePayment: String {
        case headerTitle = "cardBoarding_title_changePayment"
        case headerDescription = "cardBoarding_text_descriptionPaymentMethod"
        case monthlyTitle = "changeWayToPay_label_monthly"
        case monthlyDescription = "cardBoarding_text_descriptionMonthly"
        case monthlyButton = "cardBoardingBtnMonthlyChangePayment"
        case deferredTitle = "changeWayToPay_label_postpone"
        case deferredDescription = "cardBoarding_text_descriptionPostpone"
        case deferredSelectPercentage = "cardBoarding_text_selectPercentage"
        case deferredPlaceholder = "cardBoarding_label_percentage"
        case deferredButton = "cardBoardingBtnPostponeChangePayment"
        case deferredTextField = "changeWayToPayInputPercentaje"
        case deferredPicker = "cardBoarding_picker_Postpone"
        case minFeeLabel = "cardBoarding_label_minFee"
        case fixedFeeTitle = "changeWayToPay_label_fixedFee"
        case fixedFeeDescription = "cardBoarding_text_descriptionFixedFee"
        case fixedFeeTextField = "changeWayToPayInputAmount"
        case fixedFeePlaceholder = "cardBoarding_label_fixedFee"
        case fixedFeeButton = "cardBoardingBtnFixedFeeChangePayment"
        case fixedFeeSelectAmount = "cardBoarding_text_selectAmount"
        case fixedFeePicker = "cardBoarding_picker_fixedFee"
    }

    public enum Popup {
        public static let title = "onboarding_alert_title_completeActivation"
        public static let descriptionText = "cardBoarding_alert_text_remember"
        public static let exitButton = "cardBoardingBtnExtitProcess"
        public static let resumeButton = "cardBoarding_button_customizeCard"
        public static let closeImage = "icnClose"
        public static let popupViuew = "cardBoardingAlertExtitProcess"
        public static let sanImage = "icnSanRedBigAlert"
    }
    
    public enum AlmostDone {
        public static let header = "cardBoarding_title_almostFinished"
        public static let explanation = "cardBoarding_text_otherOptions"
        public static let carrousel = "cardBoardingCarouselOptions"
    }
    
    public enum Notifications {
        public static let title = "cardBoarding_title_notifications"
        public static let subtitle = "cardBoarding_text_descriptionNotifications"
        public static let icnNotifications = "icnBell"
        public static let notifications = "onboarding_label_notifications"
        public static let middle = "cardBoarding_text_activateNotifications"
        public static let alert = "cardBoarding_label_alerts"
        public static let icnOne = "icnShorpping"
        public static let icnTwo = "icnSecurity"
        public static let icnThree = "icnBonuses"
        public static let disabled = "onboarding_label_disabled"
        public static let labelOne = "cardBoarding_label_shopping"
        public static let labelTwo = "cardBoarding_label_security"
        public static let labelThree = "cardBoarding_label_bonuses"
        public static let switchNotification = "cardBoardingSwitchNotifications"
        public static let back = "generic_button_previous"
        public static let continueNotifications = "cardBoarding_button_next"
        public static let cardBoardingViewNotifications = "cardBoardingViewNotifications"
    }
    
    public enum ActivatedNotifications {
        public static let titleLabel = "cardBoarding_text_brilliant"
        public static let subtitleLabel = "cardBoarding_text_notificationsActivated"
        public static let ticIcn = "icnCheckToast"
    }
    
    public enum Geolocation {
        public static let headerTitle = "cardBoarding_title_geolocation"
        public static let headerDescription = "cardBoarding_text_descriptionGeolocation"
        public static let mapImageView = "imgMapOnboarding"
        public static let locationStateLabel = "cardBoarding_locationStateLabel"
        public static let switchActivateLocation = "cardBoarding_locationSwitch"
    }
}
