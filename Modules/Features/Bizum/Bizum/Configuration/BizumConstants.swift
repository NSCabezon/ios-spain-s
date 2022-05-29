enum BizumConstants {
    static let isEnableBizumNative = "enableBizumNative"
    static let isEnableSendMoneyBizumNative = "enableSendMoneyBizumNative"
    static let isEnableBizumQrOption = "enableBizumQrOption"
    static let isEnableRequestMoneyBizumNative = "enableRequestMoneyBizumNative"
    static let isCancelSendMoneyForNotClientByBizum = "cancelSendMoneyForNotClientByBizum"
    static let isReturnMoneyReceivedBizumNativeEnabled = "enableReturnMoneyReceivedBizumNative"
    static let isEnableAcceptRequestMoneyBizumNative = "enableAcceptMoneyRequestBizumNative"
    static let isWhatsAppSharingEnabled = "enabledWhatsAppSharingBizum"
    static let isCancelRequestBizumNativeEnabled = "enableCancelRequestBizumNative"
    static let isRejectRequestBizumNativeEnabled = "enableRejectRequestBizumNative"
    static let isSplitCostsBizumNativeEnabled = "enableSplitExpenseBizum"
    static let isEnableBizumDotations = "enableBizumDonations"
    static let isBizumRedsysDocumentIDEnabled = "enableBizumRedsysDocumentID"
    static let isFirstStepEnabled = "enableFirstStepOnBizumSendToFavourite"
    static let maxTotalPages = 20
}

enum BizumHistoricTrack: String {
    case all = "todos"
    case sent = "enviados"
    case received = "recibidos"
    case purchase = "compras"
}

enum BizumDetailTrack: String {
    case sendOrDonation = "C2CPush"
    case request = "C2CPull"
    case purchase = "C2eR"
}

enum BizumSimpleMultipleType: String {
    case simple
    case multiple
}
