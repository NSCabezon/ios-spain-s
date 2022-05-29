protocol GetAviosDetailDataSourceProtocol: RestDataSource {
    func getAviosInfo() throws -> BSANResponse<AviosDetailDTO>
}

public final class GetAviosDetailDataSource: GetAviosDetailDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let path = "/avios/"
    private let serviceName = "detalle"
    private let demoServiceName = "detalleAvios"
    private let headers = ["X-Santander-Channel" : "RML", "Content-type" : "application/json"]
    
    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getAviosInfo() throws -> BSANResponse<AviosDetailDTO> {
        if let aviosDetail = try self.bsanDataProvider.get(\.aviosDetail) {
            return BSANOkResponse(aviosDetail)
        }
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + path + serviceName
        let response: BSANResponse<AviosDetailDTO> = try self.executeRestCall(
            serviceName: demoServiceName,
            serviceUrl: url,
            queryParam: nil,
            body: nil,
            requestType: .get,
            headers: headers
        )
        if let responseData = try response.getResponseData() {
            self.bsanDataProvider.store(aviosDTO: responseData)
        }
        return response
    }
}
