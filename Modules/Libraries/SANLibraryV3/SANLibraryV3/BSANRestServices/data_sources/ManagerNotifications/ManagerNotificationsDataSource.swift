public final class ManagerNotificationsDataSource: ManagerNotificationsDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let basePath = "/api/v1/mensajes-gestor/"
    private let serviceName = "getMessages"
    private let headers = ["X-Santander-Channel": "RML", "Content-type": "application/json"]
    private let dictionary = [String: String]()
    
    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getManagerNotifications() throws -> BSANResponse<ManagerNotificationsDTO> {
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
