//

import Foundation
import SwiftyJSON

public class LastMovementsTimeLineDataSourceImpl: LastMovementsTimeLineDataSourceProtocol {

    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let timeLineServiceName = "timeline"
    private let basePath = "/api/v1/lisboa/envioPagos/"
    private let headers = ["X-Santander-Channel" : "RML"]

    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    
    func loadMovements(_ parameters: TimeLineMovementsParameters) throws -> BSANResponse<TimeLineResponseDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.timeLineServiceName
        do {
            return try self.executeRestCall(serviceName: timeLineServiceName,
                                                        serviceUrl: url,
                                                        params: parameters,
                                                        contentType: .queryString,
                                                        requestType: .get,
                                                        headers: headers)
        } catch {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
    }
    
}
