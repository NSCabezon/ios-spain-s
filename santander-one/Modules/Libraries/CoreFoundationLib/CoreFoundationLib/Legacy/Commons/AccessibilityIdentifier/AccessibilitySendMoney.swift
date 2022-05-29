//
//  AccessibilitySendMoney.swift
//  Pods
//
//  Created by Carlos Monfort Gómez on 30/9/21.
//

import Foundation

public enum AccessibilitySendMoneyAccountSelector {
    public static let sentIcon = "oneIcnArrowSend"
    public static let infoLabel = "originAccount_label_sentMoney"
    public static let oneLinkView = "oneLinkView"
    public static let oneLinkBtn = "oneLinkBtn"
}

public enum AccessibilitySendMoneyDestinattionAccountSelector {
    public static let receiveIcon = "oneIcnArrowReceive"
    public static let infoLabel = "destinationAccounts_label_receiveMoney"
}

public enum AccessibilitySendMoneyAmount {
    public static let amountSuffix = "_amount"
    public static let descriptionSuffix = "_description"
    public static let periodicitySuffix = "_periodicity"
    public static let deferredSuffix = "_deferredDate"
    public static let frequencySuffix = "_frequency"
    public static let startDateSuffix = "_startDate"
    public static let endDateSuffix = "_endDate"
    public static let businessDaySuffix = "_businessDay"
    // Other
    public static let selectionDateOneFilter = "selectionDateOneFilter"
    public enum ChangeCurrencyView {
        public static let chooseCurrencyViewCurrencies = "chooseCurrencyViewCurrencies"
        public static let chooseCurrencySelectorCardView = "chooseCurrencySelectorCardView"
        public static let chooseCurrencySelectorCardCurrencyLabel = "chooseCurrencySelectorCardCurrencyLabel"
        public static let chooseCurrencySelectorCardCurrencyTitle = "chooseCurrencySelectorCardCurrencyTitle"
        public static let chooseCurrencyCarouselCurrencies = "chooseCurrencyCarouselCurrencies"
        public static let chooseCurrencyListCurrencies = "chooseCurrencyListCurrencies"
        public static let icnCheck = "icnCheck"
    }
}

public enum AccessibilitySendMoneyAmountNoSepa {
    public static let recipientBank = "sendMoney_label_recipientBank"
    public static let amountAndDate = "sendMoney_label_amoundDate"
    public static let dateSending = "sendMoney_label_dateSending"
    public static let dateSendingToday = "sendMoney_label_today"
    public static let bicSuffix = "_bic"
    public static let bankNameSuffix = "_bankName"
    public static let optionalBankAddress = "_optionalBankAddress"
    public static let recipientSuffix = "_recipient"
    public static let currencySuffix = "_currency"
    public static let costSuffix = "_cost"
    public static let conceptSuffix = "_concept"
    public static let expenseSelectorTitle = "sendMoney_titlePopup_paymentCostSending"
}

public enum AccessibilitySendMoneyDestination {
    public enum Carousels {
        public enum Common {
            public static let rightIconUp = "oneIcnArrowNoRoundedUp"
            public static let rightIconDown = "oneIcnArrowNoRoundedDown"
        }
        public enum Favorites {
            public static let leftIcon = "oneIcnStar"
            public static let title = "sendMoney_label_favoritesNumber"
        }
        public enum Recents {
            public static let leftIcon = "oneIcnRecentTransfer"
            public static let title = "sendMoney_label_recentTranferNumber"
        }
        public enum NewRecipient {
            public static let leftIcon = "oneIcnPlus"
            public static let title = "sendMoney_label_newRecipient"
        }
    }
    public enum AllFavorites {
        public static let allFavoritesSuffix = "_allFavorites"
        public static let cellNameLabel = "nameLabel"
        public static let cellIBANLabel = "ibanLabel"
        public static let cellBankLogo = "bankLogo"
        public static let emptyLoader = "imgLoader"
        public static let emptyTitle = "sendMoney_label_emptyContactNotfound"
        public static let emptySubtitle = "sendMoney_label_emptyAddNewContact"
    }
    public enum NewRecipientView {
        public static let ibanSuffix = "_iban"
        public static let recipientSuffix = "_recipient"
        public static let checkFavouriteRecipientSuffix = "_checkFavouriteRecipient"
        public static let aliasSuffix = "_alias"
        public enum Alias {
            public static let mainIcon = "oneIcnWarning"
        }
    }
    public enum ChangeCountryView {
        public static let chooseCountryViewCountries = "chooseCountryViewCountries"
        public static let chooseCountrySelectorCardView = "chooseCountrySelectorCardView"
        public static let chooseCountrySelectorCardLabel = "chooseCountrySelectorCardLabel"
        public static let chooseCountrySelectorCardFlag = "chooseCountrySelectorCardFlag"
        public static let chooseCountryCarouselCountries = "chooseCountryCarouselCountries"
        public static let chooseCountryListCountries = "chooseCountryListCountries"
        public static let icnCheck = "icnCheck"
    }
}

