public enum DocumentType: String, Codable {
    case NIF = "N"
    case NIE = "S"
    case CIF = "C"
    case PASAPORTE = "I"
    case USUARIO = "U"
    
    public init?(_ type: String) {
        self.init(rawValue: type)
    }
    
    public var type: String {
        get{
            return String(describing: self)
        }
    }
}
