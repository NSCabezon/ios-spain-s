import Foundation

struct AccountTransactionListPdfHeaderInfo {
    let holder: String
    let iban: String
    let undrawnBalance: Amount
    let fromDate: Date?
    let toDate: Date?
}