public enum AccessibilitySendMoneyTransferType {
    public enum RadioButtons {
        public static let standardSuffix = "_standard"
        public static let immediateSuffix = "_immediate"
        public static let expressDeliverySuffix = "_expressDelivery"
    }
}

public enum AccessibilitySendMoneyConfirmation {
    public static let confirmTitleLabel = "confirmation_label_confirmBankTransfer"
    public static let confirmValueLabel = "sendMoneyConfirmationTotal"
    public static let recipientReceiveSuffix = "_recipientReceive"
    public static let paymentCostSuffix = "_paymentCost"
    public enum Summary {
        public static let senderSuffix = "_sender"
        public static let amountSuffix = "_amount"
        public static let typeSuffix = "_type"
        public static let recipientSuffix = "_recipient"
        public static let dateSuffix = "_date"
    }
}

public enum AccessibilitySendMoneySummary {
    public static let rocketImageView = "sendMoneySummaryViewRocketAnimation"
    public static let successLabel = "summary_label_success"
    public static let amountLabel = "summary_label_amountOf"
    public static let moneyAmountLabel = "sendMoneySummaryTotal"
    public static let financingTag = "sendMoneySummaryFinancingTag"
    public static let toggleSummaryButtonUp = "oneIcnOvalButtonUp"
    public static let toggleSummaryButtonDown = "oneIcnOvalButtonDown"
    public static let seeSummaryLabel = "summary_label_seeTheSummary"
    public static let shareLabel = "sendMoney_label_shareSummary"
    public static let financingButton = "sendMoneySummaryFinancingTagBtn"
    public enum Summary {
        public static let senderSuffix = "_sender"
        public static let typeSuffix = "_type"
        public static let recipientSuffix = "_recipient"
        public static let dateSuffix = "_date"
    }
    public enum ShareButton {
        public static let shareButtonView = "oneHorizontalButton"
        public static let shareButtonImg = "oneHorizontalButtonImg"
        public static let shareButtonTitle = "oneHorizontalButtonTitle"
        public static let pdfSuffix = "_0"
        public static let imageSuffix = "_1"
    }
    public enum OpinatorView {
        public static let opinatorView = "oneOpinatorView"
        public static let smileysImageView = "smileys"
        public static let title = "summary_label_recommend"
    }
    public enum ShareView {
        public static let santanderImage = "oneIcnSantander"
        public static let brokenTicketImage = "imgTorn"
        public static let nameTitle = "share_text_picture"
        public static let amountTitle = "share_item_amount"
        public static let amountText = "sendMoneyShareViewLabelAmount"
        public static let descriptionTitle = "share_item_concept"
        public static let descriptionText = "sendMoneyShareViewLabelDescription"
        public static let sentDateTitle = "share_item_sendingDate"
        public static let sentDateText = "sendMoneyShareViewLabelSentDate"
        public static let senderAccountTitle = "share_item_remitter"
        public static let senderAccountImage = "sendMoneyShareViewImgSenderBankLogo"
        public static let senderAccountText = "sendMoneyShareViewLabelSenderAccount"
        public static let recipientAccountTitle = "share_item_recipient"
        public static let recipientAccountImage = "sendMoneyShareViewImgRecipientBankLogo"
        public static let recipientAccountText = "sendMoneyShareViewLabelRecipientAccount"
    }
}

public enum AccessibilitySendMoneySignature {
    public static let signatureIcon = "oneIcnLock"
    public static let signatureTitle = "signing_text_key"
    public static let signatureSubtitle = "signing_text_insertNumbers"
    public static let signaturePosition = "oneInputSignatureView_position"
    public static let signatureRemember = "signing_text_remember"
    public enum ForgotSignatureView {
        public static let forgotView = "sendMoneyViewForgotElectronicSignature"
        public static let forgotTitle = "signing_title_popup_rememberInfo"
        public static let forgotSubtitle = "signing_text_popup_rememberInfoSigning"
    }
    public enum IncorrectPasswordView {
        public static let incorrectPasswordView = "sendMoneyViewOtpIncorrectPassword"
    }
    public enum BlockedView {
        public static let blockedView = "sendMoneyViewOtpAccessBlocked"
    }
}

public enum AccessibilitySendMoneyOTP {
    public static let otpTitle = "otp_text_sms"
    public static let otpSubtitle = "otp_text_insertCode"
    public static let otpErrorBottomSheetAccept = "otp_button_accept"
}
