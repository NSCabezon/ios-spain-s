import Foundation

public struct ConfirmFundTransferRequestParams {
    public var token: String
    public var tokenPasos: String
    public var personType: String
    public var personCode: String
    public var destinationFundCode: String
    public var destinationFundName: String
    public var valueDate: Date?
    public var transferTypeByManagingCompany: String
    public var quantityToSplit: String
    public var originIsinCode: String
    public var originManagingCompanyCIF: String
    public var partialTransferQuantity: String
    public var counter: String
    public var transferShares: String
    public var debitSharesBalance: String
    public var currencyWorkaround: String
    public var signatureDTO: SignatureDTO
    public var userDataDTO: UserDataDTO
    public var destinationBankCode: String
    public var destinationBranchCode: String
    public var destinationProduct: String
    public var destinationContractNumber: String
    public var originBankCode: String
    public var originBranchCode: String
    public var originProduct: String
    public var originContractNumber: String
    public var language: String
    public var dialect: String
    public var operationsType: FundOperationsType
    public var fundTransferType: FundTransferType
    public var amountForWS: String
    public var sharesNumber: String
    public var availableAmountValueWS: String
    public var availableAmountCurrency: String
}
