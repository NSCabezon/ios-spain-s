//

import Foundation

class AccountMovementListDataSource: AccountMovementListDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let serviceName = "accountMovements"
    private let bsanDataProvider: BSANDataProvider

    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func loadAccountMovementsList(params: AccountMovementListParams, account: String) throws -> BSANResponse<AccountMovementListDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + "/api/v1/accounts/" + "\(account)" + "/movements"
        return try self.executeRestCall(
            serviceName: serviceName,
            serviceUrl: url,
            params: params,
            contentType: .queryString,
            requestType: .get,
            headers: ["X-Santander-Channel" : "RML"],
            responseEncoding: .utf8
        )
    }
    
    @available(*, deprecated, message: "Use loadAccountMovementsList(params: AccountMovementListParams, account: String) instead")
    func loadAccountMovementsList(params: AccountMovementListParams) throws -> BSANResponse<AccountMovementListDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + "/api/v1/accounts/" + "\(params.accountNumber)" + "/movements"
        return try self.executeRestCall(
            serviceName: serviceName,
            serviceUrl: url,
            params: params,
            contentType: .queryString,
            requestType: .get,
            headers: ["X-Santander-Channel" : "RML"])
    }
}
