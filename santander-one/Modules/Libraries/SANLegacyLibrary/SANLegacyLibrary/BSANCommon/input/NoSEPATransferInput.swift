import CoreDomain
import Foundation

public struct NoSEPATransferInput: Codable {
    public let originAccountDTO: AccountDTO
    public let beneficiary: String
    public let beneficiaryAccount: InternationalAccountDTO
    public let beneficiaryAddress: AddressDTO?
    public let indicatorResidence: Bool
    public let dateOperation: DateModel?
    public let transferAmount: AmountDTO
    public let expensiveIndicator: ExpensesType
    public let type: TransferTypeDTO?
    public let countryCode: String
    public let concept: String?
    public let beneficiaryEmail: String?
    
    public var accountType: String {
        return beneficiaryAccount.swift != nil ? "C" : "D"
    }
    
    public init(originAccountDTO: AccountDTO, beneficiary: String, beneficiaryAccount: InternationalAccountDTO, beneficiaryAddress: AddressDTO?, indicatorResidence: Bool, dateOperation: DateModel?, transferAmount: AmountDTO, expensiveIndicator: ExpensesType, type: TransferTypeDTO, countryCode: String, concept: String, beneficiaryEmail: String?) {
        self.originAccountDTO = originAccountDTO
        self.beneficiary = beneficiary
        self.beneficiaryAccount = beneficiaryAccount
        self.beneficiaryAddress = beneficiaryAddress
        self.indicatorResidence = indicatorResidence
        self.dateOperation = dateOperation
        self.transferAmount = transferAmount
        self.expensiveIndicator = expensiveIndicator
        self.type = type
        self.countryCode = countryCode
        self.concept = concept
        self.beneficiaryEmail = beneficiaryEmail
    }
}
