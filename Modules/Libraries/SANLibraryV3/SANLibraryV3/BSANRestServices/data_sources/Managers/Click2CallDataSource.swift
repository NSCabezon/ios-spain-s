//

import Foundation

public class Click2CallDataSource: Click2CallDataSourceProtocol {
    
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let serviceName = "generate-dtmf-code"
    
    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getClick2Call(_ reason: String?) throws -> BSANResponse<Click2CallDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.click2CallURL else {
            return BSANErrorResponse(nil)
        }
        let params = Click2CallRequestParams(mainTransferReason: reason)
        return try self.executeRestCall(
            serviceName: self.serviceName,
            serviceUrl: source + self.serviceName,
            params: params,
            contentType: .json,
            requestType: .post)
    }
}

public struct Click2CallRequestParams: Codable {
    let mainTransferReason: String?
    
    enum CodingKeys: String, CodingKey {
        case mainTransferReason = "main_transfer_reason"
    }
}
