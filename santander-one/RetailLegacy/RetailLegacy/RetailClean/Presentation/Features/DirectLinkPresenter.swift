import CoreFoundationLib

enum DirectLinkTypeItem: String, CaseIterable {
    case internalTransfer
    case transfer
    case marketplace
    case cvvQuery
    case activateCard
    case ecash
    case directMoney
    case easyPay
    case cardPdfExtract
    case cesSignUp
    case payLater
    case billsAndTaxesPay
    case nationalTransfer
    case withdrawMoneyWithCode
    case extraordinaryContribution
    case fundSuscription
    case pinQuery
    case personalArea
    case tips
    case changePayMethod
    case myManager
}

extension DirectLinkTypeItem {
    
    var trackerId: String {
        return associatedDeepLink.trackerId ?? ""
    }
    
    var descriptionKey: String {
        switch self {
        case .internalTransfer:
            return "frequentOperative_button_transfer"
        case .transfer:
            return "frequentOperative_button_sendFavorite"
        case .pinQuery:
            return "frequentOperative_button_pin"
        case .cvvQuery:
            return "frequentOperative_label_cvv"
        case .activateCard:
            return "frequentOperative_label_activate"
        case .ecash:
            return "frequentOperative_label_chargeDischarge"
        case .directMoney:
            return "frequentOperative_label_directMoney"
        case .easyPay:
            return "frequentOperative_label_postponeBuy"
        case .cardPdfExtract:
            return "frequentOperative_label_pdfExtractSee"
        case .cesSignUp:
            return "frequentOperative_label_ces"
        case .payLater:
            return "frequentOperative_label_postponeReceipt"
        case .billsAndTaxesPay:
            return "frequentOperative_label_billTax"
        case .nationalTransfer:
            return "frequentOperative_label_sendMoney"
        case .withdrawMoneyWithCode:
            return "frequentOperative_label_codeWithdraw"
        case .extraordinaryContribution:
            return "frequentOperative_label_extraContribution"
        case .fundSuscription:
            return "frequentOperative_label_foundSubscription"
        case .marketplace:
            return "frequentOperative_label_marketplace"
        case .personalArea:
            return "frequentOperative_label_personalArea"
        case .tips:
            return "frequentOperative_label_tips"
        case .changePayMethod:
            return "frequentOperative_label_changeWayToPay"
        case .myManager:
            return "frequentOperative_label_myManage"
        }
    }
    
    var iconKey: String {
        switch self {
        case .internalTransfer:
            return "icnTransferAccountPg"
        case .transfer:
            return "icnTransfersPg"
        case .pinQuery:
            return "icnPinPg"
        case .cvvQuery:
            return "icnCvv"
        case .activateCard:
            return "icnActiveCardRed"
        case .ecash:
            return "icnEcash"
        case .directMoney:
            return "icnDirectMoney"
        case .easyPay:
            return "icnEasyPay"
        case .cardPdfExtract:
            return "icnPdf"
        case .cesSignUp:
            return "icnSiginCes"
        case .payLater:
            return "icnPayLater"
        case .billsAndTaxesPay:
            return "icnReceiptsAndTributesMenu"
        case .nationalTransfer:
            return "icnTransfersMenu"
        case .withdrawMoneyWithCode:
            return "icnGetMoneyCode"
        case .extraordinaryContribution:
            return "icnExtraInput"
        case .fundSuscription:
            return "icnSuscription"
        case .marketplace:
            return "icnOffers"
        case .personalArea:
            return "icnSettings"
        case .tips:
            return "icnTipsMenu"
        case .changePayMethod:
            return "icnChangePay"
        case .myManager:
            return "icnManagerMenu"
        }
    }
}

struct DirectLinkItem {
    let image: String
    let tag: Int
    let title: LocalizedStylableText
}

extension DirectLinkItem: DirectLinkItemProtocol {}

private extension DirectLinkTypeItem {
    
    var associatedDeepLink: DeepLink {
        switch self {
        case .internalTransfer:
            return .internalTransfer
        case .transfer:
            return .transfer
        case .pinQuery:
            return .pinQuery
        case .cvvQuery:
            return .cvvQuery
        case .activateCard:
            return .activateCard
        case .ecash:
            return .ecash
        case .directMoney:
            return .directMoney
        case .easyPay:
            return .easyPay
        case .cardPdfExtract:
            return .cardPdfExtract
        case .cesSignUp:
            return .cesSignUp
        case .payLater:
            return .payLater
        case .billsAndTaxesPay:
            return .billsAndTaxesPay
        case .nationalTransfer:
            return .nationalTransfer
        case .withdrawMoneyWithCode:
            return .withdrawMoneyWithCode
        case .extraordinaryContribution:
            return .extraordinaryContribution
        case .fundSuscription:
            return .fundSuscription
        case .marketplace:
            return .marketplace
        case .personalArea:
            return .personalArea
        case .tips:
            return .analysisArea
        case .changePayMethod:
            return .changeCardPayMethod
        case .myManager:
            return .myManager
        }
    }
}
