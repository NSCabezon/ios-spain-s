
import CoreDomain

public struct IBANDTO: Codable, Hashable, CustomStringConvertible {
    public var countryCode: String
    public var checkDigits: String
    public var codBban: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(ibanString: string)
    }
    
    public init(){
        self.countryCode = ""
        self.checkDigits = ""
        self.codBban = ""
    }
    
    public init(ibanString: String) {
        let ibantrim = ibanString.replace(" ", "")
        if ibantrim.count > 4 {
            self.countryCode = ibantrim.substring(0, 2) ?? ""
            self.checkDigits = ibantrim.substring(2, 4) ?? ""
            self.codBban = ibantrim.substring(4) ?? ""
        } else {
            self.countryCode = ""
            self.checkDigits = ""
            self.codBban = ""
        }
    }
    
    public init(countryCode: String, checkDigits: String, codBban: String) {
        self.countryCode = countryCode
        self.checkDigits = checkDigits
        self.codBban = codBban
    }
    
    public var codBban30: String {
        return IBANDTO.completeRightCharacter(str: codBban, size: 30, char: " ")
    }
        
    public static func completeRightCharacter(str: String, size: Int, char: String) -> String {
        var temp = ""
        for _ in (0..<size - str.count) {
            temp = temp + char
        }
        return str + temp
    }
    
    public func hash(into hasher: inout Hasher) {
        guard codBban.count >= 7, let substring = codBban.substring(codBban.count - 7) else {
            return hasher.combine(0)
        }
        return hasher.combine(substring.hashValue)
    }
    
    public var description: String {
        return countryCode + checkDigits + codBban
    }
    
    public var iban: String {
        return countryCode + codBban.replacingOccurrences(of: " ", with: "")
    }
    
    public static func == (lhs: IBANDTO, rhs: IBANDTO) -> Bool {
        return lhs.description == rhs.description
        
    }
}

extension IBANDTO: IBANRepresentable {}
