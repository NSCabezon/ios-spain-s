import Foundation

public struct ValidateFundTransferRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var destinationBankCode: String
    public var destinationBranchCode: String
    public var destinationProduct: String
    public var destinationContractNumber: String
    public var originBankCode: String
    public var originBranchCode: String
    public var originProduct: String
    public var originContractNumber: String
    public var originCompany: String
    public var originProductType: String
    public var originProductSubType: String
    public var language: String
    public var dialect: String
    public var operationsType: FundOperationsType
    public var fundTransferType: FundTransferType
    public var amountForWS: String
    public var currency: String
    public var sharesNumber: String
    public var originAmountValueWS: String
    public var originAmountCurrency: String
}
