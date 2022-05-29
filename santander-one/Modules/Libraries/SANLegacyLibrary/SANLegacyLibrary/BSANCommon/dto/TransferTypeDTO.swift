public enum TransferTypeDTO: String, Codable {
    case INTERNATIONAL_SEPA_TRANSFER
    case INTERNATIONAL_NO_SEPA_TRANSFER
    case NATIONAL_INSTANT_TRANSFER
    case NATIONAL_URGENT_TRANSFER
    case NATIONAL_TRANSFER
    case USUAL_TRANSFER
    
    public func getType() -> String {
        switch self {
        case .NATIONAL_URGENT_TRANSFER:
            return "S"
        case .NATIONAL_INSTANT_TRANSFER:
            return "I"
        default:
            return "N"
        }
    }
    
    public func getPTType() -> String {
        switch self {
        case .NATIONAL_URGENT_TRANSFER:
            return "URGENT"
        case .NATIONAL_INSTANT_TRANSFER:
            return "IMMEDIATE"
        default:
            return "STANDARD"
        }
    }
}
