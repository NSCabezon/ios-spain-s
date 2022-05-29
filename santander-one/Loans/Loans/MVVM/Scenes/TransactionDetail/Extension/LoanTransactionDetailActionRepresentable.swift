import Foundation

public protocol LoanTransactionDetailActionRepresentable {
    var type: LoanTransactionDetailActionType { get }
    var isDisabled: Bool { get }
    var isUserInteractionEnable: Bool { get }
}

public enum LoanTransactionDetailActionType {
    case partialAmortization
    case changeAccount
    case configureAlerts
    case showDetail
    case pdfExtract(Data?)
    case share
}
