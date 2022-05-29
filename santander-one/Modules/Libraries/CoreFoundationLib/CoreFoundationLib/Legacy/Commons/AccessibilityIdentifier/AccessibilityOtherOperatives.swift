//
//  AccessibilityOtherOperatives.swift
//  Commons
//
//  Created by Laura González on 05/03/2020.
//

import Foundation

public enum AccessibilityOtherOperatives: String {
    // Common
    case btnDetail
    case btnOne
    
    // Confirmation labels
    case lblConfirmationTotalAmount = "confirmation_label_totalOperation"
    case lblConfirmationAmount = "confirmation_label_totalAmount"
    case lblConfirmationOrigin = "confirmation_text_origin"
    case lblConfirmationSendType = "confirmation_label_sendType"
    case lblConfirmationShippingDate = "confirmation_item_shippingDate"
    case lblConfirmationDestination = "confirmation_label_destination"
    
    // Summary labels
    case lblSummaryAmount = "summary_item_amount"
    case lblSummaryOrigin = "summary_label_origin"
    case lblSummarySendType = "summary_item_sendType"
    case lblSummaryDestination = "summary_label_destination"
    case lblSummaryComment = "summary_item_commentary"
    case lblSummaryDate = "summary_item_shippingDate"
    
    // Account operatives
    case btnSendMoney
    case btnTransfer
    case btnSendToFavourite
    case btnDonation
    case btnOnePayFx
    case btnPayReceipt
    case btnPayTax
    case btnChangeDomicileReceipt
    case btnCancelReceipt
    case btnRequestForeignCurrency
    case btnContractAccount
    case btnChangeAliasAccount
    case btnalertConfigAccount
    case btnRequestCertificate
    case btnTransferContract
    case btnCancelBill
    case btnReceipts
    case btnReturnReceipt
    case btnAccount
    case btnCertificateOfOwnership
    
    // PT
    case btnDiaryFinancial
    case btnStatementAccount
    case btnMobileRechargeAccount
    
    // Card operatives
    case btnCardOff
    case btnCardOn
    case btnDirectMoney
    case btnChangeWayToPay
    case btnDelayPay
    case btnCardEntry
    case btnPin
    case btnCvv
    case btnCodeMoney
    case btnAddApplePay
    case btnBlockCard
    case btnMobileRecharge
    case btnicnMoreHighElectronic
    case btnPdf
    case btnModifyLimits
    case btnSolidary
    case btnContractCard
    case btnalertConfigCard
    case btnChangeAliasCard
    case btnDuplicate
    case btnSucription
    case btnFinancing
    case subscriptions = "pgBtnM4m"
    
    // Values operatives
    case btnBuyValues
    case btncheckOrders
    
    // Loans operatives
    case btnAmortizationPartial
    case bntnChangeAccount
    case btnalertConfigLoan
    case btnChangeAliasLoan
    
    // Pension plan operatives
    case btnExtraAportationPensionPlan
    case btnPeriodicAportation
    case btnSmartShare
    case btnChangeAliasPensionPlan
    
    // Funds operatives
    case btnSuscription
    case btnTransferFounds
    
    // Insurance operatives
    case btnExtraAportationInsurance
    case btnChangeAportation
    case btnActiveAportation
    
    // Protection operatives
    case btnManagePolicy
    
    // Signature
    case txtSignature
    case imgSignature = "Rectangle"
    case lblSignatureTitle = "signing_text_provisionalKey"
    case btnSignature = "signing_button_sign"
    case btnSignatureLabel = "signing_button_sign_label"
    case lblSignatureDescription = "signing_text_insertNumbers"
    case btnSignatureRemember = "signing_text_remember"
    case btnSignatureRememberLabel = "signing_text_remember_label"
}
