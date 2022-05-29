public enum OwnershipTypeDesc: String, Codable, CustomStringConvertible {
    
    case attorney = "APODERADO"
    case authorized = "AUTORIZADO"
    case holder = "TITULAR"
    case representative = "REPRESENTANTE LEGAL"
    case owner = "PROPIETARIO"
    case other = "OTRO"
    
    public static func findBy(type: String?) -> OwnershipTypeDesc? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case attorney.rawValue.uppercased():
                return attorney
            case authorized.rawValue.uppercased():
                return authorized
            case holder.rawValue.uppercased():
                return holder
            case representative.rawValue.uppercased():
                return representative
            case owner.rawValue.uppercased():
                return owner
            default:
                return other
            }
        }
        return nil
    }

    public init?(_ type: String) {
        self.init(rawValue: type)
    }

    public var type: String {
        get {
            return self.rawValue
        }
    }
    
    public var description: String {
        return type
    }
}
