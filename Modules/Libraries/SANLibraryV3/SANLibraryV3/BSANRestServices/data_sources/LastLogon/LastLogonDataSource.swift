//

import Foundation

public class LastLogonDataSource: LastLogonDataSourceProtocol {
    
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let basePath = "/api/v1"
    private let serviceName = "/bubble/data"
    private let dictionary = [String: String]()
    private let headers = ["X-Santander-Channel" : "RML", "Content-type" : "application/json"]
    
    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getLastLogonDate() throws -> BSANResponse<LastLogonDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        
        let url = source + self.basePath + self.serviceName
        
        return try self.executeRestCall(
            serviceName: self.serviceName,
            serviceUrl: url,
            params: dictionary,
            contentType: ContentType.queryString,
            requestType: .get,
            headers: headers)
        
    }
}
