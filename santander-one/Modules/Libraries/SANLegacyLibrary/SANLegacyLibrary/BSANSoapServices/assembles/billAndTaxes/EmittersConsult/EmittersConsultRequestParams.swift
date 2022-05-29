//

import Foundation

public struct EmittersConsultRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let bankCode: String
    public let branchCode: String
    public let product: String
    public let contractNumber: String
    public let emitterCode: String
    public let emitterName: String
    public let paginationXML: String
    
    public init(
        token: String,
        userDataDTO: UserDataDTO,
        bankCode: String,
        branchCode: String,
        product: String,
        contractNumber: String,
        emitterCode: String,
        emitterName: String,
        paginationXML: String
    ) {
        self.token = token
        self.userDataDTO = userDataDTO
        self.bankCode = bankCode
        self.branchCode = branchCode
        self.product = product
        self.contractNumber = contractNumber
        self.emitterCode = emitterCode
        self.emitterName = emitterName
        self.paginationXML = paginationXML
    }
}

public struct EmittersConsultParamsDTO {
    public let account: AccountDTO
    public let emitterName: String
    public let emitterCode: String
    public let pagination: EmittersPaginationAdapter
    
    public init(account: AccountDTO, emitterName: String, emitterCode: String, pagination: EmittersPaginationAdapter) {
        self.account = account
        self.emitterName = emitterName
        self.emitterCode = emitterCode
        self.pagination = pagination
    }
}
