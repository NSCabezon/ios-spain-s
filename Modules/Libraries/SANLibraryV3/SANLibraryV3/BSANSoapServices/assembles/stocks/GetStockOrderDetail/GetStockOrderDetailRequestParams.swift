import Foundation

public struct GetStockOrderDetailRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO?
    public var terminalId: String
    public var version: String
    public var language: String
    public var stockContractDTO: ContractDTO?
    public var orderNumber : String
}
