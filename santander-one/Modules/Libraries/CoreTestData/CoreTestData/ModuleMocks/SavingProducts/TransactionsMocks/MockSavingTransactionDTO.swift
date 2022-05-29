import CoreDomain
import OpenCombine

struct MockSavingTransactionDTO: Codable {
    let accountId: String
    let transactionId: String?
    let transactionReference: String?
    let amountDTO: MockAmountResponseDTO
    let creditDebitIndicator: String
    let status: String
    let transactionMutability: String
    let bookingDateTime: Date
    let valueDateTime: Date?
    let transactionInformation: String?
    let bankTransactionCodeDTO: MockBankSavingTransactionCodeDTO?
    let proprietaryBankTransactionCodeDTO: MockProprietaryBankSavingTransactionCodeDTO?
    let balanceDTO: MockSavingTransactionBalanceDTO?
    let supplementaryDataDTO: MockSavingTransactionSupplementaryDataDTO?
    
    enum CodingKeys: String, CodingKey {
        case accountId = "AccountId"
        case transactionId = "TransactionId"
        case transactionReference = "TransactionReference"
        case amountDTO = "Amount"
        case creditDebitIndicator = "CreditDebitIndicator"
        case status = "Status"
        case transactionMutability = "TransactionMutability"
        case bookingDateTime = "BookingDateTime"
        case valueDateTime = "ValueDateTime"
        case transactionInformation = "TransactionInformation"
        case bankTransactionCodeDTO = "BankTransactionCode"
        case proprietaryBankTransactionCodeDTO = "ProprietaryBankTransactionCode"
        case balanceDTO = "Balance"
        case supplementaryDataDTO = "SupplementaryData"
    }
}

extension MockSavingTransactionDTO: SavingTransactionRepresentable {
    var amount: SavingAmountRepresentable {
        return amountDTO
    }
    
    var bankTransactionCode: BankSavingTransactionCodeRepresentable? {
        return bankTransactionCodeDTO
    }
    
    var proprietaryBankTransactionCode: ProprietaryBankSavingTransactionCodeRepresentable? {
        return proprietaryBankTransactionCodeDTO
    }
    
    var balance: SavingTransactionBalanceRepresentable? {
        return balanceDTO
    }
    
    var supplementaryData: SavingTransactionSupplementaryDataRepresentable? {
        return supplementaryDataDTO
    }
}
