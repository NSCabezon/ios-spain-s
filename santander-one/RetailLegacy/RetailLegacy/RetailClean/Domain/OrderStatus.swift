import Foundation

enum OrderStatus: String {
    case pending = "PENDIENTE"
    case executed = "EJECUTADA"
    case cancelled = "ANULADA"
    case negotiated = "NEGOCIADA"
    case rejected = "RECHAZADA"
    case undefined = ""
    
    static func factory(with status: String?) -> OrderStatus {
        guard let status = status, let result = OrderStatus(rawValue: status.uppercased()) else {
            return .undefined
        }
        return result
    }
    
    var situationKey: String {
        switch self {
        case .pending:
            return "orderStatus_label_pending"
        case .executed:
            return "orderStatus_label_executed"
        case .cancelled:
            return "orderStatus_label_cancel"
        case .negotiated:
            return "orderStatus_label_negotiated"
        case .rejected:
            return "orderStatus_label_rejected"
        case .undefined:
            return ""
        }
    }
}
