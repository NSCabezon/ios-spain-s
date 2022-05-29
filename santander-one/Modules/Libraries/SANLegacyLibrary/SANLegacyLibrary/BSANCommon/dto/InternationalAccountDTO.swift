import CoreDomain

public struct InternationalAccountDTO: Codable, Hashable, CustomStringConvertible {
    public var swift: String?
    public var account: String
    public var bankData: BankDataDTO?
    
    public init(account: String) {
        self.account = account
    }
    
    public init(swift: String, account: String) {
        self.swift = swift
        self.account = account
    }
    
    public init(bankData: BankDataDTO, account: String) {
        self.account = account
        self.bankData = bankData
    }
    
    public var account34: String {
        return IBANDTO.completeRightCharacter(str: account, size: 34, char: " ")
    }
    
    public func hash(into hasher: inout Hasher) {
        guard let swift = self.swift,
              swift.count >= 7,
              let substring = swift.substring(swift.count - 7),
              let hash = Int(substring)
        else { return hasher.combine(0) }
        return hasher.combine(hash)
    }
    
    public var description: String {
        return account
    }
    
    public static func == (lhs: InternationalAccountDTO, rhs: InternationalAccountDTO) -> Bool {
        if lhs.swift == nil || lhs.bankData == nil {
            return false
        }
        return lhs.description == rhs.description
    }
}
