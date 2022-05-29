//

import Foundation

class AccountFutureBillListDataSource: AccountFutureBillListDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let serviceName = "recibos"
    private let basePath = "/"
    private let bsanDataProvider: BSANDataProvider

    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func loadAccountFutureBillList(params: AccountFutureBillParams) throws -> BSANResponse<AccountFutureBillListDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.serviceName
        return try self.executeRestCall(
            serviceName: serviceName,
            serviceUrl: url,
            params: params,
            contentType: .queryString,
            requestType: .get,
            headers: ["X-Santander-Channel" : "RML"])
    }
}
