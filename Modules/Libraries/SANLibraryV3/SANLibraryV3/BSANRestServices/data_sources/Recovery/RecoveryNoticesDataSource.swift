final class RecoveryNoticesDataSource: RecoveryNoticesDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let basePath = "/api/v1/recobros/"
    private let serviceName = "avisos"
    private let dictionary = [String: String]()
    private let headers = ["X-Santander-Channel" : "RML", "Content-type" : "application/json"]
    
    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getRecoveryNotices() throws -> BSANResponse<[RecoveryDTO]> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + self.basePath + self.serviceName
        return try self.executeRestCall(serviceName: self.serviceName,
                                        serviceUrl: url,
                                        params: dictionary,
                                        contentType: ContentType.queryString,
                                        requestType: .get,
                                        headers: headers)
    }
}
