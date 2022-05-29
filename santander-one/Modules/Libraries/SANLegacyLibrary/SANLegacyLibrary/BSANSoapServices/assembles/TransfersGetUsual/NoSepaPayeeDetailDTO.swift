import CoreDomain
import Foundation

public enum NoSepaAccountType: String, Codable {
    case A
    case C
    case D
    
    public static func findBy(type: String?) -> NoSepaAccountType? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case A.rawValue.uppercased():
                return A
            case C.rawValue.uppercased():
                return C
            case D.rawValue.uppercased():
                return D
            default:
                return nil
            }
        }
        return nil
    }
    
    public init?(_ type: String) {
        self.init(rawValue: type)
    }
}

public struct NoSepaPayeeDetailDTO: Codable {
    public var payee: NoSepaPayeeDTO?
    public var amount: AmountDTO?
    public var alias: String?
    public var codPayee: String?
    public var accountType: NoSepaAccountType?
    public var concept: String?
    public var benefActing: IdActuantePayeeDTO?
    public var bankActing: IdActuantePayeeDTO?

    public init() {}
}

extension NoSepaPayeeDetailDTO: NoSepaPayeeDetailRepresentable {
    public var payeeRepresentable: NoSepaPayeeRepresentable? {
        return payee
    }
}
