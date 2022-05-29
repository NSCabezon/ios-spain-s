import Fuzi
import CoreDomain

public struct ContractDTO: Codable, Hashable, CustomStringConvertible {
    public var bankCode: String?
    public var branchCode: String?
    public var product: String?
    public var contractNumber: String?
    
    public init() {}
    
    public init(bankCode: String?, branchCode: String?, product: String?, contractNumber: String?) {
        self.bankCode = bankCode
        self.branchCode = branchCode
        self.product = product
        self.contractNumber = contractNumber
    }

    public var formattedValue: String {
        if let bankCode = bankCode, let branchCode = branchCode, let contractNumber = contractNumber, let product = product {
            if "0030" == bankCode {
                return bankCode + branchCode + contractNumber + product
            } else {
                return bankCode + branchCode + product + contractNumber
            }
        } else {
            return ""
        }
    }

    public var contratoPK: String? {
        if let bankCode = bankCode, let branchCode = branchCode, let contractNumber = contractNumber, let product = product {
            return "\(bankCode) \(branchCode) \(product) \(contractNumber)"
        } else {
            return ""
        }
    }
    
    public var contratoPKWithNoSpaces: String {
        if let bankCode = bankCode, let branchCode = branchCode, let contractNumber = contractNumber, let product = product {
            return "\(bankCode)\(branchCode)\(product)\(contractNumber)"
        } else {
            return ""
        }
    }

    public var description: String {
        return contratoPK ?? ""
    }

    public static func == (lhs: ContractDTO, rhs: ContractDTO) -> Bool {
        if lhs.bankCode == nil || lhs.branchCode == nil || lhs.product == nil || lhs.contractNumber == nil {
            return false
        }

        return lhs.contratoPK == rhs.contratoPK
    }
    
    public func hash(into hasher: inout Hasher) {
        guard let contractNumber = contractNumber, let hash = Int(contractNumber) else {
            return hasher.combine(0)
        }
        return hasher.combine(hash)
    }
}

extension ContractDTO: ContractRepresentable {}
