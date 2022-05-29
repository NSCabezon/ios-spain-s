import CoreDomain

public struct AccountDataDTO: Codable, Hashable, CustomStringConvertible {
    public var bankCode: String
    public var branchCode: String
    public var checkDigits: String
    public var accountNumber: String
	
	public init(bankCode: String, branchCode: String, checkDigits: String, accountNumber: String) {
		self.bankCode = bankCode
		self.branchCode = branchCode
		self.checkDigits = checkDigits
		self.accountNumber = accountNumber
	}
	
	public var contract: ContractDTO {
		let empresa = bankCode
		let centro = branchCode
		let producto = accountNumber.substring(0, 3)
		let numeroContrato = accountNumber.substring(3, 10)
		return ContractDTO(bankCode: empresa, branchCode: centro, product: producto, contractNumber: numeroContrato)
	}

	public var description: String {
		return "\(bankCode)\(branchCode)\(checkDigits)\(accountNumber)"
    }

    public static func == (lhs: AccountDataDTO, rhs: AccountDataDTO) -> Bool {
        return lhs.description == rhs.description
    }

    public func hash(into hasher: inout Hasher) {
        if let hash = Int(accountNumber) {
            return hasher.combine(hash)
		}
        return hasher.combine(0)
    }
}

extension AccountDataDTO: AccountDataRepresentable { }
