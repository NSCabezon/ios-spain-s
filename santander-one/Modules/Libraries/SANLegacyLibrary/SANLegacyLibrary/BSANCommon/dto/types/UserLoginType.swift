public enum UserLoginType: String , Codable {
    case N = "NIF"
    case C = "NIE"
    case S = "CIF"
    case I = "Pasaporte"
    case U = "Usuario"

    public static func findBy(type: String?) -> UserLoginType? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case N.rawValue.uppercased():
                return N
            case C.rawValue.uppercased():
                return C
            case S.rawValue.uppercased():
                return S
            case I.rawValue.uppercased():
                return I
            case U.rawValue.uppercased():
                return U
            default:
                return nil
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

    public var name: String {
        get {
            return String(describing: self)
        }
    }
}


