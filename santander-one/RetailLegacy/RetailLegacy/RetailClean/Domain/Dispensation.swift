import SANLegacyLibrary
import Foundation

class Dispensation {
    
    private(set) var dto: DispensationDTO
    
    init(dto: DispensationDTO) {
        self.dto = dto
    }
    
    var releaseDate: Date? {
        return dto.descFechaHoraPet
    }
    var expirationDate: Date? {
        return dto.descFechaHoraExp
    }
    var messageNumber: String? {
        return dto.numMensaje
    }
    var pan: String? {
        return dto.descPAN
    }
    var status: DispensationStatus {
        return DispensationStatus.factory(with: dto.numEstado)
    }
    var otpPhone: String? {
        return dto.decryptedData?.telefonoOTP
    }
    
    var amount: Amount {
        return Amount.createFromDTO(dto.impAdisp)
    }
    
    var operationCode: String? {
        return dto.decryptedData?.claveSC
    }
}

enum DispensationStatus: Int {
    case pending = 0
    case exempt
    case partiallyExempt
    case annulled
    case partiallyAnnulled
    case cancelled
    case blocked
    case expired
    case disputed
    case revoked
    case undefined
    
    static func factory(with status: String?) -> DispensationStatus {
        guard let status = status, let numeric = Int(status), let result = DispensationStatus(rawValue: numeric) else {
            return .undefined
        }
        return result
    }
    
    var situationKey: String {
        switch self {
        case .pending:
            return "historyWhitdraw_operationStatus_remaining"
        case .exempt:
            return "historyWhitdraw_operationStatus_exempt"
        case .annulled:
            return "historyWhitdraw_operationStatus_annulled"
        case .partiallyAnnulled:
            return "historyWhitdraw_operationStatus_partiallyAnnulled"
        case .cancelled:
            return "historyWhitdraw_operationStatus_cancel"
        case .blocked:
            return "historyWhitdraw_operationStatus_blocked"
        case .expired:
            return "historyWhitdraw_operationStatus_expired"
        case .disputed:
            return "historyWhitdraw_operationStatus_dispute"
        case .partiallyExempt:
            return "historyWhitdraw_operationStatus_partiallyDispute"
        case .revoked:
            return "historyWhitdraw_operationStatus_turnDown"
        case .undefined:
            return ""
        }
    }
}

extension Dispensation: Equatable {
    static func == (lhs: Dispensation, rhs: Dispensation) -> Bool {
        return lhs.pan == rhs.pan && lhs.releaseDate == rhs.releaseDate
    }
}

extension Dispensation: GenericProductProtocol {}
