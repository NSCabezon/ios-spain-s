import Foundation

enum BillAndTaxesStatus: CaseIterable, CustomStringConvertible {
    case all
    case canceled
    case applied
    case returned
    case pendingToApply
    case pendingOfDate
    case pendingToResolve
    
    var description: String {
        switch self {
        case .all:
            return "search_label_all"
        case .canceled:
            return "receiptsAndTaxes_label_statusAnu"
        case .applied:
            return "receiptsAndTaxes_label_statusApl"
        case .returned:
            return "receiptsAndTaxes_label_statusDev"
        case .pendingToApply:
            return "receiptsAndTaxes_label_statusPap"
        case .pendingOfDate:
            return "receiptsAndTaxes_label_statusPtf"
        case .pendingToResolve:
            return "receiptsAndTaxes_label_statusPtr"
        }
    }
}
