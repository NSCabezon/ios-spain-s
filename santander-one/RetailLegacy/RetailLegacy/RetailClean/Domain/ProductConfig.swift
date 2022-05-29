import Foundation
import CoreFoundationLib

struct ProductConfig {
    var isPB: Bool?
    var isDemo: Bool?
    var isOTPExcepted: Bool?
    var hasTranferFunds: Bool?
    var enableMoneyPlanPromotion: Bool?
    var moneyPlanNativeMode: Bool?
    var isSavingInsuranceBalanceEnabled: Bool?
    var enabledLoanOperations: Bool?
    var enabledPensionOperations: Bool?
    var enablePayLater: Bool?
    var enableDirectMoney: Bool?
    var isEnabledCardLimitManagement: Bool?
    var enableAccountTransactionsPdf: Bool?
    var fundOperationsSubcriptionNativeMode: Bool?
    var fundOperationsTransferNativeMode: Bool?
    var enableBroker: Bool?
    var stocksNativeMode: Bool?
    var allianzProducts: [ProductAllianz]
}
