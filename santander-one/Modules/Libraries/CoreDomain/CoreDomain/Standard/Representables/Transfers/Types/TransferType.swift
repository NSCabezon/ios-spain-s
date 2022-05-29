//
//  TransferType.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 28/9/21.
//

public enum TransfersType: String, Codable {
    case NATIONAL_SEPA = "SN"
    case INTERNATIONAL_NO_SEPA = "NS"
    case INTERNATIONAL_SEPA = "SI"
    
    public static func findBy(type: String?) -> TransfersType? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case NATIONAL_SEPA.rawValue.uppercased():
                return NATIONAL_SEPA
            case INTERNATIONAL_NO_SEPA.rawValue.uppercased():
                return INTERNATIONAL_NO_SEPA
            case INTERNATIONAL_SEPA.rawValue.uppercased():
                return INTERNATIONAL_SEPA
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
            return String(describing:self)
        }
    }
}
