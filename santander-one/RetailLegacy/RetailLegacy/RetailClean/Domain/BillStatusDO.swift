import SANLegacyLibrary
import Foundation

public enum BillStatusDO {
    
    case unknown
    case canceled
    case applied
    case returned
    case pendingToApply
    case pendingOfDate
    case pendingToResolve
    
    init(from status: BillStatus) {
        switch status {
        case .unknown:
            self = .unknown
        case .canceled:
            self = .canceled
        case .applied:
            self = .applied
        case .returned:
            self = .returned
        case .pendingToApply:
            self = .pendingToApply
        case .pendingOfDate:
            self = .pendingOfDate
        case .pendingToResolve:
            self = .pendingToResolve
        }
    }
    
    var key: String? {
        //TODO: Añadir valores de POEditor cuando esten
        switch self {
        case .unknown:
            return nil
        case .canceled:
            return "Cancelado"
        case .applied:
            return "Aplicado"
        case .returned:
            return "Devuelto"
        case .pendingToApply:
            return "Pendiente"
        case .pendingOfDate:
            return "Pendiente"
        case .pendingToResolve:
            return "Pendiente"
        }
    }
}
