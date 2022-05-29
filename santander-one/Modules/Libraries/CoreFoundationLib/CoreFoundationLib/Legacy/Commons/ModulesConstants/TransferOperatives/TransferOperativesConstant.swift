//
//  TransferOperativesConstant.swift
//  TransferOperatives
//
//  Created by David Gálvez Alonso on 24/08/2021.
//

public struct TransferOperativesConstant {
    public static let appConfigUrgentNationalTransfersEnable5304 = "urgentNationalTransfersEnable5304"
    
    struct NationalTransferSummary {
        static let page = "transferencias_envio_nacional_resumen"
        
        enum Action: String {
            case easyPay = "easy_pay"
            case easyPayError = "easy_pay_error"
            case helpToImprove = "ayudanos_a_mejorar"
            case share = "compartir"
        }
    }
    
    public struct SendMoneyTrackerConstants {
        public enum SignaturePages {
            public static let domestic: String = "/send_money/transfer/signature"
            public static let sepa: String = "/send_money/transfer/int/sepa/signature"
            public static let noSepa: String = "/send_money/transfer/int/nosepa/signature"
        }
        public enum OTPPages {
            public static let domestic: String = "/send_money/transfer/otp_signature"
            public static let sepa: String = "/send_money/transfer/int/sepa/otp_signature"
            public static let noSepa: String = "/send_money/transfer/int/nosepa/otp_signature"
        }
        public static let parameterKey = "transfer_country"
        public static let valueSepa = "SEPA"
        public static let valueNoSepa = "NO SEPA"
    }
}

public struct InternalTransferAccountSelectorPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/send_money/switch/origin_account"
    
    public enum Action: String {
        case viewHiddenAccounts = "view_hidden_accounts"
    }
    public init() {}
}

public struct InternalTransferDestinationAccountSelectorPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/send_money/switch/recipient"

    public enum Action: String {
        case changeAccount = "change_account"
    }
    public init() {}
}

public struct InternalTransferAccountAmountPage: PageTrackable {
    public let page = "/send_money/switch/amount_date"
    public init() {}
}

public struct InternalTransferConfirmPage: PageWithActionTrackable {
    public let page = "/send_money/switch/confirm"
    public init() {}
}

public struct InternalTransferThankYouPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/send_money/switch/thank_you"

    public enum Action: String {
        case downladPDF = "file_download"
        case shareImage = "share"
        case seeSummary = "see_summary"
    }

    public init() {}
}
